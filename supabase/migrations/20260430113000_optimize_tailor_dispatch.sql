create index if not exists idx_order_assignments_tailor_active
on public.order_assignments(tailor_id)
where status in ('accepted', 'in_progress');

create unique index if not exists idx_order_assignments_one_active_per_order
on public.order_assignments(order_id)
where status in ('accepted', 'in_progress', 'completed');

create or replace function public.claim_order_assignment(
  p_assignment_id uuid,
  p_tailor_id uuid,
  p_notes text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_assignment public.order_assignments%rowtype;
  v_deleted_count integer := 0;
begin
  select *
  into v_assignment
  from public.order_assignments
  where id = p_assignment_id
    and tailor_id = p_tailor_id
  for update;

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Assignment not found.'
    );
  end if;

  if v_assignment.status <> 'pending' then
    return jsonb_build_object(
      'success', false,
      'message', 'Assignment is no longer pending.'
    );
  end if;

  if exists (
    select 1
    from public.order_assignments oa
    where oa.tailor_id = p_tailor_id
      and oa.id <> p_assignment_id
      and oa.status in ('accepted', 'in_progress')
  ) then
    return jsonb_build_object(
      'success', false,
      'message', 'Tailor already has an active order.'
    );
  end if;

  update public.orders
  set
    primary_tailor_id = p_tailor_id,
    status = 'processing'
  where id = v_assignment.order_id
    and primary_tailor_id is null
    and status = 'pending';

  if not found then
    return jsonb_build_object(
      'success', false,
      'message', 'Order is no longer available.'
    );
  end if;

  update public.order_assignments
  set
    status = 'accepted',
    accepted_at = coalesce(accepted_at, now()),
    notes = coalesce(p_notes, notes)
  where id = v_assignment.id
  returning * into v_assignment;

  delete from public.order_assignments
  where order_id = v_assignment.order_id
    and id <> v_assignment.id
    and status = 'pending';

  get diagnostics v_deleted_count = row_count;

  return jsonb_build_object(
    'success', true,
    'deleted_pending_count', v_deleted_count,
    'assignment', to_jsonb(v_assignment)
  );
exception
  when unique_violation then
    return jsonb_build_object(
      'success', false,
      'message', 'Order has already been claimed.'
    );
end;
$$;
