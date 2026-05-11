-- Ajoute un tableau de contextes d'utilisation du produit (section "Parfait pour").
-- Chaque élément est une chaîne de caractères.
-- Exemple : ["Wedding guest outfit", "Traditional ceremonies"]
-- Si vide, l'app affiche une liste par défaut basée sur la catégorie.

alter table public.products
  add column if not exists perfect_for jsonb not null default '[]'::jsonb;
