import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utilities/safe_navigation.dart';

class DataPasienScreen extends StatefulWidget {
  const DataPasienScreen({super.key});

  @override
  State<DataPasienScreen> createState() => _DataPasienScreenState();
}

class _DataPasienScreenState extends State<DataPasienScreen>
    with SafeNavigationMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allPatients = [];
  List<UserModel> _filteredPatients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
      // Use optimized stream with role filter and increased limit
      _firebaseService
          .getUsersStream(limit: 1000, role: 'pasien')
          .listen(
            (patients) {
              if (mounted) {
                setState(() {
                  _allPatients = patients;
                  _filteredPatients = _allPatients;
                  _isLoading = false;
                });
                _filterPatients();
              }
            },
            onError: (e) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                print('Error loading patients: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gagal memuat data pasien. Silakan coba lagi.',
                    ),
                    backgroundColor: const Color(0xFFEC407A),
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: _loadPatients,
                    ),
                  ),
                );
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pasien: $e'),
            backgroundColor: const Color(0xFFEC407A),
          ),
        );
      }
    }
  }

  void _filterPatients() {
    if (_searchQuery.isEmpty) {
      _filteredPatients = _allPatients;
    } else {
      _filteredPatients =
          _allPatients.where((patient) {
            return patient.nama.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                patient.email.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                patient.noHp.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                patient.alamat.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }
  }

  Future<void> _deletePatient(String patientId) async {
    try {
      await _firebaseService.deleteUser(patientId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pasien berhasil dihapus',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus pasien: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showAddEditDialog([UserModel? patient]) {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: patient?.nama ?? '');
    final _emailController = TextEditingController(text: patient?.email ?? '');
    final _passwordController = TextEditingController(
      text: patient?.password ?? '',
    );
    final _noHpController = TextEditingController(text: patient?.noHp ?? '');
    final _alamatController = TextEditingController(
      text: patient?.alamat ?? '',
    );

    // New controllers for additional fields
    final _namaSuamiController = TextEditingController(
      text: patient?.namaSuami ?? '',
    );
    final _pekerjaanSuamiController = TextEditingController(
      text: patient?.pekerjaanSuami ?? '',
    );
    final _umurSuamiController = TextEditingController(
      text: patient?.umurSuami?.toString() ?? '',
    );
    final _agamaSuamiController = TextEditingController(
      text: patient?.agamaSuami ?? '',
    );
    final _agamaPasienController = TextEditingController(
      text: patient?.agamaPasien ?? '',
    );
    final _pekerjaanPasienController = TextEditingController(
      text: patient?.pekerjaanPasien ?? '',
    );

    DateTime _selectedDate = patient?.tanggalLahir ?? DateTime.now();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    patient == null ? 'Tambah Pasien' : 'Edit Pasien',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFormField(
                            controller: _namaController,
                            label: 'Nama Lengkap',
                            icon: Icons.person_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama lengkap tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (patient == null &&
                                  (value == null || value.isEmpty)) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _noHpController,
                            label: 'No HP',
                            icon: Icons.phone_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'No HP tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _alamatController,
                            label: 'Alamat',
                            icon: Icons.home_rounded,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: const Color(0xFFEC407A),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Tgl Lahir: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Divider for husband information
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Informasi Suami',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildFormField(
                            controller: _namaSuamiController,
                            label: 'Nama Suami',
                            icon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildFormField(
                            controller: _pekerjaanSuamiController,
                            label: 'Pekerjaan Suami',
                            icon: Icons.work_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildFormField(
                            controller: _umurSuamiController,
                            label: 'Umur Suami',
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          _buildFormField(
                            controller: _agamaSuamiController,
                            label: 'Agama Suami',
                            icon: Icons.church_rounded,
                          ),
                          const SizedBox(height: 16),

                          // Divider for patient additional information
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'Informasi Tambahan Pasien',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildFormField(
                            controller: _agamaPasienController,
                            label: 'Agama',
                            icon: Icons.church_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildFormField(
                            controller: _pekerjaanPasienController,
                            label: 'Pekerjaan',
                            icon: Icons.work_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: safeCloseDialog,
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final userData = UserModel(
                                      id:
                                          patient?.id ??
                                          _firebaseService.generateId(),
                                      nama: _namaController.text,
                                      email: _emailController.text,
                                      password:
                                          _passwordController.text.isNotEmpty
                                              ? _passwordController.text
                                              : patient?.password ?? '',
                                      noHp: _noHpController.text,
                                      alamat: _alamatController.text,
                                      tanggalLahir: _selectedDate,
                                      umur:
                                          DateTime.now().year -
                                          _selectedDate.year,
                                      role: 'pasien',
                                      createdAt:
                                          patient?.createdAt ?? DateTime.now(),

                                      // New fields
                                      namaSuami:
                                          _namaSuamiController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _namaSuamiController.text
                                                  .trim(),
                                      pekerjaanSuami:
                                          _pekerjaanSuamiController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _pekerjaanSuamiController.text
                                                  .trim(),
                                      umurSuami:
                                          _umurSuamiController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : int.tryParse(
                                                _umurSuamiController.text
                                                    .trim(),
                                              ),
                                      agamaSuami:
                                          _agamaSuamiController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _agamaSuamiController.text
                                                  .trim(),
                                      agamaPasien:
                                          _agamaPasienController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _agamaPasienController.text
                                                  .trim(),
                                      pekerjaanPasien:
                                          _pekerjaanPasienController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _pekerjaanPasienController.text
                                                  .trim(),
                                    );

                                    if (patient == null) {
                                      await _firebaseService.createUser(
                                        userData,
                                      );
                                    } else {
                                      await _firebaseService.updateUser(
                                        userData,
                                      );
                                    }

                                    safeCloseDialog();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          patient == null
                                              ? 'Pasien berhasil ditambahkan'
                                              : 'Pasien berhasil diperbarui',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error: $e',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC407A),
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                patient == null ? 'Tambah' : 'Perbarui',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFEC407A)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEC407A)),
        ),
      ),
      style: GoogleFonts.poppins(),
      validator: validator,
    );
  }

  void _showDeleteDialog(UserModel patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hapus Pasien',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus data pasien ${patient.nama}?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePatient(patient.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                            Icons.people_rounded,
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
                                'Data Pasien',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Kelola data pasien',
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
                    const SizedBox(height: 20),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterPatients();
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Cari berdasarkan nama, no HP, alamat, atau email...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFFEC407A),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            'Total Pasien',
                            _allPatients.length,
                            Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard(
                            'Hari Ini',
                            _getTodayCount(),
                            Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard(
                            'Minggu Ini',
                            _getThisWeekCount(),
                            Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Patients List
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEC407A),
                          ),
                        )
                        : _filteredPatients.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada data pasien',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: const Color(
                                        0xFFEC407A,
                                      ).withValues(alpha: 0.1),
                                      child: Text(
                                        patient.nama.isNotEmpty
                                            ? patient.nama[0].toUpperCase()
                                            : '?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFEC407A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            patient.nama,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2D3748),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            patient.email,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            patient.noHp,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),

                                          // New fields
                                          if (patient.agamaPasien != null &&
                                              patient
                                                  .agamaPasien!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Agama: ${patient.agamaPasien}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],

                                          if (patient.pekerjaanPasien != null &&
                                              patient
                                                  .pekerjaanPasien!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Pekerjaan: ${patient.pekerjaanPasien}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],

                                          if (patient.namaSuami != null &&
                                              patient
                                                  .namaSuami!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Suami: ${patient.namaSuami}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        color: Colors.grey[600],
                                      ),
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _showAddEditDialog(patient);
                                            break;
                                          case 'delete':
                                            _showDeleteDialog(patient);
                                            break;
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_rounded,
                                                    size: 18,
                                                    color: Colors.blue[600],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Edit',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_rounded,
                                                    size: 18,
                                                    color: Colors.red[600],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Hapus',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC407A).withValues(alpha: 0.3),
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

  // Status count methods
  int _getTodayCount() {
    final today = DateTime.now();
    return _allPatients.where((patient) {
      final createdAt = patient.createdAt;
      return createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day;
    }).length;
  }

  int _getThisWeekCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _allPatients.where((patient) {
      final createdAt = patient.createdAt;
      return createdAt.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          createdAt.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).length;
  }

  // Status card widget
  Widget _buildStatusCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEC407A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFEC407A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
