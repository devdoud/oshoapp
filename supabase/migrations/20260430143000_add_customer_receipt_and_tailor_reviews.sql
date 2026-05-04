alter table public.orders
  add column if not exists customer_confirmed boolean not null default false,
  add column if not exists customer_received_at timestamptz;

create table if not exists public.tailor_reviews (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null unique references public.orders(id) on delete cascade,
  tailor_id uuid not null references auth.users(id) on delete restrict,
  customer_id uuid not null references auth.users(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  review_text text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.tailor_reviews enable row level security;

create index if not exists idx_tailor_reviews_tailor_id
on public.tailor_reviews(tailor_id);

create index if not exists idx_tailor_reviews_customer_id
on public.tailor_reviews(customer_id);

create or replace function public.set_tailor_reviews_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_set_tailor_reviews_updated_at on public.tailor_reviews;
create trigger trg_set_tailor_reviews_updated_at
before update on public.tailor_reviews
for each row execute function public.set_tailor_reviews_updated_at();

drop policy if exists "tailor_reviews_select_customer_own" on public.tailor_reviews;
create policy "tailor_reviews_select_customer_own"
on public.tailor_reviews
for select
using (customer_id = auth.uid());

drop policy if exists "tailor_reviews_select_tailor_own" on public.tailor_reviews;
create policy "tailor_reviews_select_tailor_own"
on public.tailor_reviews
for select
using (tailor_id = auth.uid());

drop policy if exists "tailor_reviews_insert_customer_own" on public.tailor_reviews;
create policy "tailor_reviews_insert_customer_own"
on public.tailor_reviews
for insert
with check (
  customer_id = auth.uid()
  and exists (
    select 1
    from public.orders o
    where o.id = order_id
      and o.user_id = auth.uid()
      and o.customer_confirmed = true
      and o.primary_tailor_id = tailor_id
  )
);

drop policy if exists "tailor_reviews_update_customer_own" on public.tailor_reviews;
create policy "tailor_reviews_update_customer_own"
on public.tailor_reviews
for update
using (customer_id = auth.uid())
with check (customer_id = auth.uid());
