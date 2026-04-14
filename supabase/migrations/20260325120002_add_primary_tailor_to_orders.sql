-- Add primary_tailor_id column to orders table for faster queries
-- This references the primary tailor assigned to an order (from order_assignments)
alter table public.orders
add column primary_tailor_id uuid references auth.users(id) on delete set null;

-- Create index for faster lookups
create index idx_orders_primary_tailor_id on public.orders(primary_tailor_id);

-- Create a function to auto-update primary_tailor_id when an assignment is accepted
create or replace function public.update_order_primary_tailor()
returns trigger as $$
begin
  -- When an assignment is accepted, update the order's primary_tailor_id
  if new.status = 'accepted' and (old.status is null or old.status != 'accepted') then
    update public.orders
    set primary_tailor_id = new.tailor_id
    where id = new.order_id;
  end if;
  
  -- When an assignment is cancelled/rejected, clear primary_tailor_id
  if new.status in ('cancelled', 'rejected') and old.status != 'cancelled' and old.status != 'rejected' then
    update public.orders
    set primary_tailor_id = null
    where id = new.order_id;
  end if;
  
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_update_order_primary_tailor on public.order_assignments;
create trigger trg_update_order_primary_tailor
after update on public.order_assignments
for each row execute function public.update_order_primary_tailor();
