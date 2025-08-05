import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/konsultasi_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';

class KonsultasiPasienScreen extends StatefulWidget {
  final UserModel user;

  const KonsultasiPasienScreen({super.key, required this.user});

  @override
  State<KonsultasiPasienScreen> createState() => _KonsultasiPasienScreenState();
}

class _KonsultasiPasienScreenState extends State<KonsultasiPasienScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<KonsultasiModel> _consultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultations();
  }

  Future<void> _loadConsultations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _firebaseService.getKonsultasiStream().listen((consultations) {
        setState(() {
          _consultations =
              consultations.where((c) => c.pasienId == widget.user.id).toList();
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

  void _showAddConsultationDialog() {
    final _questionController = TextEditingController();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    'Ajukan Konsultasi',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tulis pertanyaan Anda di bawah ini:',
                        style: GoogleFonts.poppins(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _questionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Tulis pertanyaan Anda...',
                          border: OutlineInputBorder(),
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
                                if (_questionController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pertanyaan tidak boleh kosong',
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
                                  final consultation = KonsultasiModel(
                                    id: _firebaseService.generateId(),
                                    pasienId: widget.user.id,
                                    pasienNama: widget.user.nama,
                                    pertanyaan: _questionController.text.trim(),
                                    status: 'pending',
                                    tanggalKonsultasi: DateTime.now(),
                                  );

                                  await _firebaseService.createKonsultasi(
                                    consultation,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Konsultasi berhasil dikirim',
                                      ),
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
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('Kirim', style: GoogleFonts.poppins()),
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
            title: Text(
              'Detail Konsultasi',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(consultation.tanggalKonsultasi)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pertanyaan:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    consultation.pertanyaan,
                    style: GoogleFonts.poppins(),
                  ),
                ),
                if (consultation.jawaban != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Jawaban:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      consultation.jawaban!,
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  if (consultation.tanggalJawaban != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dijawab pada: ${DateFormat('dd/MM/yyyy HH:mm').format(consultation.tanggalJawaban!)}',
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
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.question_answer,
                  color: const Color(0xFF667eea),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konsultasi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Ajukan pertanyaan kepada dokter',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Consultations List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _consultations.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.question_answer_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada konsultasi',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajukan pertanyaan pertama Anda',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _consultations.length,
                      itemBuilder: (context, index) {
                        final consultation = _consultations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor:
                                  consultation.status == 'pending'
                                      ? Colors.orange
                                      : Colors.green,
                              child: Icon(
                                consultation.status == 'pending'
                                    ? Icons.schedule
                                    : Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              consultation.pertanyaan,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(consultation.tanggalKonsultasi),
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        consultation.status == 'pending'
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    consultation.status == 'pending'
                                        ? 'Menunggu Jawaban'
                                        : 'Sudah Dijawab',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
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
                            trailing: IconButton(
                              onPressed: () => _showDetailDialog(consultation),
                              icon: const Icon(Icons.visibility),
                              tooltip: 'Lihat Detail',
                            ),
                            onTap: () => _showDetailDialog(consultation),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddConsultationDialog,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
