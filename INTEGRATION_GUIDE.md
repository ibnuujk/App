# Integrasi Pasien-Admin-Firebase Guide

## Overview
Dokumen ini menjelaskan integrasi yang sangat baik antara sistem pasien, admin, dan Firebase untuk aplikasi Persalinanku.

## 1. Struktur Database Firebase

### Collections yang Digunakan:

#### 1.1 Users Collection
```javascript
{
  id: "string",
  email: "string",
  password: "string", 
  nama: "string",
  noHp: "string",
  alamat: "string",
  tanggalLahir: "timestamp",
  umur: "number",
  role: "admin" | "pasien",
  createdAt: "timestamp",
  hpht: "timestamp" // Hari Pertama Haid Terakhir (opsional)
}
```

#### 1.2 Jadwal Konsultasi Collection
```javascript
{
  id: "string",
  pasienId: "string",
  tanggalTemuJanji: "timestamp",
  waktuTemuJanji: "string",
  keluhan: "string",
  alergi: "string",
  status: "pending" | "confirmed" | "completed" | "cancelled",
  createdAt: "timestamp"
}
```

#### 1.3 Pemeriksaan Ibu Hamil Collection
```javascript
{
  id: "string",
  pasienId: "string",
  tanggalPemeriksaan: "timestamp",
  beratBadan: "number",
  tekananDarah: "string",
  denyutNadi: "number",
  tinggiFundus: "number",
  lingkarLengan: "number",
  hemoglobin: "number",
  gulaDarah: "number",
  proteinUrin: "string",
  keluhan: "string",
  diagnosis: "string",
  tindakan: "string",
  createdAt: "timestamp"
}
```

#### 1.4 Chat Collection
```javascript
{
  id: "string",
  senderId: "string",
  senderRole: "admin" | "pasien",
  message: "string",
  timestamp: "timestamp"
}
```

#### 1.5 Darurat Collection
```javascript
{
  id: "string",
  userId: "string",
  tanggalLaporan: "timestamp",
  keluhan: "string",
  lokasi: "string",
  status: "pending" | "processed" | "completed",
  createdAt: "timestamp"
}
```

#### 1.6 Children Collection
```javascript
{
  id: "string",
  userId: "string",
  nama: "string",
  tanggalLahir: "timestamp",
  jenisKelamin: "Laki-laki" | "Perempuan",
  createdAt: "timestamp"
}
```

## 2. Integrasi Pasien-Admin

### 2.1 Flow Registrasi dan Login
1. **Registrasi Pasien**:
   - User mengisi form registrasi
   - Data disimpan ke Firebase Auth dan Firestore
   - Redirect ke HPHT Form untuk input data kehamilan
   - Data HPHT digunakan untuk kalkulasi informasi janin

2. **Login**:
   - Validasi email/password di Firebase Auth
   - Ambil data user dari Firestore berdasarkan email
   - Redirect ke dashboard sesuai role (admin/pasien)

### 2.2 Integrasi Jadwal Konsultasi
- **Pasien**: Membuat temu janji melalui `temu_janji.dart`
- **Admin**: Melihat dan mengelola semua jadwal di `jadwal_konsultasi.dart`
- **Real-time**: Perubahan jadwal langsung terlihat di kedua sisi

### 2.3 Integrasi Pemeriksaan
- **Admin**: Menambah pemeriksaan untuk pasien di `pemeriksaan_ibuhamil.dart`
- **Pasien**: Melihat riwayat pemeriksaan di `riwayat_pemeriksaan.dart`
- **Data**: Terintegrasi dengan data HPHT untuk kalkulasi usia kehamilan

### 2.4 Integrasi Chat
- **Pasien**: Kirim pesan ke admin di `chat_pasien.dart`
- **Admin**: Balas pesan pasien di `chat_admin.dart`
- **Real-time**: Pesan langsung terlihat di kedua sisi

### 2.5 Integrasi Darurat
- **Pasien**: Laporkan kondisi darurat di `darurat.dart`
- **Admin**: Lihat dan proses laporan darurat
- **Status**: Tracking status penanganan darurat

## 3. Firebase Service Methods

### 3.1 Authentication
```dart
// Login
Future<UserCredential?> signInWithEmailAndPassword(String email, String password)

// Register
Future<UserCredential?> createUserWithEmailAndPassword(String email, String password)

// Logout
Future<void> signOut()
```

### 3.2 User Management
```dart
// Create user
Future<void> createUser(UserModel user)

// Get user by ID
Future<UserModel?> getUserById(String userId)

// Get user by email
Future<UserModel?> getUserByEmail(String email)

// Update user
Future<void> updateUser(UserModel user)

// Get all patients (for admin)
Stream<List<UserModel>> getUsersStream()
```

### 3.3 Jadwal Konsultasi
```dart
// Get all schedules (admin)
Stream<List<Map<String, dynamic>>> getJadwalKonsultasiStream()

// Get patient schedules
Stream<List<Map<String, dynamic>>> getJadwalKonsultasiByPasienStream(String pasienId)

// Create schedule
Future<void> createJadwalKonsultasi(Map<String, dynamic> appointmentData)

// Update schedule
Future<void> updateJadwalKonsultasi(Map<String, dynamic> data)

// Delete schedule
Future<void> deleteJadwalKonsultasi(String scheduleId)
```

