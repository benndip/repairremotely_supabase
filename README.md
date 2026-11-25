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
                ├── 1──* repairs
                ├── 1──* repairer_calls          (client)
                ├── 1──* repairer_calls          (repairer, via repairer_id)
                ├── 1──* shops
                ├── 1──* laptops_for_rent
                ├── 1──* laptops_for_sale
                ├── 1──* user_rented_laptops
                └── 1──* user_bought_laptops

shops 1──* laptops_for_rent
shops 1──* laptops_for_sale
laptops_for_rent 1──* user_rented_laptops
laptops_for_sale 1──* user_bought_laptops
repairs 1──* repairer_calls
```

### Roles

`client | repairer | admin | super-admin`

New signups always start as `client`. Only staff can change a role.

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
2. Rental price → `weekly_rate` (default 5000 XAF / week)
3. Duplicate `storage` on sale listings → `storage` (capacity) + `storage_type` (HDD / SSD / NVMe)
4. `created_at` / `updated_at` on every table
5. `condition` (`new` / `used`) on both laptop tables
6. `shipping` → `shipping_available` + `shipping_cost`
7. Optional `shop_id` on both laptop listing tables

## Sync with a remote project later

1. Create the hosted project in the Supabase dashboard.
2. From this folder:

```bash
npx supabase login
npx supabase link --project-ref <project-ref>
npx supabase db push
```

`db push` applies the local migrations to the remote database. Do not run `db pull` first if the remote project is empty — that would overwrite this schema with a blank remote snapshot.

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
