-- Align schema with handwritten ERD + field notes (Feb 2025 calendar diagrams)
-- Adds what was missing relative to the earlier Week-30 PDF model.
--
-- From the diagrams:
--   roles: user, repairer, admin, superadmin
--   SHOP: shop_image, town, quarter, phone, email
--   ComputerOnRent: name, amount/week, any_known_issues, comes_with_charger, description
--   ComputerOnSale: name, processor_speed, graphics_card; belongs to SHOP
--   Review: user_id, shop_id, stars, notes
--   USER(COMPUTERONRENT): duration, amount
--
-- Existing tables (profiles, repairs, repairer_calls, kyc, purchases, etc.) are kept.

-- ---------------------------------------------------------------------------
-- Roles: diagrams use "user" instead of "client"
-- ---------------------------------------------------------------------------

alter type public.user_role rename value 'client' to 'user';

alter table public.profiles
  alter column role set default 'user';

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
    'user'
  );
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- SHOP: town, quarter, phone, email (+ shop_image alias of avatar)
-- ---------------------------------------------------------------------------

alter table public.shops
  add column if not exists town text,
  add column if not exists quarter text,
  add column if not exists phone text,
  add column if not exists email text,
  add column if not exists shop_image_url text;

comment on column public.shops.shop_image_url is 'Diagram field shop_image. avatar_url / logo_url remain for extra branding assets.';
comment on column public.shops.quarter is 'Neighborhood / quarter (notes: quator / quater).';

-- Prefer shop_image_url; keep avatar_url in sync when empty
update public.shops
set shop_image_url = avatar_url
where shop_image_url is null and avatar_url is not null;

-- ---------------------------------------------------------------------------
-- ComputerOnRent → laptops_for_rent
-- ---------------------------------------------------------------------------

alter table public.laptops_for_rent
  add column if not exists name text,
  add column if not exists any_known_issues text,
  add column if not exists comes_with_charger boolean not null default false,
  add column if not exists description text;

comment on column public.laptops_for_rent.name is 'Listing display name from ComputerOnRent diagram.';
comment on column public.laptops_for_rent.weekly_rate is 'Diagram: Amount per week.';
comment on column public.laptops_for_rent.brand is 'Diagram: mark (brand / make).';

-- ---------------------------------------------------------------------------
-- ComputerOnSale → laptops_for_sale (SHOP has Computers)
-- ---------------------------------------------------------------------------

alter table public.laptops_for_sale
  add column if not exists name text,
  add column if not exists processor_speed text,
  add column if not exists graphics_card text;

comment on column public.laptops_for_sale.name is 'Listing display name from ComputerOnSale diagram.';
comment on column public.laptops_for_sale.brand is 'Diagram: mark (brand / make).';
comment on column public.laptops_for_sale.shop_id is 'Diagram: ComputerOnSale.shop_id — computers belong to a shop.';

-- ---------------------------------------------------------------------------
-- USER(COMPUTERONRENT) → user_rented_laptops: amount
-- ---------------------------------------------------------------------------

alter table public.user_rented_laptops
  add column if not exists amount numeric(12, 2);

comment on column public.user_rented_laptops.amount is 'Total rental charge for the booking (duration × weekly rate or negotiated).';
comment on column public.user_rented_laptops.rented_laptop_id is 'Diagram: computeronrent_id / computer_rent_id.';

alter table public.user_rented_laptops
  drop constraint if exists user_rented_laptops_amount_positive;

alter table public.user_rented_laptops
  add constraint user_rented_laptops_amount_positive
  check (amount is null or amount >= 0);

-- ---------------------------------------------------------------------------
-- Review (USER writes reviews for SHOP)
-- ---------------------------------------------------------------------------

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  shop_id uuid not null references public.shops (id) on delete cascade,
  number_of_stars integer not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reviews_stars_range check (number_of_stars between 1 and 5),
  constraint reviews_user_shop_unique unique (user_id, shop_id)
);

comment on table public.reviews is 'USER → Review ← SHOP from the ERD.';
comment on column public.reviews.number_of_stars is 'Diagram: numberofstars / number of stars (1–5).';
comment on column public.reviews.notes is 'Diagram: notes / note.';

create index if not exists reviews_user_id_idx on public.reviews (user_id);
create index if not exists reviews_shop_id_idx on public.reviews (shop_id);

drop trigger if exists reviews_set_updated_at on public.reviews;
create trigger reviews_set_updated_at
before update on public.reviews
for each row execute function public.set_updated_at();

alter table public.reviews enable row level security;

drop policy if exists "Reviews are publicly readable" on public.reviews;
create policy "Reviews are publicly readable"
  on public.reviews for select
  to anon, authenticated
  using (true);

drop policy if exists "Authenticated users can create reviews" on public.reviews;
create policy "Authenticated users can create reviews"
  on public.reviews for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists "Authors and staff can update reviews" on public.reviews;
create policy "Authors and staff can update reviews"
  on public.reviews for update
  to authenticated
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

drop policy if exists "Authors and staff can delete reviews" on public.reviews;
create policy "Authors and staff can delete reviews"
  on public.reviews for delete
  to authenticated
  using (user_id = auth.uid() or public.is_staff());

grant all on table public.reviews to anon, authenticated, service_role;
