-- Software Doctors platform schema
-- Transcribed from Platform Architecture — Data Models (Week 30, 25–27 July 2025)
--
-- Decisions on open items from the notes:
-- 1. USER.fullname + last_name → profiles.first_name + profiles.last_name
-- 2. LAPTOP_FOR_RENT pricing → weekly_rate (XAF), from the "5K/Week" note
-- 3. LAPTOP_FOR_SALE duplicate storage → storage (capacity) + storage_type (HDD/SSD/NVMe)
-- 4. created_at / updated_at on every table
-- 5. condition (new / used) on both laptop listing tables
-- 6. shipping → shipping_available + shipping_cost
-- 7. Optional shop_id on both laptop listing tables
--
-- Auth: passwords live in auth.users only. public.profiles references auth.users(id).

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type public.user_role as enum ('client', 'repairer', 'admin', 'super-admin');
create type public.kyc_status as enum ('pending', 'approved', 'rejected');
create type public.repair_status as enum ('open', 'assigned', 'in_progress', 'completed', 'cancelled');
create type public.call_status as enum ('initiated', 'accepted', 'completed', 'cancelled');
create type public.rental_status as enum ('pending', 'active', 'completed', 'cancelled');
create type public.purchase_status as enum ('pending', 'paid', 'completed', 'cancelled');
create type public.payment_method as enum ('OM', 'MoMo', 'cash');
create type public.laptop_condition as enum ('new', 'used');
create type public.storage_drive_type as enum ('HDD', 'SSD', 'NVMe');

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- USER → public.profiles (hub table)
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  first_name text,
  last_name text,
  email text unique,
  phone_number text,
  avatar_url text,
  address text,
  role public.user_role not null default 'client',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_phone_number_unique unique (phone_number)
);

comment on table public.profiles is 'Platform user. Password is stored in auth.users, not here.';
comment on column public.profiles.first_name is 'Notes listed this as fullname; treated as first name because last_name is separate.';

create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role in ('admin'::public.user_role, 'super-admin'::public.user_role)
  );
$$;

