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
    );
  }
}
