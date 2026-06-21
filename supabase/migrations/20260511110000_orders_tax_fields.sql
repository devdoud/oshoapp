-- Stockage des informations de taxe sur les commandes.
-- Ces valeurs sont calculées et validées côté serveur (Edge Function),
-- jamais acceptées telles quelles depuis le client.

alter table public.orders
  add column if not exists tax_amount numeric(10, 2) not null default 0,
  add column if not exists tax_rate   numeric(6, 4)  not null default 0,
  add column if not exists tax_label  text           not null default '';
