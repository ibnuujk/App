import 'package:flutter/material.dart';
import '../utilities/safe_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/persalinan_model.dart';
import '../services/firebase_service.dart';

class RegistrasiPersalinanFormDialog extends StatefulWidget {
  final Map<String, dynamic>? examinationData;
  final PersalinanModel? persalinanData;

  const RegistrasiPersalinanFormDialog({
    super.key,
    this.examinationData,
    this.persalinanData,
  });

  @override
  State<RegistrasiPersalinanFormDialog> createState() =>
      _RegistrasiPersalinanFormDialogState();
}

class _RegistrasiPersalinanFormDialogState
    extends State<RegistrasiPersalinanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  // Form controllers
  final _namaSuamiController = TextEditingController();
  final _pekerjaanSuamiController = TextEditingController();
  final _umurSuamiController = TextEditingController();
  final _agamaSuamiController = TextEditingController();
  final _agamaPasienController = TextEditingController();
  final _pekerjaanPasienController = TextEditingController();
  final _diagnosaController = TextEditingController();
  final _tindakanController = TextEditingController();
  final _rujukanController = TextEditingController();
  final _penolongController = TextEditingController();

  DateTime _tanggalMasuk = DateTime.now();
  String _fasilitas = 'umum';
  bool _isLoading = false;

  // Patient data from examination
  String? _pasienId;
  String? _pasienNama;
  String? _pasienNoHp;
  int? _pasienUmur;
  String? _pasienAlamat;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFEC407A), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  void _initializeData() {
    if (widget.examinationData != null) {
      // Pre-fill with examination data
      _pasienId = widget.examinationData!['pasienId'];
      _pasienNama = widget.examinationData!['namaPasien'];
      _pasienNoHp = widget.examinationData!['noHp'];
      _pasienUmur = widget.examinationData!['umur'];
      _pasienAlamat = widget.examinationData!['alamat'];

      // Pre-fill agama dan pekerjaan pasien dari data pemeriksaan jika tersedia
      if (widget.examinationData!['agama'] != null) {
        _agamaPasienController.text = widget.examinationData!['agama'];
      }
      if (widget.examinationData!['pekerjaan'] != null) {
        _pekerjaanPasienController.text = widget.examinationData!['pekerjaan'];
      }
    } else if (widget.persalinanData != null) {
      // Pre-fill with existing persalinan data
      final data = widget.persalinanData!;
      _pasienId = data.pasienId;
      _pasienNama = data.pasienNama;
      _pasienNoHp = data.pasienNoHp;
      _pasienUmur = data.pasienUmur;
      _pasienAlamat = data.pasienAlamat;

      _namaSuamiController.text = data.namaSuami;
      _pekerjaanSuamiController.text = data.pekerjaanSuami;
      _umurSuamiController.text = data.umurSuami.toString();
      _agamaSuamiController.text = data.agamaSuami;
      _agamaPasienController.text = data.agamaPasien;
      _pekerjaanPasienController.text = data.pekerjaanPasien;
      _diagnosaController.text = data.diagnosaKebidanan;
      _tindakanController.text = data.tindakan;
      _rujukanController.text = data.rujukan ?? '';
      _penolongController.text = data.penolongPersalinan;

      _tanggalMasuk = data.tanggalMasuk;
      _fasilitas = data.fasilitas;
    }

    // Load complete patient data including suami data from Firebase
    if (_pasienId != null) {
      _loadPatientData();
    }
  }

  Future<void> _loadPatientData() async {
    try {
      if (_pasienId != null) {
        final userDoc = await _firebaseService.getUserById(_pasienId!);
        if (userDoc != null) {
          setState(() {
            // Update patient data with complete user data
            _pasienNama = userDoc.nama;
            _pasienNoHp = userDoc.noHp;
            _pasienUmur = userDoc.umur;
            _pasienAlamat = userDoc.alamat;

            // Update form controllers with complete patient data
            if (userDoc.agamaPasien != null &&
                userDoc.agamaPasien!.isNotEmpty) {
              _agamaPasienController.text = userDoc.agamaPasien!;
            }
            if (userDoc.pekerjaanPasien != null &&
                userDoc.pekerjaanPasien!.isNotEmpty) {
              _pekerjaanPasienController.text = userDoc.pekerjaanPasien!;
            }

            // Load suami data from Firebase
            if (userDoc.namaSuami != null && userDoc.namaSuami!.isNotEmpty) {
              _namaSuamiController.text = userDoc.namaSuami!;
            }
            if (userDoc.pekerjaanSuami != null &&
                userDoc.pekerjaanSuami!.isNotEmpty) {
              _pekerjaanSuamiController.text = userDoc.pekerjaanSuami!;
            }
            if (userDoc.umurSuami != null && userDoc.umurSuami! > 0) {
              _umurSuamiController.text = userDoc.umurSuami!.toString();
            }
            if (userDoc.agamaSuami != null && userDoc.agamaSuami!.isNotEmpty) {
              _agamaSuamiController.text = userDoc.agamaSuami!;
            }
          });
        }
      }
    } catch (e) {
      print('Error loading patient data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data pasien: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaSuamiController.dispose();
    _pekerjaanSuamiController.dispose();
    _umurSuamiController.dispose();
    _agamaSuamiController.dispose();
    _agamaPasienController.dispose();
    _pekerjaanPasienController.dispose();
    _diagnosaController.dispose();
    _tindakanController.dispose();
    _rujukanController.dispose();
    _penolongController.dispose();
    super.dispose();
  }

  Future<void> _savePersalinan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newReport = PersalinanModel(
        id: widget.persalinanData?.id ?? _firebaseService.generateId(),
        pasienId: _pasienId!,
        pasienNama: _pasienNama!,
        pasienNoHp: _pasienNoHp!,
        pasienUmur: _pasienUmur!,
        pasienAlamat: _pasienAlamat!,
        namaSuami: _namaSuamiController.text.trim(),
        pekerjaanSuami: _pekerjaanSuamiController.text.trim(),
        umurSuami: int.parse(_umurSuamiController.text.trim()),
        agamaSuami: _agamaSuamiController.text.trim(),
        agamaPasien: _agamaPasienController.text.trim(),
        pekerjaanPasien: _pekerjaanPasienController.text.trim(),
        tanggalMasuk: _tanggalMasuk,
        diagnosaKebidanan: _diagnosaController.text.trim(),
        tindakan: _tindakanController.text.trim(),
        rujukan: _rujukanController.text.trim(),
        penolongPersalinan: _penolongController.text.trim(),
        fasilitas: _fasilitas,
        createdAt: widget.persalinanData?.createdAt ?? DateTime.now(),
      );

      await _firebaseService.createPersalinan(newReport);

      if (mounted) {
        NavigationHelper.safeNavigateBack(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.persalinanData == null
                  ? 'Registrasi persalinan berhasil disimpan'
                  : 'Registrasi persalinan berhasil diperbarui',
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.persalinanData == null
                        ? Icons.add_rounded
                        : Icons.edit_rounded,
                    color: const Color(0xFFEC407A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.persalinanData == null
                            ? 'Tambah Registrasi Persalinan'
                            : 'Edit Registrasi Persalinan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      if (_pasienNama != null)
                        Text(
                          'Pasien: $_pasienNama',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      // Show success status if data already exists
                      if (widget.persalinanData != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Registrasi Berhasil',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => NavigationHelper.safeNavigateBack(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ANAMNESIS Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFEC407A,
                          ).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFEC407A,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'ANAMNESIS',
                              Icons.medical_services_rounded,
                            ),
                            const SizedBox(height: 16),

                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _tanggalMasuk,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _tanggalMasuk = date;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: const Color(0xFFEC407A),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal Masuk',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_tanggalMasuk),
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
                            const SizedBox(height: 24),

                            // DATA PASIEN Section
                            _buildSectionHeader(
                              'DATA PASIEN',
                              Icons.person_rounded,
                            ),
                            const SizedBox(height: 16),

                            // Nama Pasien (Auto-filled)
                            TextFormField(
                              initialValue: _pasienNama,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Nama Pasien',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // No HP Pasien (Auto-filled)
                            TextFormField(
                              initialValue: _pasienNoHp,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'No HP',
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Umur Pasien (Auto-filled)
                            TextFormField(
                              initialValue: _pasienUmur?.toString(),
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Umur',
                                prefixIcon: Icon(
                                  Icons.cake_outlined,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Alamat Pasien (Auto-filled)
                            TextFormField(
                              initialValue: _pasienAlamat,
                              enabled: false,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Alamat',
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Agama Pasien (Auto-filled)
                            TextFormField(
                              controller: _agamaPasienController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Agama',
                                prefixIcon: Icon(
                                  Icons.church,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Pekerjaan Pasien (Auto-filled)
                            TextFormField(
                              controller: _pekerjaanPasienController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Pekerjaan',
                                prefixIcon: Icon(
                                  Icons.work_outline,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // DATA SUAMI Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFEC407A,
                          ).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFEC407A,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              'DATA SUAMI',
                              Icons.person_outline,
                            ),
                            const SizedBox(height: 16),

                            // Nama Suami (Auto-filled)
                            TextFormField(
                              controller: _namaSuamiController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Nama Suami',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Pekerjaan Suami (Auto-filled)
                            TextFormField(
                              controller: _pekerjaanSuamiController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Pekerjaan Suami',
                                prefixIcon: Icon(
                                  Icons.work_outline,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Umur Suami (Auto-filled)
                            TextFormField(
                              controller: _umurSuamiController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Umur Suami',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Agama Suami (Auto-filled)
                            TextFormField(
                              controller: _agamaSuamiController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Agama Suami',
                                prefixIcon: Icon(
                                  Icons.church,
                                  color: const Color(0xFFEC407A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFEC407A),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fasilitas
                      DropdownButtonFormField<String>(
                        value: _fasilitas,
                        decoration: InputDecoration(
                          labelText: 'Fasilitas',
                          prefixIcon: Icon(
                            Icons.local_hospital,
                            color: const Color(0xFFEC407A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEC407A),
                              width: 2,
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'umum', child: Text('UMUM')),
                          DropdownMenuItem(value: 'bpjs', child: Text('BPJS')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _fasilitas = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Diagnosa Kebidanan
                      TextFormField(
                        controller: _diagnosaController,
                        decoration: InputDecoration(
                          labelText: 'Diagnosa Kebidanan',
                          prefixIcon: Icon(
                            Icons.medical_services,
                            color: const Color(0xFFEC407A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEC407A),
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Diagnosa tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tindakan
                      TextFormField(
                        controller: _tindakanController,
                        decoration: InputDecoration(
                          labelText: 'Tindakan',
                          prefixIcon: Icon(
                            Icons.healing,
                            color: const Color(0xFFEC407A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEC407A),
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tindakan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Penolong Persalinan
                      TextFormField(
                        controller: _penolongController,
                        decoration: InputDecoration(
                          labelText: 'Penolong Persalinan',
                          prefixIcon: Icon(
                            Icons.person_add,
                            color: const Color(0xFFEC407A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEC407A),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Penolong persalinan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Rujukan (Optional)
                      TextFormField(
                        controller: _rujukanController,
                        decoration: InputDecoration(
                          labelText: 'Rujukan (Opsional)',
                          prefixIcon: Icon(
                            Icons.forward,
                            color: const Color(0xFFEC407A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEC407A),
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => NavigationHelper.safeNavigateBack(context),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePersalinan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC407A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Simpan',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
