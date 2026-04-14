create table if not exists public.payment_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  stripe_payment_intent_id text not null unique,
  amount numeric not null,
  currency text not null default 'xof',
  status text not null default 'pending',
  order_payload jsonb not null,
  order_id uuid references public.orders(id) on delete set null,
  paid_at timestamptz,
  order_created_at timestamptz,
  notified_at timestamptz,
  error_message text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint payment_attempts_status_check check (
    status in (
      'pending',
      'requires_payment_method',
      'requires_confirmation',
      'requires_action',
      'requires_capture',
      'processing',
      'succeeded',
      'failed',
      'cancelled'
    )
  )
);

alter table public.payment_attempts enable row level security;

create or replace function public.set_payment_attempts_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_set_payment_attempts_updated_at on public.payment_attempts;
create trigger trg_set_payment_attempts_updated_at
before update on public.payment_attempts
for each row execute function public.set_payment_attempts_updated_at();

drop policy if exists "payment_attempts_select_own" on public.payment_attempts;
create policy "payment_attempts_select_own"
on public.payment_attempts
for select
using (auth.uid() = user_id);

alter table public.orders
  add column if not exists paid_at timestamptz,
  add column if not exists stripe_payment_intent_id text,
  add column if not exists payment_method text default 'card';

create unique index if not exists idx_orders_stripe_payment_intent_id
on public.orders(stripe_payment_intent_id)
where stripe_payment_intent_id is not null;

drop policy if exists "orders_select_own" on public.orders;
drop policy if exists "orders_insert_own" on public.orders;
drop policy if exists "orders_update_own" on public.orders;
drop policy if exists "orders_select_tailor" on public.orders;
drop policy if exists "orders_update_tailor" on public.orders;

create policy "orders_select_own"
on public.orders
for select
using (auth.uid() = user_id);

create policy "orders_insert_own"
on public.orders
for insert
with check (auth.uid() = user_id);

create policy "orders_update_own"
on public.orders
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "orders_select_tailor"
on public.orders
for select
using (
  coalesce(auth.jwt() -> 'user_metadata' ->> 'role', '') = 'tailor'
  and exists (
    select 1
    from public.order_assignments oa
    where oa.order_id = public.orders.id
      and oa.tailor_id = auth.uid()
  )
);

create policy "orders_update_tailor"
on public.orders
for update
using (
  coalesce(auth.jwt() -> 'user_metadata' ->> 'role', '') = 'tailor'
  and exists (
    select 1
    from public.order_assignments oa
    where oa.order_id = public.orders.id
      and oa.tailor_id = auth.uid()
      and oa.status in ('accepted', 'in_progress', 'completed')
  )
)
with check (
  coalesce(auth.jwt() -> 'user_metadata' ->> 'role', '') = 'tailor'
  and exists (
    select 1
    from public.order_assignments oa
    where oa.order_id = public.orders.id
      and oa.tailor_id = auth.uid()
      and oa.status in ('accepted', 'in_progress', 'completed')
  )
);

drop policy if exists "order_items_select_own" on public.order_items;
drop policy if exists "order_items_insert_own" on public.order_items;
drop policy if exists "order_items_select_tailor" on public.order_items;
drop policy if exists "order_items_update_tailor" on public.order_items;

create policy "order_items_select_own"
on public.order_items
for select
using (
  exists (
    select 1
    from public.orders o
    where o.id = public.order_items.order_id
      and o.user_id = auth.uid()
  )
);

create policy "order_items_insert_own"
on public.order_items
for insert
with check (
  exists (
    select 1
    from public.orders o
    where o.id = public.order_items.order_id
      and o.user_id = auth.uid()
  )
);

create policy "order_items_select_tailor"
on public.order_items
for select
using (
  coalesce(auth.jwt() -> 'user_metadata' ->> 'role', '') = 'tailor'
  and exists (
    select 1
    from public.order_assignments oa
    where oa.order_id = public.order_items.order_id
      and oa.tailor_id = auth.uid()
  )
);

create policy "order_items_update_tailor"
on public.order_items
for update
using (
  coalesce(auth.jwt() -> 'user_metadata' ->> 'role', '') = 'tailor'
  and exists (
    select 1
    from public.order_assignments oa
    where oa.order_id = public.order_items.order_id
      and oa.tailor_id = auth.uid()
      and oa.status in ('accepted', 'in_progress', 'completed')
  )
);

drop policy if exists "order_assignments_select_own" on public.order_assignments;
drop policy if exists "order_assignments_update_own" on public.order_assignments;
drop policy if exists "order_assignments_all_authenticated" on public.order_assignments;
drop policy if exists "order_assignments_insert_authenticated" on public.order_assignments;

create policy "order_assignments_select_own"
on public.order_assignments
for select
using (auth.uid() = tailor_id);

create policy "order_assignments_update_own"
on public.order_assignments
for update
using (auth.uid() = tailor_id)
with check (auth.uid() = tailor_id);

create or replace function public.update_order_primary_tailor()
returns trigger as $$
begin
  if new.status = 'accepted' and (old.status is null or old.status != 'accepted') then
    update public.orders
    set primary_tailor_id = new.tailor_id
    where id = new.order_id;
  end if;

  if new.status in ('cancelled', 'rejected')
     and old.status is distinct from new.status then
    update public.orders
    set primary_tailor_id = case
      when primary_tailor_id = new.tailor_id then null
      else primary_tailor_id
    end
    where id = new.order_id;
  end if;

  return new;
end;
$$ language plpgsql;

