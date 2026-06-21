-- Table FCM tokens pour tous les utilisateurs (clients + tailleurs)
-- Utilisée pour envoyer des notifications push depuis les Edge Functions

create table if not exists public.fcm_tokens (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users(id) on delete cascade,
  token      text not null,
  platform   text not null default 'android', -- 'android' | 'ios'
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, token)
);

alter table public.fcm_tokens enable row level security;

create or replace function public.set_fcm_tokens_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

drop trigger if exists trg_fcm_tokens_updated_at on public.fcm_tokens;
create trigger trg_fcm_tokens_updated_at
before update on public.fcm_tokens
for each row execute function public.set_fcm_tokens_updated_at();

-- Chaque user gère ses propres tokens
create policy "fcm_tokens_select_own" on public.fcm_tokens
  for select using (user_id = auth.uid());

create policy "fcm_tokens_insert_own" on public.fcm_tokens
  for insert with check (user_id = auth.uid());

create policy "fcm_tokens_delete_own" on public.fcm_tokens
  for delete using (user_id = auth.uid());

-- Service role peut tout lire (pour envoyer des notifs depuis Edge Functions)
create policy "fcm_tokens_service_select" on public.fcm_tokens
  for select using (true);

create index if not exists idx_fcm_tokens_user_id on public.fcm_tokens(user_id);
