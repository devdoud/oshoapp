-- Tailor FCM tokens table for push notifications
create table if not exists public.tailor_tokens (
  id uuid primary key default gen_random_uuid(),
  tailor_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  device_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.tailor_tokens enable row level security;

create or replace function public.set_tailor_tokens_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_set_tailor_tokens_updated_at on public.tailor_tokens;
create trigger trg_set_tailor_tokens_updated_at
before update on public.tailor_tokens
for each row execute function public.set_tailor_tokens_updated_at();

-- Policies for tailor_tokens
-- Tailors can see their own tokens
create policy "tailor_tokens_select_own"
on public.tailor_tokens
for select
using (auth.uid() = tailor_id);

-- Tailors can insert their own tokens
create policy "tailor_tokens_insert_own"
on public.tailor_tokens
for insert
with check (auth.uid() = tailor_id);

-- Tailors can update their own tokens
create policy "tailor_tokens_update_own"
on public.tailor_tokens
for update
using (auth.uid() = tailor_id)
with check (auth.uid() = tailor_id);

-- Tailors can delete their own tokens
create policy "tailor_tokens_delete_own"
on public.tailor_tokens
for delete
using (auth.uid() = tailor_id);

-- Service role can read all tokens (for notifications)
-- Note: This policy allows the backend to send notifications to all tailors
create policy "tailor_tokens_select_service_role"
on public.tailor_tokens
for select
using (true); -- Service role bypass RLS
