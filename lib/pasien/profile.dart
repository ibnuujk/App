import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/article_model.dart';
import '../../services/firebase_service.dart';
import '../../routes/route_helper.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _children = [];
  bool _isLoading = true;
  bool _isEditing = false;

  // Form controllers for editing profile
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Local user data for display
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadChildren();
    _initializeControllers();
  }

  void _initializeControllers() {
    _namaController.text = _currentUser.nama;
    _emailController.text = _currentUser.email;
    _noHpController.text = _currentUser.noHp;
    _alamatController.text = _currentUser.alamat;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _firebaseService.getChildrenStream(widget.user.id).listen((children) {
        setState(() {
          _children = children;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddChildDialog(),
    ).then((_) => _loadChildren());
  }

  void _showEditChildDialog(Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder: (context) => EditChildDialog(child: child),
    ).then((_) => _loadChildren());
  }

  void _showDeleteChildDialog(Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Hapus Data Anak',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus data anak "${child['nama']}"?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _firebaseService.deleteChild(child['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data anak berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadChildren();
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
                ),
                child: Text('Hapus', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Create updated user with only editable fields
      final updatedUser = _currentUser.copyWith(
        nama: _namaController.text.trim(),
        noHp: _noHpController.text.trim(),
        alamat: _alamatController.text.trim(),
        // Note: email, umur, tanggalLahir are not editable in profile
      );

      // Show loading state
      setState(() {
        _isLoading = true;
      });

      // Update user in Firebase
      await _firebaseService.updateUser(updatedUser);

      // Update the local state to reflect changes
      setState(() {
        _currentUser = updatedUser;
        _isEditing = false;
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Color(0xFFEC407A),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Profil Saya',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEC407A),
                    const Color(0xFFEC407A).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC407A).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      _currentUser.nama.isNotEmpty
                          ? _currentUser.nama[0].toUpperCase()
                          : 'P',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser.nama,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Pasien Sistem Persalinan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Informasi Pribadi',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2d3748),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (!_isEditing) {
                              _initializeControllers();
                            }
                          });
                        },
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit,
                          color: const Color(0xFFEC407A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isEditing) ...[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _namaController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              if (value.trim().length < 2) {
                                return 'Nama minimal 2 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            enabled: false, // Email tidak bisa diubah
                            decoration: InputDecoration(
                              labelText: 'Email (Tidak bisa diubah)',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _noHpController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'No HP',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.phone),
                              hintText: 'Contoh: 08123456789',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'No HP tidak boleh kosong';
                              }
                              if (value.trim().length < 10) {
                                return 'No HP minimal 10 digit';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                                return 'No HP hanya boleh berisi angka';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _alamatController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Alamat',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.location_on),
                              hintText: 'Masukkan alamat lengkap',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat tidak boleh kosong';
                              }
                              if (value.trim().length < 10) {
                                return 'Alamat minimal 10 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () {
                                            setState(() {
                                              _isEditing = false;
                                              _initializeControllers();
                                            });
                                          },
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEC407A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
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
                  ] else ...[
                    _buildInfoRow('Nama', _currentUser.nama),
                    _buildInfoRow('Email', _currentUser.email),
                    _buildInfoRow('No HP', _currentUser.noHp),
                    _buildInfoRow(
                      'Tanggal Lahir',
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(_currentUser.tanggalLahir),
                    ),
                    _buildInfoRow('Umur', '${_currentUser.umur} tahun'),
                    _buildInfoRow('Alamat', _currentUser.alamat),

                    // New fields
                    if (_currentUser.agamaPasien != null &&
                        _currentUser.agamaPasien!.isNotEmpty)
                      _buildInfoRow('Agama', _currentUser.agamaPasien!),
                    if (_currentUser.pekerjaanPasien != null &&
                        _currentUser.pekerjaanPasien!.isNotEmpty)
                      _buildInfoRow('Pekerjaan', _currentUser.pekerjaanPasien!),

                    // Husband information
                    if (_currentUser.namaSuami != null &&
                        _currentUser.namaSuami!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Informasi Suami',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2d3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Nama Suami', _currentUser.namaSuami!),
                      if (_currentUser.pekerjaanSuami != null &&
                          _currentUser.pekerjaanSuami!.isNotEmpty)
                        _buildInfoRow(
                          'Pekerjaan Suami',
                          _currentUser.pekerjaanSuami!,
                        ),
                      if (_currentUser.umurSuami != null)
                        _buildInfoRow(
                          'Umur Suami',
                          '${_currentUser.umurSuami} tahun',
                        ),
                      if (_currentUser.agamaSuami != null &&
                          _currentUser.agamaSuami!.isNotEmpty)
                        _buildInfoRow('Agama Suami', _currentUser.agamaSuami!),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Children Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.user.pregnancyStatus == 'miscarriage'
                            ? 'Keguguran'
                            : 'Data Anak',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2d3748),
                        ),
                      ),
                      if (widget.user.pregnancyStatus != 'miscarriage') ...[
                        ElevatedButton.icon(
                          onPressed: _showAddChildDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(
                            'Tambah Anak',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEC407A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_children.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            widget.user.pregnancyStatus == 'miscarriage'
                                ? Icons.cancel_rounded
                                : Icons.child_care_outlined,
                            size: 64,
                            color:
                                widget.user.pregnancyStatus == 'miscarriage'
                                    ? const Color(0xFFE53E3E)
                                    : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.user.pregnancyStatus == 'miscarriage'
                                ? 'Tidak ada data keguguran'
                                : 'Belum ada data anak',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.user.pregnancyStatus == 'miscarriage'
                                ? 'Data keguguran akan ditampilkan di sini'
                                : 'Tambahkan data anak Anda',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    widget.user.pregnancyStatus == 'miscarriage'
                        ? _buildMiscarriageInfo()
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _children.length,
                          itemBuilder: (context, index) {
                            final child = _children[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFFEC407A),
                                    child: Icon(
                                      Icons.child_care_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          child['nama'] ?? 'Nama Anak',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Tanggal Lahir: ${child['tanggalLahir'] is DateTime ? DateFormat('dd/MM/yyyy').format(child['tanggalLahir']) : child['tanggalLahir']}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'Jenis Kelamin: ${child['jenisKelamin']}',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditChildDialog(child);
                                      } else if (value == 'delete') {
                                        _showDeleteChildDialog(child);
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.edit,
                                                  color: Color(0xFFEC407A),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Edit',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Hapus',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),

            // Riwayat Kehamilan Section (if user has pregnancy history)
            if (widget.user.pregnancyHistory.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                        Icon(
                          Icons.history,
                          color: const Color(0xFFEC407A),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Riwayat Kehamilan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2d3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPregnancyHistorySection(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Liked Articles Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: const Color(0xFFEC407A),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Artikel yang Disukai',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2d3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLikedArticlesSection(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bookmarked Articles Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: const Color(0xFFEC407A),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Baca Nanti',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2d3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBookmarkedArticlesSection(),
                ],
              ),
            ),
          ],
        ),
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
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: const Color(0xFF2d3748)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedArticlesSection() {
    return StreamBuilder<List<String>>(
      stream: _firebaseService.getLikedArticleIds(_currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final likedArticleIds = snapshot.data ?? [];

        if (likedArticleIds.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada artikel yang disukai',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Suka artikel yang menarik untuk melihatnya di sini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Display actual liked articles
            StreamBuilder<List<Article>>(
              stream: _firebaseService.getArticlesByIds(likedArticleIds),
              builder: (context, articlesSnapshot) {
                if (articlesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (articlesSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${articlesSnapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                final articles = articlesSnapshot.data ?? [];

                if (articles.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada artikel yang ditemukan'),
                  );
                }

                return Column(
                  children:
                      articles.map((article) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteHelper.articleDetail,
                                  arguments: {
                                    'article': article,
                                    'user': _currentUser,
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.favorite,
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
                                            article.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            article.category,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookmarkedArticlesSection() {
    return StreamBuilder<List<String>>(
      stream: _firebaseService.getBookmarkedArticleIds(_currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final bookmarkedArticleIds = snapshot.data ?? [];

        if (bookmarkedArticleIds.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'Belum ada artikel yang disimpan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Simpan artikel untuk dibaca nanti',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Display actual bookmarked articles
            StreamBuilder<List<Article>>(
              stream: _firebaseService.getArticlesByIds(bookmarkedArticleIds),
              builder: (context, articlesSnapshot) {
                if (articlesSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (articlesSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${articlesSnapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                final articles = articlesSnapshot.data ?? [];

                if (articles.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada artikel yang ditemukan'),
                  );
                }

                return Column(
                  children:
                      articles.map((article) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteHelper.articleDetail,
                                  arguments: {
                                    'article': article,
                                    'user': _currentUser,
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.bookmark,
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
                                            article.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            article.category,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiscarriageInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE53E3E).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cancel_rounded,
                    color: const Color(0xFFE53E3E),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Status Keguguran',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE53E3E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tanggal: ${widget.user.pregnancyEndDate != null ? DateFormat('dd/MM/yyyy').format(widget.user.pregnancyEndDate!) : '-'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alasan: ${widget.user.pregnancyEndReason != null ? _getReasonText(widget.user.pregnancyEndReason!) : 'keguguran'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Catatan: ${widget.user.pregnancyNotes != null && widget.user.pregnancyNotes!.isNotEmpty ? widget.user.pregnancyNotes! : '-'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'miscarriage':
        return 'Keguguran';
      case 'complication':
        return 'Komplikasi Medis';
      case 'birth':
        return 'Kelahiran';
      default:
        return reason;
    }
  }

  Widget _buildPregnancyHistorySection() {
    return Column(
      children:
          widget.user.pregnancyHistory.map((history) {
            final hpht =
                history['hpht'] is String
                    ? DateTime.tryParse(history['hpht'])
                    : history['hpht'] as DateTime?;
            final endDate =
                history['pregnancyEndDate'] is String
                    ? DateTime.tryParse(history['pregnancyEndDate'])
                    : history['pregnancyEndDate'] as DateTime?;
            final status = history['pregnancyStatus'] as String?;
            final reason = history['pregnancyEndReason'] as String?;
            final notes = history['pregnancyNotes'] as String?;
            final createdAt =
                history['createdAt'] is String
                    ? DateTime.tryParse(history['createdAt'])
                    : history['createdAt'] as DateTime?;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    status == 'miscarriage'
                        ? const Color(0xFFFFEBEE)
                        : status == 'completed'
                        ? const Color(0xFFE8F5E8)
                        : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      status == 'miscarriage'
                          ? const Color(0xFFE53E3E).withValues(alpha: 0.3)
                          : status == 'completed'
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                          : Colors.grey[300]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        status == 'miscarriage'
                            ? Icons.cancel_rounded
                            : status == 'completed'
                            ? Icons.check_circle_rounded
                            : Icons.pregnant_woman_rounded,
                        color:
                            status == 'miscarriage'
                                ? const Color(0xFFE53E3E)
                                : status == 'completed'
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEC407A),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kehamilan ${status == 'miscarriage'
                            ? 'Keguguran'
                            : status == 'completed'
                            ? 'Selesai'
                            : 'Aktif'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              status == 'miscarriage'
                                  ? const Color(0xFFE53E3E)
                                  : status == 'completed'
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFEC407A),
                        ),
                      ),
                      if (createdAt != null) ...[
                        const Spacer(),
                        Text(
                          DateFormat('dd/MM/yyyy').format(createdAt),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hpht != null) ...[
                    Text(
                      'HPHT: ${DateFormat('dd/MM/yyyy').format(hpht)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (endDate != null) ...[
                    Text(
                      'Tanggal Berakhir: ${DateFormat('dd/MM/yyyy').format(endDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (reason != null && reason.isNotEmpty) ...[
                    Text(
                      'Alasan: ${_getReasonText(reason)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (notes != null && notes.isNotEmpty) ...[
                    Text(
                      'Catatan: $notes',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }
}

class AddChildDialog extends StatefulWidget {
  const AddChildDialog({super.key});

  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final _namaController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedGender = 'Laki-laki';
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal lahir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final childData = {
        'id': _firebaseService.generateId(),
        'userId': _firebaseService.currentUser?.uid,
        'nama': _namaController.text,
        'tanggalLahir': _selectedDate,
        'jenisKelamin': _selectedGender,
        'createdAt': DateTime.now(),
      };

      await _firebaseService.createChild(childData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data anak berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tambah Data Anak',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Anak *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama anak tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Pilih Tanggal Lahir *'
                                  : DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                color:
                                    _selectedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'Laki-laki',
                          child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Perempuan',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis kelamin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal', style: GoogleFonts.poppins()),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChild,
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
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text('Simpan', style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditChildDialog extends StatefulWidget {
  final Map<String, dynamic> child;

  const EditChildDialog({super.key, required this.child});

  @override
  State<EditChildDialog> createState() => _EditChildDialogState();
}

class _EditChildDialogState extends State<EditChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final _namaController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedGender = 'Laki-laki';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Debug: Print child data untuk debugging
    print('EditChildDialog - Child data: ${widget.child}');

    _namaController.text = widget.child['nama'] ?? '';

    // Handle tanggal lahir dengan berbagai format
    final tanggalLahirData = widget.child['tanggalLahir'];
    if (tanggalLahirData != null) {
      if (tanggalLahirData is String) {
        _selectedDate = DateTime.tryParse(tanggalLahirData);
      } else if (tanggalLahirData is DateTime) {
        _selectedDate = tanggalLahirData;
      }
    }

    // Validasi gender value untuk memastikan sesuai dengan options yang tersedia
    final genderFromData = widget.child['jenisKelamin'];
    print('EditChildDialog - Gender from data: $genderFromData');

    if (genderFromData == 'Laki-laki' || genderFromData == 'Perempuan') {
      _selectedGender = genderFromData;
    } else {
      print('EditChildDialog - Invalid gender value, using default: Laki-laki');
      _selectedGender = 'Laki-laki'; // default value
    }

    print('EditChildDialog - Selected gender: $_selectedGender');
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal lahir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedChildData = {
        ...widget.child,
        'nama': _namaController.text.trim(),
        'tanggalLahir': _selectedDate!.toIso8601String(),
        'jenisKelamin': _selectedGender,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firebaseService.updateChild(updatedChildData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data anak berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Data Anak',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Anak *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.child_care_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama anak tidak boleh kosong';
                        }
                        if (value.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Pilih Tanggal Lahir *'
                                  : DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                color:
                                    _selectedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'Laki-laki',
                          child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Perempuan',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis kelamin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: Text('Batal', style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateChild,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC407A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Update',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
