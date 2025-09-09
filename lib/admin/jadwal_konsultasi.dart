import 'package:flutter/material.dart';
import '../utilities/safe_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
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
  StreamSubscription<List<Map<String, dynamic>>>? _schedulesSubscription;

  @override
  void initState() {
    super.initState();
    _loadConsultationSchedules();
  }

  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadConsultationSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _schedulesSubscription?.cancel();
      _schedulesSubscription = _firebaseService.getJadwalKonsultasiStream().listen(
        (schedules) {
          if (mounted) {
            // Sort schedules: upcoming appointments first, then by date
            schedules.sort((a, b) {
              final dateA = a['tanggalKonsultasi'] as String?;
              final dateB = b['tanggalKonsultasi'] as String?;

              if (dateA == null || dateB == null) return 0;

              try {
                final parsedDateA = DateTime.parse(dateA);
                final parsedDateB = DateTime.parse(dateB);

                final now = DateTime.now();
                final isUpcomingA = parsedDateA.isAfter(now);
                final isUpcomingB = parsedDateB.isAfter(now);

                // Upcoming appointments first
                if (isUpcomingA && !isUpcomingB) return -1;
                if (!isUpcomingA && isUpcomingB) return 1;

                // Then sort by date (nearest first for upcoming, most recent first for past)
                if (isUpcomingA && isUpcomingB) {
                  return parsedDateA.compareTo(parsedDateB);
                } else {
                  return parsedDateB.compareTo(parsedDateA);
                }
              } catch (e) {
                return 0;
              }
            });

            setState(() {
              _consultationSchedules = schedules;
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading schedules: $e'),
                backgroundColor: Colors.red,
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
            content: Text('Error loading schedules: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      print('Approving schedule: $scheduleId');
      await _firebaseService.updateJadwalKonsultasi({
        'id': scheduleId,
        'status': 'confirmed',
      });

      print('Schedule approved successfully, reloading...');
      _loadConsultationSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule approved successfully')),
        );
      }
    } catch (e) {
      print('Error approving schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error approving schedule: $e')));
      }
    }
  }

  Future<void> _rejectSchedule(String scheduleId) async {
    try {
      print('Rejecting schedule: $scheduleId');
      await _firebaseService.updateJadwalKonsultasi({
        'id': scheduleId,
        'status': 'rejected',
      });

      print('Schedule rejected successfully, reloading...');
      _loadConsultationSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule rejected successfully')),
        );
      }
    } catch (e) {
      print('Error rejecting schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rejecting schedule: $e')));
      }
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      print('Deleting schedule: $scheduleId');
      await _firebaseService.deleteJadwalKonsultasi(scheduleId);

      print('Schedule deleted successfully, reloading...');
      _loadConsultationSchedules();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting schedule: $e')));
      }
    }
  }

  Future<void> _markExaminationCompleted(String scheduleId) async {
    try {
      await _firebaseService.updateJadwalKonsultasi({
        'id': scheduleId,
        'hasExamination': true,
        'examinationDate': DateTime.now().toIso8601String(),
        'status': 'selesai', // Update status to completed
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pemeriksaan telah selesai dan status diubah menjadi "Selesai"',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error marking examination as completed: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
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
                'Pemeriksaan',
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
              _buildDialogInfoRow('Nama Pasien', schedule['pasienNama'] ?? '-'),
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
              onPressed: () async {
                Navigator.of(context).pop();

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PemeriksaanIbuHamilScreen(
                          user: widget.user, // Admin user
                          consultationSchedule:
                              schedule, // Pass schedule data for context
                        ),
                  ),
                );

                if (result == true) {
                  await _markExaminationCompleted(schedule['id']);
                }
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

  // Helper method to build popup menu items based on schedule status
  List<PopupMenuEntry<String>> _buildPopupMenuItems(
    Map<String, dynamic> schedule,
  ) {
    final status = schedule['status'] as String?;
    final hasExamination =
        schedule['hasExamination'] ==
        true; // Check if examination has been performed

    List<PopupMenuEntry<String>> items = [];

    // Always show detail option
    items.add(
      const PopupMenuItem<String>(
        value: 'view',
        child: Row(
          children: [
            Icon(Icons.visibility, size: 16),
            SizedBox(width: 8),
            Text('Lihat Detail'),
          ],
        ),
      ),
    );

    if (status == 'pending') {
      // For pending appointments, show all options
      items.addAll([
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'approve',
          child: Row(
            children: [
              Icon(Icons.check, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text('Terima'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'reject',
          child: Row(
            children: [
              Icon(Icons.close, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Tolak'),
            ],
          ),
        ),
      ]);
    } else if (status == 'confirmed') {
      if (!hasExamination) {
        // If confirmed but no examination yet, show edit and examination options
        items.addAll([
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 16),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'pemeriksaan',
            child: Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text('Pemeriksaan'),
              ],
            ),
          ),
        ]);
      }
    } else if (status == 'selesai') {
      // For completed examinations, only show view and delete options
      // No edit or examination options
    }

    // Always show delete option
    items.add(
      const PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 16, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus'),
          ],
        ),
      ),
    );

    return items;
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
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
      case 'selesai':
        return Colors.blue;
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
            color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildUpcomingAppointments() {
    final upcomingAppointments =
        _consultationSchedules
            .where((schedule) {
              final dateStr = schedule['tanggalKonsultasi'] as String?;
              if (dateStr == null) return false;

              try {
                final appointmentDate = DateTime.parse(dateStr);
                final now = DateTime.now();
                // Show appointments for today and future
                return appointmentDate.isAfter(
                  now.subtract(const Duration(days: 1)),
                );
              } catch (e) {
                return false;
              }
            })
            .take(3)
            .toList(); // Show max 3 upcoming appointments

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Temu Janji Terdekat',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        upcomingAppointments.isEmpty
            ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tidak ada jadwal temu janji terdekat',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
            : Column(
              children:
                  upcomingAppointments.map((schedule) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEC407A).withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFEC407A,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            color: Color(0xFFEC407A),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          schedule['pasienNama'] ?? 'Unknown Patient',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(schedule['tanggalKonsultasi']),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  schedule['waktuKonsultasi'] ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Konsultasi
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  schedule['status'],
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(schedule['status']),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(schedule['status']),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status Pemeriksaan
                            if (schedule['status'] == 'confirmed') ...[
                              if (schedule['hasExamination'] == true)
                                // Tampilan "Selesai" jika pemeriksaan sudah selesai
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Selesai',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],

                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'view':
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
                                  case 'pemeriksaan':
                                    _navigateToPemeriksaan(schedule);
                                    break;
                                }
                              },
                              itemBuilder:
                                  (context) => _buildPopupMenuItems(schedule),
                            ),
                          ],
                        ),
                        onTap: () => _showScheduleDetailDialog(schedule),
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              // Sliver App Bar yang akan hide/show
              SliverAppBar(
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFFEC407A),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => NavigationHelper.safeNavigateBack(context),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildUpcomingAppointments(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
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
                ),
              ),

              // Sliver untuk header "Semua Jadwal"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Semua Jadwal',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      IconButton(
                        onPressed: _showAddScheduleDialog,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEC407A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sliver untuk list jadwal
              _isLoading
                  ? const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : _consultationSchedules.isEmpty
                  ? SliverToBoxAdapter(
                    child: Center(
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
                    ),
                  )
                  : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final schedule = _consultationSchedules[index];
                      final isConfirmed = schedule['status'] == 'confirmed';
                      final isRejected = schedule['status'] == 'rejected';

                      // Debug: Print schedule details
                      if (kDebugMode) {
                        print('Building schedule card $index:');
                        print(
                          '  - ID: ${schedule['id']} (type: ${schedule['id'].runtimeType})',
                        );
                        print(
                          '  - Status: ${schedule['status']} (type: ${schedule['status'].runtimeType})',
                        );
                        print('  - isConfirmed: $isConfirmed');
                        print('  - isRejected: $isRejected');
                        print(
                          '  - hasExamination: ${schedule['hasExamination']} (type: ${schedule['hasExamination'].runtimeType})',
                        );
                        print(
                          '  - pasienNama: ${schedule['pasienNama']} (type: ${schedule['pasienNama'].runtimeType})',
                        );
                        print('  - All keys: ${schedule.keys.toList()}');
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                                    schedule['status'] ?? 'pending',
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.schedule_rounded,
                                  color: _getStatusColor(
                                    schedule['status'] ?? 'pending',
                                  ),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                schedule['pasienNama'] ?? 'Unknown Patient',
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
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  final scheduleId = schedule['id'] as String?;
                                  if (scheduleId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Error: Schedule ID tidak ditemukan',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  switch (value) {
                                    case 'view':
                                      _showScheduleDetailDialog(schedule);
                                      break;
                                    case 'edit':
                                      _showEditScheduleDialog(schedule);
                                      break;
                                    case 'approve':
                                      _approveSchedule(scheduleId);
                                      break;
                                    case 'reject':
                                      _rejectSchedule(scheduleId);
                                      break;
                                    case 'delete':
                                      _deleteSchedule(scheduleId);
                                      break;
                                  }
                                },
                                itemBuilder:
                                    (context) => _buildPopupMenuItems(schedule),
                              ),
                            ),
                            // Action buttons
                            if (!isRejected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (!isConfirmed)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            final scheduleId =
                                                schedule['id'] as String?;
                                            if (scheduleId != null) {
                                              _approveSchedule(scheduleId);
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Error: Schedule ID tidak ditemukan',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.check,
                                            size: 16,
                                          ),
                                          label: Text(
                                            'Terima',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (!isConfirmed) const SizedBox(width: 8),
                                    if (!isConfirmed)
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            final scheduleId =
                                                schedule['id'] as String?;
                                            if (scheduleId != null) {
                                              _rejectSchedule(scheduleId);
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Error: Schedule ID tidak ditemukan',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            size: 16,
                                          ),
                                          label: Text(
                                            'Tolak',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (isConfirmed &&
                                        !(schedule['hasExamination'] ?? false))
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed:
                                              () => _navigateToPemeriksaan(
                                                schedule,
                                              ),
                                          icon: const Icon(
                                            Icons.medical_services,
                                            size: 16,
                                          ),
                                          label: Text(
                                            'Pemeriksaan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFEC407A,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (isConfirmed &&
                                        (schedule['hasExamination'] ?? false))
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withValues(
                                                alpha: 0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'STATUS SELESAI',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }, childCount: _consultationSchedules.length),
                  ),
            ],
          ),
        ),
      ],
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
        'pasienNama': _namaController.text,
        'tanggalKonsultasi': _tanggalController.text,
        'waktuKonsultasi': _waktuController.text,
        'keluhan': _keluhanController.text,
        'status': 'pending',
        'hasExamination': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await FirebaseService().createJadwalKonsultasi(scheduleData);

      if (mounted) {
        NavigationHelper.safeNavigateBack(context);
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
          onPressed:
              _isLoading
                  ? null
                  : () => NavigationHelper.safeNavigateBack(context),
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
      text: widget.schedule['pasienNama'] ?? '',
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
        'pasienNama': _namaController.text,
        'tanggalKonsultasi': _tanggalController.text,
        'waktuKonsultasi': _waktuController.text,
        'keluhan': _keluhanController.text,
        'status': _selectedStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final dataWithId = {'id': widget.schedule['id'], ...scheduleData};

      await FirebaseService().updateJadwalKonsultasi(dataWithId);

      if (mounted) {
        NavigationHelper.safeNavigateBack(context);
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
          onPressed:
              _isLoading
                  ? null
                  : () => NavigationHelper.safeNavigateBack(context),
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
      case 'selesai':
        return 'Selesai';
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
      case 'selesai':
        return Colors.blue;
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
          _buildInfoRow('Nama Pasien', schedule['pasienNama'] ?? 'N/A'),
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
                  color: _getStatusColor(
                    schedule['status'],
                  ).withValues(alpha: 0.1),
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
          if (schedule['status'] == 'confirmed') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Pemeriksaan: ',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                if (schedule['hasExamination'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Selesai',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Belum Selesai',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => NavigationHelper.safeNavigateBack(context),
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
