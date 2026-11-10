-- ========================================================
-- Praktik 9: Tabel Device Tokens untuk FCM Push Notification
-- ========================================================

-- 1. Buat tabel device_tokens
create table if not exists public.device_tokens (
  token      text primary key,
  user_id    uuid not null default auth.uid()
             references auth.users(id) on delete cascade,
  platform   text,
  updated_at timestamptz not null default now()
);

-- 2. Berikan izin hak akses ke role authenticated
grant select, insert, update, delete on public.device_tokens to authenticated;

-- 3. Aktifkan Row Level Security (RLS)
alter table public.device_tokens enable row level security;

-- 4. Policy RLS: User hanya boleh mengakses dan mengelola token miliknya sendiri
drop policy if exists "tokens_select_own" on public.device_tokens;
create policy "tokens_select_own" 
  on public.device_tokens for select to authenticated 
  using (auth.uid() = user_id);

drop policy if exists "tokens_insert_own" on public.device_tokens;
create policy "tokens_insert_own" 
  on public.device_tokens for insert to authenticated 
  with check (auth.uid() = user_id);

drop policy if exists "tokens_update_own" on public.device_tokens;
create policy "tokens_update_own" 
  on public.device_tokens for update to authenticated
  using (auth.uid() = user_id) 
  with check (auth.uid() = user_id);

drop policy if exists "tokens_delete_own" on public.device_tokens;
create policy "tokens_delete_own" 
  on public.device_tokens for delete to authenticated 
  using (auth.uid() = user_id);
