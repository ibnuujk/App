# ANALISIS KODE PROGRAM PERSALINANKU - LENGKAP

## 📋 DAFTAR ISI
1. [Struktur Aplikasi](#struktur-aplikasi)
2. [Arsitektur & Pola Desain](#arsitektur--pola-desain)
3. [Navigasi](#navigasi)
4. [Logika Kondisional](#logika-kondisional)
5. [Model Data](#model-data)
6. [Layanan (Services)](#layanan-services)
7. [Alur Autentikasi](#alur-autentikasi)
8. [Fitur Utama](#fitur-utama)

---

## 🏗️ STRUKTUR APLIKASI

### Hierarki Direktori
```
lib/
├── main.dart                    # Entry point aplikasi
├── firebase_options.dart        # Konfigurasi Firebase
├── admin/                       # Modul Admin/Bidan (16 files)
│   ├── home_admin.dart
│   ├── data_pasien.dart
│   ├── registrasi_persalinan.dart
│   ├── data_persalinan.dart
│   ├── chat_admin.dart
│   ├── pemeriksaan_ibuhamil.dart
│   ├── jadwal_konsultasi.dart
│   ├── analytics_screen.dart
│   ├── panel_edukasi.dart
│   ├── patient_pregnancy_management.dart
│   ├── laporan_persalinan.dart
│   ├── laporan_pasca_persalinan.dart
│   ├── keterangan_kelahiran.dart
│   └── ...
├── pasien/                      # Modul Pasien (10 files)
│   ├── home_pasien.dart
│   ├── kehamilanku.dart
│   ├── pemeriksaan.dart
│   ├── profile.dart
│   ├── konsultasi_pasien.dart
│   ├── chat_pasien.dart
│   ├── temu_janji.dart
│   ├── edukasi.dart
│   ├── jadwal_pasien.dart
│   └── emergency_screen.dart
├── screens/                     # Screen Umum (9 files)
│   ├── login_screen.dart
│   ├── register.dart
│   ├── forgot_password_screen.dart
│   ├── hpht_form.dart
│   ├── notification_screen.dart
│   ├── education_main_screen.dart
│   ├── article_list_screen.dart
│   ├── article_detail_screen.dart
│   └── article_admin_screen.dart
├── models/                      # Data Models (11 files)
│   ├── user_model.dart
│   ├── konsultasi_model.dart
│   ├── persalinan_model.dart
│   ├── chat_model.dart
│   ├── laporan_persalinan_model.dart
│   ├── laporan_pasca_persalinan_model.dart
│   ├── keterangan_kelahiran_model.dart
│   ├── notification_model.dart
│   ├── article_model.dart
│   ├── analytics_model.dart
│   └── emergency_contact_model.dart
├── services/                    # Business Logic Services (8 files)
│   ├── firebase_service.dart    # CRUD operations ke Firestore
│   ├── notification_service.dart
│   ├── notification_integration_service.dart
│   ├── notification_listener_service.dart
│   ├── article_service.dart
│   ├── analytics_service.dart
│   ├── emergency_service.dart
│   └── pdf_service.dart
├── routes/                      # Routing & Navigation
│   └── route_helper.dart        # Centralized routing
├── providers/                   # State Management
│   └── article_provider.dart    # Provider untuk artikel
├── utilities/                   # Helper Functions
│   ├── pregnancy_calculator.dart # Kalkulasi kehamilan
│   └── safe_navigation.dart     # Safe navigation helper
└── widgets/                     # Reusable Widgets (5 files)
    ├── article_card.dart
    ├── category_chips.dart
    ├── notification_badge.dart
    ├── simple_notification_badge.dart
    └── search_bar.dart
```

---

## 🏛️ ARSITEKTUR & POLA DESAIN

### 1. **Arsitektur Aplikasi**
- **Pattern**: MVC (Model-View-Controller) dengan Service Layer
- **State Management**: Provider (untuk artikel) + setState lokal
- **Backend**: Firebase (Firestore, Auth, Storage, Messaging)
- **Platform**: Flutter (Multi-platform: Android, iOS, Web)

### 2. **Pola Desain yang Digunakan**
- **Service Pattern**: Semua operasi database melalui `FirebaseService`
- **Repository Pattern**: Models dengan `fromMap()` dan `toMap()`
- **Singleton Pattern**: Services menggunakan instance tunggal
- **Factory Pattern**: Model creation melalui factory constructors
- **Observer Pattern**: Stream-based real-time updates

### 3. **Dependency Management**
```yaml
# Dependencies Utama:
- firebase_core, firebase_auth, cloud_firestore
- provider (state management)
- google_fonts (typography)
- intl (internationalization)
- table_calendar (calendar widget)
- fl_chart (charts & analytics)
- pdf (PDF generation)
- firebase_messaging, flutter_local_notifications
```

---

## 🧭 NAVIGASI

### 1. **Sistem Routing**
**File**: `lib/routes/route_helper.dart`

#### Routing Strategy:
- **Named Routes**: Menggunakan `MaterialPageRoute` dengan named routes
- **Route Constants**: Semua route didefinisikan sebagai static constants
- **Argument Passing**: Menggunakan `settings.arguments` untuk passing data

#### Route Definitions:
```dart
// Authentication Routes
static const String login = '/login';
static const String register = '/register';
static const String forgotPassword = '/forgot-password';
static const String hphtForm = '/hpht-form';

// Admin Routes
static const String homeAdmin = '/home-admin';
static const String dataPasien = '/data-pasien';
static const String registrasiPersalinan = '/registrasi-persalinan';
static const String dataKonsultasi = '/data-konsultasi';
static const String chatAdmin = '/chat-admin';
static const String pemeriksaanIbuHamil = '/pemeriksaan-ibuhamil';
static const String jadwalKonsultasi = '/jadwal-konsultasi';
static const String analytics = '/analytics';
static const String panelEdukasi = '/panel-edukasi';

// Pasien Routes
static const String homePasien = '/home-pasien';
static const String kehamilanku = '/kehamilanku';
static const String pemeriksaan = '/pemeriksaan';
static const String darurat = '/darurat';
static const String konsultasiPasien = '/konsultasi-pasien';
static const String chatPasien = '/chat-pasien';
static const String profile = '/profile';
static const String temuJanji = '/temu-janji';
static const String edukasi = '/edukasi';
static const String jadwalPasien = '/jadwal-pasien';
```

### 2. **Navigation Methods**

#### A. **Push Navigation** (Stack-based)
```dart
// Navigate dengan menambah ke stack
RouteHelper.navigateToRegister(context);
RouteHelper.navigateToEdukasi(context, user);
```

#### B. **Replace Navigation** (Ganti current route)
```dart
// Ganti route saat ini
RouteHelper.replaceToHomeAdmin(context, user);
RouteHelper.replaceToHomePasien(context, user);
```

#### C. **Clear Stack Navigation** (Login setelah auth)
```dart
// Hapus semua route sebelumnya, set sebagai root
RouteHelper.navigateToHomeAdmin(context, user);
// Menggunakan: Navigator.pushNamedAndRemoveUntil(..., (route) => false)
```

#### D. **Back Navigation**
```dart
RouteHelper.goBack(context);           // Pop satu route
RouteHelper.goBackToRoot(context);    // Pop sampai root
```

### 3. **Bottom Navigation Bar**

#### Admin Navigation (5 tabs):
```dart
IndexedStack(
  index: _selectedIndex,
  children: [
    Dashboard,      // Index 0
    DataPasien,     // Index 1
    Registrasi,     // Index 2
    Laporan,        // Index 3
    Chat,           // Index 4
  ],
)
```

#### Pasien Navigation (3 tabs):
```dart
IndexedStack(
  index: _selectedIndex,
  children: [
    Dashboard,       // Index 0
    Jadwal,         // Index 1
    Profile,        // Index 2
  ],
)
```

### 4. **Conditional Navigation Berdasarkan Role**

**File**: `lib/screens/login_screen.dart`

```dart
// Setelah login berhasil
if (user.role == 'admin') {
  RouteHelper.navigateToHomeAdmin(context, user);
} else {
  RouteHelper.navigateToHomePasien(context, user);
}
```

---

## 🔀 LOGIKA KONDISIONAL

### 1. **Role-Based Access Control**

#### A. **Autentikasi & Authorization**
```dart
// Login Screen - Role checking
if (user.role == 'admin') {
  // Navigate ke admin dashboard
} else if (user.role == 'pasien') {
  // Navigate ke pasien dashboard
}
```

#### B. **Firestore Security Rules**
```javascript
// firestore.rules
match /notifications/{notificationId} {
  allow read: if isAuthenticated() && 
    (resource.data.receiverId == request.auth.uid || 
     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
}
```

### 2. **Pregnancy Status Conditionals**

#### A. **Status Kehamilan**
```dart
// UserModel memiliki field:
pregnancyStatus: 'active' | 'miscarriage' | 'complication' | 'completed'

// Conditional rendering berdasarkan status
if (widget.user.pregnancyStatus == 'miscarriage') {
  // Tampilkan UI untuk keguguran
} else if (widget.user.hpht != null) {
  // Tampilkan informasi kehamilan aktif
} else {
  // Tampilkan form untuk input HPHT
}
```

#### B. **HPHT Validation**
```dart
// home_pasien.dart
if (widget.user.hpht != null) {
  final difference = now.difference(hpht);
  
  if (difference.inDays < 0) {
    // HPHT di masa depan - belum hamil
    _gestationalAgeWeeks = 0;
  } else {
    // Hitung usia kehamilan
    _gestationalAgeWeeks = difference.inDays ~/ 7;
  }
} else {
  // Tidak ada HPHT - tampilkan form input
}
```

### 3. **Trimester Calculation**

**File**: `lib/utilities/pregnancy_calculator.dart`

```dart
static String getTrimester(int weeks) {
  if (weeks < 13) {
    return 'Trimester 1';
  } else if (weeks < 27) {
    return 'Trimester 2';
  } else {
    return 'Trimester 3';
  }
}
```

### 4. **Fetal Size Comparison (Chain of If-Else)**

**File**: `lib/pasien/home_pasien.dart` & `lib/utilities/pregnancy_calculator.dart`

```dart
String _getFetalSizeComparison(int weeks) {
  if (weeks < 4) return 'Seukuran biji poppy';
  if (weeks < 5) return 'Seukuran biji wijen';
  if (weeks < 6) return 'Seukuran biji delima';
  // ... hingga 40 minggu
  if (weeks < 39) return 'Seukuran semangka mini';
  return 'Seukuran semangka';
}
```

### 5. **Switch Statements**

#### A. **Notification Status**
```dart
// notification_service.dart
switch (status) {
  case 'accepted':
    statusText = 'Diterima';
    break;
  case 'rejected':
    statusText = 'Ditolak';
    break;
  case 'completed':
    statusText = 'Selesai';
    break;
  default:
    statusText = status;
}
```

#### B. **Nutrition Tips by Trimester**
```dart
// pregnancy_calculator.dart
static List<String> getNutritionTips(String trimester) {
  switch (trimester) {
    case 'Trimester 1':
      return [/* tips untuk trimester 1 */];
    case 'Trimester 2':
      return [/* tips untuk trimester 2 */];
    case 'Trimester 3':
      return [/* tips untuk trimester 3 */];
    default:
      return [/* tips umum */];
  }
}
```

### 6. **Null Safety & Optional Chaining**

#### A. **Null Checks**
```dart
// Safe navigation dengan null checks
if (user.hpht != null) {
  // Process HPHT data
} else {
  // Show HPHT input form
}

// Null-aware operators
final hpht = user.hpht ?? DateTime.now();
final status = user.pregnancyStatus ?? 'active';
```

#### B. **Optional Parameters**
```dart
// UserModel dengan optional fields
final DateTime? hpht;
final String? pregnancyStatus;
final DateTime? pregnancyEndDate;
final String? pregnancyEndReason;
```

### 7. **Error Handling Conditionals**

#### A. **Try-Catch dengan Fallback**
```dart
// firebase_service.dart
try {
  // Try primary method
  return await _firestore.collection('users')
    .orderBy('createdAt', descending: true)
    .get();
} catch (e) {
  // Fallback jika index tidak ada
  return await _firestore.collection('users')
    .where('role', isEqualTo: 'pasien')
    .get();
}
```

#### B. **Connection Checks**
```dart
// firebase_service.dart
Future<bool> checkFirebaseConnection() async {
  try {
    await _firestore.collection('users')
      .limit(1)
      .get()
      .timeout(const Duration(seconds: 5));
    return true;
  } catch (e) {
    return false;
  }
}
```

### 8. **Data Validation Conditionals**

#### A. **Form Validation**
```dart
// login_screen.dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Email tidak boleh kosong';
  }
  // Email format validation
  if (!value.contains('@')) {
    return 'Format email tidak valid';
  }
  return null;
}
```

#### B. **Duplicate Check**
```dart
// firebase_service.dart - createJadwalKonsultasi
final existingAppointments = await _firestore
  .collection('jadwal_konsultasi')
  .where('pasienId', isEqualTo: data['pasienId'])
  .where('tanggalKonsultasi', isGreaterThanOrEqualTo: startOfDay)
  .get();

if (existingAppointments.docs.isNotEmpty) {
  throw Exception('Sudah ada janji temu pada tanggal yang sama');
}
```

### 9. **UI Conditional Rendering**

#### A. **Conditional Widgets dengan Spread Operator**
```dart
// home_pasien.dart
if (widget.user.hpht != null && 
    _gestationalAgeWeeks != null &&
    widget.user.pregnancyStatus != 'miscarriage') ...[
  // Show fetal information
  _buildFetalInfoColumn(...),
] else ...[
  // Show HPHT input prompt
  Container(/* HPHT form prompt */),
]
```

#### B. **Ternary Operators untuk Styling**
```dart
// home_admin.dart - Navigation item
color: isSelected ? Colors.white : Colors.grey[600],
fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
```

### 10. **Stream Error Handling**

```dart
// firebase_service.dart
.snapshots()
.map((snapshot) => /* transform data */)
.handleError((error) {
  print('Error in stream: $error');
  return <Model>[]; // Return empty list on error
})
.timeout(const Duration(seconds: 20))
```

---

## 📊 MODEL DATA

### 1. **UserModel** - Model Utama
```dart
class UserModel {
  final String id;
  final String email;
  final String password;
  final String nama;
  final String noHp;
  final String alamat;
  final DateTime tanggalLahir;
  final int umur;
  final String role; // 'admin' | 'pasien'
  
  // Pregnancy fields
  final DateTime? hpht;
  final String? pregnancyStatus; // 'active' | 'miscarriage' | 'complication' | 'completed'
  final DateTime? pregnancyEndDate;
  final String? pregnancyEndReason;
  final String? pregnancyNotes;
  final DateTime? newHpht;
  final List<Map<String, dynamic>> pregnancyHistory;
  
  // Spouse information
  final String? namaSuami;
  final String? pekerjaanSuami;
  final int? umurSuami;
  final String? agamaSuami;
  
  // Patient information
  final String? agamaPasien;
  final String? pekerjaanPasien;
  final String? jenisAsuransi; // 'bpjs' | 'umum'
}
```

### 2. **KonsultasiModel**
- Pertanyaan pasien
- Jawaban admin
- Status: pending/answered
- Timestamp

### 3. **PersalinanModel**
- Data registrasi persalinan
- Informasi ibu
- Informasi bayi
- Timestamp

### 4. **ChatModel**
- Sender & receiver info
- Message content
- Timestamp
- isRead status
- conversationId

### 5. **Laporan Models**
- `LaporanPersalinanModel`
- `LaporanPascaPersalinanModel`
- `KeteranganKelahiranModel`

---

## 🔧 LAYANAN (SERVICES)

### 1. **FirebaseService** - Core Service
**File**: `lib/services/firebase_service.dart`

#### Fungsi Utama:
- **Authentication**: Login, Register, Logout, Password Reset
- **User Management**: CRUD operations untuk users
- **Consultation Management**: Konsultasi CRUD
- **Chat Management**: Real-time chat dengan Firestore streams
- **Pregnancy Management**: HPHT, status, history
- **Schedule Management**: Jadwal konsultasi
- **Article Management**: Like, bookmark, interactions
- **Offline Persistence**: Enable offline mode

#### Pattern yang Digunakan:
```dart
// Stream-based real-time updates
Stream<List<Model>> getModelStream() {
  return _firestore.collection('collection')
    .orderBy('field', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => Model.fromMap(doc.data())).toList())
    .handleError((error) => <Model>[]);
}

// Error handling dengan fallback
try {
  // Primary query dengan orderBy
} catch (e) {
  // Fallback query tanpa orderBy
}
```

### 2. **NotificationService**
- Local notifications
- Firestore notification storage
- Unread count tracking
- Notification channels (chat, schedule, general)

### 3. **PregnancyCalculator**
- Gestational age calculation
- Due date calculation
- Trimester determination
- Fetal size comparison
- Nutrition tips by trimester

---

## 🔐 ALUR AUTENTIKASI

### 1. **Login Flow**

```
User Input (Email + Password)
    ↓
Firebase Auth Authentication
    ↓
    ├─ Success → Get User from Firestore
    │              ↓
    │         Check User Role
    │              ↓
    │         ├─ admin → Navigate to HomeAdmin
    │         └─ pasien → Navigate to HomePasien
    │
    └─ Failed → Fallback: Direct Firestore Auth
                  ↓
              Check Password Match
                  ↓
              Navigate based on Role
```

### 2. **Authentication Methods**

#### A. **Primary Method**: Firebase Auth
```dart
UserCredential? userCredential = await _firebaseService
  .signInWithEmailAndPassword(email, password);
```

#### B. **Fallback Method**: Direct Firestore
```dart
UserModel? user = await _firebaseService.getUserByEmail(email);
if (user != null && user.password == password) {
  // Login successful
}
```

### 3. **Session Management**
- Firebase Auth handles session automatically
- `ensureAuthenticated()` method checks auth status
- Auto-logout on auth failure

---

## 🎯 FITUR UTAMA

### 1. **Admin Features**
- ✅ Dashboard dengan statistik
- ✅ Data Pasien Management
- ✅ Registrasi Persalinan
- ✅ Laporan Persalinan & Pasca Persalinan
- ✅ Keterangan Kelahiran
- ✅ Chat dengan Pasien
- ✅ Pemeriksaan Ibu Hamil
- ✅ Jadwal Konsultasi Management
- ✅ Analytics & Reporting
- ✅ Panel Edukasi (Article Management)

### 2. **Pasien Features**
- ✅ Dashboard dengan informasi kehamilan
- ✅ Kehamilanku (Pregnancy tracking)
- ✅ Riwayat Pemeriksaan
- ✅ Temu Janji (Appointment booking)
- ✅ Chat dengan Bidan
- ✅ Edukasi (Article reading)
- ✅ Emergency Contact
- ✅ Profile Management
- ✅ Jadwal Pasien (Schedule view)

### 3. **Shared Features**
- ✅ Real-time Notifications
- ✅ Article System (Like, Bookmark)
- ✅ Search & Filter
- ✅ Offline Support (Firestore persistence)
- ✅ PDF Generation
- ✅ Calendar Integration

---

## 📝 KESIMPULAN

### **Kekuatan Aplikasi:**
1. ✅ **Struktur yang Terorganisir**: Pemisahan modul admin/pasien yang jelas
2. ✅ **Real-time Updates**: Stream-based untuk data dinamis
3. ✅ **Error Handling**: Comprehensive error handling dengan fallback
4. ✅ **Role-based Access**: Implementasi yang baik untuk admin/pasien
5. ✅ **Offline Support**: Firestore persistence enabled
6. ✅ **Scalable Architecture**: Service layer pattern memudahkan maintenance

### **Area untuk Improvement:**
1. ⚠️ **State Management**: Bisa dipertimbangkan menggunakan Provider/Bloc lebih luas
2. ⚠️ **Error Messages**: Bisa lebih user-friendly
3. ⚠️ **Code Duplication**: Beberapa logic duplikat (fetal size calculation)
4. ⚠️ **Testing**: Belum terlihat unit tests
5. ⚠️ **Documentation**: Bisa ditambahkan lebih banyak inline comments

### **Pattern yang Konsisten:**
- ✅ Model dengan `fromMap()` dan `toMap()`
- ✅ Service layer untuk semua database operations
- ✅ Named routes untuk navigation
- ✅ Stream-based real-time data
- ✅ Null safety dengan proper checks
- ✅ Conditional rendering berdasarkan role dan status

---

**Dokumen ini dibuat berdasarkan analisis menyeluruh terhadap kode program Persalinanku.**
**Tanggal**: $(date)
**Versi Aplikasi**: 1.0.0+1

