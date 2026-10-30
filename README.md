# Course Explorer v2

Nama: Theresia Darius | NIM: 2415051116 | Kelas: PTI 5 A

Aplikasi Flutter hasil Praktikum Pertemuan 6 (State Management & Mobile
Application Architecture). Memakai Provider dan arsitektur berlapis.

## Fitur

- Home, Courses, Favorit, dan Profile dengan navigasi responsif
  (NavigationBar di layar sempit, NavigationRail di layar lebar).
- Data course dimuat lewat Provider dengan state loading, error, dan sukses.
- Favorit memakai satu sumber state sehingga konsisten di semua layar.

## Tanggung jawab folder (lib/)

| Folder | Tanggung jawab |
| --- | --- |
| `models/` | Bentuk data (`Course`) dan parsing `fromJson`. |
| `services/` | Membaca sumber data mentah (JSON asset). Tidak mengenal UI. |
| `repositories/` | Abstraksi data untuk provider; menyembunyikan asal data. |
| `providers/` | State dan aksi (`CourseProvider`: courses, loading, error, favorit). Tidak menyimpan `BuildContext`. |
| `screens/` | Halaman utuh: shell navigasi, Home, Courses, Favorit, Detail, Profile, dan halaman bukti Tahap 2. |
| `widgets/` | Komponen UI yang dipakai ulang: kartu, tag, form, demo. |
| `constants.dart` | Nama dan NIM mahasiswa. |

## Arah dependency

Screen/Widget -> Provider -> Repository -> Service -> Data (JSON)

Lapisan bawah tidak mengimpor lapisan di atasnya. UI tidak memanggil
`rootBundle` atau `jsonDecode` secara langsung. Pembacaan asset hanya ada
di `services/course_service.dart`.

## Menjalankan

    flutter pub get
    flutter run

Pastikan `assets/data/student_data.json` dan `assets/images/profile.jpg`
terdaftar pada bagian `assets` di `pubspec.yaml`.

## Riwayat praktikum

Setiap tahap (0 sampai 17) memiliki commit sendiri. Lihat dengan:

    git log --oneline --graph --decorate -20

    

## Dokumentasi REST API (Tahap 1)

### Informasi Endpoint
- **Endpoint:** https://course-api-pearl.vercel.app/courses
- **HTTP Method:** GET
- **Status Code:** 200 OK
- **Resource:** courses
- **Format Response:** JSON berupa array objek mata kuliah.

### Contoh Response JSON

Salah satu objek yang ditemukan pada respons API:

```json
{
  "id": 3,
  "code": "MOB03",
  "title": "Flutter Widgets & Layout",
  "credits": 3,
  "status": "planned",
  "created_at": "2026-10-21T03:28:09.361747Z"
}
```

### Field JSON
- `id`: identitas unik mata kuliah.
- `code`: kode mata kuliah.
- `title`: nama mata kuliah.
- `credits`: jumlah kredit mata kuliah.
- `status`: status mata kuliah.
- `created_at`: waktu pembuatan data.

### Catatan Pengamatan

Endpoint `/courses` berhasil diakses menggunakan HTTP GET.
Hasil pengujian melalui Chrome DevTools pada tab Network menunjukkan
status code 200 OK. Response body berisi kumpulan data mata kuliah
dalam format JSON.

Screenshot pengujian endpoint dan status HTTP disiapkan sebagai
bukti praktikum Tahap 1.
