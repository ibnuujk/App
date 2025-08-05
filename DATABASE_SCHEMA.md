# Database Schema - Persalinanku

Dokumentasi lengkap struktur database Firestore untuk aplikasi Persalinanku.

## Overview

Aplikasi Persalinanku menggunakan Cloud Firestore sebagai database NoSQL. Database terdiri dari 4 collection utama:

1. **users** - Data pengguna (admin dan pasien)
2. **konsultasi** - Data konsultasi pasien
3. **persalinan** - Data laporan persalinan
4. **chats** - Data pesan chat

## Collection: users

Collection untuk menyimpan data pengguna sistem.

### Document Structure

```json
{
  "id": "string",                    // Unique ID pengguna
  "username": "string",              // Username untuk login
  "password": "string",              // Password (plain text - untuk demo)
  "nama": "string",                  // Nama lengkap
  "noHp": "string",                  // Nomor telepon
  "alamat": "string",                // Alamat lengkap
  "tanggalLahir": "timestamp",       // Tanggal lahir
  "umur": "number",                  // Usur (dihitung otomatis)
  "role": "string",                  // Role: "admin" atau "pasien"
  "createdAt": "timestamp"           // Waktu pembuatan akun
}
```

### Example Document

```json
{
  "id": "user_001",
  "username": "adminku@gmail.com",
  "password": "Admin123#",
  "nama": "Admin Persalinanku",
  "noHp": "081234567890",
  "alamat": "Jl. Contoh No. 123, Jakarta",
  "tanggalLahir": "1990-01-01T00:00:00.000Z",
  "umur": 34,
  "role": "admin",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### Indexes

- `username` (ascending) - untuk pencarian user
- `role` (ascending) - untuk filter berdasarkan role
- `createdAt` (descending) - untuk sorting berdasarkan waktu pembuatan

## Collection: konsultasi

Collection untuk menyimpan data konsultasi pasien.

### Document Structure

```json
{
  "id": "string",                    // Unique ID konsultasi
  "pasienId": "string",              // ID pasien yang mengajukan
  "pasienNama": "string",            // Nama pasien
  "pertanyaan": "string",            // Pertanyaan dari pasien
  "jawaban": "string?",              // Jawaban dari admin (nullable)
  "status": "string",                // Status: "pending" atau "answered"
  "tanggalKonsultasi": "timestamp",  // Waktu pengajuan konsultasi
  "tanggalJawaban": "timestamp?"     // Waktu jawaban (nullable)
}
```

### Example Document

```json
{
  "id": "konsultasi_001",
  "pasienId": "user_002",
  "pasienNama": "Sarah Johnson",
  "pertanyaan": "Apakah normal jika saya mengalami mual di trimester pertama?",
  "jawaban": "Ya, mual di trimester pertama adalah hal yang normal dan disebut morning sickness. Namun jika terlalu parah, sebaiknya konsultasi dengan dokter.",
  "status": "answered",
  "tanggalKonsultasi": "2024-01-15T10:30:00.000Z",
  "tanggalJawaban": "2024-01-15T14:20:00.000Z"
}
```

### Indexes

- `pasienId` (ascending) - untuk filter konsultasi per pasien
- `status` (ascending) - untuk filter berdasarkan status
- `tanggalKonsultasi` (descending) - untuk sorting berdasarkan waktu pengajuan
- `tanggalJawaban` (descending) - untuk sorting berdasarkan waktu jawaban

## Collection: persalinan

Collection untuk menyimpan data laporan persalinan.

### Document Structure

```json
{
  "id": "string",                    // Unique ID laporan
  "pasienId": "string",              // ID pasien
  "pasienNama": "string",            // Nama pasien
  "pasienNoHp": "string",            // No HP pasien
  "pasienUmur": "number",            // Usur pasien
  "pasienAlamat": "string",          // Alamat pasien
  "namaSuami": "string",             // Nama suami
  "pekerjaan": "string",             // Pekerjaan
  "tanggalMasuk": "timestamp",       // Tanggal masuk rumah sakit
  "fasilitas": "string",             // Fasilitas: "umum" atau "bpjs"
  "tanggalPartes": "timestamp",      // Tanggal persalinan
  "tanggalKeluar": "timestamp",      // Tanggal keluar rumah sakit
  "diagnosaKebidanan": "string",     // Diagnosa kebidanan
  "tindakan": "string",              // Tindakan yang dilakukan
  "rujukan": "string?",              // Rujukan (nullable)
  "penolongPersalinan": "string",    // Nama penolong persalinan
  "createdAt": "timestamp"           // Waktu pembuatan laporan
}
```

### Example Document

```json
{
  "id": "persalinan_001",
  "pasienId": "user_002",
  "pasienNama": "Sarah Johnson",
  "pasienNoHp": "081234567890",
  "pasienUmur": 28,
  "pasienAlamat": "Jl. Contoh No. 456, Jakarta",
  "namaSuami": "John Johnson",
  "pekerjaan": "Karyawan Swasta",
  "tanggalMasuk": "2024-01-20T08:00:00.000Z",
  "fasilitas": "bpjs",
  "tanggalPartes": "2024-01-20T14:30:00.000Z",
  "tanggalKeluar": "2024-01-22T10:00:00.000Z",
  "diagnosaKebidanan": "Gravida 1, Para 0, Abortus 0, Partus 1",
  "tindakan": "Persalinan normal",
  "rujukan": null,
  "penolongPersalinan": "dr. Budi Santoso",
  "createdAt": "2024-01-20T08:30:00.000Z"
}
```

### Indexes

- `pasienId` (ascending) - untuk filter laporan per pasien
- `tanggalPartes` (descending) - untuk sorting berdasarkan tanggal persalinan
- `createdAt` (descending) - untuk sorting berdasarkan waktu pembuatan
- `fasilitas` (ascending) - untuk filter berdasarkan fasilitas

## Collection: chats

Collection untuk menyimpan data pesan chat.

### Document Structure

```json
{
  "id": "string",                    // Unique ID pesan
  "senderId": "string",              // ID pengirim
  "senderName": "string",            // Nama pengirim
  "senderRole": "string",            // Role pengirim: "admin" atau "pasien"
  "message": "string",               // Isi pesan
  "timestamp": "timestamp",          // Waktu pengiriman
  "isRead": "boolean"                // Status dibaca
}
```

### Example Document

```json
{
  "id": "chat_001",
  "senderId": "user_002",
  "senderName": "Sarah Johnson",
  "senderRole": "pasien",
  "message": "Selamat pagi dokter, saya ingin bertanya tentang persiapan persalinan",
  "timestamp": "2024-01-25T09:00:00.000Z",
  "isRead": true
}
```

### Indexes

- `senderId` (ascending) - untuk filter pesan per pengirim
- `timestamp` (descending) - untuk sorting berdasarkan waktu
- `senderRole` (ascending) - untuk filter berdasarkan role
- `isRead` (ascending) - untuk filter pesan yang belum dibaca

## Security Rules

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Consultations collection
    match /konsultasi/{konsultasiId} {
      allow read, write: if request.auth != null;
    }
    
    // Childbirth reports collection
    match /persalinan/{persalinanId} {
      allow read, write: if request.auth != null;
    }
    
    // Chat messages collection
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Advanced Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Consultations collection
    match /konsultasi/{konsultasiId} {
      allow read: if request.auth != null && 
        (resource.data.pasienId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Childbirth reports collection
    match /persalinan/{persalinanId} {
      allow read: if request.auth != null && 
        (resource.data.pasienId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Chat messages collection
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Data Validation

### Client-Side Validation

Semua data yang dikirim ke Firestore harus divalidasi di client-side:

1. **Required Fields**: Pastikan semua field wajib terisi
2. **Data Types**: Pastikan tipe data sesuai dengan schema
3. **String Length**: Batasi panjang string untuk mencegah abuse
4. **Date Validation**: Pastikan tanggal valid dan masuk akal

### Server-Side Validation

Untuk production, gunakan Cloud Functions untuk validasi server-side:

```javascript
exports.validateUserData = functions.firestore
  .document('users/{userId}')
  .onCreate((snap, context) => {
    const userData = snap.data();
    
    // Validasi required fields
    if (!userData.username || !userData.password || !userData.nama) {
      throw new Error('Required fields missing');
    }
    
    // Validasi email format
    if (!userData.username.includes('@')) {
      throw new Error('Invalid email format');
    }
    
    // Validasi umur
    if (userData.umur < 0 || userData.umur > 150) {
      throw new Error('Invalid age');
    }
  });
