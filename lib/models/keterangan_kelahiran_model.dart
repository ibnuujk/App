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
  final String pasienNama;
  final int pasienUmur;
  final String agama;
  final String pekerjaan;

  // Data Ayah (auto filled from database)
  final String namaSuami;
  final int umurSuami;
  final String agamaSuami;
  final String pekerjaanSuami;
  final String pasienAlamat;

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
    required this.pasienNama,
    required this.pasienUmur,
    required this.agama,
    required this.pekerjaan,
    required this.namaSuami,
    required this.umurSuami,
    required this.agamaSuami,
    required this.pekerjaanSuami,
    required this.pasienAlamat,
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
      pasienNama: map['pasienNama'] ?? '',
      pasienUmur: map['pasienUmur'] ?? 0,
      agama: map['agama'] ?? '',
      pekerjaan: map['pekerjaan'] ?? '',
      namaSuami: map['namaSuami'] ?? '',
      umurSuami: map['umurSuami'] ?? 0,
      agamaSuami: map['agamaSuami'] ?? '',
      pekerjaanSuami: map['pekerjaanSuami'] ?? '',
      pasienAlamat: map['pasienAlamat'] ?? '',
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
      'pasienNama': pasienNama,
      'pasienUmur': pasienUmur,
      'agama': agama,
      'pekerjaan': pekerjaan,
      'namaSuami': namaSuami,
      'umurSuami': umurSuami,
      'agamaSuami': agamaSuami,
      'pekerjaanSuami': pekerjaanSuami,
      'pasienAlamat': pasienAlamat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
