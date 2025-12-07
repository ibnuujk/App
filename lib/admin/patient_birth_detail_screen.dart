import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/birth_data_model.dart';
import '../utilities/safe_navigation.dart';
import 'detail_screens.dart';

class PatientBirthDetailScreen extends StatefulWidget {
  final UserModel patient;
  final BirthDataModel birthData;

  const PatientBirthDetailScreen({
    super.key,
    required this.patient,
    required this.birthData,
  });

  @override
  State<PatientBirthDetailScreen> createState() =>
      _PatientBirthDetailScreenState();
}

class _PatientBirthDetailScreenState extends State<PatientBirthDetailScreen>
    with SafeNavigationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Kelahiran Ke-${widget.birthData.kelahiranAnakKe} - ${widget.patient.nama}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed:
              () => Navigator.pop(
                context,
                true,
              ), // Return true to indicate data might have changed
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Registrasi Persalinan Section
            _buildSectionHeader(
              'Registrasi Persalinan',
              Icons.medical_services,
            ),
            const SizedBox(height: 16),
            if (widget.birthData.registrasiPersalinan == null)
              _buildEmptyCard('Belum ada data registrasi persalinan')
            else
              _buildRegistrasiCard(widget.birthData.registrasiPersalinan!),

            const SizedBox(height: 24),

            // Laporan Persalinan Section
            _buildSectionHeader('Laporan Persalinan', Icons.assignment),
            const SizedBox(height: 16),
            if (widget.birthData.laporanPersalinan == null)
              _buildEmptyCard('Belum ada laporan persalinan')
            else
              _buildLaporanPersalinanCard(widget.birthData.laporanPersalinan!),

            const SizedBox(height: 24),

            // Laporan Pasca Persalinan Section
            _buildSectionHeader('Laporan Pasca Persalinan', Icons.healing),
            const SizedBox(height: 16),
            if (widget.birthData.laporanPascaPersalinan == null)
              _buildEmptyCard('Belum ada laporan pasca persalinan')
            else
              _buildLaporanPascaCard(widget.birthData.laporanPascaPersalinan!),

            const SizedBox(height: 24),

            // Keterangan Kelahiran Section
            _buildSectionHeader('Keterangan Kelahiran', Icons.child_care),
            const SizedBox(height: 16),
            if (widget.birthData.keteranganKelahiran == null)
              _buildEmptyCard('Belum ada keterangan kelahiran')
            else
              _buildKeteranganKelahiranCard(
                widget.birthData.keteranganKelahiran!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEC407A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFEC407A), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRegistrasiCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registrasi Persalinan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Masuk',
            DateFormat('dd/MM/yyyy').format(data.tanggalMasuk),
          ),
          _buildInfoRow('Fasilitas', data.fasilitas.toUpperCase()),
          _buildInfoRow('Diagnosa', data.diagnosaKebidanan),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => RegistrasiPersalinanDetailScreen(
                          data: data,
                          patient: widget.patient,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Lihat Detail', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanPersalinanCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Persalinan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Masuk',
            DateFormat('dd/MM/yyyy').format(data.tanggalMasuk),
          ),
          _buildInfoRow(
            'Catatan',
            data.catatan.isNotEmpty ? data.catatan : 'Tidak ada catatan',
          ),
          _buildInfoRow(
            'Tanggal Dibuat',
            DateFormat('dd/MM/yyyy').format(data.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanPascaCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Pasca Persalinan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Tanggal Keluar',
            DateFormat('dd/MM/yyyy').format(data.tanggalKeluar),
          ),
          _buildInfoRow('Tekanan Darah', data.tekananDarah),
          _buildInfoRow('Suhu Badan', '${data.suhuBadan}°C'),
          _buildInfoRow('Kondisi Keluar', data.kondisiKeluar),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LaporanPascaPersalinanDetailScreen(
                          data: data,
                          patient: widget.patient,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Lihat Detail', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeteranganKelahiranCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keterangan Kelahiran',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Anak', data.namaAnak),
          _buildInfoRow(
            'Tanggal Lahir',
            DateFormat('dd/MM/yyyy').format(data.hariTanggalLahir),
          ),
          _buildInfoRow('Jam Lahir', data.jamLahir),
          _buildInfoRow(
            'Jenis Kelamin',
            data.jenisKelamin == 'laki-laki' ? 'Laki-laki' : 'Perempuan',
          ),
          _buildInfoRow('Berat Badan', '${data.beratBadan} kg'),
          _buildInfoRow('Panjang Badan', '${data.panjangBadan} cm'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => KeteranganKelahiranDetailScreen(
                          data: data,
                          patient: widget.patient,
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Lihat Detail', style: GoogleFonts.poppins()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
