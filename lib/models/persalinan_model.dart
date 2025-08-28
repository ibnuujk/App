class PersalinanModel {
  final String id;
  final String pasienId;
  final String pasienNama;
  final String pasienNoHp;
  final int pasienUmur;
  final String pasienAlamat;

  // Data tambahan persalinan
  final String namaSuami;
  final String pekerjaanSuami;
  final int umurSuami;
  final String agamaSuami;
  final String agamaPasien;
  final String pekerjaanPasien;
  final DateTime tanggalMasuk;
  final String fasilitas;
  final String diagnosaKebidanan;
  final String tindakan;
  final String? rujukan; // opsional
  final String penolongPersalinan;
  final DateTime createdAt;

  PersalinanModel({
    required this.id,
    required this.pasienId,
    required this.pasienNama,
    required this.pasienNoHp,
    required this.pasienUmur,
    required this.pasienAlamat,
    required this.namaSuami,
    required this.pekerjaanSuami,
    required this.umurSuami,
    required this.agamaSuami,
    required this.agamaPasien,
    required this.pekerjaanPasien,
    required this.tanggalMasuk,
    required this.fasilitas,
    required this.diagnosaKebidanan,
    required this.tindakan,
    this.rujukan,
    required this.penolongPersalinan,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pasienId': pasienId,
      'pasienNama': pasienNama,
      'pasienNoHp': pasienNoHp,
      'pasienUmur': pasienUmur,
      'pasienAlamat': pasienAlamat,
      'namaSuami': namaSuami,
      'pekerjaanSuami': pekerjaanSuami,
      'umurSuami': umurSuami,
      'agamaSuami': agamaSuami,
      'agamaPasien': agamaPasien,
      'pekerjaanPasien': pekerjaanPasien,
      'tanggalMasuk': tanggalMasuk.toIso8601String(),
      'fasilitas': fasilitas,
      'diagnosaKebidanan': diagnosaKebidanan,
      'tindakan': tindakan,
      'rujukan': rujukan,
      'penolongPersalinan': penolongPersalinan,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PersalinanModel.fromMap(Map<String, dynamic> map) {
    return PersalinanModel(
      id: map['id'] ?? '',
      pasienId: map['pasienId'] ?? '',
      pasienNama: map['pasienNama'] ?? '',
      pasienNoHp: map['pasienNoHp'] ?? '',
      pasienUmur: map['pasienUmur']?.toInt() ?? 0,
      pasienAlamat: map['pasienAlamat'] ?? '',
      namaSuami: map['namaSuami'] ?? '',
      pekerjaanSuami: map['pekerjaanSuami'] ?? '',
      umurSuami: map['umurSuami']?.toInt() ?? 0,
      agamaSuami: map['agamaSuami'] ?? '',
      agamaPasien: map['agamaPasien'] ?? '',
      pekerjaanPasien: map['pekerjaanPasien'] ?? '',
      tanggalMasuk: DateTime.parse(map['tanggalMasuk']),
      fasilitas: map['fasilitas'] ?? '',
      diagnosaKebidanan: map['diagnosaKebidanan'] ?? '',
      tindakan: map['tindakan'] ?? '',
      rujukan: map['rujukan'],
      penolongPersalinan: map['penolongPersalinan'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  PersalinanModel copyWith({
    String? id,
    String? pasienId,
    String? pasienNama,
    String? pasienNoHp,
    int? pasienUmur,
    String? pasienAlamat,
    String? namaSuami,
    String? pekerjaanSuami,
    int? umurSuami,
    String? agamaSuami,
    String? agamaPasien,
    String? pekerjaanPasien,
    DateTime? tanggalMasuk,
    String? fasilitas,
    String? diagnosaKebidanan,
    String? tindakan,
    String? rujukan,
    String? penolongPersalinan,
    DateTime? createdAt,
  }) {
    return PersalinanModel(
      id: id ?? this.id,
      pasienId: pasienId ?? this.pasienId,
      pasienNama: pasienNama ?? this.pasienNama,
      pasienNoHp: pasienNoHp ?? this.pasienNoHp,
      pasienUmur: pasienUmur ?? this.pasienUmur,
      pasienAlamat: pasienAlamat ?? this.pasienAlamat,
      namaSuami: namaSuami ?? this.namaSuami,
      pekerjaanSuami: pekerjaanSuami ?? this.pekerjaanSuami,
      umurSuami: umurSuami ?? this.umurSuami,
      agamaSuami: agamaSuami ?? this.agamaSuami,
      agamaPasien: agamaPasien ?? this.agamaPasien,
      pekerjaanPasien: pekerjaanPasien ?? this.pekerjaanPasien,
      tanggalMasuk: tanggalMasuk ?? this.tanggalMasuk,
      fasilitas: fasilitas ?? this.fasilitas,
      diagnosaKebidanan: diagnosaKebidanan ?? this.diagnosaKebidanan,
      tindakan: tindakan ?? this.tindakan,
      rujukan: rujukan ?? this.rujukan,
      penolongPersalinan: penolongPersalinan ?? this.penolongPersalinan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
