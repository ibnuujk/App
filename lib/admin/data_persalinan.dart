import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';

class DataPersalinanScreen extends StatefulWidget {
  const DataPersalinanScreen({super.key});

  @override
  State<DataPersalinanScreen> createState() => _DataPersalinanScreenState();
}

class _DataPersalinanScreenState extends State<DataPersalinanScreen> {
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filterOptions = [
    'Semua',
    'Sudah Melahirkan',
    'Belum Melahirkan',
    'Pasca Persalinan',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Laporan Persalinan',
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
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
                      hintText: 'Cari data pasien...',
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
                  ),
                ),
                const SizedBox(height: 20),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children:
                        _filterOptions.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: FilterChip(
                              label: Text(
                                filter,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xFFEC407A),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              selectedColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              checkmarkColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFEC407A)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pregnant_woman_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data pasien',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data pasien akan muncul di sini',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final users =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return UserModel.fromMap(data);
                    }).toList();

                // Filter users based on search and filter
                final filteredUsers =
                    users.where((user) {
                      final matchesSearch =
                          user.nama.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          user.noHp.contains(_searchQuery) ||
                          user.alamat.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );

                      if (!matchesSearch) return false;

                      switch (_selectedFilter) {
                        case 'Sudah Melahirkan':
                          return user.pregnancyStatus == 'completed';
                        case 'Belum Melahirkan':
                          return user.pregnancyStatus == 'active' ||
                              user.pregnancyStatus == null;
                        case 'Pasca Persalinan':
                          return user.pregnancyStatus == 'completed';
                        default:
                          return true;
                      }
                    }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada hasil pencarian',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba ubah kata kunci pencarian',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildPatientCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Patient Info Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFEC407A), const Color(0xFFF48FB1)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.pregnant_woman_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nama,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.noHp,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.alamat,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getPregnancyStatusText(user.pregnancyStatus),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Laporan\nPersalinan',
                    Icons.local_hospital_rounded,
                    const Color(0xFFEC407A),
                    () => _viewChildbirthReport(user),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Laporan\nPasca Persalinan',
                    Icons.medical_services_rounded,
                    const Color(0xFFF48FB1),
                    () => _viewPostpartumReport(user),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Keterangan\nKelahiran',
                    Icons.description_rounded,
                    const Color(0xFFAB47BC),
                    () => _viewBirthCertificate(user),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPregnancyStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'miscarriage':
        return 'Keguguran';
      case 'complication':
        return 'Komplikasi';
      default:
        return 'Belum Ada';
    }
  }

  void _viewChildbirthReport(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildbirthReportScreen(user: user),
      ),
    );
  }

  void _viewPostpartumReport(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostpartumReportScreen(user: user),
      ),
    );
  }

  void _viewBirthCertificate(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BirthCertificateScreen(user: user),
      ),
    );
  }
}

// Childbirth Report Screen
class ChildbirthReportScreen extends StatelessWidget {
  final UserModel user;

  const ChildbirthReportScreen({super.key, required this.user});

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'Tidak ada data';

      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Format tanggal tidak valid';
      }

      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Laporan Persalinan',
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
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('laporan_persalinan')
                .where('pasienId', isEqualTo: user.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEC407A)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_hospital_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada laporan persalinan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laporan persalinan untuk ${user.nama} belum tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildReportCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFEC407A), const Color(0xFFF48FB1)],
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Laporan Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Tanggal Masuk',
                  _formatDate(data['tanggalMasuk']),
                ),
                _buildInfoRow(
                  'Nama Pasien',
                  data['pasienNama'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Alamat Pasien',
                  data['pasienAlamat'] ?? 'Tidak ada data',
                ),
                if (data['catatan'] != null && data['catatan'].isNotEmpty)
                  _buildInfoRow('Catatan', data['catatan']),
              ],
            ),
          ),
        ],
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
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
}

// Postpartum Report Screen
class PostpartumReportScreen extends StatelessWidget {
  final UserModel user;