### 3.4 Pemeriksaan Ibu Hamil
```dart
// Get all examinations (admin)
Stream<List<Map<String, dynamic>>> getPemeriksaanIbuHamilStream()

// Get patient examinations
Stream<List<Map<String, dynamic>>> getRiwayatPemeriksaanStream(String pasienId)

// Create examination
Future<void> createPemeriksaanIbuHamil(Map<String, dynamic> data)

// Update examination
Future<void> updatePemeriksaanIbuHamil(Map<String, dynamic> data)

// Delete examination
Future<void> deletePemeriksaanIbuHamil(String examId)
```

### 3.5 Chat
```dart
// Get all messages
Stream<List<ChatModel>> getChatStream()

// Send message
Future<void> sendMessage(ChatModel message)
```

### 3.6 Darurat
```dart
// Get emergency reports
Stream<List<Map<String, dynamic>>> getDaruratStream(String userId)

// Create emergency report
Future<void> createDarurat(Map<String, dynamic> data)

// Update emergency report
Future<void> updateDarurat(Map<String, dynamic> data)

// Delete emergency report
Future<void> deleteDarurat(String daruratId)
```

### 3.7 Children Management
```dart
// Get children
Stream<List<Map<String, dynamic>>> getChildrenStream(String userId)

// Create child
Future<void> createChild(Map<String, dynamic> data)

// Update child
Future<void> updateChild(Map<String, dynamic> data)

// Delete child
Future<void> deleteChild(String childId)
```

## 4. Navigation dan Routing

### 4.1 Route Constants
```dart
static const String login = '/login';
static const String register = '/register';
static const String hphtForm = '/hpht-form';
static const String homeAdmin = '/home-admin';
static const String homePasien = '/home-pasien';
static const String jadwal = '/jadwal';
static const String profile = '/profile';
// ... dan lainnya
```

### 4.2 Navigation Methods
```dart
// Navigate to home admin
static void navigateToHomeAdmin(BuildContext context, UserModel user)

// Navigate to home pasien
static void navigateToHomePasien(BuildContext context, UserModel user)

// Navigate to jadwal
static void navigateToJadwal(BuildContext context, UserModel user)

// Navigate to profile
static void navigateToProfile(BuildContext context, UserModel user)
```

## 5. Data Flow dan Integrasi

### 5.1 Flow Registrasi Pasien
```
Register Form → Firebase Auth → Firestore Users → HPHT Form → Children Data → Dashboard
```

### 5.2 Flow Temu Janji
```
Pasien: Temu Janji Form → Firebase Jadwal Collection → Admin Dashboard
Admin: Lihat Jadwal → Update Status → Pasien Dashboard
```

### 5.3 Flow Pemeriksaan
```
Admin: Pemeriksaan Form → Firebase Pemeriksaan Collection → Pasien Riwayat
Pasien: Lihat Riwayat → Data terintegrasi dengan HPHT
```

### 5.4 Flow Chat
```
Pasien: Kirim Pesan → Firebase Chat Collection → Admin Chat
Admin: Balas Pesan → Firebase Chat Collection → Pasien Chat
```

## 6. Security Rules

### 6.1 Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all operations for development
    // In production, implement proper authentication
    match /{document=**} {
      allow read, write, create, update, delete: if true;
    }
  }
}
```

## 7. Testing Integrasi

### 7.1 Test Cases
1. **Registrasi Pasien**: Pastikan data tersimpan di Auth dan Firestore
2. **Login**: Pastikan redirect sesuai role
3. **Temu Janji**: Pastikan data terlihat di admin dan pasien
4. **Pemeriksaan**: Pastikan data terintegrasi dengan HPHT
5. **Chat**: Pastikan pesan real-time
6. **Darurat**: Pastikan status tracking berfungsi

### 7.2 Debug Points
- Check Firebase console untuk data
- Monitor network requests
- Verify real-time listeners
- Test offline/online scenarios

## 8. Performance Optimization

### 8.1 Firebase Optimization
- Use indexes for queries
- Implement pagination for large datasets
- Optimize real-time listeners
- Cache frequently accessed data

### 8.2 App Performance
- Lazy loading for screens
- Efficient state management
- Optimize image loading
- Minimize rebuilds

## 9. Error Handling

### 9.1 Common Errors
- Network connectivity issues
- Firebase permission denied
- Invalid data format
- Authentication failures

### 9.2 Error Handling Strategy
- Graceful degradation
- User-friendly error messages
- Retry mechanisms
- Offline support

## 10. Maintenance

### 10.1 Regular Tasks
- Monitor Firebase usage
- Update security rules
- Backup important data
- Performance monitoring

### 10.2 Updates
- Keep Firebase SDK updated
- Monitor for breaking changes
- Test thoroughly before updates
- Maintain backward compatibility 