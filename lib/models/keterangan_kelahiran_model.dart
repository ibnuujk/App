class KeteranganKelahiranModel {
  final String id;
  final String laporanPascaPersalinanId; // Link to laporan pasca persalinan
  final String pasienId;

  // Data Anak
  final String namaAnak;
  final DateTime hariTanggalLahir;
  final String jamLahir;
  final String tempatLahir;
  final String jenisKelamin; // laki-laki/perempuan
  final String panjangBadan;
  final String beratBadan;
  final int kelahiranAnakKe;

  // Data Ibu (auto filled from database)
  final String namaIbu;
  final int umurIbu;
  final String agamaIbu;
  final String pekerjaanIbu;

  // Data Ayah (auto filled from database)
  final String namaAyah;
  final int umurAyah;
  final String agamaAyah;
  final String pekerjaanAyah;
  final String alamat;

  final DateTime createdAt;
  final DateTime? updatedAt;

  KeteranganKelahiranModel({
    required this.id,
    required this.laporanPascaPersalinanId,
    required this.pasienId,
    required this.namaAnak,
    required this.hariTanggalLahir,
    required this.jamLahir,
    required this.tempatLahir,
    required this.jenisKelamin,
    required this.panjangBadan,
    required this.beratBadan,
    required this.kelahiranAnakKe,
    required this.namaIbu,
    required this.umurIbu,
    required this.agamaIbu,
    required this.pekerjaanIbu,
    required this.namaAyah,
    required this.umurAyah,
    required this.agamaAyah,
    required this.pekerjaanAyah,
    required this.alamat,
    required this.createdAt,
    this.updatedAt,
  });

  factory KeteranganKelahiranModel.fromMap(Map<String, dynamic> map) {
    return KeteranganKelahiranModel(
      id: map['id'] ?? '',
      laporanPascaPersalinanId: map['laporanPascaPersalinanId'] ?? '',
      pasienId: map['pasienId'] ?? '',
      namaAnak: map['namaAnak'] ?? '',
      hariTanggalLahir:
          map['hariTanggalLahir'] != null
              ? DateTime.parse(map['hariTanggalLahir'])
              : DateTime.now(),
      jamLahir: map['jamLahir'] ?? '',
      tempatLahir: map['tempatLahir'] ?? '',
      jenisKelamin: map['jenisKelamin'] ?? '',
      panjangBadan: map['panjangBadan'] ?? '',
      beratBadan: map['beratBadan'] ?? '',
      kelahiranAnakKe: map['kelahiranAnakKe'] ?? 1,
      namaIbu: map['namaIbu'] ?? '',
      umurIbu: map['umurIbu'] ?? 0,
      agamaIbu: map['agamaIbu'] ?? '',
      pekerjaanIbu: map['pekerjaanIbu'] ?? '',
      namaAyah: map['namaAyah'] ?? '',
      umurAyah: map['umurAyah'] ?? 0,
      agamaAyah: map['agamaAyah'] ?? '',
      pekerjaanAyah: map['pekerjaanAyah'] ?? '',
      alamat: map['alamat'] ?? '',
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
      'laporanPascaPersalinanId': laporanPascaPersalinanId,
      'pasienId': pasienId,
      'namaAnak': namaAnak,
      'hariTanggalLahir': hariTanggalLahir.toIso8601String(),
      'jamLahir': jamLahir,
      'tempatLahir': tempatLahir,
      'jenisKelamin': jenisKelamin,
      'panjangBadan': panjangBadan,
      'beratBadan': beratBadan,
      'kelahiranAnakKe': kelahiranAnakKe,
      'namaIbu': namaIbu,
      'umurIbu': umurIbu,
      'agamaIbu': agamaIbu,
      'pekerjaanIbu': pekerjaanIbu,
      'namaAyah': namaAyah,
      'umurAyah': umurAyah,
      'agamaAyah': agamaAyah,
      'pekerjaanAyah': pekerjaanAyah,
      'alamat': alamat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
