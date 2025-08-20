import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/laporan_pasca_persalinan_model.dart';
import '../models/keterangan_kelahiran_model.dart';
import '../services/firebase_service.dart';

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
  final _tempatLahirController = TextEditingController();
  final _panjangBadanController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _kelahiranAnakKeController = TextEditingController(text: '1');

  // Data from previous forms
  DateTime _hariTanggalLahir = DateTime.now();
  String _jenisKelamin = 'laki-laki';

  // Data that will be auto-filled from database
  String _namaIbu = '';
  int _umurIbu = 0;
  String _agamaIbu = '';
  String _pekerjaanIbu = '';
  String _namaAyah = '';
  int _umurAyah = 0;
  String _agamaAyah = '';
  String _pekerjaanAyah = '';
  String _alamat = '';

  List<KeteranganKelahiranModel> _keteranganList = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
    _loadKeteranganKelahiran();
  }

  @override
  void dispose() {
    _namaAnakController.dispose();
    _jamLahirController.dispose();
    _tempatLahirController.dispose();
    _panjangBadanController.dispose();
    _beratBadanController.dispose();
    _kelahiranAnakKeController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      // Load patient data for parent information
      final registrasiData = await _firebaseService.getPersalinanById(
        widget.laporanPascaPersalinanData.laporanPersalinanId,
      );
      if (registrasiData != null) {
        final userData = await _firebaseService.getUserById(
          registrasiData.pasienId,
        );
        if (userData != null) {
          setState(() {
            _namaIbu = userData.nama;
            _umurIbu = userData.umur;
            _agamaIbu = 'Islam'; // Default value
            _pekerjaanIbu = 'Ibu Rumah Tangga'; // Default value
            _alamat = userData.alamat;

            // For demo purposes, set husband data (in real app, this should come from registration form)
            _namaAyah = registrasiData.namaSuami;
            _umurAyah = 30; // This should come from registration form
            _agamaAyah = 'Islam'; // Default value
            _pekerjaanAyah = registrasiData.pekerjaan;
          });
        }
      }

      // Pre-fill some data from previous form
      setState(() {
        _jenisKelamin = widget.laporanPascaPersalinanData.jenisKelamin;
        _panjangBadanController.text =
            widget.laporanPascaPersalinanData.panjangBadan;
        _beratBadanController.text =
            widget.laporanPascaPersalinanData.beratBadan;
        _tempatLahirController.text = 'Rumah Sakit Bunda'; // Default value
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadKeteranganKelahiran() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _firebaseService
          .getKeteranganKelahiranByLaporanPascaId(
            widget.laporanPascaPersalinanData.id,
          )
          .timeout(const Duration(seconds: 15)) // Increase timeout
          .listen(
            (keteranganList) {
              if (mounted) {
                setState(() {
                  _keteranganList = keteranganList;
                  _isLoading = false;
                });
              }
            },
            onError: (error) {
              print('Error loading keterangan kelahiran: $error');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading data: $error'),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: _loadKeteranganKelahiran,
                    ),
                  ),
                );
              }
            },
          );
    } catch (e) {
      print('Exception in _loadKeteranganKelahiran: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadKeteranganKelahiran,
            ),
          ),
        );
      }
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
        tempatLahir: _tempatLahirController.text.trim(),
        jenisKelamin: _jenisKelamin,
        panjangBadan: _panjangBadanController.text.trim(),
        beratBadan: _beratBadanController.text.trim(),
        kelahiranAnakKe: int.tryParse(_kelahiranAnakKeController.text) ?? 1,
        namaIbu: _namaIbu,
        umurIbu: _umurIbu,
        agamaIbu: _agamaIbu,
        pekerjaanIbu: _pekerjaanIbu,
        namaAyah: _namaAyah,
        umurAyah: _umurAyah,
        agamaAyah: _agamaAyah,
        pekerjaanAyah: _pekerjaanAyah,
        alamat: _alamat,
        createdAt: DateTime.now(),
      );

      await _firebaseService.createKeteranganKelahiran(keterangan);

      // Clear form
      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keterangan kelahiran berhasil disimpan'),
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
    _namaAnakController.clear();
    _jamLahirController.clear();
    _kelahiranAnakKeController.text = '1';

    setState(() {
      _hariTanggalLahir = DateTime.now();
      _jenisKelamin = 'laki-laki';
    });
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
                                    _buildTextField(
                                      controller: _tempatLahirController,
                                      label: 'Tempat Lahir',
                                      validator:
                                          (value) =>
                                              value?.isEmpty == true
                                                  ? 'Wajib diisi'
                                                  : null,
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
                                    _buildReadOnlyField('Nama', _namaIbu),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildReadOnlyField(
                                            'Umur',
                                            '$_umurIbu tahun',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildReadOnlyField(
                                            'Agama',
                                            _agamaIbu,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildReadOnlyField(
                                      'Pekerjaan',
                                      _pekerjaanIbu,
                                    ),

                                    // Data Ayah Section
                                    _buildSectionTitle(
                                      'AYAH (Data otomatis terisi sesuai database)',
                                    ),
                                    _buildReadOnlyField('Nama', _namaAyah),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildReadOnlyField(
                                            'Umur',
                                            '$_umurAyah tahun',
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildReadOnlyField(
                                            'Agama',
                                            _agamaAyah,
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildReadOnlyField(
                                      'Pekerjaan',
                                      _pekerjaanAyah,
                                    ),
                                    _buildReadOnlyField(
                                      'Alamat (sesuai database pasien)',
                                      _alamat,
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
                                          color: Colors.black.withValues(alpha: 0.1),
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
