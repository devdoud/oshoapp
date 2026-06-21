-- Fix 1 : Le trigger ne remettait pas orders.status à 'pending' lors d'un refus.
--         L'ordre restait bloqué en 'processing' indéfiniment, ce qui faisait
--         échouer claim_order_assignment (condition status = 'pending' non satisfaite)
--         et affichait « commande prise » à tort.
--
-- Fix 2 : Supprimer la ligne order_assignments après un refus/annulation du tailleur
--         pour qu'elle disparaisse automatiquement de sa page.

-- ── 1. Trigger corrigé ────────────────────────────────────────────────────────
create or replace function public.update_order_primary_tailor()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- INSERT : admin assigne directement avec status = 'accepted'
  if TG_OP = 'INSERT' then
    if new.status = 'accepted' then
      update public.orders
      set
        primary_tailor_id = new.tailor_id,
        status            = 'processing'
      where id     = new.order_id
        and status = 'pending';
    end if;
    return new;
  end if;

  -- UPDATE : transitions de statut
  if TG_OP = 'UPDATE' then

    -- Acceptation
    if new.status = 'accepted' and old.status <> 'accepted' then
      update public.orders
      set
        primary_tailor_id = new.tailor_id,
        status            = 'processing'
      where id     = new.order_id
        and status = 'pending';
    end if;

    -- Refus ou annulation : remettre l'ordre à 'pending' si ce tailleur
    -- était bien le tailleur principal (ou si aucun n'est encore assigné).
    if new.status in ('cancelled', 'rejected')
       and old.status not in ('cancelled', 'rejected') then
      update public.orders
      set
        primary_tailor_id = null,
        status            = 'pending'
      where id = new.order_id
        and (primary_tailor_id = new.tailor_id or primary_tailor_id is null)
        and status in ('pending', 'processing');
    end if;

  end if;

  return new;
end;
$$;

-- Recréer le trigger (inchangé : INSERT ou UPDATE)
drop trigger if exists trg_update_order_primary_tailor on public.order_assignments;
create trigger trg_update_order_primary_tailor
after insert or update on public.order_assignments
for each row execute function public.update_order_primary_tailor();


-- ── 2. Nettoyage des données bloquées (à exécuter une seule fois) ─────────────
-- Remet à 'pending' les ordres en 'processing' sans tailleur actif assigné.
update public.orders o
set
  primary_tailor_id = null,
  status            = 'pending'
where o.status = 'processing'
  and not exists (
    select 1
    from public.order_assignments oa
    where oa.order_id = o.id
      and oa.status in ('accepted', 'in_progress')
  );

-- Supprime les assignations orphelines en 'accepted' sans ordre valide
-- (cas où un tailleur a accepté mais l'ordre a été réassigné manuellement).
delete from public.order_assignments
where status = 'accepted'
  and order_id in (
    select id from public.orders where status = 'pending'
  );
