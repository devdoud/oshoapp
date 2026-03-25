-- Addresses table for user shipping details
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  full_name text not null,
  phone text not null,
  address text not null,
  city text not null,
  quartier text not null,
  postal_code text,
  country text,
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.addresses enable row level security;

create or replace function public.set_addresses_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_set_addresses_updated_at on public.addresses;
create trigger trg_set_addresses_updated_at
before update on public.addresses
for each row execute function public.set_addresses_updated_at();

drop policy if exists "addresses_select_own" on public.addresses;
drop policy if exists "addresses_insert_own" on public.addresses;
drop policy if exists "addresses_update_own" on public.addresses;
drop policy if exists "addresses_delete_own" on public.addresses;

create policy "addresses_select_own"
on public.addresses
for select
using (auth.uid() = user_id);

create policy "addresses_insert_own"
on public.addresses
for insert
with check (auth.uid() = user_id);

create policy "addresses_update_own"
on public.addresses
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "addresses_delete_own"
on public.addresses
for delete
using (auth.uid() = user_id);
