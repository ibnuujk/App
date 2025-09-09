import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/persalinan_model.dart';
import '../models/laporan_pasca_persalinan_model.dart';
import '../models/keterangan_kelahiran_model.dart';

// Detail Screen for Delivery Registration
class RegistrasiPersalinanDetailScreen extends StatelessWidget {
  final PersalinanModel data;
  final UserModel patient;

  const RegistrasiPersalinanDetailScreen({
    super.key,
    required this.data,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Registrasi Persalinan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            _buildPatientInfoCard(),
            const SizedBox(height: 24),

            // Registration Details Card
            _buildRegistrationDetailsCard(),
            const SizedBox(height: 24),

            // Medical Information Card
            _buildMedicalInfoCard(),
            const SizedBox(height: 24),

            // Additional Information Card
            _buildAdditionalInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Pasien',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      patient.nama,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEC407A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Umur', '${patient.umur} tahun'),
          _buildDetailRow('No. HP', patient.noHp),
          _buildDetailRow('Alamat', patient.alamat),
        ],
      ),
    );
  }

  Widget _buildRegistrationDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Detail Registrasi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Tanggal Masuk',
            DateFormat('dd MMMM yyyy', 'id_ID').format(data.tanggalMasuk),
          ),
          _buildDetailRow('Fasilitas', data.fasilitas.toUpperCase()),
          _buildDetailRow('Diagnosa Kebidanan', data.diagnosaKebidanan),
          _buildDetailRow('Tindakan', data.tindakan),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Medis',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Nama Suami', data.namaSuami),
          _buildDetailRow('Umur Suami', '${data.umurSuami} tahun'),
          _buildDetailRow('Pekerjaan Suami', data.pekerjaanSuami),
          _buildDetailRow('Agama Suami', data.agamaSuami),
          _buildDetailRow('Agama Pasien', data.agamaPasien),
          _buildDetailRow('Pekerjaan Pasien', data.pekerjaanPasien),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Tambahan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Penolong Persalinan', data.penolongPersalinan),
          _buildDetailRow('Rujukan', data.rujukan ?? 'Tidak ada'),
          _buildDetailRow(
            'Tanggal Dibuat',
            DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(data.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Screen for Post-Delivery Report
class LaporanPascaPersalinanDetailScreen extends StatelessWidget {
  final LaporanPascaPersalinanModel data;
  final UserModel patient;

  const LaporanPascaPersalinanDetailScreen({
    super.key,
    required this.data,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Laporan Pasca Persalinan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            _buildPatientInfoCard(),
            const SizedBox(height: 24),

            // Discharge Information Card
            _buildDischargeInfoCard(),
            const SizedBox(height: 24),

            // Health Status Card
            _buildHealthStatusCard(),
            const SizedBox(height: 24),

            // Post-Delivery Care Card
            _buildPostDeliveryCareCard(),
            const SizedBox(height: 24),

            // Additional Information Card
            _buildAdditionalInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Pasien',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      patient.nama,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEC407A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Umur', '${patient.umur} tahun'),
          _buildDetailRow('No. HP', patient.noHp),
          _buildDetailRow('Alamat', patient.alamat),
        ],
      ),
    );
  }

  Widget _buildDischargeInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.exit_to_app,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Pulang',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Tanggal Keluar',
            DateFormat('dd MMMM yyyy', 'id_ID').format(data.tanggalKeluar),
          ),
          _buildDetailRow('Jam Keluar', data.jamKeluar),
          _buildDetailRow('Kondisi Keluar', data.kondisiKeluar),
          _buildDetailRow('Catatan Keluar', data.catatanKeluar),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Kondisi Kesehatan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Tekanan Darah', data.tekananDarah),
          _buildDetailRow('Suhu Badan', '${data.suhuBadan}°C'),
          _buildDetailRow('Nadi', '${data.nadi} bpm'),
          _buildDetailRow('Pernapasan', '${data.pernafasan} /menit'),
          _buildDetailRow('Kontraksi', data.kontraksi),
        ],
      ),
    );
  }

  Widget _buildPostDeliveryCareCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.healing,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Perawatan Pasca Persalinan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Pendarahan Kala III', data.pendarahanKalaIII),
          _buildDetailRow('Pendarahan Kala IV', data.pendarahanKalaIV),
          _buildDetailRow(
            'Tanggal Fundus Uterus',
            DateFormat(
              'dd MMMM yyyy',
              'id_ID',
            ).format(data.tanggalFundusUterus),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Tambahan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Kelahiran Anak', data.kelahiranAnak),
          _buildDetailRow('Jenis Kelamin', data.jenisKelamin),
          _buildDetailRow('Berat Badan', '${data.beratBadan} gram'),
          _buildDetailRow('Panjang Badan', '${data.panjangBadan} cm'),
          _buildDetailRow('Lingkar Kepala', '${data.lingkarKepala} cm'),
          _buildDetailRow('Lingkar Dada', '${data.lingkarDada} cm'),
          _buildDetailRow('APGAR Skor', data.apgarSkor),
          _buildDetailRow('APGAR Catatan', data.apgarCatatan),
          _buildDetailRow(
            'Tanggal Dibuat',
            DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(data.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Screen for Birth Certificate
class KeteranganKelahiranDetailScreen extends StatelessWidget {
  final KeteranganKelahiranModel data;
  final UserModel patient;

  const KeteranganKelahiranDetailScreen({
    super.key,
    required this.data,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Keterangan Kelahiran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Card
            _buildPatientInfoCard(),
            const SizedBox(height: 24),

            // Baby Information Card
            _buildBabyInfoCard(),
            const SizedBox(height: 24),

            // Birth Information Card
            _buildBirthInfoCard(),
            const SizedBox(height: 24),

            // Additional Information Card
            _buildAdditionalInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Ibu',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      patient.nama,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEC407A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Umur', '${patient.umur} tahun'),
          _buildDetailRow('No. HP', patient.noHp),
          _buildDetailRow('Alamat', patient.alamat),
          _buildDetailRow('Agama', patient.agamaPasien ?? 'Tidak diisi'),
          _buildDetailRow(
            'Pekerjaan',
            patient.pekerjaanPasien ?? 'Tidak diisi',
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.child_care,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Bayi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Nama Anak', data.namaAnak),
          _buildDetailRow('Jenis Kelamin', data.jenisKelamin),
          _buildDetailRow('Berat Badan', '${data.beratBadan} gram'),
          _buildDetailRow('Panjang Badan', '${data.panjangBadan} cm'),
          _buildDetailRow('Kelahiran Anak Ke', '${data.kelahiranAnakKe}'),
        ],
      ),
    );
  }

  Widget _buildBirthInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Kelahiran',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Tanggal Lahir',
            DateFormat('dd MMMM yyyy', 'id_ID').format(data.hariTanggalLahir),
          ),
          _buildDetailRow('Jam Lahir', data.jamLahir),
          _buildDetailRow('Tempat Lahir', data.tempatLahir),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info,
                  color: Color(0xFFEC407A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Tambahan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Nama Ayah', data.namaSuami),
          _buildDetailRow('Umur Ayah', '${data.umurSuami} tahun'),
          _buildDetailRow('Agama Ayah', data.agamaSuami),
          _buildDetailRow('Pekerjaan Ayah', data.pekerjaanSuami),
          _buildDetailRow('Alamat', data.alamat),
          _buildDetailRow(
            'Tanggal Dibuat',
            DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(data.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
