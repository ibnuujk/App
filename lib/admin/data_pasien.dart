import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class DataPasienScreen extends StatefulWidget {
  const DataPasienScreen({super.key});

  @override
  State<DataPasienScreen> createState() => _DataPasienScreenState();
}

class _DataPasienScreenState extends State<DataPasienScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<UserModel> _allPatients = [];
  List<UserModel> _filteredPatients = [];
  bool _isLoading = true;
  bool _isRetrying = false;
  String _searchQuery = '';
  String? _errorMessage;
  int _retryCount = 0;
  final int _maxRetries = 3;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<List<UserModel>>? _patientsSubscription;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _patientsSubscription?.cancel();
    super.dispose();
  }

  void _loadPatients() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isRetrying = false;
    });

    // Cancel existing subscription if any
    _patientsSubscription?.cancel();

    _patientsSubscription = _firebaseService
        .getUsersStream(limit: 100)
        .listen(
          (patients) {
            if (mounted) {
              setState(() {
                _allPatients = patients;
                _filterPatients();
                _isLoading = false;
                _retryCount = 0; // Reset retry count on success
                _errorMessage = null;
              });
            }
          },
          onError: (e) {
            if (mounted) {
              print('Error loading patients: $e');
              setState(() {
                _isLoading = false;
                _errorMessage = e.toString();
              });
              _handleLoadError(e);
            }
          },
        );

    // Add timeout fallback
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Loading timeout. Please check your connection.';
        });
        _handleLoadError('Timeout');
      }
    });
  }

  void _handleLoadError(dynamic error) {
    if (_retryCount < _maxRetries) {
      setState(() {
        _isRetrying = true;
      });

      // Auto retry after delay
      Future.delayed(Duration(seconds: 2 + _retryCount), () {
        if (mounted) {
          _retryCount++;
          print('Retrying to load patients... Attempt $_retryCount');
          _loadPatients();
        }
      });
    } else {
      // Show error message after max retries
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load patients after $_maxRetries attempts',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _retryCount = 0;
                _loadPatients();
              },
            ),
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
            final query = _searchQuery.toLowerCase();
            return patient.nama.toLowerCase().contains(query) ||
                patient.noHp.contains(query) ||
                patient.alamat.toLowerCase().contains(query) ||
                patient.email.toLowerCase().contains(query);
          }).toList();
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
                                return 'Nama tidak boleh kosong';
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
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _noHpController,
                            label: 'Nomor HP',
                            icon: Icons.phone_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor HP tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _alamatController,
                            label: 'Alamat',
                            icon: Icons.location_on_rounded,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEC407A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEC407A).withOpacity(0.2),
                                width: 1,
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tanggal Lahir',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd MMMM yyyy',
                                        ).format(_selectedDate),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme:
                                                const ColorScheme.light(
                                                  primary: Color(0xFFEC407A),
                                                ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _selectedDate = date;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    color: const Color(0xFFEC407A),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (!_formKey.currentState!.validate()) return;
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  final newPatient = UserModel(
                                    id:
                                        patient?.id ??
                                        _firebaseService.generateId(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                    nama: _namaController.text.trim(),
                                    noHp: _noHpController.text.trim(),
                                    alamat: _alamatController.text.trim(),
                                    tanggalLahir: _selectedDate,
                                    umur: _firebaseService.calculateAge(
                                      _selectedDate,
                                    ),
                                    role: 'pasien',
                                    createdAt:
                                        patient?.createdAt ?? DateTime.now(),
                                  );
                                  await _firebaseService.createUser(newPatient);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        patient == null
                                            ? 'Pasien berhasil ditambahkan'
                                            : 'Pasien berhasil diperbarui',
                                      ),
                                      backgroundColor: const Color(0xFFEC407A),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                patient == null ? 'Tambah' : 'Simpan',
                                style: GoogleFonts.poppins(),
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
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFEC407A)),
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
          borderSide: const BorderSide(color: Color(0xFFEC407A), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
    );
  }

  void _showDeleteDialog(UserModel patient) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Hapus Pasien',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus pasien ${patient.nama}?',
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
                  try {
                    await _firebaseService.deleteUser(patient.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pasien berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Hapus', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFEC407A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(
          'Tambah Pasien',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
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
                          Icons.people_rounded,
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
                              'Data Pasien',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kelola data pasien dengan mudah',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                if (_errorMessage != null && !_isLoading)
                                  IconButton(
                                    onPressed: () {
                                      _retryCount = 0;
                                      _loadPatients();
                                    },
                                    icon: Icon(
                                      Icons.refresh,
                                      color: Colors.red[400],
                                      size: 20,
                                    ),
                                    tooltip: 'Retry loading',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _errorMessage != null
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            _errorMessage != null
                                ? Colors.red.withOpacity(0.3)
                                : Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _errorMessage != null ? Icons.wifi_off : Icons.wifi,
                          size: 16,
                          color:
                              _errorMessage != null ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage != null
                                ? 'Koneksi bermasalah - ${_allPatients.length} data tersimpan'
                                : '${_allPatients.length} pasien dimuat',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  _errorMessage != null
                                      ? Colors.red[700]
                                      : Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_isLoading || _isRetrying)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Cari berdasarkan nama, no HP, alamat, atau email...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: const Color(0xFFEC407A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterPatients();
                      });
                    },
                  ),
                ],
              ),
            ),

            // Patient List
            Expanded(
              child:
                  _isLoading || _isRetrying
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFFEC407A),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isRetrying
                                  ? 'Mencoba lagi... ($_retryCount/$_maxRetries)'
                                  : 'Memuat data pasien...',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Error: $_errorMessage',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      )
                      : _errorMessage != null && _filteredPatients.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat data pasien',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage ?? 'Terjadi kesalahan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _retryCount = 0;
                                _loadPatients();
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEC407A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : _filteredPatients.isEmpty
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
                                Icons.people_outline_rounded,
                                size: 60,
                                color: const Color(0xFFEC407A),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Belum ada data pasien'
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
                                  ? 'Tambahkan pasien pertama Anda'
                                  : 'Coba kata kunci yang berbeda',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: () async {
                          _retryCount = 0;
                          _loadPatients();
                          // Wait for data to load or timeout
                          int waitTime = 0;
                          while (_isLoading && waitTime < 5000) {
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            waitTime += 100;
                          }
                        },
                        color: const Color(0xFFEC407A),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
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
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFEC407A,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFEC407A,
                                          ).withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          patient.nama.isNotEmpty
                                              ? patient.nama[0].toUpperCase()
                                              : 'P',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFEC407A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
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
                                            patient.nama,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: const Color(0xFF2D3748),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            Icons.phone_rounded,
                                            patient.noHp,
                                          ),
                                          const SizedBox(height: 4),
                                          _buildInfoRow(
                                            Icons.cake_rounded,
                                            '${patient.umur} tahun',
                                          ),
                                          const SizedBox(height: 4),
                                          _buildInfoRow(
                                            Icons.location_on_rounded,
                                            patient.alamat,
                                            maxLines: 2,
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showAddEditDialog(patient);
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(patient);
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
                                                    color: const Color(
                                                      0xFFEC407A,
                                                    ),
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Edit',
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(
                                                        0xFFEC407A,
                                                      ),
                                                    ),
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
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Hapus',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.red,
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
                            );
                          },
                        ),
                      ),
            ),
          ],
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
