import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/laporan_pasca_persalinan_model.dart';
import '../models/keterangan_kelahiran_model.dart';
import '../services/firebase_service.dart';
import '../services/pdf_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KeteranganKelahiranScreen extends StatefulWidget {
  final LaporanPascaPersalinanModel laporanPascaPersalinanData;

  const KeteranganKelahiranScreen({
    super.key,
    required this.laporanPascaPersalinanData,
  });

  @override
  State<KeteranganKelahiranScreen> createState() =>
      _KeteranganKelahiranScreenState();
}

class _KeteranganKelahiranScreenState extends State<KeteranganKelahiranScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _namaAnakController = TextEditingController();
  final _jamLahirController = TextEditingController();
  final _panjangBadanController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _kelahiranAnakKeController = TextEditingController(text: '1');

  // Father's data controllers
  final _umurSuamiController = TextEditingController();
  final _agamaSuamiController = TextEditingController();
  final _pekerjaanSuamiController = TextEditingController();

  // Data from previous forms
  DateTime _hariTanggalLahir = DateTime.now();
  String _jenisKelamin = 'laki-laki';

  // Data that will be auto-filled from database
  String _pasienNama = '';
  int _pasienUmur = 0;
  String _pasienAgama =
      'Islam'; // Default value since UserModel doesn't have agama
  String _pasienPekerjaan =
      'Ibu Rumah Tangga'; // Default value since UserModel doesn't have pekerjaan
  String _namaSuami = '';
  int _umurSuami = 0;
  String _agamaSuami =
      'Islam'; // Default value, will be updated from registrasi persalinan
  String _pekerjaanSuami =
      'Karyawan'; // Default value, will be updated from registrasi persalinan
  String _pasienAlamat = '';

  List<KeteranganKelahiranModel> _keteranganList = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Load data with retry mechanism
      await _loadDataFromDatabase();
      await _loadKeteranganKelahiran();
    } catch (e) {
      print('Error during initialization: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data awal: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _initializeData,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaAnakController.dispose();
    _jamLahirController.dispose();
    _panjangBadanController.dispose();
    _beratBadanController.dispose();
    _kelahiranAnakKeController.dispose();
    _umurSuamiController.dispose();
    _agamaSuamiController.dispose();
    _pekerjaanSuamiController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      // Load patient data for parent information
      final registrasiData = await _firebaseService
          .getPersalinanById(
            widget.laporanPascaPersalinanData.laporanPersalinanId,
          )
          .timeout(const Duration(seconds: 30));

      if (registrasiData != null) {
        // Load mother's data from users collection
        final userData = await _firebaseService
            .getUserById(registrasiData.pasienId)
            .timeout(const Duration(seconds: 30));

        if (userData != null) {
          setState(() {
            // Mother's data from users collection
            _pasienNama = userData.nama;
            _pasienUmur = userData.umur;
            _pasienAlamat = userData.alamat;

            // Father's data from persalinan collection
            _namaSuami = registrasiData.namaSuami;
            _pekerjaanSuami = registrasiData.pekerjaan;

            // Set father's data controllers with loaded values
            _umurSuamiController.text = _umurSuami.toString();
            _agamaSuamiController.text = _agamaSuami;
            _pekerjaanSuamiController.text = _pekerjaanSuami;
          });
        } else {
          // Fallback if user data not found
          setState(() {
            _pasienNama = 'Data tidak ditemukan';
            _pasienUmur = 0;
            _pasienAlamat = 'Data tidak ditemukan';
          });
        }
      } else {
        // Fallback if registrasi data not found
        setState(() {
          _namaSuami = 'Data tidak ditemukan';
          _pekerjaanSuami = 'Data tidak ditemukan';
        });
      }

      // Pre-fill some data from previous form
      setState(() {
        _jenisKelamin = widget.laporanPascaPersalinanData.jenisKelamin;
        _panjangBadanController.text =
            widget.laporanPascaPersalinanData.panjangBadan;
        _beratBadanController.text =
            widget.laporanPascaPersalinanData.beratBadan;
      });

      // Try to get father's detailed information from pregnancy examination
      await _loadFatherDataFromPregnancyExamination();
    } catch (e) {
      print('Error in _loadDataFromDatabase: $e');
      if (mounted) {
        // Show error but don't block the UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Warning: Beberapa data tidak dapat dimuat: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadDataFromDatabase,
            ),
          ),
        );
      }
    }
  }

  // Load father's detailed data from pregnancy examination
  Future<void> _loadFatherDataFromPregnancyExamination() async {
    try {
      // Get registrasi persalinan data to find the patient ID
      final registrasiData = await _firebaseService
          .getPersalinanById(
            widget.laporanPascaPersalinanData.laporanPersalinanId,
          )
          .timeout(const Duration(seconds: 20));

      if (registrasiData != null) {
        // Look for pregnancy examination data for this patient
        final pregnancyExaminationSnapshot = await FirebaseFirestore.instance
            .collection('pemeriksaan_ibu_hamil')
            .where('pasienId', isEqualTo: registrasiData.pasienId)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 15));

        if (pregnancyExaminationSnapshot.docs.isNotEmpty) {
          final examinationData =
              pregnancyExaminationSnapshot.docs.first.data();

          // Update father's data if available in examination
          setState(() {
            if (examinationData['namaSuami'] != null &&
                examinationData['namaSuami'].toString().isNotEmpty) {
              _namaSuami = examinationData['namaSuami'];
            }
            if (examinationData['umurSuami'] != null) {
              _umurSuami = examinationData['umurSuami'];
              _umurSuamiController.text = _umurSuami.toString();
            }
            if (examinationData['pekerjaanSuami'] != null &&
                examinationData['pekerjaanSuami'].toString().isNotEmpty) {
              _pekerjaanSuami = examinationData['pekerjaanSuami'];
              _pekerjaanSuamiController.text = _pekerjaanSuami;
            }
            if (examinationData['agamaSuami'] != null &&
                examinationData['agamaSuami'].toString().isNotEmpty) {
              _agamaSuami = examinationData['agamaSuami'];
              _agamaSuamiController.text = _agamaSuami;
            }
          });
        }
      }
    } catch (e) {
      print('Error loading father data from pregnancy examination: $e');
      // Don't show error to user, just use default values
      // This is not critical data, so we can continue with defaults
    }
  }

  Future<void> _loadKeteranganKelahiran() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to load data with timeout and fallback
      final stream = _firebaseService
          .getKeteranganKelahiranByLaporanPascaId(
            widget.laporanPascaPersalinanData.id,
          )
          .timeout(const Duration(seconds: 20));

      await for (final keteranganList in stream) {
        if (mounted) {
          setState(() {
            _keteranganList = keteranganList;
            _isLoading = false;
          });
        }
        break; // Exit after first successful load
      }
    } catch (e) {
      print('Error loading keterangan kelahiran: $e');

      // Try fallback method - direct query instead of stream
      try {
        await _loadKeteranganKelahiranFallback();
      } catch (fallbackError) {
        print('Fallback method also failed: $fallbackError');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _keteranganList = []; // Empty list if all methods fail
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat memuat data: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: _loadKeteranganKelahiran,
              ),
            ),
          );
        }
      }
    }
  }

  // Fallback method using direct Firestore query
  Future<void> _loadKeteranganKelahiranFallback() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('keterangan_kelahiran')
          .where(
            'laporanPascaPersalinanId',
            isEqualTo: widget.laporanPascaPersalinanData.id,
          )
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 15));

      final List<KeteranganKelahiranModel> keteranganList = [];

      for (final doc in snapshot.docs) {
        try {
          final keterangan = KeteranganKelahiranModel.fromMap({
            'id': doc.id,
            ...doc.data(),
          });
          keteranganList.add(keterangan);
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _keteranganList = keteranganList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Fallback method failed: $e');
      throw e; // Re-throw to be handled by caller
    }
  }

  Future<void> _saveKeteranganKelahiran() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final keterangan = KeteranganKelahiranModel(
        id: _firebaseService.generateId(),
        laporanPascaPersalinanId: widget.laporanPascaPersalinanData.id,
        pasienId: widget.laporanPascaPersalinanData.pasienId,
        namaAnak: _namaAnakController.text.trim(),
        hariTanggalLahir: _hariTanggalLahir,
        jamLahir: _jamLahirController.text.trim(),
        tempatLahir: 'PMB Umiyatun S.ST', // Fixed value as requested
        jenisKelamin: _jenisKelamin,
        panjangBadan: _panjangBadanController.text.trim(),
        beratBadan: _beratBadanController.text.trim(),
        kelahiranAnakKe: int.tryParse(_kelahiranAnakKeController.text) ?? 1,
        pasienNama: _pasienNama,
        pasienUmur: _pasienUmur,
        agama: _pasienAgama,
        pekerjaan: _pasienPekerjaan,
        namaSuami: _namaSuami,
        umurSuami: int.tryParse(_umurSuamiController.text) ?? _umurSuami,
        agamaSuami:
            _agamaSuamiController.text.isNotEmpty
                ? _agamaSuamiController.text
                : _agamaSuami,
        pekerjaanSuami:
            _pekerjaanSuamiController.text.isNotEmpty
                ? _pekerjaanSuamiController.text
                : _pekerjaanSuami,
        pasienAlamat: _pasienAlamat,
        createdAt: DateTime.now(),
      );

      await _firebaseService.createKeteranganKelahiran(keterangan);

      // Clear form
      _clearForm();

      if (mounted) {
        // Show success alert
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keterangan kelahiran berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait for 2 seconds then navigate back to home
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            try {
              // Try to navigate using named route first
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home-admin', (route) => false);
            } catch (e) {
              // Fallback: pop all routes to go back to home
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _clearForm() {
    _namaAnakController.clear();
    _jamLahirController.clear();
    _kelahiranAnakKeController.text = '1';
    _umurSuamiController.clear();
    _agamaSuamiController.clear();
    _pekerjaanSuamiController.clear();

    setState(() {
      _hariTanggalLahir = DateTime.now();
      _jenisKelamin = 'laki-laki';
    });
  }

  Future<void> _downloadKeteranganKelahiran() async {
    if (_keteranganList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data keterangan kelahiran untuk diunduh'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: Color(0xFFEC407A)),
                SizedBox(width: 20),
                Text('Membuat PDF...'),
              ],
            ),
          );
        },
      );

      // Generate PDF for the first keterangan (most recent)
      final keterangan = _keteranganList.first;
      await PdfService.generateKeteranganKelahiranPDF(keterangan);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF berhasil dibuat dan dapat diunduh'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuat PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEC407A), width: 2),
          ),
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEC407A), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker({
    required DateTime selectedDate,
    required String label,
    required Function(DateTime) onDateSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            onDateSelected(date);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFFEC407A)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    DateFormat(
                      'EEEE, dd MMMM yyyy',
                      'id_ID',
                    ).format(selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFEC407A),
        ),
      ),
    );
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
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEC407A),
                    const Color(0xFFEC407A).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.child_care_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keterangan Kelahiran',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Surat keterangan kelahiran anak',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Download button in header
                      if (_keteranganList.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _downloadKeteranganKelahiran,
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Download PDF',
                          ),
                        ),

                      // Refresh button
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _initializeData,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'Refresh Data',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Section
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEC407A),
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Form Container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Keterangan Kelahiran',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Telah lahir seorang anak:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                    // Data Anak Section
                                    _buildSectionTitle('DATA ANAK'),
                                    _buildTextField(
                                      controller: _namaAnakController,
                                      label: 'Nama',
                                      validator:
                                          (value) =>
                                              value?.isEmpty == true
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),
                                    _buildDatePicker(
                                      selectedDate: _hariTanggalLahir,
                                      label: 'Hari/Tanggal Lahir',
                                      onDateSelected: (date) {
                                        setState(() {
                                          _hariTanggalLahir = date;
                                        });
                                      },
                                    ),
                                    _buildTextField(
                                      controller: _jamLahirController,
                                      label: 'Jam Lahir',
                                      suffix: 'WIB',
                                      validator:
                                          (value) =>
                                              value?.isEmpty == true
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),
                                    _buildReadOnlyField(
                                      'Tempat Lahir',
                                      'PMB Umiyatun S.ST',
                                    ),
                                    _buildDropdown(
                                      value: _jenisKelamin,
                                      items: ['laki-laki', 'perempuan'],
                                      label: 'Jenis Kelamin',
                                      onChanged: (value) {
                                        setState(() {
                                          _jenisKelamin = value!;
                                        });
                                      },
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _panjangBadanController,
                                            label: 'Panjang Badan',
                                            suffix: 'cm',
                                            keyboardType: TextInputType.number,
                                            validator:
                                                (value) =>
                                                    value?.isEmpty == true
                                                        ? 'Wajib diisi'
                                                        : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _beratBadanController,
                                            label: 'Berat Badan',
                                            suffix: 'gram',
                                            keyboardType: TextInputType.number,
                                            validator:
                                                (value) =>
                                                    value?.isEmpty == true
                                                        ? 'Wajib diisi'
                                                        : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildTextField(
                                      controller: _kelahiranAnakKeController,
                                      label: 'Kelahiran Anak Ke',
                                      keyboardType: TextInputType.number,
                                      validator:
                                          (value) =>
                                              value?.isEmpty == true
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),

                                    // Data Ibu Section
                                    _buildSectionTitle(
                                      'IBU (Data otomatis terisi sesuai database)',
                                    ),
                                    _buildReadOnlyField(
                                      'Nama Ibu',
                                      _pasienNama,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildReadOnlyField(
                                            'Umur Ibu',
                                            '$_pasienUmur tahun',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildReadOnlyField(
                                            'Agama Ibu',
                                            _pasienAgama,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildReadOnlyField(
                                      'Pekerjaan Ibu',
                                      _pasienPekerjaan,
                                    ),
                                    _buildReadOnlyField(
                                      'Alamat Ibu',
                                      _pasienAlamat,
                                    ),

                                    // Data Ayah Section
                                    _buildSectionTitle(
                                      'AYAH (Data dapat diubah)',
                                    ),
                                    _buildReadOnlyField(
                                      'Nama Ayah',
                                      _namaSuami,
                                    ),
                                    _buildTextField(
                                      controller: _umurSuamiController,
                                      label: 'Umur Ayah',
                                      keyboardType: TextInputType.number,
                                      validator:
                                          (value) =>
                                              value?.isEmpty == true
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),
                                    _buildTextField(
                                      controller: _agamaSuamiController,
                                      label: 'Agama Ayah',
                                      keyboardType: TextInputType.text,
                                      validator:
                                          (value) =>
                                              value?.isEmpty == true
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),
                                    _buildTextField(
                                      controller: _pekerjaanSuamiController,
                                      label: 'Pekerjaan Ayah',
                                      keyboardType: TextInputType.text,
                                      validator:
                                          (value) =>
                                              value?.isEmpty == true
                                                  ? 'Wajib diisi'
                                                  : null,
                                    ),

                                    const SizedBox(height: 20),

                                    // Save Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isSaving
                                                ? null
                                                : _saveKeteranganKelahiran,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFEC407A,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                        child:
                                            _isSaving
                                                ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                                : Text(
                                                  'Simpan',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                      ),
                                    ),

                                    // Download Button
                                    if (_keteranganList.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              _downloadKeteranganKelahiran,
                                          icon: const Icon(
                                            Icons.download,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'Download PDF',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF10B981,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // List Keterangan yang sudah disimpan
                            if (_keteranganList.isNotEmpty) ...[
                              const SizedBox(height: 30),
                              Text(
                                'Keterangan Kelahiran Tersimpan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 16),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _keteranganList.length,
                                itemBuilder: (context, index) {
                                  final keterangan = _keteranganList[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFEC407A,
                                                ).withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.child_care_rounded,
                                                color: Color(0xFFEC407A),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    keterangan.namaAnak,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                        0xFF2D3748,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                      'dd MMM yyyy, HH:mm',
                                                    ).format(
                                                      keterangan.createdAt,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Jenis Kelamin: ${keterangan.jenisKelamin}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFF2D3748),
                                          ),
                                        ),
                                        Text(
                                          'Berat: ${keterangan.beratBadan} gram, Panjang: ${keterangan.panjangBadan} cm',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFF2D3748),
                                          ),
                                        ),
                                        Text(
                                          'Tanggal Lahir: ${DateFormat('dd MMMM yyyy').format(keterangan.hariTanggalLahir)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFF2D3748),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              try {
                                                // Show loading indicator
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return const AlertDialog(
                                                      content: Row(
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color: Color(
                                                              0xFFEC407A,
                                                            ),
                                                          ),
                                                          SizedBox(width: 20),
                                                          Text(
                                                            'Membuat PDF...',
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );

                                                await PdfService.generateKeteranganKelahiranPDF(
                                                  keterangan,
                                                );

                                                // Close loading dialog
                                                if (mounted) {
                                                  Navigator.of(context).pop();

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'PDF berhasil dibuat dan dapat diunduh',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                // Close loading dialog
                                                if (mounted) {
                                                  Navigator.of(context).pop();

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error membuat PDF: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.download,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            label: Text(
                                              'Download PDF',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF10B981,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              elevation: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
