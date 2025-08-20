import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationIntegrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== ADMIN ID MANAGEMENT =====

  // Get admin ID from email
  static Future<String?> _getAdminId() async {
    try {
      final adminDoc =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: 'admin@gmail.com')
              .where('role', isEqualTo: 'admin')
              .limit(1)
              .get();

      if (adminDoc.docs.isNotEmpty) {
        return adminDoc.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting admin ID: $e');
      return null;
    }
  }

  // ===== CHAT NOTIFICATIONS =====

  // Ketika pasien mengirim chat baru
  static Future<void> notifyAdminNewChat({
    required String chatId,
    required String patientName,
    required String message,
    required String patientId,
  }) async {
    try {
      // Buat notifikasi untuk admin
      final adminId = await _getAdminId();
      if (adminId != null) {
        await NotificationService.createNotification(
          userId: adminId,
          title: 'Chat Baru dari $patientName',
          message: _truncateMessage(message),
          type: 'chat',
          referenceId: chatId,
        );
        print('Chat notification sent to admin: $patientName');
      }
    } catch (e) {
      print('Error sending chat notification to admin: $e');
    }
  }

  // Ketika admin membalas chat
  static Future<void> notifyPatientChatReply({
    required String patientId,
    required String chatId,
    required String adminName,
    required String message,
  }) async {
    try {
      await NotificationService.createNotification(
        userId: patientId,
        title: 'Balasan dari $adminName',
        message: _truncateMessage(message),
        type: 'chat',
        referenceId: chatId,
      );
      print('Chat reply notification sent to patient: $patientId');
    } catch (e) {
      print('Error sending chat reply notification to patient: $e');
    }
  }

  // ===== APPOINTMENT NOTIFICATIONS =====

  // Ketika pasien membuat jadwal temu janji
  static Future<void> notifyAdminNewAppointment({
    required String appointmentId,
    required String patientName,
    required String appointmentType,
    required DateTime appointmentTime,
    required String patientId,
  }) async {
    try {
      // Buat notifikasi untuk admin
      final adminId = await _getAdminId();
      if (adminId != null) {
        await NotificationService.createNotification(
          userId: adminId,
          title: 'Jadwal Temu Janji Baru',
          message:
              '$patientName membuat jadwal $appointmentType pada ${_formatDateTime(appointmentTime)}',
          type: 'appointment',
          referenceId: appointmentId,
        );
        print('Appointment notification sent to admin: $patientName');
      }
    } catch (e) {
      print('Error sending appointment notification to admin: $e');
    }
  }

  // Ketika admin menerima jadwal temu janji
  static Future<void> notifyPatientAppointmentAccepted({
    required String patientId,
    required String appointmentId,
    required String adminName,
    required String appointmentType,
    required DateTime appointmentTime,
  }) async {
    try {
      await NotificationService.createNotification(
        userId: patientId,
        title: 'Jadwal Temu Janji Diterima',
        message:
            'Jadwal $appointmentType Anda telah diterima oleh $adminName pada ${_formatDateTime(appointmentTime)}',
        type: 'appointment_accepted',
        referenceId: appointmentId,
      );
      print('Appointment accepted notification sent to patient: $patientId');
    } catch (e) {
      print('Error sending appointment accepted notification to patient: $e');
    }
  }

  // Ketika admin menolak jadwal temu janji
  static Future<void> notifyPatientAppointmentRejected({
    required String patientId,
    required String appointmentId,
    required String adminName,
    required String reason,
  }) async {
    try {
      await NotificationService.createNotification(
        userId: patientId,
        title: 'Jadwal Temu Janji Ditolak',
        message: 'Jadwal Anda ditolak oleh $adminName. Alasan: $reason',
        type: 'appointment_rejected',
        referenceId: appointmentId,
      );
      print('Appointment rejected notification sent to patient: $patientId');
    } catch (e) {
      print('Error sending appointment rejected notification to patient: $e');
    }
  }

  // ===== KONSULTASI NOTIFICATIONS =====

  // Ketika pasien membuat konsultasi baru
  static Future<void> notifyAdminNewKonsultasi({
    required String konsultasiId,
    required String patientName,
    required String question,
    required String patientId,
  }) async {
    try {
      final adminId = await _getAdminId();
      if (adminId != null) {
        await NotificationService.createNotification(
          userId: adminId,
          title: 'Konsultasi Baru dari $patientName',
          message: _truncateMessage(question),
          type: 'konsultasi',
          referenceId: konsultasiId,
        );
        print('Konsultasi notification sent to admin: $patientName');
      }
    } catch (e) {
      print('Error sending konsultasi notification to admin: $e');
    }
  }

  // Ketika admin menjawab konsultasi
  static Future<void> notifyPatientKonsultasiAnswered({
    required String patientId,
    required String konsultasiId,
    required String adminName,
    required String answer,
  }) async {
    try {
      await NotificationService.createNotification(
        userId: patientId,
        title: 'Jawaban Konsultasi dari $adminName',
        message: _truncateMessage(answer),
        type: 'konsultasi_answered',
        referenceId: konsultasiId,
      );
      print('Konsultasi answer notification sent to patient: $patientId');
    } catch (e) {
      print('Error sending konsultasi answer notification to patient: $e');
    }
  }

  // ===== UTILITY METHODS =====

  static String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  static String _truncateMessage(String message) {
    if (message.length <= 50) return message;
    return '${message.substring(0, 50)}...';
  }

  // ===== BULK NOTIFICATIONS =====

  // Notifikasi untuk admin
  static Future<void> notifyAdmin({
    required String title,
    required String message,
    required String type,
    required String referenceId,
  }) async {
    try {
      final adminId = await _getAdminId();
      if (adminId != null) {
        await NotificationService.createNotification(
          userId: adminId,
          title: title,
          message: message,
          type: type,
          referenceId: referenceId,
        );
      }
    } catch (e) {
      print('Error notifying admin: $e');
    }
  }

  // Notifikasi untuk semua pasien
  static Future<void> notifyAllPatients({
    required String title,
    required String message,
    required String type,
    required String referenceId,
  }) async {
    try {
      // Get all patient IDs from users collection
      final patientsSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'pasien')
              .get();

      for (final doc in patientsSnapshot.docs) {
        await NotificationService.createNotification(
          userId: doc.id,
          title: title,
          message: message,
          type: type,
          referenceId: referenceId,
        );
      }
    } catch (e) {
      print('Error notifying all patients: $e');
    }
  }

  // ===== ADMIN SPECIFIC NOTIFICATIONS =====

  // Notifikasi untuk admin tentang pasien baru
  static Future<void> notifyAdminNewPatient({
    required String patientId,
    required String patientName,
  }) async {
    await notifyAdmin(
      title: 'Pasien Baru Terdaftar',
      message: '$patientName telah mendaftar sebagai pasien baru',
      type: 'registration',
      referenceId: patientId,
    );
  }

  // Notifikasi untuk admin tentang pemeriksaan baru
  static Future<void> notifyAdminNewExamination({
    required String examinationId,
    required String patientName,
    required String examinationType,
  }) async {
    await notifyAdmin(
      title: 'Pemeriksaan Baru',
      message: '$patientName melakukan pemeriksaan $examinationType',
      type: 'examination',
      referenceId: examinationId,
    );
  }

  // Notifikasi untuk admin tentang laporan baru
  static Future<void> notifyAdminNewReport({
    required String reportId,
    required String patientName,
    required String reportType,
  }) async {
    await notifyAdmin(
      title: 'Laporan Baru',
      message: '$patientName mengirim laporan $reportType',
      type: 'report',
      referenceId: reportId,
    );
  }
}