```

## Backup Strategy

### Automated Backups

1. **Firestore Export**: Gunakan Firebase CLI untuk export data
2. **Scheduled Backups**: Setup cron job untuk backup otomatis
3. **Multiple Locations**: Simpan backup di multiple storage

### Manual Backup Commands

```bash
# Export all collections
gcloud firestore export gs://your-backup-bucket

# Export specific collection
gcloud firestore export gs://your-backup-bucket --collection-ids=users,konsultasi,persalinan,chats

# Import data
gcloud firestore import gs://your-backup-bucket/2024-01-01T00:00:00_00000
```

## Performance Optimization

### Indexes

Buat composite indexes untuk query yang sering digunakan:

1. `users` collection: `role + createdAt`
2. `konsultasi` collection: `pasienId + tanggalKonsultasi`
3. `persalinan` collection: `pasienId + tanggalPartes`
4. `chats` collection: `senderId + timestamp`

### Query Optimization

1. **Limit Results**: Gunakan `limit()` untuk membatasi jumlah hasil
2. **Pagination**: Implementasi pagination untuk data besar
3. **Selective Fields**: Gunakan `select()` untuk mengambil field tertentu saja
4. **Caching**: Implementasi caching untuk data yang jarang berubah

## Monitoring

### Firestore Metrics

Monitor metrics berikut di Firebase Console:

1. **Read Operations**: Jumlah operasi baca
2. **Write Operations**: Jumlah operasi tulis
3. **Delete Operations**: Jumlah operasi hapus
4. **Document Count**: Jumlah dokumen per collection
5. **Storage Size**: Ukuran storage yang digunakan

### Alerts

Setup alerts untuk:

1. **High Usage**: Ketika usage melebihi threshold
2. **Error Rate**: Ketika error rate tinggi
3. **Cost**: Ketika biaya melebihi budget
4. **Performance**: Ketika query lambat

## Migration Strategy

### Schema Changes

1. **Add Fields**: Tambahkan field baru dengan default value
2. **Remove Fields**: Gunakan Cloud Functions untuk cleanup
3. **Change Types**: Lakukan migration bertahap
4. **Versioning**: Gunakan version field untuk backward compatibility

### Example Migration

```javascript
exports.migrateUserSchema = functions.firestore
  .document('users/{userId}')
  .onUpdate((change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();
    
    // Add new field if not exists
    if (!newData.hasOwnProperty('lastLogin')) {
      change.after.ref.update({
        lastLogin: null
      });
    }
  });
```

## Best Practices

1. **Consistent Naming**: Gunakan naming convention yang konsisten
2. **Data Normalization**: Normalisasi data untuk menghindari redundancy
3. **Security First**: Selalu prioritaskan keamanan
4. **Performance**: Optimasi query dan indexes
5. **Monitoring**: Monitor usage dan performance secara regular
6. **Backup**: Lakukan backup secara regular
7. **Documentation**: Dokumentasikan semua perubahan schema 