# Firebase Integration Documentation

## Overview

This document describes the improved Firebase integration for the maternal health application, including authentication, Firestore database operations, security rules, and best practices.

## 🔐 Authentication

### User Authentication Flow

```dart
// Sign in with email and password
Future<UserCredential?> signInWithEmailAndPassword(String email, String password)

// Create new user account
Future<UserCredential?> createUserWithEmailAndPassword(String email, String password)

// Sign out
Future<void> signOut()

// Check authentication status
bool get isAuthenticated
User? get currentUser
String? get currentUserId
```

### Authentication Best Practices

1. **Always check authentication before operations**
   ```dart
   await ensureAuthenticated();
   ```

2. **Handle authentication errors gracefully**
   ```dart
   try {
     await signInWithEmailAndPassword(email, password);
   } catch (e) {
     // Handle specific Firebase Auth errors
     if (e is FirebaseAuthException) {
       switch (e.code) {
         case 'user-not-found':
           // Handle user not found
           break;
         case 'wrong-password':
           // Handle wrong password
           break;
       }
     }
   }
   ```

## 📊 Firestore Collections

### 1. Users Collection (`users`)
- **Purpose**: Store user profiles and authentication data
- **Access**: Users can read/update their own data, admins can access all
- **Fields**:
  - `id`: Unique user ID
  - `email`: User email
  - `nama`: Full name
  - `noHp`: Phone number
  - `alamat`: Address
  - `tanggalLahir`: Birth date
  - `umur`: Age
  - `role`: User role ('admin' or 'pasien')
  - `createdAt`: Account creation timestamp

### 2. Konsultasi Collection (`konsultasi`)
- **Purpose**: Store consultation requests and responses
- **Access**: Patients can create/read their own, admins can manage all
- **Fields**:
  - `id`: Unique consultation ID
  - `pasienId`: Patient user ID
  - `pasienNama`: Patient name
  - `pertanyaan`: Patient question
  - `jawaban`: Admin response
  - `status`: Status ('pending' or 'answered')
  - `tanggalKonsultasi`: Consultation date
  - `createdAt`: Creation timestamp

### 3. Persalinan Collection (`persalinan`)
- **Purpose**: Store childbirth reports
- **Access**: Patients can create/read their own, admins can manage all
- **Fields**:
  - `id`: Unique report ID
  - `pasienId`: Patient user ID
  - `namaSuami`: Husband's name
  - `pekerjaan`: Occupation
  - `tanggalMasuk`: Admission date
  - `tanggalPartes`: Birth date
  - `tanggalKeluar`: Discharge date
  - `diagnosaKebidanan`: Diagnosis
  - `tindakan`: Medical actions taken
  - `penolongPersalinan`: Birth assistant
  - `createdAt`: Creation timestamp

### 4. Chats Collection (`chats`)
- **Purpose**: Store chat messages between patients and admin
- **Access**: Users can read messages they sent/received
- **Fields**:
  - `id`: Unique message ID
  - `senderId`: Sender user ID
  - `senderName`: Sender name
  - `senderRole`: Sender role ('admin' or 'pasien')
  - `message`: Message content
  - `timestamp`: Message timestamp
  - `isRead`: Read status
  - `conversationId`: Conversation identifier
  - `recipientId`: Recipient user ID

### 5. Kehamilanku Collection (`kehamilanku`)
- **Purpose**: Store pregnancy tracking data
- **Access**: Patients can manage their own data
- **Fields**:
  - `id`: Unique record ID
  - `pasienId`: Patient user ID
  - `tanggalPemeriksaan`: Examination date
  - `usiaKehamilan`: Pregnancy age in weeks
  - `beratBadan`: Weight
  - `tekananDarah`: Blood pressure
  - `catatan`: Notes
  - `createdAt`: Creation timestamp

### 6. Pemeriksaan Ibu Hamil Collection (`pemeriksaan_ibuhamil`)
- **Purpose**: Store detailed pregnancy examinations
- **Access**: Admin only (create, read, update, delete)
- **Fields**:
  - `id`: Unique examination ID
  - `pasienId`: Patient user ID
  - `tanggalPemeriksaan`: Examination date
  - `usiaKehamilan`: Pregnancy age
  - `beratBadan`: Weight
  - `tekananDarah`: Blood pressure
  - `tinggiBadan`: Height
  - `lingkarLengan`: Arm circumference
  - `hemoglobin`: Hemoglobin level
  - `proteinUrin`: Protein in urine
  - `gulaDarah`: Blood sugar
  - `statusGizi`: Nutritional status
  - `keluhan`: Complaints
  - `diagnosa`: Diagnosis
  - `tindakan`: Medical actions
  - `namaBidan`: Midwife name
  - `screeningQuestions`: Screening questionnaire
  - `createdAt`: Creation timestamp

### 7. Jadwal Konsultasi Collection (`jadwal_konsultasi`)
- **Purpose**: Store consultation schedules
- **Access**: Admin only (create, read, update, delete)
- **Fields**:
  - `id`: Unique schedule ID
  - `pasienId`: Patient user ID
  - `namaPasien`: Patient name
  - `tanggalKonsultasi`: Consultation date
  - `waktuKonsultasi`: Consultation time
  - `jenisKonsultasi`: Consultation type
  - `dokter`: Doctor name
  - `catatan`: Notes
  - `status`: Status
  - `createdAt`: Creation timestamp

### 8. Darurat Collection (`darurat`)
- **Purpose**: Store emergency reports
- **Access**: Users can manage their own reports
- **Fields**:
  - `id`: Unique report ID
  - `userId`: User ID
  - `jenisDarurat`: Emergency type
  - `deskripsi`: Description
  - `lokasi`: Location
  - `tanggalLaporan`: Report date
  - `status`: Status
  - `createdAt`: Creation timestamp

