import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/laporan_persalinan_model.dart';
import '../models/laporan_pasca_persalinan_model.dart';
import '../services/firebase_service.dart';
import 'keterangan_kelahiran.dart';
import '../utilities/safe_navigation.dart';

class LaporanPascaPersalinanScreen extends StatefulWidget {
  final LaporanPersalinanModel laporanPersalinanData;

  const LaporanPascaPersalinanScreen({
    super.key,
    required this.laporanPersalinanData,
  });

  @override
  State<LaporanPascaPersalinanScreen> createState() =>
      _LaporanPascaPersalinanScreenState();
}

class _LaporanPascaPersalinanScreenState
    extends State<LaporanPascaPersalinanScreen>
    with SafeNavigationMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _tekananDarahController = TextEditingController();
  final _suhuBadanController = TextEditingController();
  final _nadiController = TextEditingController();
  final _pernafasanController = TextEditingController();
  final _kontraksiController = TextEditingController();
  final _pendarahanKalaIIIController = TextEditingController();
  final _pendarahanKalaIVController = TextEditingController();

  // Keadaan Anak
  String _kelahiranAnak = 'hidup';
  final _sebabMatiController = TextEditingController();
  String _jenisKelamin = 'laki-laki';
  final _beratBadanController = TextEditingController();
  final _panjangBadanController = TextEditingController();
  final _lingkarKepalaController = TextEditingController();
  final _lingkarDadaController = TextEditingController();
  String _kelainan = 'tidak';
  final _detailKelainanController = TextEditingController();

  // APGAR Score
  final _apgarSkorController = TextEditingController(text: '9/10');
  final _apgarCatatanController = TextEditingController();

  // Placenta
  final _placentaBentukController = TextEditingController();
  final _placentaPanjangController = TextEditingController();
  final _placentaLebarController = TextEditingController();
  final _placentaTebalController = TextEditingController();
  final _placentaBeratController = TextEditingController();
  final _panjangTaliPusatController = TextEditingController();

  // Keadaan Penderita Keluar
  DateTime _tanggalFundusUterus = DateTime.now();
  DateTime _tanggalKeluar = DateTime.now();
  final _jamKeluarController = TextEditingController();
  String _kondisiKeluar = 'sembuh';
  final _sebabMeninggalController = TextEditingController();
  final _namaRSController = TextEditingController();
  final _sebabKeluarPaksaController = TextEditingController();
  final _catatanKeluarController = TextEditingController();

  List<LaporanPascaPersalinanModel> _laporanPascaList = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLaporanPascaPersalinan();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _tekananDarahController.dispose();
    _suhuBadanController.dispose();
    _nadiController.dispose();
    _pernafasanController.dispose();
    _kontraksiController.dispose();
    _pendarahanKalaIIIController.dispose();
    _pendarahanKalaIVController.dispose();
    _sebabMatiController.dispose();
    _beratBadanController.dispose();
    _panjangBadanController.dispose();
    _lingkarKepalaController.dispose();
    _lingkarDadaController.dispose();
    _detailKelainanController.dispose();
    _apgarSkorController.dispose();
    _apgarCatatanController.dispose();
    _placentaBentukController.dispose();
    _placentaPanjangController.dispose();
    _placentaLebarController.dispose();
    _placentaTebalController.dispose();
    _placentaBeratController.dispose();
    _panjangTaliPusatController.dispose();
    _jamKeluarController.dispose();
    _sebabMeninggalController.dispose();
    _namaRSController.dispose();
    _sebabKeluarPaksaController.dispose();
    _catatanKeluarController.dispose();
    super.dispose();
  }

  Future<void> _loadLaporanPascaPersalinan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _firebaseService
          .getLaporanPascaPersalinanByLaporanId(widget.laporanPersalinanData.id)
          .timeout(const Duration(seconds: 30)) // Increased timeout
          .listen(
            (laporanList) {
              if (mounted) {
                setState(() {
                  _laporanPascaList = laporanList;
                  _isLoading = false;
                });
              }
            },
            onError: (error) {
              print('Error loading laporan pasca persalinan: $error');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  // Set empty list on error to allow user to continue
                  _laporanPascaList = [];
                });

                // Only show error for critical issues, not timeout
                if (!error.toString().toLowerCase().contains('timeout') &&
                    !error.toString().toLowerCase().contains('time limit')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gagal memuat data tersimpan: ${error.toString()}',
                      ),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Coba Lagi',
                        textColor: Colors.white,
                        onPressed: _loadLaporanPascaPersalinan,
                      ),
                    ),
                  );
                }
              }
            },
          );
    } catch (e) {
      print('Exception in _loadLaporanPascaPersalinan: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _laporanPascaList = [];
        });

        // Only show error for critical issues, not timeout
        if (!e.toString().toLowerCase().contains('timeout') &&
            !e.toString().toLowerCase().contains('time limit')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat data: ${e.toString()}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Coba Lagi',
                textColor: Colors.white,
                onPressed: _loadLaporanPascaPersalinan,
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveLaporanPascaPersalinan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final laporanPasca = LaporanPascaPersalinanModel(
        id: _firebaseService.generateId(),
        laporanPersalinanId: widget.laporanPersalinanData.id,
        pasienId: widget.laporanPersalinanData.pasienId,
        pasienNama: widget.laporanPersalinanData.pasienNama,
        tekananDarah: _tekananDarahController.text.trim(),
        suhuBadan: _suhuBadanController.text.trim(),
        nadi: _nadiController.text.trim(),
        pernafasan: _pernafasanController.text.trim(),
        tanggalFundusUterus: _tanggalFundusUterus,
        kontraksi: _kontraksiController.text.trim(),
        pendarahanKalaIII: _pendarahanKalaIIIController.text.trim(),
        pendarahanKalaIV: _pendarahanKalaIVController.text.trim(),
        kelahiranAnak: _kelahiranAnak,
        sebabMati:
            _kelahiranAnak == 'mati' ? _sebabMatiController.text.trim() : null,
        jenisKelamin: _jenisKelamin,
        beratBadan: _beratBadanController.text.trim(),
        panjangBadan: _panjangBadanController.text.trim(),
        lingkarKepala: _lingkarKepalaController.text.trim(),
        lingkarDada: _lingkarDadaController.text.trim(),
        kelainan: _kelainan,
        detailKelainan:
            _kelainan == 'ya' ? _detailKelainanController.text.trim() : null,
        apgarSkor: _apgarSkorController.text.trim(),
        apgarCatatan: _apgarCatatanController.text.trim(),
        placentaBentuk: _placentaBentukController.text.trim(),
        placentaPanjang: _placentaPanjangController.text.trim(),
        placentaLebar: _placentaLebarController.text.trim(),
        placentaTebal: _placentaTebalController.text.trim(),
        placentaBerat: _placentaBeratController.text.trim(),
        panjangTaliPusat: _panjangTaliPusatController.text.trim(),
        tanggalKeluar: _tanggalKeluar,
        jamKeluar: _jamKeluarController.text.trim(),
        kondisiKeluar: _kondisiKeluar,
        sebabMeninggal:
            _kondisiKeluar == 'meninggal'
                ? _sebabMeninggalController.text.trim()
                : null,
        namaRS:
            _kondisiKeluar == 'dipindahkan'
                ? _namaRSController.text.trim()
                : null,
        sebabKeluarPaksa:
            _kondisiKeluar == 'keluar_paksa'
                ? _sebabKeluarPaksaController.text.trim()
                : null,
        catatanKeluar: _catatanKeluarController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firebaseService.createLaporanPascaPersalinan(laporanPasca);

      // Clear form
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan pasca persalinan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
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
    _tekananDarahController.clear();
    _suhuBadanController.clear();
    _nadiController.clear();
    _pernafasanController.clear();
    _kontraksiController.clear();
    _pendarahanKalaIIIController.clear();
    _pendarahanKalaIVController.clear();
    _sebabMatiController.clear();
    _beratBadanController.clear();
    _panjangBadanController.clear();
    _lingkarKepalaController.clear();
    _lingkarDadaController.clear();
    _detailKelainanController.clear();
    _apgarCatatanController.clear();
    _placentaBentukController.clear();
    _placentaPanjangController.clear();
    _placentaLebarController.clear();
    _placentaTebalController.clear();
    _placentaBeratController.clear();
    _panjangTaliPusatController.clear();
    _jamKeluarController.clear();
    _sebabMeninggalController.clear();
    _namaRSController.clear();
    _sebabKeluarPaksaController.clear();
    _catatanKeluarController.clear();

    setState(() {
      _kelahiranAnak = 'hidup';
      _jenisKelamin = 'laki-laki';
      _kelainan = 'tidak';
      _kondisiKeluar = 'sembuh';
      _tanggalFundusUterus = DateTime.now();
      _tanggalKeluar = DateTime.now();
    });
  }

  void _navigateToKeteranganKelahiran(
    LaporanPascaPersalinanModel laporanPasca,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => KeteranganKelahiranScreen(
              laporanPascaPersalinanData: laporanPasca,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEC407A), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
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
                    DateFormat('dd/MM/yyyy').format(selectedDate),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC407A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => NavigationHelper.safeNavigateBack(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  borderRadius: BorderRadius.circular(16),
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
                            Icons.medical_services_rounded,
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
                                'Laporan Pasca Persalinan',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Data lengkap pasca persalinan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
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
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tambah Laporan Pasca Persalinan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2D3748),
                                        ),
                                      ),

                                      // Data Ibu Section
                                      _buildSectionTitle('DATA IBU'),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller:
                                                  _tekananDarahController,
                                              label: 'Tekanan Darah',
                                              suffix: 'mmHg',
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
                                              controller: _suhuBadanController,
                                              label: 'Suhu Badan',
                                              suffix: '°C',
                                              keyboardType:
                                                  TextInputType.number,
                                              validator:
                                                  (value) =>
                                                      value?.isEmpty == true
                                                          ? 'Wajib diisi'
                                                          : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller: _nadiController,
                                              label: 'Nadi',
                                              suffix: 'x/mnt',
                                              keyboardType:
                                                  TextInputType.number,
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
                                              controller: _pernafasanController,
                                              label: 'Pernafasan',
                                              suffix: '/mnt',
                                              keyboardType:
                                                  TextInputType.number,
                                              validator:
                                                  (value) =>
                                                      value?.isEmpty == true
                                                          ? 'Wajib diisi'
                                                          : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildDatePicker(
                                        selectedDate: _tanggalFundusUterus,
                                        label: 'Tanggal Fundus Uterus',
                                        onDateSelected: (date) {
                                          setState(() {
                                            _tanggalFundusUterus = date;
                                          });
                                        },
                                      ),
                                      _buildTextField(
                                        controller: _kontraksiController,
                                        label: 'Kontraksi',
                                        validator:
                                            (value) =>
                                                value?.isEmpty == true
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller:
                                                  _pendarahanKalaIIIController,
                                              label: 'Pendarahan Kala III',
                                              suffix: 'ml',
                                              keyboardType:
                                                  TextInputType.number,
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
                                              controller:
                                                  _pendarahanKalaIVController,
                                              label: 'Pendarahan Kala IV',
                                              suffix: 'ml',
                                              keyboardType:
                                                  TextInputType.number,
                                              validator:
                                                  (value) =>
                                                      value?.isEmpty == true
                                                          ? 'Wajib diisi'
                                                          : null,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Keadaan Anak Section
                                      _buildSectionTitle('KEADAAN ANAK'),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDropdown(
                                              value: _kelahiranAnak,
                                              items: ['hidup', 'mati'],
                                              label: 'Lahir',
                                              onChanged: (value) {
                                                setState(() {
                                                  _kelahiranAnak = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          if (_kelahiranAnak == 'mati') ...[
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildTextField(
                                                controller:
                                                    _sebabMatiController,
                                                label: 'Sebab Mati',
                                                validator:
                                                    (value) =>
                                                        _kelahiranAnak ==
                                                                    'mati' &&
                                                                value?.isEmpty ==
                                                                    true
                                                            ? 'Wajib diisi'
                                                            : null,
                                              ),
                                            ),
                                          ],
                                        ],
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
                                              controller: _beratBadanController,
                                              label: 'Berat Badan',
                                              suffix: 'gram',
                                              keyboardType:
                                                  TextInputType.number,
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
                                              controller:
                                                  _panjangBadanController,
                                              label: 'Panjang Badan',
                                              suffix: 'cm',
                                              keyboardType:
                                                  TextInputType.number,
                                              validator:
                                                  (value) =>
                                                      value?.isEmpty == true
                                                          ? 'Wajib diisi'
                                                          : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller:
                                                  _lingkarKepalaController,
                                              label: 'Lingkar Kepala',
                                              suffix: 'cm',
                                              keyboardType:
                                                  TextInputType.number,
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
                                              controller:
                                                  _lingkarDadaController,
                                              label: 'Lingkar Dada',
                                              suffix: 'cm',
                                              keyboardType:
                                                  TextInputType.number,
                                              validator:
                                                  (value) =>
                                                      value?.isEmpty == true
                                                          ? 'Wajib diisi'
                                                          : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDropdown(
                                              value: _kelainan,
                                              items: ['ya', 'tidak'],
                                              label: 'Kelainan',
                                              onChanged: (value) {
                                                setState(() {
                                                  _kelainan = value!;
                                                });
                                              },
                                            ),
                                          ),
                                          if (_kelainan == 'ya') ...[
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildTextField(
                                                controller:
                                                    _detailKelainanController,
                                                label: 'Bila ada sebutkan',
                                                validator:
                                                    (value) =>
                                                        _kelainan == 'ya' &&
                                                                value?.isEmpty ==
                                                                    true
                                                            ? 'Wajib diisi'
                                                            : null,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),

                                      // APGAR Score Section
                                      _buildSectionTitle('APGAR SKOR'),
                                      _buildTextField(
                                        controller: _apgarSkorController,
                                        label: 'APGAR Skor',
                                        validator:
                                            (value) =>
                                                value?.isEmpty == true
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      _buildTextField(
                                        controller: _apgarCatatanController,
                                        label: 'Catatan APGAR',
                                        maxLines: 3,
                                      ),

                                      // Placenta Section
                                      _buildSectionTitle('PLACENTA'),
                                      _buildTextField(
                                        controller: _placentaBentukController,
                                        label: 'Bentuk',
                                        validator:
                                            (value) =>
                                                value?.isEmpty == true
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller:
                                                  _placentaPanjangController,
                                              label: 'Panjang',
                                              suffix: 'cm',
                                              keyboardType:
                                                  TextInputType.number,
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
                                              controller:
                                                  _placentaLebarController,
                                              label: 'Lebar',
                                              suffix: 'cm',
                                              keyboardType:
                                                  TextInputType.number,
                                              validator:
                                                  (value) =>
                                                      value?.isEmpty == true
                                                          ? 'Wajib diisi'
                                                          : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller:
                                                  _placentaTebalController,
                                              label: 'Tebal',
                                              suffix: 'cm',
                                              keyboardType:
                                                  TextInputType.number,
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
                                              controller:
                                                  _placentaBeratController,
                                              label: 'Berat',
                                              suffix: 'gram',
                                              keyboardType:
                                                  TextInputType.number,
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
                                        controller: _panjangTaliPusatController,
                                        label: 'Panjang Tali Pusat',
                                        suffix: 'cm',
                                        keyboardType: TextInputType.number,
                                        validator:
                                            (value) =>
                                                value?.isEmpty == true
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),

                                      // Keadaan Penderita Keluar Section
                                      _buildSectionTitle(
                                        'KEADAAN PENDERITA KELUAR',
                                      ),
                                      _buildDatePicker(
                                        selectedDate: _tanggalKeluar,
                                        label: 'Tanggal Keluar',
                                        onDateSelected: (date) {
                                          setState(() {
                                            _tanggalKeluar = date;
                                          });
                                        },
                                      ),
                                      _buildTextField(
                                        controller: _jamKeluarController,
                                        label: 'Jam',
                                        suffix: 'WIB',
                                        validator:
                                            (value) =>
                                                value?.isEmpty == true
                                                    ? 'Wajib diisi'
                                                    : null,
                                      ),
                                      _buildDropdown(
                                        value: _kondisiKeluar,
                                        items: [
                                          'sembuh',
                                          'meninggal',
                                          'dipindahkan',
                                          'keluar_paksa',
                                        ],
                                        label: 'Kondisi',
                                        onChanged: (value) {
                                          setState(() {
                                            _kondisiKeluar = value!;
                                          });
                                        },
                                      ),
                                      if (_kondisiKeluar == 'meninggal')
                                        _buildTextField(
                                          controller: _sebabMeninggalController,
                                          label: 'Sebab Meninggal',
                                          validator:
                                              (value) =>
                                                  _kondisiKeluar ==
                                                              'meninggal' &&
                                                          value?.isEmpty == true
                                                      ? 'Wajib diisi'
                                                      : null,
                                        ),
                                      if (_kondisiKeluar == 'dipindahkan')
                                        _buildTextField(
                                          controller: _namaRSController,
                                          label: 'Dipindahkan ke RS',
                                          validator:
                                              (value) =>
                                                  _kondisiKeluar ==
                                                              'dipindahkan' &&
                                                          value?.isEmpty == true
                                                      ? 'Wajib diisi'
                                                      : null,
                                        ),
                                      if (_kondisiKeluar == 'keluar_paksa')
                                        _buildTextField(
                                          controller:
                                              _sebabKeluarPaksaController,
                                          label: 'Sebab Pemohon Pulang Paksa',
                                          validator:
                                              (value) =>
                                                  _kondisiKeluar ==
                                                              'keluar_paksa' &&
                                                          value?.isEmpty == true
                                                      ? 'Wajib diisi'
                                                      : null,
                                        ),
                                      _buildTextField(
                                        controller: _catatanKeluarController,
                                        label: 'Catatan Tambahan',
                                        maxLines: 3,
                                      ),

                                      const SizedBox(height: 20),

                                      // Save Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:
                                              _isSaving
                                                  ? null
                                                  : _saveLaporanPascaPersalinan,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFEC407A,
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // List Laporan Pasca yang sudah disimpan
                              if (_laporanPascaList.isNotEmpty) ...[
                                const SizedBox(height: 30),
                                Text(
                                  'Laporan Pasca Persalinan Tersimpan',
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
                                  itemCount: _laporanPascaList.length,
                                  itemBuilder: (context, index) {
                                    final laporanPasca =
                                        _laporanPascaList[index];
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
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFEC407A,
                                                  ).withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .medical_services_rounded,
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
                                                      'Laporan Pasca ${index + 1}',
                                                      style:
                                                          GoogleFonts.poppins(
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
                                                        laporanPasca.createdAt,
                                                      ),
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Kondisi Keluar: ${laporanPasca.kondisiKeluar}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF2D3748),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  () =>
                                                      _navigateToKeteranganKelahiran(
                                                        laporanPasca,
                                                      ),
                                              icon: const Icon(
                                                Icons.add_rounded,
                                                size: 20,
                                              ),
                                              label: Text(
                                                'Tambah Keterangan Kelahiran',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
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
      ),
    );
  }
}
