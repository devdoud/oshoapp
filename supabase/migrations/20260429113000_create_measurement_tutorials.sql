insert into storage.buckets (id, name, public)
values ('measurement-tutorials', 'measurement-tutorials', true)
on conflict (id) do update
set public = excluded.public;

create table if not exists public.measurement_tutorials (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  description text not null,
  video_path text not null,
  thumbnail_path text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.measurement_tutorials enable row level security;

drop policy if exists "measurement tutorials are readable by everyone"
on public.measurement_tutorials;

create policy "measurement tutorials are readable by everyone"
on public.measurement_tutorials
for select
using (true);

create or replace function public.set_measurement_tutorials_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_measurement_tutorials_updated_at
on public.measurement_tutorials;

create trigger set_measurement_tutorials_updated_at
before update on public.measurement_tutorials
for each row
execute function public.set_measurement_tutorials_updated_at();

insert into public.measurement_tutorials (
  slug,
  title,
  description,
  video_path,
  thumbnail_path,
  sort_order,
  is_active
)
values
  (
    'neck',
    'Le Cou',
    'Mesurez autour de la base de votre cou, la ou se trouve le col.',
    'videos/neck.mp4',
    'thumbnails/neck.png',
    1,
    true
  ),
  (
    'chest',
    'La Poitrine',
    'Passez le metre ruban sous vos bras, autour de la partie la plus large.',
    'videos/chest.mp4',
    'thumbnails/chest.png',
    2,
    true
  ),
  (
    'waist',
    'La Taille',
    'Mesurez autour de votre taille naturelle, juste au-dessus du nombril.',
    'videos/waist.mp4',
    'thumbnails/waist.png',
    3,
    true
  ),
  (
    'hips',
    'Les Hanches',
    'Mesurez autour de la partie la plus large de vos hanches.',
    'videos/hips.mp4',
    'thumbnails/hips.png',
    4,
    true
  )
on conflict (slug) do update
set
  title = excluded.title,
  description = excluded.description,
  video_path = excluded.video_path,
  thumbnail_path = excluded.thumbnail_path,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  updated_at = now();
