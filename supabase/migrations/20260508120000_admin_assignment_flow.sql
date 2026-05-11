-- Adapt the assignment trigger to support admin-driven assignment via Supabase dashboard.
--
-- Previously the trigger only fired on UPDATE (tailors accepting auto-assigned rows).
-- Now the admin inserts directly into order_assignments, so the trigger must also
-- fire on INSERT to keep orders.primary_tailor_id in sync.

create or replace function public.update_order_primary_tailor()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- INSERT: admin assigns directly with status = 'accepted'
  if TG_OP = 'INSERT' then
    if new.status = 'accepted' then
      update public.orders
      set
        primary_tailor_id = new.tailor_id,
        status = 'processing'
      where id = new.order_id
        and status = 'pending';
    end if;
    return new;
  end if;

  -- UPDATE: status transition
  if TG_OP = 'UPDATE' then
    if new.status = 'accepted' and old.status <> 'accepted' then
      update public.orders
      set
        primary_tailor_id = new.tailor_id,
        status = 'processing'
      where id = new.order_id
        and status = 'pending';
    end if;

    if new.status in ('cancelled', 'rejected')
       and old.status not in ('cancelled', 'rejected') then
      update public.orders
      set primary_tailor_id = case
        when primary_tailor_id = new.tailor_id then null
        else primary_tailor_id
      end
      where id = new.order_id;
    end if;
  end if;

  return new;
end;
$$;

-- Recreate trigger to fire on both INSERT and UPDATE
drop trigger if exists trg_update_order_primary_tailor on public.order_assignments;
create trigger trg_update_order_primary_tailor
after insert or update on public.order_assignments
for each row execute function public.update_order_primary_tailor();
