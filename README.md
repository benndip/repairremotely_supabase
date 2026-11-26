# Software Doctors — local Supabase

Local Supabase app for the repair, rental, and laptop-sales platform. Schema follows *Platform Architecture — Data Models* (Week 30, 25–27 July 2025).

This project is local-only until you create the hosted Supabase project and link it.

## Prerequisites

- Docker Desktop running
- Node.js (the CLI is run with `npx supabase`)

## Start locally

```bash
cd /Users/benndip/Desktop/AllProjects/Supabase/SoftwareDoctors
npx supabase start
```

Studio: [http://127.0.0.1:54323](http://127.0.0.1:54323)

API: [http://127.0.0.1:54321](http://127.0.0.1:54321)

Postgres: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`

`npx supabase status` prints the local URL, anon key, and service role key.

To rebuild the database from migrations:

```bash
npx supabase db reset
```

Stop:

```bash
npx supabase stop
```

## Schema

`profiles` is the hub. It is **not** a password table — auth lives in `auth.users`, and a profile row is created on signup.

```
auth.users 1──1 profiles
                ├── 1──1 kyc
                ├── 1──* repairs                 (book)
                ├── 1──* repairer_calls          (talk to — client side)
                ├── 1──* repairer_calls          (talk to — repairer_id)
                ├── 1──* shops
                ├── 1──* reviews
                ├── 1──* laptops_for_rent        (rent out / ComputerOnRent)
                ├── 1──* laptops_for_sale
                ├── 1──* user_rented_laptops     (USER ↔ ComputerOnRent)
                └── 1──* user_bought_laptops

shops 1──* laptops_for_rent
shops 1──* laptops_for_sale                    (have Computers / ComputerOnSale)
shops 1──* reviews
laptops_for_rent 1──* user_rented_laptops
laptops_for_sale 1──* user_bought_laptops
repairs 1──* repairer_calls
```

### Roles

`user | repairer | admin | super-admin`

New signups always start as `user`. Only staff can change a role.

### Storage buckets

Upload path: `{bucket}/{user_id}/{filename}`

| Bucket | Public | Use |
| --- | --- | --- |
| `avatars` | yes | Profile photos |
| `kyc` | no | ID front/back + selfie |
| `repairs` | no | Two images, ~30s video, voice note |
| `shops` | yes | Shop avatar + logo |
| `laptops` | yes | Listing photos + optional 3D model |
| `rental-verification` | no | Rental ID + face photos |

## Decisions from the handwritten notes

1. `fullname` + `last_name` → `first_name` + `last_name`
2. Rental price → `weekly_rate` (default 5000 XAF / week) = diagram "Amount per week"
3. Duplicate `storage` on sale listings → `storage` (capacity) + `storage_type` (HDD / SSD / NVMe)
4. `created_at` / `updated_at` on every table
5. `condition` (`new` / `used`) on both laptop tables
6. `shipping` → `shipping_available` + `shipping_cost`
7. Optional `shop_id` on both laptop listing tables (sale listings are shop-owned in the ERD)
8. Role `client` renamed to `user` to match the diagrams
9. Added `reviews` (user + shop + stars + notes)
10. Shop contact/location: `town`, `quarter`, `phone`, `email`, `shop_image_url`
11. Rent listings: `name`, `any_known_issues`, `comes_with_charger`, `description`
12. Sale listings: `name`, `processor_speed`, `graphics_card`
13. Rental bookings: `amount` on `user_rented_laptops`

## Remote project

Linked project: **RepairRemotely** (`baerfogfstmxwohgbzrb`)

```bash
npx supabase db push --remote --yes
```

Do not run `db pull` against an empty or divergent remote unless you intend to import remote-only changes into this repo.

## Frontend env

Copy values from `npx supabase status` into the app:

```bash
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon key>
```

Generated TypeScript types live in `types/database.ts`. Regenerate after schema changes with:

```bash
npx supabase gen types typescript --local > types/database.ts
```
