-- Synchronise public.user_roles → auth.users.raw_user_meta_data
-- afin que les policies RLS basées sur auth.jwt()->'user_metadata'->>'role'
-- reflètent toujours le rôle réel stocké dans user_roles.

create or replace function public.sync_user_role_to_metadata()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (TG_OP = 'DELETE') then
    -- Suppression du rôle : revenir à 'customer' par défaut
    update auth.users
    set raw_user_meta_data = raw_user_meta_data || '{"role": "customer"}'::jsonb
    where id = OLD.user_id;
    return OLD;
  else
    -- INSERT ou UPDATE : appliquer le nouveau rôle
    update auth.users
    set raw_user_meta_data = raw_user_meta_data || jsonb_build_object('role', NEW.role)
    where id = NEW.user_id;
    return NEW;
  end if;
end;
$$;

drop trigger if exists trg_sync_user_role_to_metadata on public.user_roles;
create trigger trg_sync_user_role_to_metadata
after insert or update or delete on public.user_roles
for each row execute function public.sync_user_role_to_metadata();
