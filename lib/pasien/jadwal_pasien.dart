import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class JadwalPasienScreen extends StatefulWidget {
  final UserModel user;

  const JadwalPasienScreen({super.key, required this.user});

  @override
  State<JadwalPasienScreen> createState() => _JadwalPasienScreenState();
}

class _JadwalPasienScreenState extends State<JadwalPasienScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadAppointments();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('id_ID', null);
    } catch (e) {
      print('Error initializing locale: $e');
      // Fallback to default locale if Indonesian locale fails
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID from Firebase Auth
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Listen to appointment stream for this patient
      _firebaseService
          .getJadwalKonsultasiByPasienStream(currentUser.uid)
          .listen(
            (appointments) {
              setState(() {
                _appointments = appointments;
                _isLoading = false;
              });
              // Update selected events for the currently selected day
              _selectedEvents.value = _getEventsForDay(_selectedDay!);
            },
            onError: (error) {
              print('Error loading appointments: $error');
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memuat jadwal: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
    } catch (e) {
      print('Error in _loadAppointments: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat jadwal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _appointments.where((appointment) {
      final appointmentDate = _parseAppointmentDate(
        appointment['tanggalKonsultasi'],
      );
      if (appointmentDate == null) return false;

      return isSameDay(appointmentDate, day);
    }).toList();
  }

  DateTime? _parseAppointmentDate(dynamic dateValue) {
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return null;
    } catch (e) {
      print('Error parsing date: $dateValue, error: $e');
      return null;
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final appointmentDate = _parseAppointmentDate(
      appointment['tanggalKonsultasi'],
    );

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
                Icons.event_rounded,
                color: const Color(0xFFEC407A),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Detail Temu Janji',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Tanggal',
                  appointmentDate != null
                      ? _formatDate(appointmentDate)
                      : 'Tanggal tidak valid',
                ),
                _buildDetailRow(
                  'Waktu',
                  appointment['waktuKonsultasi'] ?? 'Waktu belum ditentukan',
                ),
                _buildDetailRow(
                  'Status',
                  _getStatusText(appointment['status'] ?? 'pending'),
                ),
                _buildDetailRow(
                  'Keluhan',
                  appointment['keluhan'] ?? 'Tidak ada keluhan',
                ),
                if (appointment['riwayatAlergi'] != null &&
                    appointment['riwayatAlergi'].toString().isNotEmpty)
                  _buildDetailRow(
                    'Riwayat Alergi',
                    appointment['riwayatAlergi'],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Tutup',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _addToCalendar(appointment),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                'Tambah ke Kalender',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC407A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _addToCalendar(Map<String, dynamic> appointment) async {
    try {
      final appointmentDate = _parseAppointmentDate(
        appointment['tanggalKonsultasi'],
      );
      if (appointmentDate == null) {
        throw Exception('Tanggal temu janji tidak valid');
      }

      // Parse time
      final waktu = appointment['waktuKonsultasi'] ?? '09:00';
      final timeParts = waktu.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 9;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      final startTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        hour,
        minute,
      );

      final endTime = startTime.add(const Duration(hours: 1));

      final event = Event(
        title: 'Konsultasi - ${appointment['namaPasien'] ?? 'Temu Janji'}',
        description:
            'Keluhan: ${appointment['keluhan'] ?? 'Tidak ada keluhan'}',
        location: 'Klinik Persalinanku',
        startDate: startTime,
        endDate: endTime,
        iosParams: const IOSParams(reminder: Duration(minutes: 30)),
        androidParams: const AndroidParams(emailInvites: []),
      );

      final success = await Add2Calendar.addEvent2Cal(event);

      if (success) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Berhasil menambahkan ke kalender'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        throw Exception('Gagal menambahkan ke kalender');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      // Fallback to default locale if Indonesian locale fails
      return DateFormat('dd MMMM yyyy').format(date);
    }
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
                        child: const Icon(
                          Icons.calendar_month_rounded,
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
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Kelola jadwal temu janji Anda',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_appointments.length} jadwal temu janji',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Calendar and Content
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFEC407A),
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Calendar
                            Container(
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
                              child: TableCalendar<Map<String, dynamic>>(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                calendarFormat: _calendarFormat,
                                eventLoader: _getEventsForDay,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: _onDaySelected,
                                onFormatChanged: (format) {
                                  if (_calendarFormat != format) {
                                    setState(() {
                                      _calendarFormat = format;
                                    });
                                  }
                                },
                                onPageChanged: (focusedDay) {
                                  _focusedDay = focusedDay;
                                },
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  weekendTextStyle: GoogleFonts.poppins(
                                    color: const Color(0xFF4A5568),
                                  ),
                                  holidayTextStyle: GoogleFonts.poppins(
                                    color: const Color(0xFFEC407A),
                                  ),
                                  defaultTextStyle: GoogleFonts.poppins(
                                    color: const Color(0xFF2D3748),
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Color(0xFFEC407A),
                                    shape: BoxShape.circle,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: const Color(
                                      0xFFEC407A,
                                    ).withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  markerDecoration: const BoxDecoration(
                                    color: Color(0xFF20B2AA),
                                    shape: BoxShape.circle,
                                  ),
                                  markersMaxCount: 3,
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: true,
                                  titleCentered: true,
                                  formatButtonShowsNext: false,
                                  formatButtonDecoration: BoxDecoration(
                                    color: const Color(0xFFEC407A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  formatButtonTextStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  titleTextStyle: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Events for selected day
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: _selectedEvents,
                              builder: (context, events, _) {
                                return Container(
                                  width: double.infinity,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.event_note_rounded,
                                              color: const Color(0xFFEC407A),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Jadwal ${_selectedDay != null ? _formatDate(_selectedDay!) : 'Hari Ini'}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF2D3748),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        if (events.isEmpty)
                                          Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.event_busy_rounded,
                                                  size: 48,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Tidak ada jadwal',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          ...events.map(
                                            (event) => Card(
                                              margin: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: InkWell(
                                                onTap:
                                                    () =>
                                                        _showAppointmentDetails(
                                                          event,
                                                        ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 4,
                                                        height: 60,
                                                        decoration: BoxDecoration(
                                                          color: _getStatusColor(
                                                            event['status'] ??
                                                                'pending',
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .access_time_rounded,
                                                                  size: 16,
                                                                  color: const Color(
                                                                    0xFFEC407A,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  event['waktuKonsultasi'] ??
                                                                      'Waktu belum ditentukan',
                                                                  style: GoogleFonts.poppins(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: const Color(
                                                                      0xFFEC407A,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              event['keluhan'] ??
                                                                  'Konsultasi',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 13,
                                                                color:
                                                                    const Color(
                                                                      0xFF2D3748,
                                                                    ),
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: _getStatusColor(
                                                                  event['status'] ??
                                                                      'pending',
                                                                ).withOpacity(
                                                                  0.1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      6,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                _getStatusText(
                                                                  event['status'] ??
                                                                      'pending',
                                                                ),
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: _getStatusColor(
                                                                    event['status'] ??
                                                                        'pending',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                        size: 16,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
