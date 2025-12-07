import 'persalinan_model.dart';
import 'laporan_persalinan_model.dart';
import 'laporan_pasca_persalinan_model.dart';
import 'keterangan_kelahiran_model.dart';

/// Model untuk mengelompokkan data kelahiran berdasarkan kelahiranAnakKe
class BirthDataModel {
  final int kelahiranAnakKe;
  final PersalinanModel? registrasiPersalinan;
  final LaporanPersalinanModel? laporanPersalinan;
  final LaporanPascaPersalinanModel? laporanPascaPersalinan;
  final KeteranganKelahiranModel? keteranganKelahiran;
  final DateTime? tanggalLahir; // Dari keterangan kelahiran atau laporan pasca

  BirthDataModel({
    required this.kelahiranAnakKe,
    this.registrasiPersalinan,
    this.laporanPersalinan,
    this.laporanPascaPersalinan,
    this.keteranganKelahiran,
    this.tanggalLahir,
  });

  /// Mendapatkan tanggal lahir dari data yang tersedia
  DateTime? getTanggalLahir() {
    if (keteranganKelahiran != null) {
      return keteranganKelahiran!.hariTanggalLahir;
    }
    if (laporanPascaPersalinan != null) {
      // Jika tidak ada keterangan kelahiran, gunakan tanggal dari laporan pasca
      return laporanPascaPersalinan!.tanggalKeluar;
    }
    if (registrasiPersalinan != null) {
      return registrasiPersalinan!.tanggalMasuk;
    }
    return null;
  }

  /// Mendapatkan nama anak jika ada
  String? getNamaAnak() {
    return keteranganKelahiran?.namaAnak;
  }

  /// Mendapatkan jenis kelamin jika ada
  String? getJenisKelamin() {
    if (keteranganKelahiran != null) {
      return keteranganKelahiran!.jenisKelamin;
    }
    if (laporanPascaPersalinan != null) {
      return laporanPascaPersalinan!.jenisKelamin;
    }
    return null;
  }

  /// Cek apakah data lengkap (memiliki semua komponen)
  bool get isComplete {
    return registrasiPersalinan != null &&
        laporanPersalinan != null &&
        laporanPascaPersalinan != null &&
        keteranganKelahiran != null;
  }

  /// Cek apakah ada data minimal
  bool get hasData {
    return registrasiPersalinan != null ||
        laporanPersalinan != null ||
        laporanPascaPersalinan != null ||
        keteranganKelahiran != null;
  }
}
