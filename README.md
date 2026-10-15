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