import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/konsultasi_model.dart';
import '../../services/firebase_service.dart';

class DataKonsultasiPasienScreen extends StatefulWidget {
  const DataKonsultasiPasienScreen({super.key});

  @override
  State<DataKonsultasiPasienScreen> createState() =>
      _DataKonsultasiPasienScreenState();
}

class _DataKonsultasiPasienScreenState
    extends State<DataKonsultasiPasienScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<KonsultasiModel> _allConsultations = [];
  List<KonsultasiModel> _filteredConsultations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all'; // 'all', 'pending', 'answered'

  @override
  void initState() {
    super.initState();
    _loadConsultations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConsultations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _firebaseService.getKonsultasiStream().listen((consultations) {
        setState(() {
          _allConsultations = consultations;
          _filterConsultations();
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

  void _filterConsultations() {
    List<KonsultasiModel> filtered = _allConsultations;

    // Filter by status
    if (_selectedStatus != 'all') {
      filtered =
          filtered
              .where((consultation) => consultation.status == _selectedStatus)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((consultation) {
            return consultation.pasienNama.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                consultation.pertanyaan.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (consultation.jawaban?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);
          }).toList();
    }

    setState(() {
      _filteredConsultations = filtered;
    });
  }

  void _showResponseDialog(KonsultasiModel consultation) {
    final _responseController = TextEditingController(
      text: consultation.jawaban ?? '',
    );
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
                    'Jawab Konsultasi',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              Icons.person_rounded,
                              color: const Color(0xFFEC407A),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dari Pasien',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    consultation.pasienNama,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2D3748),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pertanyaan:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          consultation.pertanyaan,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Jawaban:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _responseController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tulis jawaban Anda...',
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
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
                                if (_responseController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Jawaban tidak boleh kosong',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final updatedConsultation = consultation
                                      .copyWith(
                                        jawaban:
                                            _responseController.text.trim(),
                                        status: 'answered',
                                        tanggalJawaban: DateTime.now(),
                                      );

                                  await _firebaseService.updateKonsultasi(
                                    updatedConsultation,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Jawaban berhasil dikirim'),
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
                                'Kirim Jawaban',
                                style: GoogleFonts.poppins(),
                              ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDetailDialog(KonsultasiModel consultation) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Detail Konsultasi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Pasien', consultation.pasienNama),
                _buildDetailRow(
                  'Tanggal',
                  DateFormat(
                    'dd MMMM yyyy HH:mm',
                  ).format(consultation.tanggalKonsultasi),
                ),
                _buildDetailRow(
                  'Status',
                  consultation.status == 'pending'
                      ? 'Menunggu Jawaban'
                      : 'Sudah Dijawab',
                ),
                const SizedBox(height: 16),
                Text(
                  'Pertanyaan:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Text(
                    consultation.pertanyaan,
                    style: GoogleFonts.poppins(color: const Color(0xFF2D3748)),
                  ),
                ),
                if (consultation.jawaban != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Jawaban:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                    child: Text(
                      consultation.jawaban!,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  if (consultation.tanggalJawaban != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dijawab pada: ${DateFormat('dd MMMM yyyy HH:mm').format(consultation.tanggalJawaban!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup', style: GoogleFonts.poppins()),
              ),
              if (consultation.status == 'pending')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showResponseDialog(consultation);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC407A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Jawab', style: GoogleFonts.poppins()),
                ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: const Color(0xFF2D3748)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Data Konsultasi Pasien',
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
                    const Color(0xFFEC407A).withOpacity(0.8),
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
                    color: const Color(0xFFEC407A).withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.question_answer_rounded,
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
                              'Kelola Data Konsultasi',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Input dan kelola konsultasi pasien',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Status Summary
                  Row(
                    children: [
                      _buildStatusCard(
                        'Total',
                        _allConsultations.length,
                        Colors.white,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusCard(
                        'Pending',
                        _allConsultations
                            .where((c) => c.status == 'pending')
                            .length,
                        Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusCard(
                        'Answered',
                        _allConsultations
                            .where((c) => c.status == 'answered')
                            .length,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Cari berdasarkan nama pasien atau pertanyaan...',
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
                        _filterConsultations();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip('Semua', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Menunggu', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Dijawab', 'answered'),
                    ],
                  ),
                ],
              ),
            ),

            // Consultation List
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEC407A),
                        ),
                      )
                      : _filteredConsultations.isEmpty
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
                                Icons.question_answer_outlined,
                                size: 60,
                                color: const Color(0xFFEC407A),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isEmpty && _selectedStatus == 'all'
                                  ? 'Belum ada data konsultasi'
                                  : 'Tidak ada hasil pencarian',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty && _selectedStatus == 'all'
                                  ? 'Pasien akan mengirim konsultasi di sini'
                                  : 'Coba kata kunci atau filter yang berbeda',
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
                        itemCount: _filteredConsultations.length,
                        itemBuilder: (context, index) {
                          final consultation = _filteredConsultations[index];
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
                                      // Status Icon
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color:
                                              consultation.status == 'pending'
                                                  ? Colors.orange.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.green.withOpacity(
                                                    0.1,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                consultation.status == 'pending'
                                                    ? Colors.orange.withOpacity(
                                                      0.3,
                                                    )
                                                    : Colors.green.withOpacity(
                                                      0.3,
                                                    ),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          consultation.status == 'pending'
                                              ? Icons.schedule_rounded
                                              : Icons.check_circle_rounded,
                                          color:
                                              consultation.status == 'pending'
                                                  ? Colors.orange
                                                  : Colors.green,
                                          size: 24,
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
                                              consultation.pasienNama,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: const Color(0xFF2D3748),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat(
                                                'dd MMM yyyy HH:mm',
                                              ).format(
                                                consultation.tanggalKonsultasi,
                                              ),
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
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
                                            _showDetailDialog(consultation);
                                          } else if (value == 'respond' &&
                                              consultation.status ==
                                                  'pending') {
                                            _showResponseDialog(consultation);
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
                                              if (consultation.status ==
                                                  'pending')
                                                PopupMenuItem(
                                                  value: 'respond',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.reply_rounded,
                                                        color: Colors.green,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Jawab',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.green,
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
                                  // Question
                                  Text(
                                    consultation.pertanyaan,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF2D3748),
                                      fontSize: 14,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          consultation.status == 'pending'
                                              ? Colors.orange.withOpacity(0.1)
                                              : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            consultation.status == 'pending'
                                                ? Colors.orange.withOpacity(0.3)
                                                : Colors.green.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      consultation.status == 'pending'
                                          ? 'Menunggu Jawaban'
                                          : 'Sudah Dijawab',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color:
                                            consultation.status == 'pending'
                                                ? Colors.orange
                                                : Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
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
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = value;
          _filterConsultations();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEC407A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFEC407A) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? Colors.white : color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color:
                    color == Colors.white
                        ? Colors.white.withOpacity(0.9)
                        : color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