create or replace function public.current_user_role()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role
  from public.profiles
  where id = auth.uid();
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, first_name, last_name, phone_number, role)
  values (
    new.id,
    new.email,
    nullif(trim(coalesce(new.raw_user_meta_data->>'first_name', '')), ''),
    nullif(trim(coalesce(new.raw_user_meta_data->>'last_name', '')), ''),
    coalesce(
      nullif(trim(coalesce(new.raw_user_meta_data->>'phone_number', '')), ''),
      new.phone
    ),
    'client'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.handle_user_email_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email is distinct from old.email then
    update public.profiles
    set email = new.email
    where id = new.id;
  end if;
  return new;
end;
$$;

create trigger on_auth_user_email_changed
after update of email on auth.users
for each row execute function public.handle_user_email_change();

create or replace function public.prevent_privilege_escalation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' and new.role is distinct from old.role and not public.is_staff() then
    raise exception 'Only admins can change roles';
  end if;
  return new;
end;
$$;

create trigger profiles_prevent_privilege_escalation
before update on public.profiles
for each row execute function public.prevent_privilege_escalation();

-- ---------------------------------------------------------------------------
-- KYC
-- ---------------------------------------------------------------------------

create table public.kyc (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  front_id_image text,
  back_id_image text,
  front_facing_image text,
  status public.kyc_status not null default 'pending',
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on column public.kyc.front_facing_image is 'Selfie / front-facing identity photo.';

create trigger kyc_set_updated_at
before update on public.kyc
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- REPAIR
-- ---------------------------------------------------------------------------

create table public.repairs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  image_one text,
  image_two text,
  video_url text,
  voice_url text,
  description text,
  city text,
  quarter text,
  country text,
  status public.repair_status not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on column public.repairs.video_url is 'Intended as a ~30 second clip; enforced in the client.';
comment on column public.repairs.description is 'Notes field named text.';

create index repairs_user_id_idx on public.repairs (user_id);
create index repairs_status_idx on public.repairs (status);

create trigger repairs_set_updated_at
before update on public.repairs
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- REPAIRER_CALLS
-- ---------------------------------------------------------------------------

create table public.repairer_calls (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  repairer_id uuid not null references public.profiles (id) on delete cascade,
  repair_id uuid references public.repairs (id) on delete set null,
  status public.call_status not null default 'initiated',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint repairer_calls_distinct_users check (user_id <> repairer_id)
);

comment on column public.repairer_calls.user_id is 'The client.';
comment on column public.repairer_calls.repairer_id is 'The repairer.';

create index repairer_calls_user_id_idx on public.repairer_calls (user_id);
create index repairer_calls_repairer_id_idx on public.repairer_calls (repairer_id);
create index repairer_calls_repair_id_idx on public.repairer_calls (repair_id);

create trigger repairer_calls_set_updated_at
before update on public.repairer_calls
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- SHOP
-- ---------------------------------------------------------------------------

create table public.shops (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  avatar_url text,
  logo_url text,
  physical_address text,
  longitude double precision,
  latitude double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index shops_user_id_idx on public.shops (user_id);

create trigger shops_set_updated_at
before update on public.shops
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- LAPTOP_FOR_RENT
-- ---------------------------------------------------------------------------

create table public.laptops_for_rent (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  shop_id uuid references public.shops (id) on delete set null,
  image_one text,
  image_two text,
  image_three text,
  image_four text,
  location text,
  ram text,
  storage text,
  storage_type public.storage_drive_type,
  model text,
  operating_system text,
  keyboard_type text,
  processor text,
  brand text,
  weekly_rate numeric(12, 2) not null default 5000,
  currency text not null default 'XAF',
  condition public.laptop_condition not null default 'used',
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint laptops_for_rent_weekly_rate_positive check (weekly_rate >= 0)
);

comment on column public.laptops_for_rent.brand is 'Notes field named mark (brand / make).';
comment on column public.laptops_for_rent.weekly_rate is 'From the 5K/Week pricing note.';

create index laptops_for_rent_user_id_idx on public.laptops_for_rent (user_id);
create index laptops_for_rent_shop_id_idx on public.laptops_for_rent (shop_id);
create index laptops_for_rent_available_idx on public.laptops_for_rent (is_available);

create trigger laptops_for_rent_set_updated_at
before update on public.laptops_for_rent
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- USER_RENTED_LAPTOP
-- ---------------------------------------------------------------------------

create table public.user_rented_laptops (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  rented_laptop_id uuid not null references public.laptops_for_rent (id) on delete restrict,
  duration integer not null,
  front_id text,
  back_id text,
  face_id_1 text,
  face_id_2 text,
  status public.rental_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_rented_laptops_duration_positive check (duration > 0)
);

comment on column public.user_rented_laptops.duration is 'Rental length in weeks.';

create index user_rented_laptops_user_id_idx on public.user_rented_laptops (user_id);
create index user_rented_laptops_laptop_id_idx on public.user_rented_laptops (rented_laptop_id);

create trigger user_rented_laptops_set_updated_at
before update on public.user_rented_laptops
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- LAPTOP_FOR_SALE
-- ---------------------------------------------------------------------------

create table public.laptops_for_sale (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  shop_id uuid references public.shops (id) on delete set null,
  price numeric(12, 2) not null,
  lowest_amount numeric(12, 2),
  currency text not null default 'XAF',
  negotiable boolean not null default false,
  town text,
  quarter text,
  model_3d_url text,
  ram text,
  storage text,
  storage_type public.storage_drive_type,
  model text,
  operating_system text,
  processor text,
  brand text,
  shipping_available boolean not null default false,
  shipping_cost numeric(12, 2),
  condition public.laptop_condition not null default 'used',
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint laptops_for_sale_price_positive check (price >= 0),
  constraint laptops_for_sale_lowest_amount_positive check (lowest_amount is null or lowest_amount >= 0),
  constraint laptops_for_sale_shipping_cost_positive check (shipping_cost is null or shipping_cost >= 0)
);

comment on column public.laptops_for_sale.price is 'Notes grouped this under amount.';
comment on column public.laptops_for_sale.lowest_amount is 'Negotiation floor; notes grouped this under amount.';
comment on column public.laptops_for_sale.storage is 'Capacity (e.g. 512GB).';
comment on column public.laptops_for_sale.storage_type is 'Drive type; notes listed this as hard_drive_type.';
comment on column public.laptops_for_sale.brand is 'Notes field named mark (brand / make).';
comment on column public.laptops_for_sale.model_3d_url is 'Notes field named 3d_model.';

create index laptops_for_sale_user_id_idx on public.laptops_for_sale (user_id);
create index laptops_for_sale_shop_id_idx on public.laptops_for_sale (shop_id);
create index laptops_for_sale_available_idx on public.laptops_for_sale (is_available);

create trigger laptops_for_sale_set_updated_at
before update on public.laptops_for_sale
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- USER_BOUGHT_LAPTOP
-- ---------------------------------------------------------------------------

create table public.user_bought_laptops (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  laptop_for_sale_id uuid not null references public.laptops_for_sale (id) on delete restrict,
  payment_method public.payment_method not null,
  status public.purchase_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index user_bought_laptops_user_id_idx on public.user_bought_laptops (user_id);
create index user_bought_laptops_laptop_id_idx on public.user_bought_laptops (laptop_for_sale_id);

create trigger user_bought_laptops_set_updated_at
before update on public.user_bought_laptops
for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.kyc enable row level security;
alter table public.repairs enable row level security;
alter table public.repairer_calls enable row level security;
alter table public.shops enable row level security;
alter table public.laptops_for_rent enable row level security;
alter table public.user_rented_laptops enable row level security;
alter table public.laptops_for_sale enable row level security;
alter table public.user_bought_laptops enable row level security;

-- profiles
create policy "Profiles are readable by authenticated users"
  on public.profiles for select
  to authenticated
  using (true);

create policy "Users can update their own profile"
  on public.profiles for update
  to authenticated
  using (id = auth.uid() or public.is_staff())
  with check (id = auth.uid() or public.is_staff());

-- kyc
create policy "Users can view own KYC"
  on public.kyc for select
  to authenticated
  using (user_id = auth.uid() or public.is_staff());

create policy "Users can insert own KYC"
  on public.kyc for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Users can update own KYC"
  on public.kyc for update
  to authenticated
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

-- repairs
create policy "Clients see own repairs; repairers and staff see all"
  on public.repairs for select
  to authenticated
  using (
    user_id = auth.uid()
    or public.current_user_role() = 'repairer'
    or public.is_staff()
  );

create policy "Clients can create repairs"
  on public.repairs for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Owners and staff can update repairs"
  on public.repairs for update
  to authenticated
  using (
    user_id = auth.uid()
    or public.current_user_role() = 'repairer'
    or public.is_staff()
  )
  with check (
    user_id = auth.uid()
    or public.current_user_role() = 'repairer'
    or public.is_staff()
  );

create policy "Owners and staff can delete repairs"
  on public.repairs for delete
  to authenticated
  using (user_id = auth.uid() or public.is_staff());

-- repairer_calls
create policy "Participants and staff can view calls"
  on public.repairer_calls for select
  to authenticated
  using (user_id = auth.uid() or repairer_id = auth.uid() or public.is_staff());

create policy "Clients can create calls"
  on public.repairer_calls for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Participants and staff can update calls"
  on public.repairer_calls for update
  to authenticated
  using (user_id = auth.uid() or repairer_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or repairer_id = auth.uid() or public.is_staff());

-- shops
create policy "Shops are publicly readable"
  on public.shops for select
  to anon, authenticated
  using (true);

create policy "Owners can insert shops"
  on public.shops for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Owners and staff can update shops"
  on public.shops for update
  to authenticated
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

create policy "Owners and staff can delete shops"
  on public.shops for delete
  to authenticated
  using (user_id = auth.uid() or public.is_staff());

-- laptops_for_rent
create policy "Available rentals are publicly readable"
  on public.laptops_for_rent for select
  to anon, authenticated
  using (is_available or user_id = auth.uid() or public.is_staff());

create policy "Owners can insert rentals"
  on public.laptops_for_rent for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Owners and staff can update rentals"
  on public.laptops_for_rent for update
  to authenticated
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

create policy "Owners and staff can delete rentals"
  on public.laptops_for_rent for delete
  to authenticated
  using (user_id = auth.uid() or public.is_staff());

-- user_rented_laptops
create policy "Renter, owner, and staff can view rentals"
  on public.user_rented_laptops for select
  to authenticated
  using (
    user_id = auth.uid()
    or public.is_staff()
    or exists (
      select 1
      from public.laptops_for_rent l
      where l.id = rented_laptop_id and l.user_id = auth.uid()
    )
  );

create policy "Users can create their own rental requests"
  on public.user_rented_laptops for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Renter, owner, and staff can update rentals"
  on public.user_rented_laptops for update
  to authenticated
  using (
    user_id = auth.uid()
    or public.is_staff()
    or exists (
      select 1
      from public.laptops_for_rent l
      where l.id = rented_laptop_id and l.user_id = auth.uid()
    )
  )
  with check (
    user_id = auth.uid()
    or public.is_staff()
    or exists (
      select 1
      from public.laptops_for_rent l
      where l.id = rented_laptop_id and l.user_id = auth.uid()
    )
  );

-- laptops_for_sale
create policy "Available sales are publicly readable"
  on public.laptops_for_sale for select
  to anon, authenticated
  using (is_available or user_id = auth.uid() or public.is_staff());

create policy "Owners can insert sales"
  on public.laptops_for_sale for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Owners and staff can update sales"
  on public.laptops_for_sale for update
  to authenticated
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

create policy "Owners and staff can delete sales"
  on public.laptops_for_sale for delete
  to authenticated
  using (user_id = auth.uid() or public.is_staff());

-- user_bought_laptops
create policy "Buyer, seller, and staff can view purchases"
  on public.user_bought_laptops for select
  to authenticated
  using (
    user_id = auth.uid()
    or public.is_staff()
    or exists (
      select 1
      from public.laptops_for_sale l
      where l.id = laptop_for_sale_id and l.user_id = auth.uid()
    )
  );

create policy "Users can create their own purchases"
  on public.user_bought_laptops for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "Buyer, seller, and staff can update purchases"
  on public.user_bought_laptops for update
  to authenticated
  using (
    user_id = auth.uid()
    or public.is_staff()
    or exists (
      select 1
      from public.laptops_for_sale l
      where l.id = laptop_for_sale_id and l.user_id = auth.uid()
    )
  )
  with check (
    user_id = auth.uid()
    or public.is_staff()
    or exists (
      select 1
      from public.laptops_for_sale l
      where l.id = laptop_for_sale_id and l.user_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Privileges (required now that the API no longer auto-exposes new tables)
-- ---------------------------------------------------------------------------

grant usage on schema public to anon, authenticated, service_role;

grant all on all tables in schema public to anon, authenticated, service_role;
grant all on all routines in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;

alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on routines to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Storage
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'avatars',
    'avatars',
    true,
    5242880,
    array['image/png', 'image/jpeg', 'image/webp', 'image/gif']
  ),
  (
    'kyc',
    'kyc',
    false,
    10485760,
    array['image/png', 'image/jpeg', 'image/webp']
  ),
  (
    'repairs',
    'repairs',
    false,
    52428800,
    array[
      'image/png', 'image/jpeg', 'image/webp',
      'video/mp4', 'video/quicktime', 'video/webm',
      'audio/mpeg', 'audio/mp4', 'audio/webm', 'audio/wav', 'audio/x-m4a'
    ]
  ),
  (
    'shops',
    'shops',
    true,
    5242880,
    array['image/png', 'image/jpeg', 'image/webp']
  ),
  (
    'laptops',
    'laptops',
    true,
    10485760,
    array['image/png', 'image/jpeg', 'image/webp', 'model/gltf-binary', 'model/gltf+json']
  ),
  (
    'rental-verification',
    'rental-verification',
    false,
    10485760,
    array['image/png', 'image/jpeg', 'image/webp']
  )
on conflict (id) do nothing;

-- Path convention: {bucket}/{auth.uid()}/{filename}

create policy "Avatar images are publicly readable"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'avatars');

create policy "Users can upload their own avatar"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own avatar"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can delete their own avatar"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users and staff can read KYC files"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'kyc'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_staff()
    )
  );

create policy "Users can upload their own KYC files"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'kyc'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own KYC files"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'kyc'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff())
  );

create policy "Repair media readable by owner, repairers, and staff"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'repairs'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.current_user_role() = 'repairer'
      or public.is_staff()
    )
  );

create policy "Users can upload their own repair media"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'repairs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own repair media"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'repairs'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff())
  );

create policy "Shop images are publicly readable"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'shops');

create policy "Users can upload their own shop images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'shops'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own shop images"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'shops'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff())
  );

create policy "Users can delete their own shop images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'shops'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff())
  );

create policy "Laptop images are publicly readable"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'laptops');

create policy "Users can upload their own laptop images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'laptops'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own laptop images"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'laptops'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff())
  );

create policy "Users can delete their own laptop images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'laptops'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff())
  );

create policy "Rental verification readable by owner and staff"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'rental-verification'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_staff()
    )
  );

create policy "Users can upload their own rental verification"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'rental-verification'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own rental verification"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'rental-verification'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_staff())
  );
