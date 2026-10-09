-- Alleen project zkocfksybffyokzafwbd (Omzet Import Tool).
-- Additieve migratie: bestaande omzetregels en permissies blijven ongewijzigd.
begin;
create table if not exists public.omzet_archive_admins(email text primary key);
alter table public.omzet_archive_admins enable row level security;
revoke all on public.omzet_archive_admins from anon, authenticated;
insert into public.omzet_archive_admins(email) values ('p.groot@groundresearch.nl') on conflict do nothing;
create or replace function public.omzet_archive_admin() returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.omzet_archive_admins a
 where a.email=lower(auth.jwt()->>'email')) and auth.uid() is not null;
$$;
revoke all on function public.omzet_archive_admin() from public,anon;
grant execute on function public.omzet_archive_admin() to anon,authenticated;
create table if not exists public.omzet_documents(
 id text primary key check (id ~ '^[a-f0-9]{64}$'),
 metadata jsonb not null check(jsonb_typeof(metadata)='object'),
 revision integer not null default 1 check(revision>0)
);
alter table public.omzet_documents enable row level security;
revoke all on public.omzet_documents from anon,authenticated;
grant select,insert,update on public.omzet_documents to authenticated;
drop policy if exists omzet_archive_access on public.omzet_documents;
create policy omzet_archive_access on public.omzet_documents for all to authenticated
using(public.omzet_archive_admin()) with check(public.omzet_archive_admin());
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('omzet-bonnen','omzet-bonnen',false,52428800,array['application/pdf'])
on conflict(id) do update set public=false,file_size_limit=52428800,allowed_mime_types=array['application/pdf'];
drop policy if exists omzet_archive_read on storage.objects;
create policy omzet_archive_read on storage.objects for select to authenticated
using(bucket_id='omzet-bonnen' and public.omzet_archive_admin());
drop policy if exists omzet_archive_insert on storage.objects;
create policy omzet_archive_insert on storage.objects for insert to authenticated
with check(bucket_id='omzet-bonnen' and name ~ '^[a-f0-9]{64}\.pdf$' and public.omzet_archive_admin());
-- Restrictieve guards voorkomen toegang via eventuele algemene bucket-policies.
drop policy if exists omzet_archive_private_read on storage.objects;
create policy omzet_archive_private_read on storage.objects as restrictive for select to public
using(bucket_id<>'omzet-bonnen' or (select auth.role())='authenticated' and public.omzet_archive_admin());
drop policy if exists omzet_archive_private_insert on storage.objects;
create policy omzet_archive_private_insert on storage.objects as restrictive for insert to public
with check(bucket_id<>'omzet-bonnen' or (select auth.role())='authenticated' and name ~ '^[a-f0-9]{64}\.pdf$' and public.omzet_archive_admin());
drop policy if exists omzet_archive_no_overwrite on storage.objects;
create policy omzet_archive_no_overwrite on storage.objects as restrictive for update to public
using(bucket_id<>'omzet-bonnen') with check(bucket_id<>'omzet-bonnen');
drop policy if exists omzet_archive_no_delete on storage.objects;
create policy omzet_archive_no_delete on storage.objects as restrictive for delete to public
using(bucket_id<>'omzet-bonnen');
notify pgrst,'reload schema';
commit;
select 'Bonarchief ingericht; controleer beheerderslogin en test synchronisatie op twee apparaten.' as resultaat;
