import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_model.dart';
import '../models/analytics_model.dart';

import '../services/firebase_service.dart';

class ExcelExportService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Export comprehensive analytics data to Excel format
  Future<void> exportAnalyticsToExcel({
    required AnalyticsData analyticsData,
    required UserModel user,
  }) async {
    try {
      // Get additional patient data
      final patientData = await _getPatientData();

      // Create Excel content
      final excelContent = _createExcelContent(
        analyticsData: analyticsData,
        patientData: patientData,
        user: user,
      );

      // Save to temporary file
      final file = await _saveToFile(excelContent, 'analytics_data');

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Data Analytics PersalinanKu - ${DateTime.now().toString().split('.')[0]}',
      );

      // Clean up temporary file
      await file.delete();
    } catch (e) {
      print('Error exporting to Excel: $e');
      rethrow;
    }
  }

  /// Get comprehensive patient data from Firebase
  Future<List<Map<String, dynamic>>> _getPatientData() async {
    try {
      // Get all patients using stream and convert to list
      final patientsStream = _firebaseService.getUsersStream(
        limit: 1000,
        role: 'pasien',
      );
      final patients = await patientsStream.first;
      final patientData = <Map<String, dynamic>>[];

      for (final patient in patients) {
        // Calculate age
        final age = _calculateAge(patient.tanggalLahir);

        // Get trimester status if pregnant
        String trimesterStatus = 'Tidak Hamil';
        if (patient.pregnancyStatus == 'active') {
          trimesterStatus = _getTrimesterStatus(patient.hpht);
        }

        patientData.add({
          'nama': patient.nama,
          'umur': age,
          'alamat': patient.alamat,
          'no_hp': patient.noHp,
          'email': patient.email,
          'trimester': trimesterStatus,
          'tanggal_daftar': patient.createdAt.toIso8601String(),
          'status_kehamilan':
              patient.pregnancyStatus == 'active' ? 'Hamil' : 'Tidak Hamil',

          // New fields
          'agama': patient.agamaPasien ?? '-',
          'pekerjaan': patient.pekerjaanPasien ?? '-',
          'nama_suami': patient.namaSuami ?? '-',
          'pekerjaan_suami': patient.pekerjaanSuami ?? '-',
          'umur_suami': patient.umurSuami ?? '-',
          'agama_suami': patient.agamaSuami ?? '-',
        });
      }

      return patientData;
    } catch (e) {
      print('Error getting patient data: $e');
      return [];
    }
  }

  /// Calculate age from birth date
  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;

    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Get trimester status based on HPHT
  String _getTrimesterStatus(DateTime? hpht) {
    if (hpht == null) return 'Tidak ada data HPHT';

    final now = DateTime.now();
    final weeks = now.difference(hpht).inDays ~/ 7;

    if (weeks < 13) return 'Trimester 1 (${weeks} minggu)';
    if (weeks < 27) return 'Trimester 2 (${weeks} minggu)';
    if (weeks < 42) return 'Trimester 3 (${weeks} minggu)';
    return 'Overdue (${weeks} minggu)';
  }

  /// Create comprehensive Excel content
  String _createExcelContent({
    required AnalyticsData analyticsData,
    required List<Map<String, dynamic>> patientData,
    required UserModel user,
  }) {
    final buffer = StringBuffer();

    // Add BOM for Excel UTF-8 support
    buffer.write('\uFEFF');

    // Title and Header
    buffer.writeln('DASHBOARD ANALYTICS PERSALINANKU');
    buffer.writeln('Pratik Mandiri Bidan ${user.nama}');
    buffer.writeln(
      'Tanggal Export: ${DateTime.now().toString().split('.')[0]}',
    );
    buffer.writeln('');

    // Section 1: Summary Metrics
    buffer.writeln('METRICS UTAMA');
    buffer.writeln(
      'Total Pasien Terdaftar,${analyticsData.keyMetrics.totalPatients}',
    );
    buffer.writeln(
      'Pasien Baru Bulan Ini,${analyticsData.keyMetrics.newPatientsThisMonth}',
    );
    buffer.writeln(
      'Persalinan Bulan Ini,${analyticsData.keyMetrics.deliveriesThisMonth}',
    );
    buffer.writeln(
      'Janji Hari Ini,${analyticsData.keyMetrics.appointmentsToday}',
    );
    buffer.writeln(
      'Konsultasi Pending,${analyticsData.keyMetrics.pendingConsultations}',
    );
    buffer.writeln('');

    // Section 2: Patient Data
    buffer.writeln('DATA PASIEN LENGKAP');
    buffer.writeln(
      'Nama,Umur,Alamat,No HP,Email,Status Trimester,Tanggal Daftar,Status Kehamilan',
    );

    for (final patient in patientData) {
      buffer.writeln(
        '${patient['nama']},${patient['umur']},"${patient['alamat']}",${patient['no_hp']},${patient['email']},${patient['trimester']},${patient['tanggal_daftar']},${patient['status_kehamilan']}',
      );
    }
    buffer.writeln('');

    // Section 3: Growth Trend (30 days)
    buffer.writeln('GRAFIK PERTUMBUHAN PASIEN (30 Hari Terakhir)');
    buffer.writeln('Tanggal,Jumlah Pasien Baru');

    for (final point in analyticsData.growthTrend.points) {
      buffer.writeln('${point.formattedDate},${point.count}');
    }
    buffer.writeln('');

    // Section 4: Age Distribution
    buffer.writeln('DISTRIBUSI UMUR PASIEN');
    buffer.writeln('Rentang Usia,Jumlah Pasien,Persentase');

    final totalPatients = analyticsData.ageDistribution.totalPatients;
    for (final entry in analyticsData.ageDistribution.distribution.entries) {
      final percentage =
          totalPatients > 0
              ? (entry.value / totalPatients * 100).toStringAsFixed(1)
              : '0.0';
      buffer.writeln('${entry.key},${entry.value},${percentage}%');
    }
    buffer.writeln('');

    // Section 5: Trimester Distribution
    buffer.writeln('DISTRIBUSI STATUS TRIMESTER');
    buffer.writeln('Trimester,Jumlah Pasien,Persentase');

    final totalPregnant =
        analyticsData.trimesterDistribution.totalPregnantPatients;
    for (final entry
        in analyticsData.trimesterDistribution.distribution.entries) {
      final percentage =
          totalPregnant > 0
              ? (entry.value / totalPregnant * 100).toStringAsFixed(1)
              : '0.0';
      buffer.writeln('${entry.key},${entry.value},${percentage}%');
    }
    buffer.writeln('');

    // Section 6: Due Date Calendar
    buffer.writeln('KALENDER TANGGAL PERKIRAAN LAHIR');
    buffer.writeln('Tanggal,Nama Pasien,Status,Emoji');

    for (final dueDate in analyticsData.dueDateCalendar.allDueDates) {
      buffer.writeln(
        '${dueDate.formattedDueDate},${dueDate.patientName},${dueDate.colorCode},${dueDate.colorCode}',
      );
    }
    buffer.writeln('');

    // Section 7: Monthly Summary
    buffer.writeln('RINGKASAN BULANAN');
    buffer.writeln('Bulan,Jumlah Due Date,Status');

    final monthKeys = analyticsData.dueDateCalendar.monthKeys.take(3).toList();
    for (final monthKey in monthKeys) {
      final dueDates = analyticsData.dueDateCalendar.getDueDatesForMonth(
        monthKey,
      );
      buffer.writeln('$monthKey,${dueDates.length},Aktif');
    }
    buffer.writeln('');

    // Section 8: Statistics Summary
    buffer.writeln('STATISTIK KESELURUHAN');
    buffer.writeln('Metrik,Nilai');
    buffer.writeln('Total Pasien,${analyticsData.keyMetrics.totalPatients}');
    buffer.writeln(
      'Pasien Hamil,${analyticsData.trimesterDistribution.totalPregnantPatients}',
    );
    buffer.writeln(
      'Pasien Non-Hamil,${analyticsData.keyMetrics.totalPatients - analyticsData.trimesterDistribution.totalPregnantPatients}',
    );
    buffer.writeln('Rata-rata Umur,${_calculateAverageAge(patientData)}');
    buffer.writeln(
      'Pasien Terdaftar Bulan Ini,${analyticsData.keyMetrics.newPatientsThisMonth}',
    );
    buffer.writeln(
      'Persalinan Bulan Ini,${analyticsData.keyMetrics.deliveriesThisMonth}',
    );
    buffer.writeln('');

    // Footer
    buffer.writeln('DIEKSPOR OLEH: Bidan ${user.nama}');
    buffer.writeln('TANGGAL: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln(
      'WAKTU: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    );

    return buffer.toString();
  }

  /// Calculate average age from patient data
  double _calculateAverageAge(List<Map<String, dynamic>> patientData) {
    if (patientData.isEmpty) return 0.0;

    final totalAge = patientData.fold<int>(
      0,
      (sum, patient) => sum + (patient['umur'] as int),
    );
    return (totalAge / patientData.length).roundToDouble();
  }

  /// Save content to temporary file
  Future<File> _saveToFile(String content, String filename) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/${filename}_$timestamp.csv');

    await file.writeAsString(content, encoding: const Utf8Codec());
    return file;
  }
}
