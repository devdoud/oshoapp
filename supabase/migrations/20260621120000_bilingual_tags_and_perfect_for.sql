-- Ajoute le support bilingue (FR/EN) pour les tags produits et la section
-- "Perfect For", afin que le contenu saisi côté admin/Supabase puisse être
-- traduit fidèlement dans l'app au lieu de dépendre d'un dictionnaire client.

-- Tags : label_en optionnel. Si absent, l'app retombe sur le label FR existant.
alter table public.product_tags
  add column if not exists label_en text;

-- Perfect For : chaque élément du tableau jsonb devient un objet {"fr": "...", "en": "..."}.
-- Les anciennes valeurs (chaînes simples) restent acceptées côté app et sont
-- traitées comme du FR uniquement (pas de migration de données nécessaire).
comment on column public.products.perfect_for is
  'Tableau JSON. Chaque élément est soit une chaîne (FR uniquement, ancien format), soit un objet {"fr": "...", "en": "..."}.';
