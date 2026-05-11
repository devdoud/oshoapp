-- Add product-specific customization option arrays.
--
-- fabric_options   : list of fabric variants to show in Step 1 for this product.
--                    If empty, the global catalog is used filtered by the product's
--                    `fabric` field (fabric type / category).
-- embroidery_options: list of embroidery/cut variants for Step 2.
--                    If empty AND product.embroidery is not null, the global catalog
--                    is used. If product.embroidery IS null/empty, Step 2 is skipped.
-- finish_options   : list of finish/accessory variants for Step 3.
--                    Same skip logic as embroidery_options.
--
-- Each array element has the shape: { "name": "...", "image_url": "..." }

alter table public.products
  add column if not exists fabric_options     jsonb not null default '[]'::jsonb,
  add column if not exists embroidery_options jsonb not null default '[]'::jsonb,
  add column if not exists finish_options     jsonb not null default '[]'::jsonb;
