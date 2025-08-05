# Firebase Setup Guide

## 1. Firebase Project Configuration

### Project Details
- **Project ID**: skripsi-ibnu
- **Project Name**: Persalinanku
- **Firebase Console**: https://console.firebase.google.com/project/skripsi-ibnu

## 2. Firestore Database Setup

### Deploy Firestore Rules
1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project:
   ```bash
   firebase init firestore
   ```

4. Deploy Firestore rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Firestore Rules Content
The `firestore.rules` file contains the security rules for all collections:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all collections for development
    // In production, you should implement proper authentication and authorization
    
    // Users collection - allow all operations
    match /users/{userId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Konsultasi collection - allow all operations
    match /konsultasi/{konsultasiId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Persalinan collection - allow all operations
    match /persalinan/{persalinanId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Chat collection - allow all operations
    match /chats/{chatId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Children collection - allow all operations
    match /children/{childId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Pregnancy examinations collection - allow all operations
    match /pemeriksaan_ibuhamil/{examId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Schedules collection - allow all operations
    match /jadwal_konsultasi/{scheduleId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Emergency reports collection - allow all operations
    match /darurat/{reportId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Kehamilanku collection - allow all operations
    match /kehamilanku/{kehamilanId} {
      allow read, write, create, update, delete: if true;
    }
    
    // Default rule for any other collection
    match /{document=**} {
      allow read, write, create, update, delete: if true;
    }
  }
}
```

## 3. Firebase Authentication Setup

### Enable Authentication Methods
1. Go to Firebase Console > Authentication
2. Enable Email/Password authentication
3. Add authorized domains for your app

### Test Users
- **Admin User**:
  - Email: `adminku@gmail.com`
  - Password: `admin123`
  - Role: `admin`

- **Test Patient**:
  - Email: `pasien@test.com`
  - Password: `pasien123`
  - Role: `pasien`

## 4. Flutter Configuration

### Dependencies
Make sure these dependencies are in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
```

### Firebase Options
The `lib/utilities/firebase_option.dart` file contains the configuration for:
- Web platform
- Android platform

## 5. Database Collections

### Users Collection
```javascript
{
  "id": "string",
  "email": "string",
  "password": "string",
  "nama": "string",
  "noHp": "string",
  "alamat": "string",
  "tanggalLahir": "timestamp",
  "umur": "number",
  "role": "string", // "admin" or "pasien"
  "createdAt": "timestamp",
  "hpht": "timestamp" // optional
}
```

### Other Collections
- `konsultasi` - Consultation data
- `persalinan` - Childbirth reports
- `chats` - Chat messages
- `children` - Children data
- `pemeriksaan_ibuhamil` - Pregnancy examinations
- `jadwal_konsultasi` - Consultation schedules
- `darurat` - Emergency reports
- `kehamilanku` - Pregnancy data

## 6. Troubleshooting

### Permission Denied Errors
If you encounter "Missing or insufficient permissions" errors:

1. **Deploy Firestore Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Check Firebase Console**:
   - Go to Firestore Database > Rules
   - Verify rules are deployed correctly

3. **Test Rules**:
   - Use Firebase Console to test read/write operations
   - Check if collections exist and are accessible

### Authentication Issues
1. **Enable Authentication**:
   - Go to Firebase Console > Authentication
   - Enable Email/Password sign-in method

2. **Add Test Users**:
   - Create users manually in Firebase Console
   - Or use the registration flow in the app

## 7. Production Considerations

### Security Rules
For production, implement proper authentication:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only allow authenticated users
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow users to read their own data
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Environment Variables
Store sensitive configuration in environment variables:
- API keys
- Project IDs
- Service account credentials

## 8. Testing

### Manual Testing
1. **Registration**: Test user registration flow
2. **Login**: Test login with email/password
3. **CRUD Operations**: Test all create, read, update, delete operations
4. **Role-based Access**: Test admin vs patient access

### Automated Testing
Consider implementing unit tests and integration tests for Firebase operations.

## 9. Support

For issues related to:
- **Firebase Configuration**: Check Firebase Console
- **Flutter Integration**: Check Flutter Firebase documentation
- **Security Rules**: Test in Firebase Console Rules Playground 