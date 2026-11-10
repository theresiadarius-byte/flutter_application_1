-- ========================================================
-- Praktik 5: Membuat Tabel Kos, RLS, dan Policies
-- ========================================================

-- 1. Buat tabel public.kos
create table if not exists public.kos (
  id         uuid primary key default gen_random_uuid(),
  owner_id   uuid not null default auth.uid()
             references auth.users(id) on delete cascade,
  name       text not null,
  address    text,
  price      integer,
  created_at timestamptz not null default now()
);

-- 2. Berikan izin hak akses tabel ke role authenticated
grant select, insert, update, delete on public.kos to authenticated;

-- 3. Aktifkan Row Level Security (RLS) pada tabel kos
alter table public.kos enable row level security;

-- 4. Policy 1 - SELECT: Semua pengguna yang sudah login (authenticated) boleh membaca seluruh data kos
drop policy if exists "kos_select_authenticated" on public.kos;
create policy "kos_select_authenticated"
  on public.kos for select to authenticated
  using (true);

-- 5. Policy 2 - INSERT: owner_id harus sama dengan akun yang login,
--    dan hanya pengguna dengan role 'owner' atau 'admin' yang boleh menambah kos
drop policy if exists "kos_insert_owner" on public.kos;
create policy "kos_insert_owner"
  on public.kos for insert to authenticated
  with check (
    auth.uid() = owner_id
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role in ('owner', 'admin')
    )
  );

-- 6. Policy 3 - UPDATE: Hanya pemilik data yang boleh mengubah datanya sendiri
drop policy if exists "kos_update_own" on public.kos;
create policy "kos_update_own"
  on public.kos for update to authenticated
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- 7. Policy 4 - DELETE: Hanya pemilik data yang boleh menghapus datanya sendiri
drop policy if exists "kos_delete_own" on public.kos;
create policy "kos_delete_own"
  on public.kos for delete to authenticated
  using (auth.uid() = owner_id);

-- 8. Opsional: Fungsi & Policy akses penuh untuk role Admin
create or replace function public.is_admin()
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

drop policy if exists "kos_admin_all" on public.kos;
create policy "kos_admin_all"
  on public.kos for all to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- ========================================================
-- QUERY VERIFIKASI KEAMANAN (Jalankan untuk memeriksa RLS)
-- ========================================================

-- Periksa policy apa saja yang sedang aktif pada tabel kos:
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public' and tablename = 'kos';

-- Periksa status relrowsecurity (harus bernilai true):
select relname, relrowsecurity
from pg_class
where relname = 'kos';
