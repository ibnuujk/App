# Class Diagram Persalinanku - Panduan Konversi

## Deskripsi
Dokumen ini berisi class diagram lengkap untuk aplikasi Flutter **Persalinanku** yang dapat dikonversi ke berbagai format.

## File Diagram

### 1. `class_diagram_persalinanku.puml` - Diagram Lengkap
Diagram lengkap yang mencakup semua kelas, atribut, dan metode dalam aplikasi.

### 2. `class_diagram_simplified.puml` - Diagram Sederhana
Diagram yang fokus pada arsitektur inti dan kelas utama saja.

## Cara Konversi

### A. Menggunakan PlantUML Online
1. Buka [PlantUML Online Server](http://www.plantuml.com/plantuml/uml/)
2. Copy-paste isi file `.puml`
3. Diagram akan otomatis di-render
4. Klik kanan pada diagram → "Save as" untuk download

### B. Menggunakan VS Code Extension
1. Install extension "PlantUML" di VS Code
2. Buka file `.puml`
3. Tekan `Alt+Shift+P` → "PlantUML: Preview Current Diagram"
4. Klik kanan pada preview → "Export Current Diagram"

### C. Menggunakan Command Line
```bash
# Install PlantUML
npm install -g plantuml

# Convert to PNG
plantuml class_diagram_persalinanku.puml

# Convert to SVG
plantuml -tsvg class_diagram_persalinanku.puml

# Convert to PDF
plantuml -tpdf class_diagram_persalinanku.puml
```

### D. Menggunakan IntelliJ IDEA / Android Studio
1. Install plugin "PlantUML integration"
2. Buka file `.puml`
3. Diagram akan otomatis di-render
4. Klik kanan → "Export Diagram"

## Format Output yang Didukung
- **PNG** - Gambar raster, bagus untuk presentasi
- **SVG** - Gambar vektor, bagus untuk web dan scaling
- **PDF** - Dokumen, bagus untuk laporan dan printing
- **EPS** - Format vektor untuk publishing

## Struktur Aplikasi

### Data Models
- **UserModel** - Model untuk user (admin/pasien)
- **PersalinanModel** - Model untuk data persalinan
- **KonsultasiModel** - Model untuk jadwal konsultasi
- **ArticleModel** - Model untuk artikel edukasi

### Core Services
- **FirebaseService** - Layanan utama untuk Firebase operations
- **NotificationService** - Layanan notifikasi
- **PDFService** - Layanan generate PDF

### Admin Screens
- **PemeriksaanIbuHamilScreen** - Screen utama pemeriksaan
- **HomeAdminScreen** - Dashboard admin
- **DataPasienScreen** - Manajemen data pasien

### Patient Screens
- **HomePasienScreen** - Dashboard pasien
- **KehamilankuScreen** - Informasi kehamilan
- **ProfileScreen** - Profil pasien

## Fitur Utama Aplikasi

### Untuk Admin
- Manajemen data pasien ibu hamil
- Pemeriksaan kehamilan
- Registrasi persalinan
- Laporan dan analytics
- Manajemen artikel edukasi
- Chat dengan pasien

### Untuk Pasien
- Monitoring kehamilan
- Jadwal konsultasi
- Chat dengan bidan
- Akses artikel edukasi
- Emergency contact
- Profile management

## Teknologi yang Digunakan
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication)
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Notifications**: Firebase Cloud Messaging
- **PDF Generation**: pdf package
- **Excel Export**: excel package

## Arsitektur
Aplikasi menggunakan arsitektur **MVVM (Model-View-ViewModel)** dengan:
- **Models**: Data classes untuk struktur data
- **Views**: Flutter widgets (screens)
- **ViewModels**: Business logic dalam services
- **Providers**: State management

## Database Schema
- **users**: Data pengguna (admin/pasien)
- **pemeriksaan_ibu_hamil**: Data pemeriksaan kehamilan
- **persalinan**: Data persalinan
- **konsultasi**: Jadwal konsultasi
- **articles**: Artikel edukasi
- **chats**: Riwayat chat
- **notifications**: Notifikasi sistem

## Keamanan
- Firebase Authentication untuk login
- Role-based access control (admin/pasien)
- Firestore security rules
- Data encryption in transit

## Deployment
- **Android**: Google Play Store
- **iOS**: Apple App Store
- **Web**: Firebase Hosting
- **Backend**: Firebase Cloud Functions

## Maintenance
- Regular Firebase security updates
- Flutter SDK updates
- Dependency updates
- Performance monitoring
- User feedback integration

## Kontak
Untuk pertanyaan lebih lanjut tentang class diagram atau aplikasi, silakan hubungi tim development.

---
*Dokumen ini dibuat untuk keperluan dokumentasi dan maintenance aplikasi Persalinanku*
