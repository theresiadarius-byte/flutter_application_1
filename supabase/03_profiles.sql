-- ========================================================
-- Praktik 3: Membuat Tabel Profiles, RLS, dan Trigger User
-- ========================================================

-- 1. Buat tabel public.profiles
create table if not exists public.profiles (
  id    uuid primary key references auth.users(id) on delete cascade,
  email text,
  name  text,
  role  text not null default 'seeker'
        check (role in ('seeker', 'owner', 'admin'))
);

-- 2. Aktifkan Row Level Security (RLS)
alter table public.profiles enable row level security;

-- 3. Policy SELECT: user hanya boleh membaca profile miliknya sendiri
-- (Catatan: Tidak dibuat policy UPDATE, sehingga user tidak dapat memodifikasi rolenya sendiri)
create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using (auth.uid() = id);

-- 4. Fungsi trigger untuk membuat row profile otomatis saat ada user baru terdaftar
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    case
      when new.raw_user_meta_data->>'role' in ('seeker', 'owner')
        then new.raw_user_meta_data->>'role'
      else 'seeker'
    end
  );
  return new;
end;
$$;

-- Pasang trigger pada tabel auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ========================================================
-- QUERY MANUAL / HELPER (Dijalankan sesuai kebutuhan)
-- ========================================================

-- A. Masukkan data profile untuk akun-akun lama yang sudah terdaftar sebelum trigger dibuat:
insert into public.profiles (id, email, name, role)
select id, email, '', 'seeker' from auth.users
on conflict (id) do nothing;

-- B. Contoh mengubah role pengguna menjadi 'owner' atau 'admin':
-- update public.profiles set role = 'owner' where email = 'owner@contoh.com';
-- update public.profiles set role = 'admin' where email = 'admin@contoh.com';
