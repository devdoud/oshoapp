-- Ajout des mesures supplémentaires nécessaires pour les tenues africaines.
-- Ces mesures complètent le profil de base (neck, chest, waist, hips, shoulder, sleeve, inseam).

alter table public.measurement_profiles
  add column if not exists upper_arm     numeric(5,1),   -- Tour de bras (biceps)
  add column if not exists back_length   numeric(5,1),   -- Longueur dos (nuque → taille)
  add column if not exists dress_length  numeric(5,1),   -- Longueur totale (nuque → ourlet)
  add column if not exists thigh         numeric(5,1),   -- Tour de cuisse
  add column if not exists trouser_length numeric(5,1),  -- Longueur pantalon (taille → cheville)
  add column if not exists bust_height   numeric(5,1);   -- Hauteur poitrine (épaule → point poitrine, femme)
