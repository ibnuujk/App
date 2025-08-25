# Fitur CRUD Artikel dengan Link Website

## Deskripsi
Fitur artikel pada aplikasi PersalinanKu telah diubah menjadi sistem CRUD (Create, Read, Update, Delete) yang memungkinkan bidan/admin untuk mengelola artikel edukasi dengan link website eksternal.

## Fitur yang Tersedia

### 1. Panel Admin (CRUD Artikel)
- **Tab 1: Generator Artikel** - Fitur lama untuk generate artikel otomatis
- **Tab 2: Kelola Artikel** - Fitur baru untuk CRUD artikel manual
- **Tab 3: Daftar Artikel** - Daftar semua artikel dengan tombol edit/hapus

### 2. Form CRUD Artikel
Admin dapat mengisi:
- **Judul Artikel** - Judul artikel edukasi
- **Deskripsi Singkat** - Informasi singkat tentang artikel
- **URL Website** - Link ke website eksternal (opsional)
- **Kategori** - Trimester 1, 2, atau 3
- **Status Aktif** - Toggle untuk menampilkan/menyembunyikan artikel

### 3. Fitur Pasien
- **Tampilan Artikel** - Artikel ditampilkan seperti sebelumnya
- **Link Website** - Jika artikel memiliki URL, pasien dapat membuka website
- **Fitur Suka & Simpan** - Tetap tersedia seperti sebelumnya

## Cara Penggunaan

### Untuk Admin/Bidan:

1. **Membuat Artikel Baru:**
   - Buka Panel Edukasi Admin
   - Pilih tab "Kelola Artikel"
   - Isi form dengan judul, deskripsi, dan URL website
   - Pilih kategori dan status
   - Klik "Simpan Artikel"

2. **Edit Artikel:**
   - Di tab "Daftar Artikel", klik tombol "Edit"
   - Form akan terisi dengan data artikel yang ada
   - Ubah data yang diperlukan
   - Klik "Simpan Artikel"

3. **Hapus Artikel:**
   - Di tab "Daftar Artikel", klik tombol "Hapus"
   - Konfirmasi penghapusan
   - Artikel akan dihapus dari sistem

### Untuk Pasien:

1. **Melihat Artikel:**
   - Buka halaman Edukasi
   - Artikel ditampilkan dengan deskripsi singkat
   - Jika ada URL website, akan ada indikator link

2. **Membuka Website:**
   - Klik pada artikel yang memiliki URL website
   - Dialog konfirmasi akan muncul
   - Klik "Buka Website" untuk membuka di browser

3. **Fitur Interaksi:**
   - Suka artikel (like)
   - Simpan artikel (bookmark)
   - Filter berdasarkan kategori dan jenis konten

## Struktur Data Artikel

```dart
class Article {
  final String id;
  final String title;
  final String description;        // Deskripsi singkat
  final String websiteUrl;         // Link website eksternal
  final String category;           // Trimester 1/2/3
  final int readTime;              // Waktu baca (menit)
  final int views;                 // Jumlah view
  final bool isActive;             // Status aktif
  final DateTime createdAt;        // Tanggal dibuat
  final bool isLiked;              // Status suka user
  final bool isBookmarked;         // Status simpan user
}
```

## Keuntungan Fitur Baru

1. **Kemudahan Admin:** Bidan dapat membuat artikel dengan mudah tanpa perlu menulis konten panjang
2. **Link Eksternal:** Artikel dapat mengarahkan ke website edukasi yang sudah ada
3. **Fleksibilitas:** Admin dapat mengelola artikel secara manual atau menggunakan generator otomatis
4. **Konsistensi:** Tetap mempertahankan fitur suka dan simpan artikel
5. **Kategorisasi:** Artikel tetap dikelompokkan berdasarkan trimester kehamilan

## Catatan Teknis

- Field `content` lama tetap didukung untuk backward compatibility
- Field baru `description` dan `websiteUrl` ditambahkan
- Service artikel diupdate untuk mendukung field baru
- UI diupdate untuk menampilkan informasi website
- Fitur CRUD lengkap tersedia untuk admin

## Pengembangan Selanjutnya

1. **URL Launcher:** Implementasi package `url_launcher` untuk membuka website langsung
2. **Validasi URL:** Validasi format URL yang lebih baik
3. **Preview Website:** Preview website dalam aplikasi
4. **Analytics:** Tracking klik pada link website
5. **Bulk Operations:** Operasi massal untuk artikel (import/export)
