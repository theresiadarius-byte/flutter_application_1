-- ========================================================
-- Praktik 6: Security Testing Row Level Security (SQL Editor)
-- ========================================================

-- Simulasi Pengujian:
-- User B mencoba mengutak-atik (UPDATE & DELETE) data kos milik User A.
-- Seluruh pengujian dibungkus dalam blok transaction (BEGIN ... ROLLBACK)
-- sehingga tidak ada data yang berubah secara permanen di database.

-- Petunjuk:
-- Ganti 'UUID_USER_B' dengan id akun User B (dapat dilihat di Authentication > Users)
-- Ganti 'UUID_KOS_USER_A' dengan id salah satu data kos milik User A (dapat dilihat di Table Editor > kos)

begin;

  -- 1. Berperilaku seolah-olah request berasal dari koneksi pengguna login (authenticated)
  set local role authenticated;

  -- 2. Simulasi token JWT login atas nama User B
  select set_config(
    'request.jwt.claims',
    '{"sub":"UUID_USER_B","role":"authenticated"}',
    true
  );

  -- 3. Percobaan 1: User B mencoba mengubah (UPDATE) nama kos milik User A
  -- HASIL YANG DIHARAPKAN: UPDATE 0 (tidak ada baris yang terubah karena RLS menolak)
  update public.kos 
  set name = 'HACKED BY USER B' 
  where id = 'UUID_KOS_USER_A';

  -- 4. Percobaan 2: User B mencoba menghapus (DELETE) data kos milik User A
  -- HASIL YANG DIHARAPKAN: DELETE 0 (tidak ada baris yang terhapus karena RLS menolak)
  delete from public.kos 
  where id = 'UUID_KOS_USER_A';

-- Batalkan seluruh transaksi pengujian agar database tetap bersih
rollback;
