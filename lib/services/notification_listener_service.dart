import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class NotificationListenerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream subscriptions
  static StreamSubscription<QuerySnapshot>? _chatSubscription;
  static StreamSubscription<QuerySnapshot>? _scheduleSubscription;

  // Initialize listeners for admin
  static void initializeAdminListeners() {
    _listenToNewChatsForAdmin();
    _listenToNewSchedulesForAdmin();
    _listenToScheduleUpdatesForAdmin(); // Tambahkan listener untuk update status
  }

  // Initialize listeners for pasien
  static void initializePasienListeners(String userId) {
    _listenToNewChatsForPasien(userId);
    _listenToScheduleStatusUpdatesForPasien(userId);
  }

  // Listen to new chats for admin
  static void _listenToNewChatsForAdmin() {
    _chatSubscription = _firestore
        .collection('chats')
        .where(
          'recipientId',
          isEqualTo: 'admin',
        ) // Admin selalu recipientId = 'admin'
        .where('senderRole', isEqualTo: 'pasien') // Hanya chat dari pasien
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data() as Map<String, dynamic>;
                _showChatNotificationForAdmin(
                  chatId: change.doc.id,
                  senderName: data['senderName'] ?? 'Pasien',
                  message: data['message'] ?? '',
                  senderId: data['senderId'] ?? '',
                );
              }
            }
          },
          onError: (error) {
            print('Error listening to admin chats: $error');
          },
        );
  }

  // Listen to new chats for pasien
  static void _listenToNewChatsForPasien(String userId) {
    _chatSubscription = _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              _showChatNotificationForPasien(
                chatId: change.doc.id,
                adminName: data['senderName'] ?? 'Bidan',
                message: data['message'] ?? '',
                adminId: data['senderId'] ?? '',
              );
            }
          }
        });
  }

  // Listen to new schedules for admin
  static void _listenToNewSchedulesForAdmin() {
    _scheduleSubscription = _firestore
        .collection('konsultasi')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data() as Map<String, dynamic>;
                _showScheduleNotificationForAdmin(
                  scheduleId: change.doc.id,
                  patientName: data['pasienNama'] ?? 'Pasien',
                  scheduleType: data['jenisKonsultasi'] ?? 'Konsultasi',
                  scheduleTime:
                      (data['tanggalKonsultasi'] as Timestamp).toDate(),
                );
              }
            }
          },
          onError: (error) {
            print('Error listening to admin schedules: $error');
          },
        );
  }

  // Listen to schedule status updates for pasien
  static void _listenToScheduleStatusUpdatesForPasien(String userId) {
    _scheduleSubscription = _firestore
        .collection('konsultasi')
        .where('pasienId', isEqualTo: userId)
        .where('status', whereIn: ['accepted', 'rejected'])
        .where('isNotified', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final data = change.doc.data() as Map<String, dynamic>;
              _showScheduleStatusNotificationForPasien(
                scheduleId: change.doc.id,
                status: data['status'] ?? '',
                adminName: data['adminNama'] ?? 'Bidan',
                note: data['catatanAdmin'],
              );

              // Mark as notified
              NotificationService.markScheduleAsNotified(change.doc.id);
            }
          }
        });
  }

  // Listen to schedule updates for admin (when admin changes status)
  static void _listenToScheduleUpdatesForAdmin() {
    _scheduleSubscription = _firestore
        .collection('konsultasi')
        .where('status', whereIn: ['accepted', 'rejected', 'completed'])
        .where('isNotified', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.modified) {
                final data = change.doc.data() as Map<String, dynamic>;
                _showScheduleUpdateNotificationForAdmin(
                  scheduleId: change.doc.id,
                  patientName: data['pasienNama'] ?? 'Pasien',
                  status: data['status'] ?? '',
                  scheduleType: data['jenisKonsultasi'] ?? 'Konsultasi',
                  note: data['catatanAdmin'],
                );
              }
            }
          },
          onError: (error) {
            print('Error listening to admin schedule updates: $error');
          },
        );
  }

  // Show chat notification for admin
  static void _showChatNotificationForAdmin({
    required String chatId,
    required String senderName,
    required String message,
    required String senderId,
  }) {
    NotificationService.showChatNotificationForAdmin(
      chatId: chatId,
      senderName: senderName,
      message: message,
      senderId: senderId,
    );
  }

  // Show chat notification for pasien
  static void _showChatNotificationForPasien({
    required String chatId,
    required String adminName,
    required String message,
    required String adminId,
  }) {
    NotificationService.showChatNotificationForPasien(
      chatId: chatId,
      adminName: adminName,
      message: message,
      adminId: adminId,
    );
  }

  // Show schedule notification for admin
  static void _showScheduleNotificationForAdmin({
    required String scheduleId,
    required String patientName,
    required String scheduleType,
    required DateTime scheduleTime,
  }) {
    NotificationService.showScheduleNotificationForAdmin(
      scheduleId: scheduleId,
      patientName: patientName,
      scheduleType: scheduleType,
      scheduleTime: scheduleTime,
    );
  }

  // Show schedule update notification for admin
  static void _showScheduleUpdateNotificationForAdmin({
    required String scheduleId,
    required String patientName,
    required String status,
    required String scheduleType,
    String? note,
  }) {
    NotificationService.showScheduleUpdateNotificationForAdmin(
      scheduleId: scheduleId,
      patientName: patientName,
      status: status,
      scheduleType: scheduleType,
      note: note,
    );
  }

  // Show schedule status notification for pasien
  static void _showScheduleStatusNotificationForPasien({
    required String scheduleId,
    required String status,
    required String adminName,
    String? note,
  }) {
    NotificationService.showScheduleStatusNotificationForPasien(
      scheduleId: scheduleId,
      status: status,
      adminName: adminName,
      note: note,
    );
  }

  // Dispose all listeners
  static void dispose() {
    _chatSubscription?.cancel();
    _scheduleSubscription?.cancel();
  }

  // Dispose specific listener
  static void disposeChatListener() {
    _chatSubscription?.cancel();
  }

  static void disposeScheduleListener() {
    _scheduleSubscription?.cancel();
  }
}
