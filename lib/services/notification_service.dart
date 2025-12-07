import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

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
    try {
      // Try to use custom notification icon first
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_notification');

      // Fallback to default icon if custom icon not available
      const AndroidInitializationSettings fallbackSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      const InitializationSettings fallbackSettings = InitializationSettings(
        android: fallbackSettingsAndroid,
      );

      // Try to initialize with custom icon
      bool initialized = false;
      try {
        await _notifications.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        );
        initialized = true;
        print('Notification service initialized with custom icon');
      } catch (e) {
        print('Failed to initialize with custom icon: $e');
        // Try with fallback icon
        try {
          await _notifications.initialize(
            fallbackSettings,
            onDidReceiveNotificationResponse: _onNotificationTapped,
          );
          initialized = true;
          print('Notification service initialized with fallback icon');
        } catch (e2) {
          print('Failed to initialize with fallback icon: $e2');
          // Last resort: initialize without icon specification
          await _notifications.initialize(
            const InitializationSettings(),
            onDidReceiveNotificationResponse: _onNotificationTapped,
          );
          initialized = true;
          print('Notification service initialized without icon specification');
        }
      }

      if (initialized) {
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

        print('Notification channels created successfully');
      }
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap based on payload
    if (response.payload != null) {
      // Navigate based on payload
      print('Notification tapped: ${response.payload}');
    }
  }

  // ===== SIMPLE NOTIFICATION SYSTEM METHODS =====

  // Create notification in database
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String referenceId,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        receiverId: userId, // Set receiverId same as userId
        title: title,
        message: message,
        type: type,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      );

      // Create notification document with receiverId field for Firestore rules
      final notificationData = {
        'id': notification.id,
        'userId': notification.userId,
        'receiverId': notification.receiverId, // Use receiverId from model
        'title': notification.title,
        'message': notification.message,
        'type': notification.type,
        'referenceId': notification.referenceId,
        'isRead': notification.isRead,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notificationData);

      print('Notification created: $title');
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // Get notifications for current user (optimized for admin performance)
  static Stream<List<NotificationModel>> getNotifications() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    try {
      // Use only essential fields for faster loading
      return _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUserId)
          .limit(50) // Get more documents to sort in memory
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) return <NotificationModel>[];

            return snapshot.docs.map((doc) {
              try {
                final data = doc.data();
                return NotificationModel(
                  id: doc.id,
                  userId: data['userId'] ?? data['receiverId'] ?? currentUserId,
                  receiverId: data['receiverId'] ?? currentUserId,
                  title: data['title'] ?? 'Notifikasi',
                  message: data['message'] ?? 'Pesan notifikasi',
                  type: data['type'] ?? 'general',
                  referenceId: data['referenceId'] ?? '',
                  isRead: data['isRead'] ?? false,
                  createdAt:
                      data['createdAt'] != null
                          ? (data['createdAt'] as Timestamp).toDate()
                          : DateTime.now(),
                );
              } catch (e) {
                print('Error parsing notification ${doc.id}: $e');
                return NotificationModel(
                  id: doc.id,
                  userId: currentUserId,
                  receiverId: currentUserId,
                  title: 'Notifikasi',
                  message: 'Pesan notifikasi',
                  type: 'general',
                  referenceId: '',
                  isRead: false,
                  createdAt: DateTime.now(),
                );
              }
            }).toList();
          })
          .handleError((error) {
            print('Error in notifications stream: $error');
            return <NotificationModel>[];
          });
    } catch (e) {
      print('Error setting up notifications stream: $e');
      // Fallback: try without orderBy for faster loading
      try {
        return _firestore
            .collection('notifications')
            .where('receiverId', isEqualTo: currentUserId)
            .limit(15) // Reduce limit for faster loading
            .snapshots()
            .map((snapshot) {
              try {
                final notifications =
                    snapshot.docs.map((doc) {
                      try {
                        final data = doc.data();
                        if (data['createdAt'] == null) {
                          data['createdAt'] = FieldValue.serverTimestamp();
                        }
                        return NotificationModel.fromMap({
                          'id': doc.id,
                          ...data,
                        });
                      } catch (e) {
                        print(
                          'Error parsing notification document ${doc.id}: $e',
                        );
                        final data = doc.data();
                        return NotificationModel(
                          id: doc.id,
                          userId: data['receiverId'] ?? currentUserId ?? '',
                          receiverId: data['receiverId'] ?? currentUserId ?? '',
                          title: data['title'] ?? 'Notifikasi',
                          message: data['message'] ?? 'Pesan notifikasi',
                          type: data['type'] ?? 'general',
                          referenceId: data['referenceId'] ?? '',
                          isRead: data['isRead'] ?? false,
                          createdAt: DateTime.now(),
                        );
                      }
                    }).toList();

                // Sort by createdAt locally if available
                notifications.sort(
                  (a, b) => b.createdAt.compareTo(a.createdAt),
                );
                return notifications;
              } catch (e) {
                print('Error processing fallback notifications: $e');
                return <NotificationModel>[];
              }
            })
            .handleError((error) {
              print('Error in fallback notifications stream: $error');
              return <NotificationModel>[];
            });
      } catch (fallbackError) {
        print('Fallback notifications stream also failed: $fallbackError');
        return Stream.value(<NotificationModel>[]);
      }
    }
  }

  // Get notifications with pagination for better performance
  static Stream<List<NotificationModel>> getNotificationsPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return query
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs.map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['createdAt'] == null) {
                    data['createdAt'] = FieldValue.serverTimestamp();
                  }
                  return NotificationModel.fromMap({'id': doc.id, ...data});
                } catch (e) {
                  print('Error parsing notification document ${doc.id}: $e');
                  final data = doc.data() as Map<String, dynamic>;
                  return NotificationModel(
                    id: doc.id,
                    userId: data['userId'] ?? currentUserId ?? '',
                    receiverId:
                        data['receiverId'] ??
                        currentUserId ??
                        '', // Add receiverId
                    title: data['title'] ?? 'Notifikasi',
                    message: data['message'] ?? 'Pesan notifikasi',
                    type: data['type'] ?? 'general',
                    referenceId: data['referenceId'] ?? '',
                    isRead: data['isRead'] ?? false,
                    createdAt: DateTime.now(),
                  );
                }
              }).toList();
            } catch (e) {
              print('Error processing notifications snapshot: $e');
              return <NotificationModel>[];
            }
          })
          .handleError((error) {
            print('Error in notifications paginated stream: $error');
            return <NotificationModel>[];
          });
    } catch (e) {
      print('Error setting up notifications paginated stream: $e');
      return Stream.value(<NotificationModel>[]);
    }
  }

  // Get unread notifications count
  static Stream<int> getUnreadCount() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value(0);

    try {
      return _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .limit(20) // Reduce limit for faster performance
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((error) {
            print('Error in unread count stream: $error');
            return 0;
          });
    } catch (e) {
      print('Error setting up unread count stream: $e');
      return Stream.value(0);
    }
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final notifications =
          await _firestore
              .collection('notifications')
              .where('receiverId', isEqualTo: currentUserId) // Use receiverId
              .where('isRead', isEqualTo: false)
              .limit(500) // Limit untuk performance
              .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Get notification first to check permissions
      final notificationDoc =
          await _firestore
              .collection('notifications')
              .doc(notificationId)
              .get();

      if (!notificationDoc.exists) {
        throw Exception('Notifikasi tidak ditemukan');
      }

      final notificationData = notificationDoc.data();
      if (notificationData == null) {
        throw Exception('Data notifikasi tidak valid');
      }

      final receiverId = notificationData['receiverId'] as String?;

      // Check if user is admin
      bool isAdmin = false;
      try {
        final userDoc =
            await _firestore.collection('users').doc(currentUserId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          isAdmin = userData?['role'] == 'admin';
        }
      } catch (e) {
        print('Error checking admin status: $e');
        // Continue with delete attempt
      }

      // Allow delete if user owns the notification or is admin
      if (receiverId == currentUserId || isAdmin) {
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
        print('Notification deleted successfully: $notificationId');
      } else {
        throw Exception('Tidak memiliki izin untuk menghapus notifikasi ini');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow; // Re-throw to show error to user
    }
  }

  // Clear all notifications for current user
  static Future<void> clearAllNotifications() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User tidak terautentikasi');
    }

    try {
      // Check if user is admin
      bool isAdmin = false;
      try {
        final userDoc =
            await _firestore.collection('users').doc(currentUserId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          isAdmin = userData?['role'] == 'admin';
        }
      } catch (e) {
        print('Error checking admin status: $e');
      }

      // For admin, delete all notifications they can see (all notifications)
      // For regular users, delete only their own notifications
      Query query = _firestore.collection('notifications');

      if (!isAdmin) {
        query = query.where('receiverId', isEqualTo: currentUserId);
      }

      final batch = _firestore.batch();
      final notifications =
          await query.limit(500).get(); // Limit untuk performance

      if (notifications.docs.isEmpty) {
        print('No notifications to clear');
        return;
      }

      for (var doc in notifications.docs) {
        // For admin, check if they can delete (their own or all)
        if (isAdmin) {
          batch.delete(doc.reference);
        } else {
          // For regular users, only delete their own
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null && data['receiverId'] == currentUserId) {
            batch.delete(doc.reference);
          }
        }
      }

      await batch.commit();
      print('All notifications cleared successfully');
    } catch (e) {
      print('Error clearing all notifications: $e');
      rethrow;
    }
  }

  // ===== TESTING METHODS =====

  // Create test notification for testing purposes
  static Future<void> createTestNotification({
    required String userId,
    String? title,
    String? message,
    String? type,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        receiverId: userId, // Add receiverId
        title: title ?? 'Test Notifikasi',
        message:
            message ?? 'Ini adalah notifikasi test untuk memverifikasi sistem',
        type: type ?? 'test',
        referenceId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      print('Test notification created: ${notification.title}');
    } catch (e) {
      print('Error creating test notification: $e');
    }
  }

  // ===== EXISTING METHODS (KEEP FOR BACKWARD COMPATIBILITY) =====

  // Show chat notification for admin
  static Future<void> showChatNotificationForAdmin({
    required String chatId,
    required String senderName,
    required String message,
    required String senderId,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'chat_channel',
            'Chat Notifications',
            channelDescription: 'This channel is used for chat notifications.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@drawable/ic_notification',
            color: Color(0xFFEC407A),
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
    } catch (e) {
      print('Error showing chat notification for admin: $e');
    }
  }

  // Show chat notification for pasien
  static Future<void> showChatNotificationForPasien({
    required String chatId,
    required String adminName,
    required String message,
    required String adminId,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'chat_channel',
            'Chat Notifications',
            channelDescription: 'This channel is used for chat notifications.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@drawable/ic_notification',
            color: Color(0xFFEC407A),
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
    } catch (e) {
      print('Error showing chat notification for pasien: $e');
    }
  }

  // Show schedule notification for admin
  static Future<void> showScheduleNotificationForAdmin({
    required String scheduleId,
    required String patientName,
    required String scheduleType,
    required DateTime scheduleTime,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'schedule_channel',
            'Schedule Notifications',
            channelDescription:
                'This channel is used for schedule notifications.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@drawable/ic_notification',
            color: Color(0xFFEC407A),
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
    } catch (e) {
      print('Error showing schedule notification for admin: $e');
    }
  }

  // Show schedule status notification for pasien
  static Future<void> showScheduleStatusNotificationForPasien({
    required String scheduleId,
    required String status,
    required String adminName,
    String? note,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'schedule_channel',
            'Schedule Notifications',
            channelDescription:
                'This channel is used for schedule notifications.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@drawable/ic_notification',
            color: Color(0xFFEC407A),
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
    } catch (e) {
      print('Error showing schedule status notification for pasien: $e');
    }
  }

  // Show schedule update notification for admin
  static Future<void> showScheduleUpdateNotificationForAdmin({
    required String scheduleId,
    required String patientName,
    required String status,
    required String scheduleType,
    String? note,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'schedule_channel',
            'Schedule Notifications',
            channelDescription:
                'This channel is used for schedule notifications.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@drawable/ic_notification',
            color: Color(0xFFEC407A),
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      String statusText = '';
      switch (status) {
        case 'accepted':
          statusText = 'Diterima';
          break;
        case 'rejected':
          statusText = 'Ditolak';
          break;
        case 'completed':
          statusText = 'Selesai';
          break;
        default:
          statusText = status;
      }

      await _notifications.show(
        '${scheduleId}_update'.hashCode,
        'Update Status Temu Janji',
        '$patientName - $scheduleType: $statusText',
        platformChannelSpecifics,
        payload: 'schedule_update:$scheduleId',
      );
    } catch (e) {
      print('Error showing schedule update notification for admin: $e');
    }
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

  // Get notifications with better pagination and caching
  static Stream<List<NotificationModel>> getNotificationsOptimized({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    try {
      Query query = _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUserId)
          .limit(limit);

      // Add pagination if lastDocument is provided
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      return query
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs.map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data != null && data['createdAt'] == null) {
                    data['createdAt'] = FieldValue.serverTimestamp();
                  }
                  return NotificationModel.fromMap({'id': doc.id, ...?data});
                } catch (e) {
                  print('Error parsing notification document ${doc.id}: $e');
                  final data = doc.data() as Map<String, dynamic>?;
                  if (data != null) {
                    return NotificationModel(
                      id: doc.id,
                      userId: data['receiverId'] ?? currentUserId ?? '',
                      receiverId: data['receiverId'] ?? currentUserId ?? '',
                      title: data['title'] ?? 'Notifikasi',
                      message: data['message'] ?? 'Pesan notifikasi',
                      type: data['type'] ?? 'general',
                      referenceId: data['referenceId'] ?? '',
                      isRead: data['isRead'] ?? false,
                      createdAt: DateTime.now(),
                    );
                  } else {
                    return NotificationModel(
                      id: doc.id,
                      userId: currentUserId,
                      receiverId: currentUserId,
                      title: 'Notifikasi',
                      message: 'Pesan notifikasi',
                      type: 'general',
                      referenceId: '',
                      isRead: false,
                      createdAt: DateTime.now(),
                    );
                  }
                }
              }).toList();
            } catch (e) {
              print('Error processing optimized notifications: $e');
              return <NotificationModel>[];
            }
          })
          .handleError((error) {
            print('Error in optimized notifications stream: $error');
            return <NotificationModel>[];
          });
    } catch (e) {
      print('Error setting up optimized notifications stream: $e');
      return Stream.value(<NotificationModel>[]);
    }
  }

  // Get recent notifications (last 7 days) for faster loading
  static Stream<List<NotificationModel>> getRecentNotifications() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    try {
      return _firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: currentUserId)
          .where('createdAt', isGreaterThan: sevenDaysAgo)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs.map((doc) {
                try {
                  final data = doc.data();
                  if (data['createdAt'] == null) {
                    data['createdAt'] = FieldValue.serverTimestamp();
                  }
                  return NotificationModel.fromMap({'id': doc.id, ...data});
                } catch (e) {
                  print(
                    'Error parsing recent notification document ${doc.id}: $e',
                  );
                  final data = doc.data();
                  return NotificationModel(
                    id: doc.id,
                    userId: data['receiverId'] ?? currentUserId,
                    receiverId: data['receiverId'] ?? currentUserId,
                    title: data['title'] ?? 'Notifikasi',
                    message: data['message'] ?? 'Pesan notifikasi',
                    type: data['type'] ?? 'general',
                    referenceId: data['referenceId'] ?? '',
                    isRead: data['isRead'] ?? false,
                    createdAt: DateTime.now(),
                  );
                }
              }).toList();
            } catch (e) {
              print('Error processing recent notifications: $e');
              return <NotificationModel>[];
            }
          })
          .handleError((error) {
            print('Error in recent notifications stream: $error');
            return <NotificationModel>[];
          });
    } catch (e) {
      print('Error setting up recent notifications stream: $e');
      return Stream.value(<NotificationModel>[]);
    }
  }
}
