-- Order items table
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid not null,
  quantity integer not null default 1,
  price numeric,
  unit_price numeric,
  total_price numeric,
  measurement_profile_id uuid references public.measurement_profiles(id),
  customization_details jsonb,
  configuration_snapshot jsonb,
  measurements_snapshot jsonb,
  created_at timestamptz not null default now()
);

alter table public.order_items enable row level security;

-- Policies for order_items (same as orders)
create policy "order_items_select_own"
on public.order_items
for select
using (exists (select 1 from public.orders where id = order_id and user_id = auth.uid()));

create policy "order_items_insert_own"
on public.order_items
for insert
with check (exists (select 1 from public.orders where id = order_id and user_id = auth.uid()));

create policy "order_items_select_tailor"
on public.order_items
for select
using (true);

create policy "order_items_update_tailor"
on public.order_items
for update
using (true);