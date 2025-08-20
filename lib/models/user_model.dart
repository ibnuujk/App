class UserModel {
  final String id;
  final String email;
  final String password;
  final String nama;
  final String noHp;
  final String alamat;
  final DateTime tanggalLahir;
  final int umur;
  final String role; // 'admin' atau 'pasien'
  final DateTime createdAt;
  final DateTime? hpht; // Hari Pertama Haid Terakhir
  final String?
  pregnancyStatus; // 'active', 'miscarriage', 'complication', 'completed'
  final DateTime? pregnancyEndDate;
  final String? pregnancyEndReason; // 'miscarriage', 'complication', 'birth'
  final String? pregnancyNotes; // Catatan tambahan dari bidan
  final DateTime? newHpht; // HPHT baru untuk kehamilan berikutnya
  final List<Map<String, dynamic>>
  pregnancyHistory; // Riwayat kehamilan sebelumnya

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.nama,
    required this.noHp,
    required this.alamat,
    required this.tanggalLahir,
    required this.umur,
    required this.role,
    required this.createdAt,
    this.hpht,
    this.pregnancyStatus,
    this.pregnancyEndDate,
    this.pregnancyEndReason,
    this.pregnancyNotes,
    this.newHpht,
    this.pregnancyHistory = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'nama': nama,
      'noHp': noHp,
      'alamat': alamat,
      'tanggalLahir': tanggalLahir.toIso8601String(),
      'umur': umur,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'hpht': hpht?.toIso8601String(),
      'pregnancyStatus': pregnancyStatus,
      'pregnancyEndDate': pregnancyEndDate?.toIso8601String(),
      'pregnancyEndReason': pregnancyEndReason,
      'pregnancyNotes': pregnancyNotes,
      'newHpht': newHpht?.toIso8601String(),
      'pregnancyHistory': pregnancyHistory,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing DateTime: $value, error: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      nama: map['nama'] ?? '',
      noHp: map['noHp'] ?? '',
      alamat: map['alamat'] ?? '',
      tanggalLahir: parseDateTime(map['tanggalLahir']),
      umur: map['umur']?.toInt() ?? 0,
      role: map['role'] ?? '',
      createdAt: parseDateTime(map['createdAt']),
      hpht: map['hpht'] != null ? parseDateTime(map['hpht']) : null,
      pregnancyStatus: map['pregnancyStatus'],
      pregnancyEndDate:
          map['pregnancyEndDate'] != null
              ? parseDateTime(map['pregnancyEndDate'])
              : null,
      pregnancyEndReason: map['pregnancyEndReason'],
      pregnancyNotes: map['pregnancyNotes'],
      newHpht: map['newHpht'] != null ? parseDateTime(map['newHpht']) : null,
      pregnancyHistory: List<Map<String, dynamic>>.from(
        map['pregnancyHistory'] ?? [],
      ),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? nama,
    String? noHp,
    String? alamat,
    DateTime? tanggalLahir,
    int? umur,
    String? role,
    DateTime? createdAt,
    DateTime? hpht,
    String? pregnancyStatus,
    DateTime? pregnancyEndDate,
    String? pregnancyEndReason,
    String? pregnancyNotes,
    DateTime? newHpht,
    List<Map<String, dynamic>>? pregnancyHistory,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      umur: umur ?? this.umur,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      hpht: hpht ?? this.hpht,
      pregnancyStatus: pregnancyStatus ?? this.pregnancyStatus,
      pregnancyEndDate: pregnancyEndDate ?? this.pregnancyEndDate,
      pregnancyEndReason: pregnancyEndReason ?? this.pregnancyEndReason,
      pregnancyNotes: pregnancyNotes ?? this.pregnancyNotes,
      newHpht: newHpht ?? this.newHpht,
      pregnancyHistory: pregnancyHistory ?? this.pregnancyHistory,
    );
  }
}
