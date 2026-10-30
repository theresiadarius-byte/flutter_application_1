# Course Data Manager

Aplikasi Flutter untuk mengelola data mata kuliah (course) dengan backend **Supabase**.
Pengembangan dari Course Explorer v2 (Pertemuan 5–6) pada praktikum Pertemuan 7:
REST API, Backend, dan Database.

- **Nama:** Theresia Darius
- **NIM:** 2415051116
- **Kelas:** PTI 5 A

## Deskripsi

Course Data Manager menampilkan daftar course dari database Supabase dan mendukung
operasi CRUD lengkap:

- **Read** – daftar course dengan state loading, empty, success, dan error (tombol coba lagi).
- **Create** – form tambah course dengan validasi (kode unik, judul, credits angka, status).
- **Update** – edit course dari halaman detail (kode tidak dapat diubah).
- **Delete** – hapus course dengan dialog konfirmasi.
- **Favorites** – tandai course favorit (kunci: kode course), konsisten di beberapa halaman.
- **Responsive navigation** – NavigationBar (layar sempit) dan NavigationRail (layar lebar).

## Backend yang Digunakan

Supabase (PostgreSQL + REST otomatis) melalui package `supabase_flutter`.
Aplikasi hanya memakai **anon (publishable) key**. Jangan pernah menaruh `service_role`
key di aplikasi Flutter.

Tabel `courses`:

| Kolom      | Tipe                  | Keterangan                              |
| ---------- | --------------------- | --------------------------------------- |
| id         | bigint (identity)     | Primary key                             |
| code       | text, unique          | Kode course                             |
| title      | text                  | Judul course                            |
| credits    | int                   | Jumlah SKS                              |
| status     | text                  | `planned` / `active` / `done` (CHECK)   |
| created_at | timestamptz           | Waktu pembuatan (default `now()`)       |

> RLS diaktifkan dengan policy permisif untuk role `anon` agar praktikum berjalan.
> Policy ini hanya untuk laboratorium, bukan pola produksi.

## Arsitektur Singkat

Alur data: **Screen → Provider → Repository → DataSource → Backend**

```
lib/
├── main.dart                        # inisialisasi Supabase + pemilihan data source aktif
├── constants.dart                   # nama & NIM
├── supabase_config.dart             # URL dan anon key Supabase
├── models/course.dart               # Course.fromJson() / toJson()
├── services/
│   ├── course_data_source.dart      # kontrak (abstract class)
│   ├── course_supabase_service.dart # implementasi Supabase (aktif)
│   └── course_api_service.dart      # implementasi REST API (alternatif)
├── repositories/course_repository.dart
├── providers/course_provider.dart   # state: loading, error, courses, favorites
├── screens/                         # halaman UI (tidak mengakses backend langsung)
└── widgets/                         # komponen UI (course_card, error_view, dll.)
```

Sumber data dipilih hanya di `main.dart`:

```dart
final CourseDataSource dataSource = CourseSupabaseService();
// Untuk REST: CourseApiService(apiBaseUrl)
```

Screen, provider, dan repository tidak berubah saat berpindah antara REST dan Supabase.

## Cara Menjalankan

1. Pastikan Flutter SDK sudah terpasang (`flutter doctor`).
2. Clone repository dan masuk ke foldernya:
   ```bash
   git clone https://github.com/theresiadarius-byte/flutter_application_1.git
   cd flutter_application_1
   ```
3. Pasang dependency:
   ```bash
   flutter pub get
   ```
4. Pastikan `lib/supabase_config.dart` berisi URL dan **anon key** project Supabase
   yang memiliki tabel `courses` (lihat struktur tabel di atas).
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Keamanan

- Hanya anon key yang ada di source code; tidak ada `service_role` key, password, atau token pribadi.
- Validasi di UI bukan pengganti validasi/otorisasi backend; keamanan sebenarnya ada di
  constraint database dan RLS.