### 9. Children Collection (`children`)
- **Purpose**: Store child information
- **Access**: Users can manage their own children data
- **Fields**:
  - `id`: Unique child ID
  - `userId`: Parent user ID
  - `nama`: Child name
  - `tanggalLahir`: Birth date
  - `jenisKelamin`: Gender
  - `beratLahir`: Birth weight
  - `panjangLahir`: Birth length
  - `hpht`: First day of last menstrual period
  - `createdAt`: Creation timestamp

## 🔒 Security Rules

### Overview
Firestore security rules ensure that:
- Only authenticated users can access data
- Users can only access their own data
- Admins have broader access for management purposes
- Data integrity is maintained

### Key Security Functions

```javascript
// Check if user is authenticated
function isAuthenticated() {
  return request.auth != null;
}

// Check if user is admin
function isAdmin() {
  return isAuthenticated() && 
    exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

// Check if user owns the data
function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}
```

### Collection-Specific Rules

1. **Users**: Users can read/update their own data, admins can manage all
2. **Konsultasi**: Patients can create/read their own, admins can manage all
3. **Persalinan**: Patients can create/read their own, admins can manage all
4. **Chats**: Users can read messages they sent/received
5. **Kehamilanku**: Patients can manage their own data
6. **Pemeriksaan Ibu Hamil**: Admin only access
7. **Jadwal Konsultasi**: Admin only access
8. **Darurat**: Users can manage their own reports
9. **Children**: Users can manage their own children data

## 🛠️ Error Handling

### Comprehensive Error Handling

```dart
try {
  await firebaseService.createUser(user);
} catch (e) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        // Handle permission error
        break;
      case 'not-found':
        // Handle not found error
        break;
      case 'already-exists':
        // Handle duplicate error
        break;
      default:
        // Handle other Firebase errors
        break;
    }
  } else {
    // Handle other errors
  }
}
```

### Stream Error Handling

```dart
Stream<List<UserModel>> getUsersStream() {
  return _firestore
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList())
      .handleError((error) {
        print('Error in getUsersStream: $error');
        return <UserModel>[];
      });
}
```

## 📈 Performance Optimization

### 1. Offline Persistence
```dart
Future<void> enableOfflinePersistence() async {
  try {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    print('Error enabling offline persistence: $e');
  }
}
```

### 2. Query Optimization
- Use `limit()` to restrict result size
- Use `orderBy()` with indexes
- Use `where()` clauses efficiently
- Implement pagination for large datasets

### 3. Batch Operations
```dart
Future<void> markMessagesAsRead(String conversationId) async {
  final batch = _firestore.batch();
  // Add multiple operations to batch
  await batch.commit();
}
```

## 🔍 Monitoring and Debugging

### Health Check
```dart
Future<bool> checkFirebaseConnection() async {
  try {
    await _firestore.collection('health_check').doc('test').get();
    return true;
  } catch (e) {
    print('Firebase connection error: $e');
    return false;
  }
}
```

### Debug Methods
```dart
// Create test user for debugging
Future<void> createTestUser() async

// List all users for debugging
Future<void> listAllUsers() async

// Clear cache for debugging
Future<void> clearCache() async
```

## 🚀 Best Practices

### 1. Authentication
- Always check authentication before operations
- Handle authentication errors gracefully
- Implement proper sign-out functionality

### 2. Data Operations
- Use batch operations for multiple writes
- Implement proper error handling
- Use transactions for critical operations
- Validate data before writing

### 3. Security
- Follow principle of least privilege
- Validate user permissions
- Use security rules effectively
- Sanitize user inputs

### 4. Performance
- Enable offline persistence
- Use efficient queries
- Implement pagination
- Monitor query performance

### 5. Error Handling
- Catch and handle specific Firebase errors
- Provide meaningful error messages
- Implement retry mechanisms
- Log errors for debugging

## 📱 Integration with Flutter

### Service Initialization
```dart
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
}
```

### Usage in Widgets
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Use Firebase service methods
    } catch (e) {
      // Handle errors
    }
  }
}
```

## 🔧 Configuration

### Firebase Configuration Files
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- `firestore.rules` (Security rules)

### Environment Setup
1. Initialize Firebase in your app
2. Configure authentication providers
3. Set up Firestore database
4. Deploy security rules
5. Test all operations

## 📋 Checklist for Production

- [ ] Security rules deployed and tested
- [ ] Authentication flow tested
- [ ] Error handling implemented
- [ ] Offline persistence enabled
- [ ] Performance optimized
- [ ] Monitoring configured
- [ ] Backup strategy implemented
- [ ] Documentation updated
- [ ] Testing completed
- [ ] Deployment verified

## 🆘 Troubleshooting

### Common Issues

1. **Permission Denied**
   - Check security rules
   - Verify user authentication
   - Check user role permissions

2. **Connection Issues**
   - Check internet connection
   - Verify Firebase configuration
   - Test with health check method

3. **Data Not Loading**
   - Check query filters
   - Verify collection names
   - Check data structure

4. **Performance Issues**
   - Optimize queries
   - Implement pagination
   - Use indexes effectively

### Debug Commands
```dart
// Check Firebase connection
await firebaseService.checkFirebaseConnection();

// List all users (debug only)
await firebaseService.listAllUsers();

// Clear cache
await firebaseService.clearCache();
```

This documentation provides a comprehensive guide for the improved Firebase integration, ensuring secure, performant, and maintainable database operations for the maternal health application. 