import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/user_model.dart';
import '../models/persalinan_model.dart';
import '../models/laporan_persalinan_model.dart';
import '../models/laporan_pasca_persalinan_model.dart';
import '../models/keterangan_kelahiran_model.dart';
import '../utilities/safe_navigation.dart';
import 'detail_screens.dart';

class DataPersalinanScreen extends StatefulWidget {
  const DataPersalinanScreen({super.key});

  @override
  State<DataPersalinanScreen> createState() => _DataPersalinanScreenState();
}

class _DataPersalinanScreenState extends State<DataPersalinanScreen>
    with SafeNavigationMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModel> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize Indonesian locale for date formatting
    initializeDateFormatting('id_ID', null);
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all patients who have delivery data
      final patientsQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'pasien')
              .get();

      List<UserModel> patientsWithDelivery = [];

      for (var doc in patientsQuery.docs) {
        final patient = UserModel.fromMap({'id': doc.id, ...doc.data()});

        // Check if patient has any delivery-related data
        final hasRegistrasi = await _hasDeliveryRegistration(patient.id);
        final hasLaporanPersalinan = await _hasDeliveryReport(patient.id);
        final hasLaporanPasca = await _hasPostDeliveryReport(patient.id);
        final hasKelahiran = await _hasBirthCertificate(patient.id);

        if (hasRegistrasi ||
            hasLaporanPersalinan ||
            hasLaporanPasca ||
            hasKelahiran) {
          patientsWithDelivery.add(patient);
        }
      }

      setState(() {
        _patients = patientsWithDelivery;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _hasDeliveryRegistration(String patientId) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('persalinan')
              .where('pasienId', isEqualTo: patientId)
              .limit(1)
              .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasDeliveryReport(String patientId) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('laporan_persalinan')
              .where('pasienId', isEqualTo: patientId)
              .limit(1)
              .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasPostDeliveryReport(String patientId) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('laporan_pasca_persalinan')
              .where('pasienId', isEqualTo: patientId)
              .limit(1)
              .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasBirthCertificate(String patientId) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('keterangan_kelahiran')
              .where('pasienId', isEqualTo: patientId)
              .limit(1)
              .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  List<UserModel> get filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    return _patients.where((patient) {
      return patient.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          patient.noHp.contains(_searchQuery);
    }).toList();
  }

  int _getBpjsCount() {
    return _patients.where((patient) => patient.jenisAsuransi == 'bpjs').length;
  }

  int _getUmumCount() {
    return _patients
        .where(
          (patient) =>
              patient.jenisAsuransi == 'umum' || patient.jenisAsuransi == null,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Riwayat Persalinan',
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
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
                        hintText: 'Cari nama pasien atau nomor HP...',
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
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Pasien',
                          _patients.length.toString(),
                          Icons.circle,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'BPJS',
                          _getBpjsCount().toString(),
                          Icons.circle,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Umum',
                          _getUmumCount().toString(),
                          Icons.circle,
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Patient List
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFEC407A),
                      ),
                    )
                    : filteredPatients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        return _buildPatientCard(patient);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEC407A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEC407A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.baby_changing_station,
              size: 60,
              color: Color(0xFFEC407A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Data Persalinan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data riwayat persalinan akan ditampilkan di sini',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(UserModel patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Expanded(
                child: Text(
                  patient.nama,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    _showDeletePatientDialog(patient);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${patient.umur} tahun',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                patient.noHp,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            patient.alamat,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToPatientDetail(patient),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Lihat Detail',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPatientDetail(UserModel patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDeliveryDetailScreen(patient: patient),
      ),
    );
  }

  void _showDeletePatientDialog(UserModel patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Hapus Data Persalinan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus semua data persalinan untuk ${patient.nama}?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deletePatientDeliveryData(patient.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Hapus', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  Future<void> _deletePatientDeliveryData(String patientId) async {
    try {
      // Delete from all collections
      final collections = [
        'persalinan',
        'laporan_persalinan',
        'laporan_pasca_persalinan',
        'keterangan_kelahiran',
      ];

      for (String collection in collections) {
        final query =
            await FirebaseFirestore.instance
                .collection(collection)
                .where('pasienId', isEqualTo: patientId)
                .get();

        for (var doc in query.docs) {
          await doc.reference.delete();
        }
      }

      _loadPatients(); // Refresh list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data persalinan berhasil dihapus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Patient Detail Screen showing all delivery-related data
class PatientDeliveryDetailScreen extends StatefulWidget {
  final UserModel patient;

  const PatientDeliveryDetailScreen({super.key, required this.patient});

  @override
  State<PatientDeliveryDetailScreen> createState() =>
      _PatientDeliveryDetailScreenState();
}

class _PatientDeliveryDetailScreenState
    extends State<PatientDeliveryDetailScreen> {
  List<PersalinanModel> _registrasiData = [];
  List<LaporanPersalinanModel> _laporanPersalinan = [];
  List<LaporanPascaPersalinanModel> _laporanPasca = [];
  List<KeteranganKelahiranModel> _keteranganKelahiran = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all delivery-related data
      await Future.wait([
        _loadRegistrasiData(),
        _loadLaporanPersalinan(),
        _loadLaporanPasca(),
        _loadKeteranganKelahiran(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRegistrasiData() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('persalinan')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      _registrasiData =
          query.docs
              .map(
                (doc) => PersalinanModel.fromMap({'id': doc.id, ...doc.data()}),
              )
              .toList();
    } catch (e) {
      print('Error loading registrasi data: $e');
    }
  }

  Future<void> _loadLaporanPersalinan() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('laporan_persalinan')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      _laporanPersalinan =
          query.docs
              .map(
                (doc) => LaporanPersalinanModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }),
              )
              .toList();
    } catch (e) {
      print('Error loading laporan persalinan: $e');
    }
  }

  Future<void> _loadLaporanPasca() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('laporan_pasca_persalinan')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      _laporanPasca =
          query.docs
              .map(
                (doc) => LaporanPascaPersalinanModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }),
              )
              .toList();
    } catch (e) {
      print('Error loading laporan pasca: $e');
    }
  }

  Future<void> _loadKeteranganKelahiran() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('keterangan_kelahiran')
              .where('pasienId', isEqualTo: widget.patient.id)
              .get();

      _keteranganKelahiran =
          query.docs
              .map(
                (doc) => KeteranganKelahiranModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }),
              )
              .toList();
    } catch (e) {
      print('Error loading keterangan kelahiran: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.patient.nama,
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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFEC407A)),
              )
              : SingleChildScrollView(
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
                    if (_registrasiData.isEmpty)
                      _buildEmptyCard('Belum ada data registrasi persalinan')
                    else
                      ..._registrasiData
                          .map((data) => _buildRegistrasiCard(data))
                          .toList(),

                    const SizedBox(height: 24),

                    // Laporan Persalinan Section
                    _buildSectionHeader('Laporan Persalinan', Icons.assignment),
                    const SizedBox(height: 16),
                    if (_laporanPersalinan.isEmpty)
                      _buildEmptyCard('Belum ada laporan persalinan')
                    else
                      ..._laporanPersalinan
                          .map((data) => _buildLaporanPersalinanCard(data))
                          .toList(),

                    const SizedBox(height: 24),

                    // Laporan Pasca Persalinan Section
                    _buildSectionHeader(
                      'Laporan Pasca Persalinan',
                      Icons.healing,
                    ),
                    const SizedBox(height: 16),
                    if (_laporanPasca.isEmpty)
                      _buildEmptyCard('Belum ada laporan pasca persalinan')
                    else
                      ..._laporanPasca
                          .map((data) => _buildLaporanPascaCard(data))
                          .toList(),

                    const SizedBox(height: 24),

                    // Keterangan Kelahiran Section
                    _buildSectionHeader(
                      'Keterangan Kelahiran',
                      Icons.child_care,
                    ),
                    const SizedBox(height: 16),
                    if (_keteranganKelahiran.isEmpty)
                      _buildEmptyCard('Belum ada keterangan kelahiran')
                    else
                      ..._keteranganKelahiran
                          .map((data) => _buildKeteranganKelahiranCard(data))
                          .toList(),
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

  Widget _buildRegistrasiCard(PersalinanModel data) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Registrasi Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteRegistrasi(data.id);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
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
              onPressed: () => _showRegistrasiDetail(data),
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

  Widget _buildLaporanPersalinanCard(LaporanPersalinanModel data) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Laporan Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteLaporanPersalinan(data.id);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
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

  Widget _buildLaporanPascaCard(LaporanPascaPersalinanModel data) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Laporan Pasca Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteLaporanPasca(data.id);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
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
              onPressed: () => _showLaporanPascaDetail(data),
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

  Widget _buildKeteranganKelahiranCard(KeteranganKelahiranModel data) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Keterangan Kelahiran',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteKeteranganKelahiran(data.id);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Anak', data.namaAnak),
          _buildInfoRow(
            'Tanggal Lahir',
            DateFormat('dd/MM/yyyy').format(data.hariTanggalLahir),
          ),
          _buildInfoRow('Jam Lahir', data.jamLahir),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showKeteranganKelahiranDetail(data),
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
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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

  // Delete methods
  Future<void> _deleteRegistrasi(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('persalinan')
          .doc(id)
          .delete();
      _loadData();
      _showSuccessMessage('Registrasi persalinan berhasil dihapus');
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  Future<void> _deleteLaporanPersalinan(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('laporan_persalinan')
          .doc(id)
          .delete();
      _loadData();
      _showSuccessMessage('Laporan persalinan berhasil dihapus');
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  Future<void> _deleteLaporanPasca(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('laporan_pasca_persalinan')
          .doc(id)
          .delete();
      _loadData();
      _showSuccessMessage('Laporan pasca persalinan berhasil dihapus');
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  Future<void> _deleteKeteranganKelahiran(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('keterangan_kelahiran')
          .doc(id)
          .delete();
      _loadData();
      _showSuccessMessage('Keterangan kelahiran berhasil dihapus');
    } catch (e) {
      _showErrorMessage('Error: $e');
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Detail navigation methods
  void _showRegistrasiDetail(PersalinanModel data) {
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
  }

  void _showLaporanPascaDetail(LaporanPascaPersalinanModel data) {
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
  }

  void _showKeteranganKelahiranDetail(KeteranganKelahiranModel data) {
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
  }
}
