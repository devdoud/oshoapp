-- Order assignments table to map orders to tailors
create table if not exists public.order_assignments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  tailor_id uuid not null references auth.users(id) on delete restrict,
  status text not null default 'pending',
  assigned_at timestamptz not null default now(),
  accepted_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  
  -- Ensure a tailor is not assigned twice to the same order
  unique(order_id, tailor_id),
  
  -- Add constraint for valid status values
  constraint valid_assignment_status check (status in ('pending', 'accepted', 'in_progress', 'completed', 'rejected', 'cancelled'))
);

alter table public.order_assignments enable row level security;

create or replace function public.set_order_assignments_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_set_order_assignments_updated_at on public.order_assignments;
create trigger trg_set_order_assignments_updated_at
before update on public.order_assignments
for each row execute function public.set_order_assignments_updated_at();

-- Create index for fast assignment lookup
create index idx_order_assignments_order_id on public.order_assignments(order_id);
create index idx_order_assignments_tailor_id on public.order_assignments(tailor_id);
create index idx_order_assignments_status on public.order_assignments(status);

-- Policies for order_assignments
-- Tailors can see their own assignments
create policy "order_assignments_select_own"
on public.order_assignments
for select
using (auth.uid() = tailor_id);

-- Tailors can update their own assignments (accept, start, complete)
create policy "order_assignments_update_own"
on public.order_assignments
for update
using (auth.uid() = tailor_id)
with check (auth.uid() = tailor_id);

-- Allow admin/service to manage assignments (for assignment logic)
-- In production, consider using a more secure approach with a specific admin role
create policy "order_assignments_all_authenticated"
on public.order_assignments
for select
using (true);

create policy "order_assignments_insert_authenticated"
on public.order_assignments
for insert
with check (true);
