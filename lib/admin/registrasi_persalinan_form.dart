import 'package:flutter/material.dart';
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
  final _pekerjaanController = TextEditingController();
  final _diagnosaController = TextEditingController();
  final _tindakanController = TextEditingController();
  final _rujukanController = TextEditingController();
  final _penolongController = TextEditingController();

  DateTime _tanggalMasuk = DateTime.now();
  DateTime _tanggalPartes = DateTime.now();
  DateTime _tanggalKeluar = DateTime.now();
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

  void _initializeData() {
    if (widget.examinationData != null) {
      // Pre-fill with examination data
      _pasienId = widget.examinationData!['pasienId'];
      _pasienNama = widget.examinationData!['namaPasien'];
      _pasienNoHp = widget.examinationData!['noHp'];
      _pasienUmur = widget.examinationData!['umur'];
      _pasienAlamat = widget.examinationData!['alamat'];
    } else if (widget.persalinanData != null) {
      // Pre-fill with existing persalinan data
      final data = widget.persalinanData!;
      _pasienId = data.pasienId;
      _pasienNama = data.pasienNama;
      _pasienNoHp = data.pasienNoHp;
      _pasienUmur = data.pasienUmur;
      _pasienAlamat = data.pasienAlamat;

      _namaSuamiController.text = data.namaSuami;
      _pekerjaanController.text = data.pekerjaan;
      _diagnosaController.text = data.diagnosaKebidanan;
      _tindakanController.text = data.tindakan;
      _rujukanController.text = data.rujukan ?? '';
      _penolongController.text = data.penolongPersalinan;

      _tanggalMasuk = data.tanggalMasuk;
      _tanggalPartes = data.tanggalPartes;
      _tanggalKeluar = data.tanggalKeluar;
      _fasilitas = data.fasilitas;
    }
  }

  @override
  void dispose() {
    _namaSuamiController.dispose();
    _pekerjaanController.dispose();
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
        pekerjaan: _pekerjaanController.text.trim(),
        tanggalMasuk: _tanggalMasuk,
        tanggalPartes: _tanggalPartes,
        tanggalKeluar: _tanggalKeluar,
        diagnosaKebidanan: _diagnosaController.text.trim(),
        tindakan: _tindakanController.text.trim(),
        rujukan: _rujukanController.text.trim(),
        penolongPersalinan: _penolongController.text.trim(),
        fasilitas: _fasilitas,
        createdAt: widget.persalinanData?.createdAt ?? DateTime.now(),
      );

      await _firebaseService.createPersalinan(newReport);

      if (mounted) {
        Navigator.pop(context);
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
                    color: const Color(0xFFEC407A).withOpacity(0.1),
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
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
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
                      // Patient Information (Read-only)
                      if (_pasienNama != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC407A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEC407A).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Pasien',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Nama: $_pasienNama'),
                              Text('No HP: $_pasienNoHp'),
                              Text('Umur: $_pasienUmur tahun'),
                              Text('Alamat: $_pasienAlamat'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Nama Suami
                      TextFormField(
                        controller: _namaSuamiController,
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama suami tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pekerjaan
                      TextFormField(
                        controller: _pekerjaanController,
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
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pekerjaan tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

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

                      // Tanggal Masuk
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 16),

                      // Tanggal Partes
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _tanggalPartes,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _tanggalPartes = date;
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Persalinan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_tanggalPartes),
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
                      const SizedBox(height: 16),

                      // Tanggal Keluar
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _tanggalKeluar,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _tanggalKeluar = date;
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Keluar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_tanggalKeluar),
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
                    onPressed: () => Navigator.pop(context),
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
