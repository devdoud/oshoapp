-- Align order_items schema with app code
alter table if exists public.order_items
  add column if not exists price numeric,
  add column if not exists customization_details jsonb,
  add column if not exists measurement_snapshot jsonb;

alter table if exists public.order_items
  alter column unit_price drop not null,
  alter column total_price drop not null;

update public.order_items
set price = unit_price
where price is null and unit_price is not null;

update public.order_items
set customization_details = configuration_snapshot
where customization_details is null and configuration_snapshot is not null;

update public.order_items
set measurement_snapshot = measurements_snapshot
where measurement_snapshot is null and measurements_snapshot is not null;

create or replace function public.sync_order_item_fields()
returns trigger as $$
begin
  if new.quantity is null then
    new.quantity := 1;
  end if;

  if new.price is null then
    new.price := new.unit_price;
  end if;
  if new.unit_price is null then
    new.unit_price := new.price;
  end if;
  if new.total_price is null then
    new.total_price := new.unit_price * new.quantity;
  end if;

  if new.customization_details is null then
    new.customization_details := new.configuration_snapshot;
  end if;
  if new.configuration_snapshot is null then
    new.configuration_snapshot := new.customization_details;
  end if;

  if new.measurement_snapshot is null then
    new.measurement_snapshot := new.measurements_snapshot;
  end if;
  if new.measurements_snapshot is null then
    new.measurements_snapshot := new.measurement_snapshot;
  end if;

  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_sync_order_item_fields on public.order_items;
create trigger trg_sync_order_item_fields
before insert or update on public.order_items
for each row execute function public.sync_order_item_fields();

-- Cart table for authenticated users
create table if not exists public.cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  title text not null,
  image text,
  price numeric not null,
  quantity integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, product_id)
);

alter table public.cart_items enable row level security;

create or replace function public.set_cart_items_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_set_cart_items_updated_at on public.cart_items;
create trigger trg_set_cart_items_updated_at
before update on public.cart_items
for each row execute function public.set_cart_items_updated_at();

drop policy if exists "cart_items_select_own" on public.cart_items;
drop policy if exists "cart_items_insert_own" on public.cart_items;
drop policy if exists "cart_items_update_own" on public.cart_items;
drop policy if exists "cart_items_delete_own" on public.cart_items;

create policy "cart_items_select_own"
on public.cart_items
for select
using (auth.uid() = user_id);

create policy "cart_items_insert_own"
on public.cart_items
for insert
with check (auth.uid() = user_id);

create policy "cart_items_update_own"
on public.cart_items
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "cart_items_delete_own"
on public.cart_items
for delete
using (auth.uid() = user_id);