  const PostpartumReportScreen({super.key, required this.user});

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'Tidak ada data';

      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Format tanggal tidak valid';
      }

      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Laporan Pasca Persalinan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFF48FB1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('laporan_pasca_persalinan')
                .where('pasienId', isEqualTo: user.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF48FB1)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada laporan pasca persalinan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laporan pasca persalinan untuk ${user.nama} belum tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildPostpartumCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostpartumCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFF48FB1), const Color(0xFFF8BBD9)],
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Laporan Pasca Persalinan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Tanggal Fundus Uterus',
                  _formatDate(data['tanggalFundusUterus']),
                ),
                _buildInfoRow(
                  'Tanggal Keluar',
                  _formatDate(data['tanggalKeluar']),
                ),
                _buildInfoRow(
                  'Jam Keluar',
                  data['jamKeluar'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Kondisi Keluar',
                  data['kondisiKeluar'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Tekanan Darah',
                  data['tekananDarah'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Suhu Badan',
                  data['suhuBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow('Nadi', data['nadi'] ?? 'Tidak ada data'),
                _buildInfoRow(
                  'Pernafasan',
                  data['pernafasan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Kelahiran Anak',
                  data['kelahiranAnak'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Jenis Kelamin',
                  data['jenisKelamin'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Berat Badan',
                  data['beratBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Panjang Badan',
                  data['panjangBadan'] ?? 'Tidak ada data',
                ),
                if (data['catatanKeluar'] != null &&
                    data['catatanKeluar'].isNotEmpty)
                  _buildInfoRow('Catatan Keluar', data['catatanKeluar']),
              ],
            ),
          ),
        ],
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
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
}

// Birth Certificate Screen
class BirthCertificateScreen extends StatelessWidget {
  final UserModel user;

  const BirthCertificateScreen({super.key, required this.user});

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'Tidak ada data';

      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Format tanggal tidak valid';
      }

      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  String _formatTime(dynamic timeValue) {
    try {
      if (timeValue == null || timeValue.toString().isEmpty)
        return 'Tidak ada data';
      return timeValue.toString();
    } catch (e) {
      return 'Format waktu tidak valid';
    }
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
        backgroundColor: const Color(0xFFAB47BC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('keterangan_kelahiran')
                .where('pasienId', isEqualTo: user.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFAB47BC)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada keterangan kelahiran',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keterangan kelahiran untuk ${user.nama} belum tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildBirthCertificateCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildBirthCertificateCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFFAB47BC), const Color(0xFFCE93D8)],
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Keterangan Kelahiran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Nama Anak',
                  data['namaAnak'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Jenis Kelamin',
                  data['jenisKelamin'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Tanggal Lahir',
                  _formatDate(data['hariTanggalLahir']),
                ),
                _buildInfoRow('Jam Lahir', _formatTime(data['jamLahir'])),
                _buildInfoRow(
                  'Tempat Lahir',
                  data['tempatLahir'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Berat Badan',
                  data['beratBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Panjang Badan',
                  data['panjangBadan'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Kelahiran Anak Ke',
                  '${data['kelahiranAnakKe'] ?? 1}',
                ),
                _buildInfoRow(
                  'Nama Ayah',
                  data['namaAyah'] ?? 'Tidak ada data',
                ),
                _buildInfoRow('Nama Ibu', data['namaIbu'] ?? 'Tidak ada data'),
                _buildInfoRow('Umur Ayah', '${data['umurAyah'] ?? 0} tahun'),
                _buildInfoRow('Umur Ibu', '${data['umurIbu'] ?? 0} tahun'),
                _buildInfoRow(
                  'Pekerjaan Ayah',
                  data['pekerjaanAyah'] ?? 'Tidak ada data',
                ),
                _buildInfoRow(
                  'Pekerjaan Ibu',
                  data['pekerjaanIbu'] ?? 'Tidak ada data',
                ),
                _buildInfoRow('Alamat', data['alamat'] ?? 'Tidak ada data'),
              ],
            ),
          ),
        ],
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
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
}
