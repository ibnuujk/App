import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'pemeriksaan_ibuhamil.dart';

class JadwalKonsultasiScreen extends StatefulWidget {
  final UserModel user;

  const JadwalKonsultasiScreen({super.key, required this.user});

  @override
  State<JadwalKonsultasiScreen> createState() => _JadwalKonsultasiScreenState();
}

class _JadwalKonsultasiScreenState extends State<JadwalKonsultasiScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _consultationSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultationSchedules();
  }

  Future<void> _loadConsultationSchedules() async {
    try {
      _firebaseService.getJadwalKonsultasiStream().listen((schedules) {
        setState(() {
          _consultationSchedules = schedules;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading schedules: $e')));
      }
    }
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddConsultationScheduleDialog(
            onScheduleAdded: _loadConsultationSchedules,
          ),
    );
  }

  void _showEditScheduleDialog(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder:
          (context) => EditConsultationScheduleDialog(
            schedule: schedule,
            onScheduleUpdated: _loadConsultationSchedules,
          ),
    );
  }

  void _showScheduleDetailDialog(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder:
          (context) => ConsultationScheduleDetailDialog(schedule: schedule),
    );
  }

  Future<void> _approveSchedule(String scheduleId) async {
    try {
      await _firebaseService.updateJadwalKonsultasi({
        'id': scheduleId,
        'status': 'confirmed',
      });
      _loadConsultationSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule approved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error approving schedule: $e')));
      }
    }
  }

  Future<void> _rejectSchedule(String scheduleId) async {
    try {
      await _firebaseService.updateJadwalKonsultasi({
        'id': scheduleId,
        'status': 'rejected',
      });
      _loadConsultationSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule rejected successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rejecting schedule: $e')));
      }
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await _firebaseService.deleteJadwalKonsultasi(scheduleId);
      _loadConsultationSchedules();
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule deleted successfully')),
      );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting schedule: $e')));
      }
    }
  }

  // Helper method to format date
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(parsedDate);
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  // Helper method for dialog info rows
  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A5568),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to pemeriksaan ibu hamil
  void _navigateToPemeriksaan(Map<String, dynamic> schedule) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.medical_services_rounded,
                color: const Color(0xFFEC407A),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Lakukan Pemeriksaan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin melakukan pemeriksaan untuk:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              _buildDialogInfoRow('Nama Pasien', schedule['namaPasien'] ?? '-'),
              _buildDialogInfoRow(
                'Tanggal Konsultasi',
                _formatDate(schedule['tanggalKonsultasi']),
              ),
              _buildDialogInfoRow('Waktu', schedule['waktuKonsultasi'] ?? '-'),
              if (schedule['keluhan'] != null &&
                  schedule['keluhan'].toString().isNotEmpty)
                _buildDialogInfoRow('Keluhan', schedule['keluhan']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to pemeriksaan screen with schedule data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PemeriksaanIbuHamilScreen(
                      user: widget.user, // Admin user
                      consultationSchedule: schedule, // Pass schedule data for context
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lanjutkan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getPendingCount() {
    return _consultationSchedules
        .where((schedule) => schedule['status'] == 'pending')
        .length;
  }

  int _getConfirmedCount() {
    return _consultationSchedules
        .where((schedule) => schedule['status'] == 'confirmed')
        .length;
  }

  int _getRejectedCount() {
    return _consultationSchedules
        .where((schedule) => schedule['status'] == 'rejected')
        .length;
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
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
          'Jadwal Konsultasi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEC407A), Color(0xFFE91E63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC407A), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
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
                        child: const Icon(
                          Icons.schedule_rounded,
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
                              'Jadwal Konsultasi',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Kelola jadwal konsultasi pasien',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
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
            const SizedBox(height: 24),

            // Status summary cards
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Menunggu',
                    _getPendingCount(),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    'Diterima',
                    _getConfirmedCount(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    'Ditolak',
                    _getRejectedCount(),
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Schedule list
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _consultationSchedules.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                Icons.schedule_outlined,
                              size: 64,
                              color: Colors.grey[400],
                              ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada jadwal konsultasi',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _consultationSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = _consultationSchedules[index];
                          final isConfirmed = schedule['status'] == 'confirmed';
                          final isRejected = schedule['status'] == 'rejected';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        schedule['status'],
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.schedule_rounded,
                                      color: _getStatusColor(schedule['status']),
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    schedule['namaPasien'] ?? 'Unknown Patient',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tanggal: ${_formatDate(schedule['tanggalKonsultasi'])}',
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                      Text(
                                        'Waktu: ${schedule['waktuKonsultasi'] ?? 'N/A'}',
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            schedule['status'],
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusText(schedule['status']),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: _getStatusColor(
                                              schedule['status'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'detail':
                                          _showScheduleDetailDialog(schedule);
                                          break;
                                        case 'edit':
                                          _showEditScheduleDialog(schedule);
                                          break;
                                        case 'approve':
                                          _approveSchedule(schedule['id']);
                                          break;
                                        case 'reject':
                                          _rejectSchedule(schedule['id']);
                                          break;
                                        case 'delete':
                                          _deleteSchedule(schedule['id']);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'detail',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info_outline),
                                            SizedBox(width: 8),
                                            Text('Detail'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      if (schedule['status'] == 'pending') ...[
                                        const PopupMenuItem(
                                          value: 'approve',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Terima'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'reject',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Tolak'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Hapus'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Show examination button only for confirmed schedules
                                if (isConfirmed)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: ElevatedButton.icon(
                                      onPressed: () => _navigateToPemeriksaan(schedule),
                                      icon: const Icon(
                                        Icons.medical_services_rounded,
                                        size: 20,
                                      ),
                                      label: Text(
                                        'Lakukan Pemeriksaan',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEC407A),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                
                                // Show rejection message for rejected schedules
                                if (isRejected)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.block,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Jadwal konsultasi ditolak',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddScheduleDialog,
          backgroundColor: const Color(0xFFEC407A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddConsultationScheduleDialog extends StatefulWidget {
  final VoidCallback onScheduleAdded;

  const AddConsultationScheduleDialog({
    super.key,
    required this.onScheduleAdded,
  });

  @override
  State<AddConsultationScheduleDialog> createState() =>
      _AddConsultationScheduleDialogState();
}

class _AddConsultationScheduleDialogState
    extends State<AddConsultationScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _waktuController = TextEditingController();
  final _keluhanController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _waktuController.dispose();
    _keluhanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _waktuController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final scheduleData = {
        'namaPasien': _namaController.text,
        'tanggalKonsultasi': _tanggalController.text,
        'waktuKonsultasi': _waktuController.text,
        'keluhan': _keluhanController.text,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirebaseService().createJadwalKonsultasi(scheduleData);

      if (mounted) {
      Navigator.pop(context);
        widget.onScheduleAdded();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule added successfully')),
      );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding schedule: $e')));
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
    return AlertDialog(
      title: Text(
                  'Tambah Jadwal Konsultasi',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
            mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pasien',
                          border: OutlineInputBorder(),
                ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                    return 'Nama pasien harus diisi';
                            }
                            return null;
                          },
                      ),
                      const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Konsultasi',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                    return 'Tanggal konsultasi harus dipilih';
                            }
                            return null;
                          },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                controller: _waktuController,
                decoration: InputDecoration(
                  labelText: 'Waktu Konsultasi',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _selectTime,
                  ),
                ),
                readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                    return 'Waktu konsultasi harus dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                controller: _keluhanController,
                        decoration: const InputDecoration(
                  labelText: 'Keluhan',
                          border: OutlineInputBorder(),
                ),
                maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                    return 'Keluhan harus diisi';
                          }
                          return null;
                        },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
                    onPressed: _isLoading ? null : _saveSchedule,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Simpan'),
        ),
      ],
    );
  }
}

class EditConsultationScheduleDialog extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback onScheduleUpdated;

  const EditConsultationScheduleDialog({
    super.key,
    required this.schedule,
    required this.onScheduleUpdated,
  });

  @override
  State<EditConsultationScheduleDialog> createState() =>
      _EditConsultationScheduleDialogState();
}

class _EditConsultationScheduleDialogState
    extends State<EditConsultationScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _tanggalController;
  late final TextEditingController _waktuController;
  late final TextEditingController _keluhanController;
  String _selectedStatus = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.schedule['namaPasien'] ?? '',
    );
    _tanggalController = TextEditingController(
      text: widget.schedule['tanggalKonsultasi'] ?? '',
    );
    _waktuController = TextEditingController(
      text: widget.schedule['waktuKonsultasi'] ?? '',
    );
    _keluhanController = TextEditingController(
      text: widget.schedule['keluhan'] ?? '',
    );
    _selectedStatus = widget.schedule['status'] ?? 'pending';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _waktuController.dispose();
    _keluhanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _waktuController.text = picked.format(context);
      });
    }
  }

  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final scheduleData = {
        'namaPasien': _namaController.text,
        'tanggalKonsultasi': _tanggalController.text,
        'waktuKonsultasi': _waktuController.text,
        'keluhan': _keluhanController.text,
        'status': _selectedStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseService().updateJadwalKonsultasi(
        widget.schedule['id'],
        scheduleData,
      );

      if (mounted) {
      Navigator.pop(context);
        widget.onScheduleUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated successfully')),
      );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating schedule: $e')));
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
    return AlertDialog(
      title: Text(
                  'Edit Jadwal Konsultasi',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
            mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pasien',
                          border: OutlineInputBorder(),
                ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                    return 'Nama pasien harus diisi';
                            }
                            return null;
                          },
                      ),
                      const SizedBox(height: 16),
              TextFormField(
                controller: _tanggalController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Konsultasi',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                    return 'Tanggal konsultasi harus dipilih';
                            }
                            return null;
                          },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                controller: _waktuController,
                decoration: InputDecoration(
                  labelText: 'Waktu Konsultasi',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _selectTime,
                  ),
                ),
                readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                    return 'Waktu konsultasi harus dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                controller: _keluhanController,
                        decoration: const InputDecoration(
                  labelText: 'Keluhan',
                          border: OutlineInputBorder(),
                        ),
                maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                    return 'Keluhan harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                  labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
                  DropdownMenuItem(value: 'confirmed', child: Text('Diterima')),
                  DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                ],
                onChanged: (value) {
                            setState(() {
                    _selectedStatus = value!;
                            });
                        },
                      ),
                    ],
                  ),
                ),
              ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
                    onPressed: _isLoading ? null : _updateSchedule,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Update'),
        ),
      ],
    );
  }
}

class ConsultationScheduleDetailDialog extends StatelessWidget {
  final Map<String, dynamic> schedule;

  const ConsultationScheduleDetailDialog({super.key, required this.schedule});

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(parsedDate);
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Detail Jadwal Konsultasi',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildInfoRow('Nama Pasien', schedule['namaPasien'] ?? 'N/A'),
          _buildInfoRow('Tanggal', _formatDate(schedule['tanggalKonsultasi'])),
          _buildInfoRow('Waktu', schedule['waktuKonsultasi'] ?? 'N/A'),
          _buildInfoRow('Keluhan', schedule['keluhan'] ?? 'N/A'),
          const SizedBox(height: 8),
            Row(
              children: [
              Text(
                'Status: ',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                  color: _getStatusColor(schedule['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(schedule['status']),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(schedule['status']),
                  ),
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
                onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
}