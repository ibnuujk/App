import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/konsultasi_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Notification channels
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
        'chat_channel',
        'Chat Notifications',
        description: 'This channel is used for chat notifications.',
        importance: Importance.defaultImportance,
      );

  static const AndroidNotificationChannel _scheduleChannel =
      AndroidNotificationChannel(
        'schedule_channel',
        'Schedule Notifications',
        description: 'This channel is used for schedule notifications.',
        importance: Importance.defaultImportance,
      );

  // Initialize notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_chatChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_scheduleChannel);
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap based on payload
    if (response.payload != null) {
      // Navigate based on payload
      print('Notification tapped: ${response.payload}');
    }
  }

  // Show chat notification for admin
  static Future<void> showChatNotificationForAdmin({
    required String chatId,
    required String senderName,
    required String message,
    required String senderId,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          channelDescription: 'This channel is used for chat notifications.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notifications.show(
      chatId.hashCode,
      'Chat Baru dari $senderName',
      message.length > 50 ? '${message.substring(0, 50)}...' : message,
      platformChannelSpecifics,
      payload: 'chat:$chatId:$senderId',
    );
  }

  // Show chat notification for pasien
  static Future<void> showChatNotificationForPasien({
    required String chatId,
    required String adminName,
    required String message,
    required String adminId,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          channelDescription: 'This channel is used for chat notifications.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notifications.show(
      chatId.hashCode,
      'Balasan dari Bidan',
      message.length > 50 ? '${message.substring(0, 50)}...' : message,
      platformChannelSpecifics,
      payload: 'chat:$chatId:$adminId',
    );
  }

  // Show schedule notification for admin
  static Future<void> showScheduleNotificationForAdmin({
    required String scheduleId,
    required String patientName,
    required String scheduleType,
    required DateTime scheduleTime,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'schedule_channel',
          'Schedule Notifications',
          channelDescription:
              'This channel is used for schedule notifications.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final timeString =
        '${scheduleTime.hour.toString().padLeft(2, '0')}:${scheduleTime.minute.toString().padLeft(2, '0')}';

    await _notifications.show(
      scheduleId.hashCode,
      'Jadwal Baru dari $patientName',
      '$scheduleType pada $timeString',
      platformChannelSpecifics,
      payload: 'schedule:$scheduleId',
    );
  }

  // Show schedule status notification for pasien
  static Future<void> showScheduleStatusNotificationForPasien({
    required String scheduleId,
    required String status,
    required String adminName,
    String? note,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'schedule_channel',
          'Schedule Notifications',
          channelDescription:
              'This channel is used for schedule notifications.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    String title = '';
    String body = '';

    if (status == 'accepted') {
      title = 'Jadwal Diterima';
      body = 'Jadwal temu janji Anda telah diterima oleh $adminName';
    } else if (status == 'rejected') {
      title = 'Jadwal Ditolak';
      body =
          note != null && note.isNotEmpty
              ? 'Jadwal temu janji Anda ditolak: $note'
              : 'Jadwal temu janji Anda ditolak oleh $adminName';
    }

    await _notifications.show(
      scheduleId.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: 'schedule:$scheduleId',
    );
  }

  // Get unread chat count for admin
  static Stream<int> getUnreadChatCountForAdmin() {
    return _firestore
        .collection('chats')
        .where('isRead', isEqualTo: false)
        .where('receiverId', isEqualTo: _auth.currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get unread chat count for pasien
  static Stream<int> getUnreadChatCountForPasien(String userId) {
    return _firestore
        .collection('chats')
        .where('isRead', isEqualTo: false)
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get pending schedule count for admin
  static Stream<int> getPendingScheduleCountForAdmin() {
    return _firestore
        .collection('konsultasi')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get schedule status update count for pasien
  static Stream<int> getScheduleStatusUpdateCountForPasien(String userId) {
    return _firestore
        .collection('konsultasi')
        .where('pasienId', isEqualTo: userId)
        .where('status', whereIn: ['accepted', 'rejected'])
        .where('isNotified', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark chat as read
  static Future<void> markChatAsRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark schedule as notified
  static Future<void> markScheduleAsNotified(String scheduleId) async {
    await _firestore.collection('konsultasi').doc(scheduleId).update({
      'isNotified': true,
      'notifiedAt': FieldValue.serverTimestamp(),
    });
  }

  // Listen to new chats for admin
  static Stream<QuerySnapshot> listenToNewChatsForAdmin() {
    return _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: _auth.currentUser?.uid)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Listen to new chats for pasien
  static Stream<QuerySnapshot> listenToNewChatsForPasien(String userId) {
    return _firestore
        .collection('chats')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Listen to new schedules for admin
  static Stream<QuerySnapshot> listenToNewSchedulesForAdmin() {
    return _firestore
        .collection('konsultasi')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Listen to schedule status updates for pasien
  static Stream<QuerySnapshot> listenToScheduleStatusUpdatesForPasien(
    String userId,
  ) {
    return _firestore
        .collection('konsultasi')
        .where('pasienId', isEqualTo: userId)
        .where('status', whereIn: ['accepted', 'rejected'])
        .where('isNotified', isEqualTo: false)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
