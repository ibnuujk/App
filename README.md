# Persalinanku - Sistem Informasi Persalinan

Aplikasi mobile untuk mengelola data persalinan dan konsultasi antara pasien dan dokter/admin.

## Deskripsi

Persalinanku adalah aplikasi Flutter yang terintegrasi dengan Firebase untuk mengelola sistem informasi persalinan. Aplikasi ini memiliki dua role pengguna:

### Admin
- Mengelola data pasien (CRUD)
- Melihat dan menjawab konsultasi pasien
- Mengelola laporan persalinan
- Chat dengan pasien

### Pasien
- Melihat rekam medis pribadi
- Mengajukan konsultasi
- Chat dengan dokter/admin
- Melihat riwayat persalinan

## Fitur Utama

### 🔐 Sistem Autentikasi
- Login dengan username dan password
- Registrasi pasien baru
- Role-based access control (Admin/Pasien)

### 👥 Manajemen Pasien
- Tambah, edit, hapus data pasien
- Pencarian dan filter data pasien
- Informasi lengkap pasien (nama, umur, alamat, dll)

### 💬 Sistem Konsultasi
- Pasien dapat mengajukan pertanyaan
- Admin dapat menjawab konsultasi
- Status konsultasi (pending/answered)
- Riwayat konsultasi

### 📋 Laporan Persalinan
- Input data persalinan lengkap
- Informasi medis detail
- Riwayat persalinan pasien
- Export dan laporan

### 💭 Chat Real-time
- Chat langsung antara admin dan pasien
- Interface mirip WhatsApp
- Notifikasi pesan baru
- Riwayat chat

## Teknologi yang Digunakan

### Frontend
- **Flutter** - Framework mobile development
- **Google Fonts** - Typography
- **Provider** - State management

### Backend
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.4.3
  firebase_storage: ^12.3.3
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.4.1
  provider: ^6.1.2
  intl: ^0.19.0
  image_picker: ^1.1.2
  file_picker: ^7.0.0
  uuid: ^4.5.1
  shared_preferences: ^2.3.2
```

## Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   ├── user_model.dart
│   ├── konsultasi_model.dart
│   ├── persalinan_model.dart
│   └── chat_model.dart
├── services/                 # Business logic
│   └── firebase_service.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── register.dart
│   ├── admin/               # Admin screens
│   │   ├── home_admin.dart
│   │   ├── data_pasien.dart
│   │   ├── data_konsultasi_pasien.dart
│   │   ├── laporan_persalinan.dart
│   │   └── chat_admin.dart
│   └── pasien/              # Patient screens
│       ├── home_pasien.dart
│       ├── rekam_medis.dart
│       ├── konsultasi_pasien.dart
│       └── chat_pasien.dart
└── utilities/               # Utilities
    └── firebase_option.dart
```

## Instalasi dan Setup

### Prerequisites
- Flutter SDK (versi terbaru)
- Android Studio / VS Code
- Firebase project

### Langkah Instalasi

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd persalinanku
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Buat project Firebase baru
   - Aktifkan Authentication, Firestore, dan Storage
   - Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
   - Place file konfigurasi di folder yang sesuai

4. **Update Firebase configuration**
   - Edit `lib/utilities/firebase_option.dart`
   - Sesuaikan dengan project Firebase Anda

5. **Run aplikasi**
   ```bash
   flutter run
   ```

## Konfigurasi Firebase

### Firestore Collections

#### users
```json
{
  "id": "string",
  "username": "string",
  "password": "string",
  "nama": "string",
  "noHp": "string",
  "alamat": "string",
  "tanggalLahir": "timestamp",
  "umur": "number",
  "role": "string", // "admin" atau "pasien"
  "createdAt": "timestamp"
}
```

#### konsultasi
```json
{
  "id": "string",
  "pasienId": "string",
  "pasienNama": "string",
  "pertanyaan": "string",
  "jawaban": "string?",
  "status": "string", // "pending" atau "answered"
  "tanggalKonsultasi": "timestamp",
  "tanggalJawaban": "timestamp?"
}
```

#### persalinan
```json
{
  "id": "string",
  "pasienId": "string",
  "pasienNama": "string",
  "pasienNoHp": "string",
  "pasienUmur": "number",
  "pasienAlamat": "string",
  "namaSuami": "string",
  "pekerjaan": "string",
  "tanggalMasuk": "timestamp",
  "fasilitas": "string", // "umum" atau "bpjs"
  "tanggalPartes": "timestamp",
  "tanggalKeluar": "timestamp",
  "diagnosaKebidanan": "string",
  "tindakan": "string",
  "rujukan": "string?",
  "penolongPersalinan": "string",
  "createdAt": "timestamp"
}
```

#### chats
```json
{
  "id": "string",
  "senderId": "string",
  "senderName": "string",
  "senderRole": "string", // "admin" atau "pasien"
  "message": "string",
  "timestamp": "timestamp",
  "isRead": "boolean"
}
```

## Penggunaan

### Login Admin
- Username: `adminku@gmail.com`
- Password: `Admin123#`

### Registrasi Pasien
1. Klik "Daftar Sekarang" di halaman login
2. Isi form registrasi dengan lengkap
3. Klik "DAFTAR" untuk menyelesaikan registrasi

### Fitur Admin
- **Dashboard**: Overview statistik dan quick actions
- **Data Pasien**: Kelola data pasien (CRUD)
- **Konsultasi**: Lihat dan jawab pertanyaan pasien
- **Laporan**: Kelola laporan persalinan
- **Chat**: Komunikasi langsung dengan pasien

### Fitur Pasien
- **Dashboard**: Informasi pribadi dan layanan tersedia
- **Rekam Medis**: Lihat riwayat pemeriksaan
- **Konsultasi**: Ajukan pertanyaan ke dokter
- **Chat**: Komunikasi langsung dengan dokter

## Screenshots

### Login Screen
- Clean white background
- Red illustration
- Modern form design
- Teal login button

### Admin Dashboard
- Welcome section with gradient
- Quick stats cards
- Action buttons grid
- Bottom navigation

### Patient Dashboard
- Personal information card
- Available services grid
- Profile management
- Medical records access

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

Untuk dukungan teknis atau pertanyaan, silakan hubungi:
- Email: support@persalinanku.com
- Documentation: [docs.persalinanku.com](https://docs.persalinanku.com)

## Changelog

### Version 1.0.0
- Initial release
- Basic authentication system
- Patient and admin dashboards
- Consultation system
- Chat functionality
- Medical records management
