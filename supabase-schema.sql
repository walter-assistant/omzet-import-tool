create table if not exists public.omzet_import_rows (
  id text primary key,
  status text,
  afdeling text,
  categorie text,
  bron text,
  blok text,
  project text,
  naam text,
  datum text,
  bedrag numeric default 0,
  opmerking text,
  bestand text,
  source_device text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists omzet_import_rows_datum_idx on public.omzet_import_rows (datum);
create index if not exists omzet_import_rows_blok_idx on public.omzet_import_rows (blok);
create index if not exists omzet_import_rows_categorie_idx on public.omzet_import_rows (categorie);

alter table public.omzet_import_rows enable row level security;

drop policy if exists "omzet_import_rows_select" on public.omzet_import_rows;
drop policy if exists "omzet_import_rows_insert" on public.omzet_import_rows;
drop policy if exists "omzet_import_rows_update" on public.omzet_import_rows;
drop policy if exists "omzet_import_rows_delete" on public.omzet_import_rows;

create policy "omzet_import_rows_select" on public.omzet_import_rows
  for select to anon using (true);
create policy "omzet_import_rows_insert" on public.omzet_import_rows
  for insert to anon with check (true);
create policy "omzet_import_rows_update" on public.omzet_import_rows
  for update to anon using (true) with check (true);
create policy "omzet_import_rows_delete" on public.omzet_import_rows
  for delete to anon using (true);
