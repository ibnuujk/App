class LaporanPersalinanModel {
  final String id;
  final String registrasiPersalinanId; // Link to registrasi persalinan
  final String pasienId;
  final String pasienNama;
  final String pasienAlamat;
  final DateTime tanggalMasuk;
  final String catatan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LaporanPersalinanModel({
    required this.id,
    required this.registrasiPersalinanId,
    required this.pasienId,
    required this.pasienNama,
    required this.pasienAlamat,
    required this.tanggalMasuk,
    required this.catatan,
    required this.createdAt,
    this.updatedAt,
  });

  factory LaporanPersalinanModel.fromMap(Map<String, dynamic> map) {
    return LaporanPersalinanModel(
      id: map['id'] ?? '',
      registrasiPersalinanId: map['registrasiPersalinanId'] ?? '',
      pasienId: map['pasienId'] ?? '',
      pasienNama: map['pasienNama'] ?? '',
      pasienAlamat: map['pasienAlamat'] ?? '',
      tanggalMasuk:
          map['tanggalMasuk'] != null
              ? DateTime.parse(map['tanggalMasuk'])
              : DateTime.now(),
      catatan: map['catatan'] ?? '',
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'registrasiPersalinanId': registrasiPersalinanId,
      'pasienId': pasienId,
      'pasienNama': pasienNama,
      'pasienAlamat': pasienAlamat,
      'tanggalMasuk': tanggalMasuk.toIso8601String(),
      'catatan': catatan,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
