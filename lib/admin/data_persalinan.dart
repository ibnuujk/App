import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/user_model.dart';
import '../utilities/safe_navigation.dart';

class DataPersalinanScreen extends StatefulWidget {
  const DataPersalinanScreen({super.key});

  @override
  State<DataPersalinanScreen> createState() => _DataPersalinanScreenState();
}

class _DataPersalinanScreenState extends State<DataPersalinanScreen>
    with SafeNavigationMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize Indonesian locale for date formatting
    initializeDateFormatting('id_ID', null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Laporan Persalinan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFEC407A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari data pasien...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .orderBy(
                        'createdAt',
                        descending: true,
                      ) // Sort by newest first
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFEC407A)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pregnant_woman_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data pasien',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data pasien akan muncul di sini',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final users =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return UserModel.fromMap(data);
                    }).toList();

                // Filter users based on search and filter
                final filteredUsers =
                    users.where((user) {
                      final matchesSearch =
                          user.nama.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          user.noHp.contains(_searchQuery) ||
                          user.alamat.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                      return matchesSearch;
                    }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada hasil pencarian',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Return FutureBuilder to check complete data for each user
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getCompletePatients(filteredUsers),
                  builder: (context, completeSnapshot) {
                    if (completeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEC407A),
                        ),
                      );
                    }

                    if (completeSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${completeSnapshot.error}',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      );
                    }

                    final completePatientsData = completeSnapshot.data ?? [];

                    if (completePatientsData.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.incomplete_circle_rounded,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada pasien dengan data lengkap',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hanya menampilkan pasien yang sudah mengisi\nLaporan Persalinan, Laporan Pasca Persalinan,\ndan Keterangan Kelahiran',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: completePatientsData.length,
                      itemBuilder: (context, index) {
                        final patientData = completePatientsData[index];
                        return _buildPatientCard(patientData);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patientData) {
    final user = patientData['user'] as UserModel;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Patient Info Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Profile Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE4EC), // Light pink background
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: const Color(0xFFE91E63), // Darker pink icon
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Patient Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nama,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            user.noHp,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            '${_calculateAge(user.tanggalLahir)} tahun',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.alamat,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Options Menu
                IconButton(
                  icon: Icon(Icons.more_vert, color: const Color(0xFFE91E63)),
                  onPressed: () {
                    _showOptionsMenu(context, user);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons - PDF Style Layout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Main Action Row
                Row(
                  children: [
                    Expanded(
                      child: _buildPDFStyleButton(
                        'Lihat Detail',
                        Icons.visibility_rounded,
                        const Color(0xFFEC407A),
                        () => _viewCompleteDetails(patientData),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPDFStyleButton(
                        'Edit Data',
                        Icons.edit_rounded,
                        const Color(0xFF4CAF50),
                        () => _editPatientData(patientData),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Build PDF style button
  Widget _buildPDFStyleButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to calculate age
  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Helper method to check if a patient has all required data and fetch detailed information
  Future<List<Map<String, dynamic>>> _getCompletePatients(
    List<UserModel> users,
  ) async {
    final List<Map<String, dynamic>> completePatientsData = [];

    for (final user in users) {
      try {
        // Check if user has completed the entire flow
        // 1. Check if user has registrasi persalinan
        final registrasiSnapshot =
            await FirebaseFirestore.instance
                .collection('persalinan')
                .where('pasienId', isEqualTo: user.id)
                .orderBy('createdAt', descending: true)
                .limit(1)
                .get();

        if (registrasiSnapshot.docs.isNotEmpty) {
          final registrasiData = registrasiSnapshot.docs.first.data();
          final registrasiId = registrasiSnapshot.docs.first.id;

          // 2. Check if user has laporan persalinan
          final laporanSnapshot =
              await FirebaseFirestore.instance
                  .collection('laporan_persalinan')
                  .where('registrasiPersalinanId', isEqualTo: registrasiId)
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .get();

          if (laporanSnapshot.docs.isNotEmpty) {
            final laporanData = laporanSnapshot.docs.first.data();
            final laporanId = laporanSnapshot.docs.first.id;

            // 3. Check if user has laporan pasca persalinan
            final pascaSnapshot =
                await FirebaseFirestore.instance
                    .collection('laporan_pasca_persalinan')
                    .where('laporanPersalinanId', isEqualTo: laporanId)
                    .orderBy('createdAt', descending: true)
                    .limit(1)
                    .get();

            if (pascaSnapshot.docs.isNotEmpty) {
              final pascaData = pascaSnapshot.docs.first.data();
              final pascaId = pascaSnapshot.docs.first.id;

              // 4. Check if user has keterangan kelahiran
              final keteranganSnapshot =
                  await FirebaseFirestore.instance
                      .collection('keterangan_kelahiran')
                      .where('laporanPascaPersalinanId', isEqualTo: pascaId)
                      .orderBy('createdAt', descending: true)
                      .limit(1)
                      .get();

              // Only add user if all four documents exist (complete flow)
              if (keteranganSnapshot.docs.isNotEmpty) {
                final keteranganData = keteranganSnapshot.docs.first.data();

                // Create comprehensive data object
                final patientData = {
                  'user': user,
                  'registrasiPersalinan': {
                    'id': registrasiId,
                    'data': registrasiData,
                  },
                  'laporanPersalinan': {'id': laporanId, 'data': laporanData},
                  'laporanPascaPersalinan': {'id': pascaId, 'data': pascaData},
                  'keteranganKelahiran': {
                    'id': keteranganSnapshot.docs.first.id,
                    'data': keteranganData,
                  },
                };

                completePatientsData.add(patientData);
              }
            }
          }
        }
      } catch (e) {
        print('Error checking complete data for user ${user.id}: $e');
      }
    }

    return completePatientsData;
  }

  // View complete details for a patient
  void _viewCompleteDetails(Map<String, dynamic> patientData) {
    final user = patientData['user'] as UserModel;
    final registrasiData =
        patientData['registrasiPersalinan']['data'] as Map<String, dynamic>;
    final laporanData =
        patientData['laporanPersalinan']['data'] as Map<String, dynamic>;
    final pascaData =
        patientData['laporanPascaPersalinan']['data'] as Map<String, dynamic>;
    final keteranganData =
        patientData['keteranganKelahiran']['data'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC407A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_services_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Detail Lengkap ${user.nama}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Registrasi Persalinan
                        _buildDetailSection(
                          'Registrasi Persalinan',
                          Icons.app_registration_rounded,
                          const Color(0xFF9C27B0),
                          [
                            'Tanggal Masuk: ${_formatDate(registrasiData['tanggalMasuk'])}',
                            'Fasilitas: ${registrasiData['fasilitas'] ?? 'Tidak ada data'}',
                            'Diagnosa: ${registrasiData['diagnosaKebidanan'] ?? 'Tidak ada data'}',
                            'Tindakan: ${registrasiData['tindakan'] ?? 'Tidak ada data'}',
                            'Penolong: ${registrasiData['penolongPersalinan'] ?? 'Tidak ada data'}',
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Laporan Persalinan
                        _buildDetailSection(
                          'Laporan Persalinan',
                          Icons.local_hospital_rounded,
                          const Color(0xFFEC407A),
                          [
                            'Tanggal Masuk: ${_formatDate(laporanData['tanggalMasuk'])}',
                            'Catatan: ${laporanData['catatan'] ?? 'Tidak ada data'}',
                            'Tanggal Dibuat: ${_formatDate(laporanData['createdAt'])}',
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Laporan Pasca Persalinan
                        _buildDetailSection(
                          'Laporan Pasca Persalinan',
                          Icons.healing_rounded,
                          const Color(0xFF4CAF50),
                          [
                            'Tanggal Fundus Uterus: ${_formatDate(pascaData['tanggalFundusUterus'])}',
                            'Tanggal Keluar: ${_formatDate(pascaData['tanggalKeluar'])}',
                            'Jam Keluar: ${_formatTime(pascaData['jamKeluar'])}',
                            'Tekanan Darah: ${pascaData['tekananDarah'] ?? 'Tidak ada data'}',
                            'Suhu Badan: ${pascaData['suhuBadan'] ?? 'Tidak ada data'}',
                            'Nadi: ${pascaData['nadi'] ?? 'Tidak ada data'}',
                            'Pernafasan: ${pascaData['pernafasan'] ?? 'Tidak ada data'}',
                            'Kelahiran Anak: ${pascaData['kelahiranAnak'] ?? 'Tidak ada data'}',
                            'Jenis Kelamin: ${pascaData['jenisKelamin'] ?? 'Tidak ada data'}',
                            'Berat Badan: ${_formatDataWithUnit(pascaData['beratBadan'], 'gram')}',
                            'Panjang Badan: ${_formatDataWithUnit(pascaData['panjangBadan'], 'cm')}',
                            'Lingkar Kepala: ${_formatDataWithUnit(pascaData['lingkarKepala'], 'cm')}',
                            'Lingkar Dada: ${_formatDataWithUnit(pascaData['lingkarDada'], 'cm')}',
                            'APGAR Score: ${pascaData['apgarSkor'] ?? 'Tidak ada data'}',
                            'Kondisi Keluar: ${pascaData['kondisiKeluar'] ?? 'Tidak ada data'}',
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Keterangan Kelahiran
                        _buildDetailSection(
                          'Keterangan Kelahiran',
                          Icons.child_care_rounded,
                          const Color(0xFF2196F3),
                          [
                            'Nama Anak: ${keteranganData['namaAnak'] ?? 'Tidak ada data'}',
                            'Tanggal Lahir: ${_formatDate(keteranganData['hariTanggalLahir'])}',
                            'Jam Lahir: ${_formatTime(keteranganData['jamLahir'])}',
                            'Tempat Lahir: ${keteranganData['tempatLahir'] ?? 'Tidak ada data'}',
                            'Jenis Kelamin: ${keteranganData['jenisKelamin'] ?? 'Tidak ada data'}',
                            'Berat Badan: ${_formatDataWithUnit(keteranganData['beratBadan'], 'gram')}',
                            'Panjang Badan: ${_formatDataWithUnit(keteranganData['panjangBadan'], 'cm')}',
                            'Kelahiran Anak Ke: ${keteranganData['kelahiranAnakKe'] ?? 'Tidak ada data'}',
                            'Nama Ibu: ${keteranganData['namaIbu'] ?? 'Tidak ada data'}',
                            'Umur Ibu: ${_formatDataWithUnit(keteranganData['umurIbu'], 'tahun')}',
                            'Agama Ibu: ${keteranganData['agamaIbu'] ?? 'Tidak ada data'}',
                            'Pekerjaan Ibu: ${keteranganData['pekerjaanIbu'] ?? 'Tidak ada data'}',
                            'Nama Ayah: ${keteranganData['namaAyah'] ?? 'Tidak ada data'}',
                            'Umur Ayah: ${_formatDataWithUnit(keteranganData['umurAyah'], 'tahun')}',
                            'Agama Ayah: ${keteranganData['agamaAyah'] ?? 'Tidak ada data'}',
                            'Pekerjaan Ayah: ${keteranganData['pekerjaanAyah'] ?? 'Tidak ada data'}',
                            'Alamat: ${keteranganData['alamat'] ?? 'Tidak ada data'}',
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Edit patient data
  void _editPatientData(Map<String, dynamic> patientData) {
    final user = patientData['user'] as UserModel;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.edit, color: const Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(
                'Edit Data Pasien',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Pilih data yang ingin diedit untuk ${user.nama}:',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToEditForm('registrasi', patientData);
              },
              child: Text(
                'Registrasi Persalinan',
                style: GoogleFonts.poppins(color: const Color(0xFF9C27B0)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToEditForm('laporan', patientData);
              },
              child: Text(
                'Laporan Persalinan',
                style: GoogleFonts.poppins(color: const Color(0xFFEC407A)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToEditForm('pasca', patientData);
              },
              child: Text(
                'Laporan Pasca Persalinan',
                style: GoogleFonts.poppins(color: const Color(0xFF4CAF50)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToEditForm('keterangan', patientData);
              },
              child: Text(
                'Keterangan Kelahiran',
                style: GoogleFonts.poppins(color: const Color(0xFF2196F3)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Navigate to edit form
  void _navigateToEditForm(String formType, Map<String, dynamic> patientData) {
    // TODO: Implement navigation to actual edit forms
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Membuka form edit $formType untuk ${patientData['user'].nama}',
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  // Show options menu
  void _showOptionsMenu(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: const Color(0xFFE91E63)),
                  title: Text(
                    'Edit Data Pasien',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    safeCloseDialog();
                    // Add edit functionality here
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Hapus Data Pasien',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    safeCloseDialog();
                    // Add delete functionality here
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Format date helper - Enhanced version
  String _formatDate(dynamic date) {
    try {
      if (date == null) return 'Tidak ada data';

      DateTime dateTime;

      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is DateTime) {
        dateTime = date;
      } else if (date is String) {
        if (date.isEmpty) return 'Tidak ada data';
        // Try to parse different string formats
        try {
          dateTime = DateTime.parse(date);
        } catch (e) {
          // Try other formats if parse fails
          try {
            dateTime = DateFormat('dd/MM/yyyy').parse(date);
          } catch (e2) {
            try {
              dateTime = DateFormat('yyyy-MM-dd').parse(date);
            } catch (e3) {
              try {
                dateTime = DateFormat('dd-MM-yyyy').parse(date);
              } catch (e4) {
                return 'Format tanggal tidak valid';
              }
            }
          }
        }
      } else if (date is int) {
        // Handle timestamp in milliseconds
        dateTime = DateTime.fromMillisecondsSinceEpoch(date);
      } else {
        return 'Format tanggal tidak valid';
      }

      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return 'Format tanggal tidak valid';
    }
  }

  // Format time only helper
  String _formatTime(dynamic time) {
    try {
      if (time == null) return 'Tidak ada data';

      if (time is String) {
        if (time.isEmpty) return 'Tidak ada data';

        // Check if it's already in HH:mm format
        if (RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) {
          return time;
        }

        // Check if it's in HH:mm:ss format
        if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(time)) {
          return time.substring(0, 5); // Take only HH:mm
        }

        // Try to parse as DateTime and extract time
        try {
          final dateTime = DateTime.parse(time);
          return DateFormat('HH:mm').format(dateTime);
        } catch (e) {
          return time.toString();
        }
      } else if (time is DateTime) {
        return DateFormat('HH:mm').format(time);
      } else if (time is Timestamp) {
        return DateFormat('HH:mm').format(time.toDate());
      }

      return time.toString();
    } catch (e) {
      print('Error formatting time: $e');
      return 'Format waktu tidak valid';
    }
  }

  // Validate and format data helper
  String _formatDataWithUnit(
    dynamic value,
    String unit, {
    String defaultText = 'Tidak ada data',
  }) {
    if (value == null || value.toString().isEmpty) return defaultText;
    return '${value.toString()} $unit';
  }

  // Build detail section for dialog
  Widget _buildDetailSection(
    String title,
    IconData icon,
    Color color,
    List<String> details,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details
              .map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    detail,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

// Childbirth Report Screen
class ChildbirthReportScreen extends StatelessWidget {
  final UserModel user;

  const ChildbirthReportScreen({super.key, required this.user});

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'Tidak ada data';

      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Format tanggal tidak valid';
      }

      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Laporan Persalinan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('laporan_persalinan')
                .where('pasienId', isEqualTo: user.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEC407A)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_hospital_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada laporan persalinan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laporan persalinan untuk ${user.nama} belum tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildReportCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFEC407A), const Color(0xFFF48FB1)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Laporan Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Tanggal Masuk',
                  _formatDate(data['tanggalMasuk']),
                ),
                _buildInfoRow(
                  'Nama Pasien',
                  data['pasienNama'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Alamat Pasien',
                  data['pasienAlamat'] ?? 'Tidak ada data',
                ),
                if (data['catatan'] != null && data['catatan'].isNotEmpty)
                  _buildInfoRow('Catatan', data['catatan']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

// Postpartum Report Screen
class PostpartumReportScreen extends StatelessWidget {
  final UserModel user;

  const PostpartumReportScreen({super.key, required this.user});

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'Tidak ada data';

      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Format tanggal tidak valid';
      }

      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Laporan Pasca Persalinan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFF48FB1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('laporan_pasca_persalinan')
                .where('pasienId', isEqualTo: user.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF48FB1)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada laporan pasca persalinan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laporan pasca persalinan untuk ${user.nama} belum tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildPostpartumCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostpartumCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFF48FB1), const Color(0xFFF8BBD9)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Laporan Pasca Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Tanggal Fundus Uterus',
                  _formatDate(data['tanggalFundusUterus']),
                ),
                _buildInfoRow(
                  'Tanggal Keluar',
                  _formatDate(data['tanggalKeluar']),
                ),
                _buildInfoRow(
                  'Jam Keluar',
                  data['jamKeluar'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Kondisi Keluar',
                  data['kondisiKeluar'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Tekanan Darah',
                  data['tekananDarah'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Suhu Badan',
                  data['suhuBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow('Nadi', data['nadi'] ?? 'Tidak ada data'),
                _buildInfoRow(
                  'Pernafasan',
                  data['pernafasan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Kelahiran Anak',
                  data['kelahiranAnak'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Jenis Kelamin',
                  data['jenisKelamin'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Berat Badan',
                  data['beratBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Panjang Badan',
                  data['panjangBadan'] ?? 'Tidak ada data',
                ),
                if (data['catatanKeluar'] != null &&
                    data['catatanKeluar'].isNotEmpty)
                  _buildInfoRow('Catatan Keluar', data['catatanKeluar']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

// Birth Certificate Screen
class BirthCertificateScreen extends StatelessWidget {
  final UserModel user;

  const BirthCertificateScreen({super.key, required this.user});

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'Tidak ada data';

      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Format tanggal tidak valid';
      }

      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  String _formatTime(dynamic timeValue) {
    try {
      if (timeValue == null || timeValue.toString().isEmpty)
        return 'Tidak ada data';
      return timeValue.toString();
    } catch (e) {
      return 'Format waktu tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Keterangan Kelahiran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFAB47BC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('keterangan_kelahiran')
                .where('pasienId', isEqualTo: user.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFAB47BC)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada keterangan kelahiran',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keterangan kelahiran untuk ${user.nama} belum tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildBirthCertificateCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildBirthCertificateCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFAB47BC), const Color(0xFFCE93D8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Keterangan Kelahiran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Nama Anak',
                  data['namaAnak'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Jenis Kelamin',
                  data['jenisKelamin'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Tanggal Lahir',
                  _formatDate(data['hariTanggalLahir']),
                ),
                _buildInfoRow('Jam Lahir', _formatTime(data['jamLahir'])),
                _buildInfoRow(
                  'Tempat Lahir',
                  data['tempatLahir'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Berat Badan',
                  data['beratBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Panjang Badan',
                  data['panjangBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Kelahiran Anak Ke',
                  '${data['kelahiranAnakKe'] ?? 1}',
                ),
                _buildInfoRow(
                  'Nama Ayah',
                  data['namaSuami'] ?? 'Tidak ada data',
                ),
                _buildInfoRow('Umur Ayah', '${data['umurSuami'] ?? 0} tahun'),
                _buildInfoRow(
                  'Agama Ayah',
                  data['agamaSuami'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Pekerjaan Ayah',
                  data['pekerjaanSuami'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Nama Ibu',
                  data['pasienNama'] ?? 'Tidak ada data',
                ),
                _buildInfoRow('Umur Ibu', '${data['pasienUmur'] ?? 0} tahun'),
                _buildInfoRow('Agama Ibu', data['agama'] ?? 'Tidak ada data'),
                _buildInfoRow(
                  'Pekerjaan Ibu',
                  data['pekerjaan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Alamat',
                  data['pasienAlamat'] ?? 'Tidak ada data',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
