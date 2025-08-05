import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/persalinan_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class LaporanPersalinanScreen extends StatefulWidget {
  const LaporanPersalinanScreen({super.key});

  @override
  State<LaporanPersalinanScreen> createState() =>
      _LaporanPersalinanScreenState();
}

class _LaporanPersalinanScreenState extends State<LaporanPersalinanScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<PersalinanModel> _allReports = [];
  List<PersalinanModel> _filteredReports = [];
  List<UserModel> _patients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load patients
      _firebaseService.getUsersStream().listen((patients) {
        setState(() {
          _patients = patients;
        });
      });

      // Load reports
      _firebaseService.getPersalinanStream().listen((reports) {
        setState(() {
          _allReports = reports;
          _filterReports();
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFEC407A),
        ),
      );
    }
  }

  void _filterReports() {
    if (_searchQuery.isEmpty) {
      _filteredReports = _allReports;
    } else {
      _filteredReports =
          _allReports.where((report) {
            return report.pasienNama.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.pasienNoHp.contains(_searchQuery) ||
                report.pasienAlamat.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.namaSuami.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }
  }

  void _showAddEditDialog([PersalinanModel? report]) {
    final _formKey = GlobalKey<FormState>();
    UserModel? _selectedPatient =
        report != null
            ? _patients.firstWhere(
              (p) => p.id == report.pasienId,
              orElse: () => _patients.first,
            )
            : null;

    final _namaSuamiController = TextEditingController(
      text: report?.namaSuami ?? '',
    );
    final _pekerjaanController = TextEditingController(
      text: report?.pekerjaan ?? '',
    );
    final _diagnosaController = TextEditingController(
      text: report?.diagnosaKebidanan ?? '',
    );
    final _tindakanController = TextEditingController(
      text: report?.tindakan ?? '',
    );
    final _rujukanController = TextEditingController(
      text: report?.rujukan ?? '',
    );
    final _penolongController = TextEditingController(
      text: report?.penolongPersalinan ?? '',
    );

    DateTime _tanggalMasuk = report?.tanggalMasuk ?? DateTime.now();
    DateTime _tanggalPartes = report?.tanggalPartes ?? DateTime.now();
    DateTime _tanggalKeluar = report?.tanggalKeluar ?? DateTime.now();
    String _fasilitas = report?.fasilitas ?? 'umum';
    bool _isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height * 0.9,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC407A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                report == null
                                    ? Icons.add_rounded
                                    : Icons.edit_rounded,
                                color: const Color(0xFFEC407A),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              report == null
                                  ? 'Tambah Laporan Persalinan'
                                  : 'Edit Laporan Persalinan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Patient Selection
                                  DropdownButtonFormField<UserModel>(
                                    value: _selectedPatient,
                                    decoration: InputDecoration(
                                      labelText: 'Pilih Pasien',
                                      prefixIcon: Icon(
                                        Icons.person_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    items:
                                        _patients.map((patient) {
                                          return DropdownMenuItem(
                                            value: patient,
                                            child: Text(
                                              '${patient.nama} - ${patient.noHp}',
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPatient = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Pilih pasien';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Husband's Name
                                  TextFormField(
                                    controller: _namaSuamiController,
                                    decoration: InputDecoration(
                                      labelText: 'Nama Suami',
                                      prefixIcon: Icon(
                                        Icons.person_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama suami tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Job
                                  TextFormField(
                                    controller: _pekerjaanController,
                                    decoration: InputDecoration(
                                      labelText: 'Pekerjaan',
                                      prefixIcon: Icon(
                                        Icons.work_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Pekerjaan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Admission Date
                                  _buildDatePickerTile(
                                    'Tanggal Masuk',
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_tanggalMasuk),
                                    () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _tanggalMasuk,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                            _tanggalMasuk,
                                          ),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _tanggalMasuk = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Facility Type
                                  DropdownButtonFormField<String>(
                                    value: _fasilitas,
                                    decoration: InputDecoration(
                                      labelText: 'Fasilitas',
                                      prefixIcon: Icon(
                                        Icons.local_hospital_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'umum',
                                        child: Text('Umum'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'bpjs',
                                        child: Text('BPJS'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _fasilitas = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Birth Date
                                  _buildDatePickerTile(
                                    'Tanggal/Jam Partes',
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_tanggalPartes),
                                    () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _tanggalPartes,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                            _tanggalPartes,
                                          ),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _tanggalPartes = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Discharge Date
                                  _buildDatePickerTile(
                                    'Tanggal/Jam Keluar',
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(_tanggalKeluar),
                                    () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _tanggalKeluar,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                            _tanggalKeluar,
                                          ),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _tanggalKeluar = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Diagnosis
                                  TextFormField(
                                    controller: _diagnosaController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Diagnosa Kebidanan',
                                      prefixIcon: Icon(
                                        Icons.medical_services_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Diagnosa tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Action
                                  TextFormField(
                                    controller: _tindakanController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Tindakan',
                                      prefixIcon: Icon(
                                        Icons.healing_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tindakan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Referral (Optional)
                                  TextFormField(
                                    controller: _rujukanController,
                                    decoration: InputDecoration(
                                      labelText: 'Rujukan (Opsional)',
                                      prefixIcon: Icon(
                                        Icons.transfer_within_a_station_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Birth Assistant
                                  TextFormField(
                                    controller: _penolongController,
                                    decoration: InputDecoration(
                                      labelText: 'Penolong Persalinan',
                                      prefixIcon: Icon(
                                        Icons.people_rounded,
                                        color: const Color(0xFFEC407A),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFEC407A),
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Penolong persalinan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;

                                          setState(() {
                                            _isLoading = true;
                                          });

                                          try {
                                            final newReport = PersalinanModel(
                                              id:
                                                  report?.id ??
                                                  _firebaseService.generateId(),
                                              pasienId: _selectedPatient!.id,
                                              pasienNama:
                                                  _selectedPatient!.nama,
                                              pasienNoHp:
                                                  _selectedPatient!.noHp,
                                              pasienUmur:
                                                  _selectedPatient!.umur,
                                              pasienAlamat:
                                                  _selectedPatient!.alamat,
                                              namaSuami:
                                                  _namaSuamiController.text
                                                      .trim(),
                                              pekerjaan:
                                                  _pekerjaanController.text
                                                      .trim(),
                                              tanggalMasuk: _tanggalMasuk,
                                              fasilitas: _fasilitas,
                                              tanggalPartes: _tanggalPartes,
                                              tanggalKeluar: _tanggalKeluar,
                                              diagnosaKebidanan:
                                                  _diagnosaController.text
                                                      .trim(),
                                              tindakan:
                                                  _tindakanController.text
                                                      .trim(),
                                              rujukan:
                                                  _rujukanController.text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _rujukanController.text
                                                          .trim(),
                                              penolongPersalinan:
                                                  _penolongController.text
                                                      .trim(),
                                              createdAt:
                                                  report?.createdAt ??
                                                  DateTime.now(),
                                            );

                                            await _firebaseService
                                                .createPersalinan(newReport);
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  report == null
                                                      ? 'Laporan berhasil ditambahkan'
                                                      : 'Laporan berhasil diperbarui',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } finally {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEC407A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          report == null ? 'Tambah' : 'Simpan',
                                          style: GoogleFonts.poppins(),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildDatePickerTile(
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: const Color(0xFFEC407A),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(PersalinanModel report) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC407A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.visibility_rounded,
                          color: const Color(0xFFEC407A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Detail Laporan Persalinan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection('Data Pasien', [
                            _buildDetailRow('Nama Pasien', report.pasienNama),
                            _buildDetailRow('No HP', report.pasienNoHp),
                            _buildDetailRow(
                              'Umur',
                              '${report.pasienUmur} tahun',
                            ),
                            _buildDetailRow('Alamat', report.pasienAlamat),
                          ]),
                          const SizedBox(height: 16),
                          _buildDetailSection('Data Suami', [
                            _buildDetailRow('Nama Suami', report.namaSuami),
                            _buildDetailRow('Pekerjaan', report.pekerjaan),
                          ]),
                          const SizedBox(height: 16),
                          _buildDetailSection('Data Persalinan', [
                            _buildDetailRow(
                              'Tanggal Masuk',
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(report.tanggalMasuk),
                            ),
                            _buildDetailRow(
                              'Fasilitas',
                              report.fasilitas == 'umum' ? 'Umum' : 'BPJS',
                            ),
                            _buildDetailRow(
                              'Tanggal Partes',
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(report.tanggalPartes),
                            ),
                            _buildDetailRow(
                              'Tanggal Keluar',
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(report.tanggalKeluar),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          _buildDetailSection('Diagnosa & Tindakan', [
                            _buildDetailRow(
                              'Diagnosa',
                              report.diagnosaKebidanan,
                            ),
                            _buildDetailRow('Tindakan', report.tindakan),
                            if (report.rujukan != null)
                              _buildDetailRow('Rujukan', report.rujukan!),
                            _buildDetailRow(
                              'Penolong',
                              report.penolongPersalinan,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC407A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Tutup', style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEC407A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                          color: const Color(0xFFEC407A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medical_services_rounded,
                          color: const Color(0xFFEC407A),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laporan Persalinan',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              'Kelola data laporan persalinan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Cari berdasarkan nama pasien, no HP, alamat, atau nama suami...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: const Color(0xFFEC407A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFEC407A),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterReports();
                      });
                    },
                  ),
                ],
              ),
            ),

            // Reports List
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEC407A),
                        ),
                      )
                      : _filteredReports.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC407A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Icon(
                                Icons.medical_services_outlined,
                                size: 60,
                                color: const Color(0xFFEC407A),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Belum ada data laporan persalinan'
                                  : 'Tidak ada hasil pencarian',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Tambahkan laporan persalinan pertama'
                                  : 'Coba kata kunci yang berbeda',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = _filteredReports[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Patient Avatar
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFEC407A,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFFEC407A,
                                            ).withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.medical_services_rounded,
                                          color: const Color(0xFFEC407A),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Patient Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.pasienNama,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: const Color(0xFF2D3748),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            _buildInfoRow(
                                              Icons.phone_rounded,
                                              report.pasienNoHp,
                                            ),
                                            const SizedBox(height: 4),
                                            _buildInfoRow(
                                              Icons.cake_rounded,
                                              '${report.pasienUmur} tahun',
                                            ),
                                            const SizedBox(height: 4),
                                            _buildInfoRow(
                                              Icons.location_on_rounded,
                                              report.pasienAlamat,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Action Menu
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert_rounded,
                                          color: const Color(0xFFEC407A),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        onSelected: (value) {
                                          if (value == 'detail') {
                                            _showDetailDialog(report);
                                          } else if (value == 'edit') {
                                            _showAddEditDialog(report);
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                value: 'detail',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.visibility_rounded,
                                                      color: const Color(
                                                        0xFFEC407A,
                                                      ),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'Detail',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: const Color(
                                                              0xFFEC407A,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.edit_rounded,
                                                      color: Colors.orange,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'Edit',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Birth Date
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFEC407A,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFEC407A,
                                        ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: const Color(0xFFEC407A),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Partes: ${DateFormat('dd MMM yyyy').format(report.tanggalPartes)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: const Color(0xFFEC407A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC407A).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: const Color(0xFFEC407A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
