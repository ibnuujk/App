class LaporanPascaPersalinanModel {
  final String id;
  final String laporanPersalinanId; // Link to laporan persalinan
  final String pasienId;
  final String pasienNama;

  // Data Ibu
  final String tekananDarah;
  final String suhuBadan;
  final String nadi;
  final String pernafasan;
  final DateTime tanggalFundusUterus;
  final String kontraksi;
  final String pendarahanKalaIII;
  final String pendarahanKalaIV;

  // Keadaan Anak
  final String kelahiranAnak; // hidup/mati
  final String? sebabMati; // jika mati
  final String jenisKelamin; // laki-laki/perempuan
  final String beratBadan;
  final String panjangBadan;
  final String lingkarKepala;
  final String lingkarDada;
  final String kelainan; // ya/tidak
  final String? detailKelainan; // jika ada kelainan

  // APGAR Score
  final String apgarSkor;
  final String apgarCatatan;

  // Placenta
  final String placentaBentuk;
  final String placentaPanjang;
  final String placentaLebar;
  final String placentaTebal;
  final String placentaBerat;
  final String panjangTaliPusat;

  // Keadaan Penderita Keluar
  final DateTime tanggalKeluar;
  final String jamKeluar;
  final String kondisiKeluar; // sembuh/meninggal/dipindahkan/keluar_paksa
  final String? sebabMeninggal;
  final String? namaRS;
  final String? sebabKeluarPaksa;
  final String catatanKeluar;

  final DateTime createdAt;
  final DateTime? updatedAt;

  LaporanPascaPersalinanModel({
    required this.id,
    required this.laporanPersalinanId,
    required this.pasienId,
    required this.pasienNama,
    required this.tekananDarah,
    required this.suhuBadan,
    required this.nadi,
    required this.pernafasan,
    required this.tanggalFundusUterus,
    required this.kontraksi,
    required this.pendarahanKalaIII,
    required this.pendarahanKalaIV,
    required this.kelahiranAnak,
    this.sebabMati,
    required this.jenisKelamin,
    required this.beratBadan,
    required this.panjangBadan,
    required this.lingkarKepala,
    required this.lingkarDada,
    required this.kelainan,
    this.detailKelainan,
    required this.apgarSkor,
    required this.apgarCatatan,
    required this.placentaBentuk,
    required this.placentaPanjang,
    required this.placentaLebar,
    required this.placentaTebal,
    required this.placentaBerat,
    required this.panjangTaliPusat,
    required this.tanggalKeluar,
    required this.jamKeluar,
    required this.kondisiKeluar,
    this.sebabMeninggal,
    this.namaRS,
    this.sebabKeluarPaksa,
    required this.catatanKeluar,
    required this.createdAt,
    this.updatedAt,
  });

  factory LaporanPascaPersalinanModel.fromMap(Map<String, dynamic> map) {
    return LaporanPascaPersalinanModel(
      id: map['id'] ?? '',
      laporanPersalinanId: map['laporanPersalinanId'] ?? '',
      pasienId: map['pasienId'] ?? '',
      pasienNama: map['pasienNama'] ?? '',
      tekananDarah: map['tekananDarah'] ?? '',
      suhuBadan: map['suhuBadan'] ?? '',
      nadi: map['nadi'] ?? '',
      pernafasan: map['pernafasan'] ?? '',
      tanggalFundusUterus:
          map['tanggalFundusUterus'] != null
              ? DateTime.parse(map['tanggalFundusUterus'])
              : DateTime.now(),
      kontraksi: map['kontraksi'] ?? '',
      pendarahanKalaIII: map['pendarahanKalaIII'] ?? '',
      pendarahanKalaIV: map['pendarahanKalaIV'] ?? '',
      kelahiranAnak: map['kelahiranAnak'] ?? '',
      sebabMati: map['sebabMati'],
      jenisKelamin: map['jenisKelamin'] ?? '',
      beratBadan: map['beratBadan'] ?? '',
      panjangBadan: map['panjangBadan'] ?? '',
      lingkarKepala: map['lingkarKepala'] ?? '',
      lingkarDada: map['lingkarDada'] ?? '',
      kelainan: map['kelainan'] ?? '',
      detailKelainan: map['detailKelainan'],
      apgarSkor: map['apgarSkor'] ?? '',
      apgarCatatan: map['apgarCatatan'] ?? '',
      placentaBentuk: map['placentaBentuk'] ?? '',
      placentaPanjang: map['placentaPanjang'] ?? '',
      placentaLebar: map['placentaLebar'] ?? '',
      placentaTebal: map['placentaTebal'] ?? '',
      placentaBerat: map['placentaBerat'] ?? '',
      panjangTaliPusat: map['panjangTaliPusat'] ?? '',
      tanggalKeluar:
          map['tanggalKeluar'] != null
              ? DateTime.parse(map['tanggalKeluar'])
              : DateTime.now(),
      jamKeluar: map['jamKeluar'] ?? '',
      kondisiKeluar: map['kondisiKeluar'] ?? '',
      sebabMeninggal: map['sebabMeninggal'],
      namaRS: map['namaRS'],
      sebabKeluarPaksa: map['sebabKeluarPaksa'],
      catatanKeluar: map['catatanKeluar'] ?? '',
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
      'laporanPersalinanId': laporanPersalinanId,
      'pasienId': pasienId,
      'pasienNama': pasienNama,
      'tekananDarah': tekananDarah,
      'suhuBadan': suhuBadan,
      'nadi': nadi,
      'pernafasan': pernafasan,
      'tanggalFundusUterus': tanggalFundusUterus.toIso8601String(),
      'kontraksi': kontraksi,
      'pendarahanKalaIII': pendarahanKalaIII,
      'pendarahanKalaIV': pendarahanKalaIV,
      'kelahiranAnak': kelahiranAnak,
      'sebabMati': sebabMati,
      'jenisKelamin': jenisKelamin,
      'beratBadan': beratBadan,
      'panjangBadan': panjangBadan,
      'lingkarKepala': lingkarKepala,
      'lingkarDada': lingkarDada,
      'kelainan': kelainan,
      'detailKelainan': detailKelainan,
      'apgarSkor': apgarSkor,
      'apgarCatatan': apgarCatatan,
      'placentaBentuk': placentaBentuk,
      'placentaPanjang': placentaPanjang,
      'placentaLebar': placentaLebar,
      'placentaTebal': placentaTebal,
      'placentaBerat': placentaBerat,
      'panjangTaliPusat': panjangTaliPusat,
      'tanggalKeluar': tanggalKeluar.toIso8601String(),
      'jamKeluar': jamKeluar,
      'kondisiKeluar': kondisiKeluar,
      'sebabMeninggal': sebabMeninggal,
      'namaRS': namaRS,
      'sebabKeluarPaksa': sebabKeluarPaksa,
      'catatanKeluar': catatanKeluar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
