class KeteranganKelahiranModel {
  final String id;
  final String laporanPascaPersalinanId;
  final String pasienId;

  // Data Anak
  final String namaAnak;
  final DateTime hariTanggalLahir;
  final String jamLahir;
  final String tempatLahir;
  final String jenisKelamin;
  final String panjangBadan;
  final String beratBadan;
  final int kelahiranAnakKe;

  // Data Ibu
  final String nama;
  final int umur;
  final String agamaPasien;
  final String pekerjaanPasien;

  // Data Ayah
  final String namaSuami;
  final int umurSuami;
  final String agamaSuami;
  final String pekerjaanSuami;
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
    required this.nama,
    required this.umur,
    required this.agamaPasien,
    required this.pekerjaanPasien,
    required this.namaSuami,
    required this.umurSuami,
    required this.agamaSuami,
    required this.pekerjaanSuami,
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
      nama: map['nama'] ?? '',
      umur: map['umur'] ?? 0,
      agamaPasien: map['agamaPasien'] ?? '',
      pekerjaanPasien: map['pekerjaanPasien'] ?? '',
      namaSuami: map['namaSuami'] ?? '',
      umurSuami: map['umurSuami'] ?? 0,
      agamaSuami: map['agamaSuami'] ?? '',
      pekerjaanSuami: map['pekerjaanSuami'] ?? '',
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
      'nama': nama,
      'umur': umur,
      'agamaPasien': agamaPasien,
      'pekerjaanPasien': pekerjaanPasien,
      'namaSuami': namaSuami,
      'umurSuami': umurSuami,
      'agamaSuami': agamaSuami,
      'pekerjaanSuami': pekerjaanSuami,
      'alamat': alamat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
