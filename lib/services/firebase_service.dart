import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/konsultasi_model.dart';
import '../models/persalinan_model.dart';
import '../models/chat_model.dart';
import '../models/laporan_persalinan_model.dart';
import '../models/laporan_pasca_persalinan_model.dart';
import '../models/keterangan_kelahiran_model.dart';
import '../models/article_model.dart';
import 'notification_integration_service.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Authentication
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Password reset functionality
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Check Firebase connection status
  Future<bool> checkFirebaseConnection() async {
    try {
      await _firestore
          .collection('users')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      print('Firebase connection check failed: $e');
      return false;
    }
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Ensure user is authenticated
  Future<void> ensureAuthenticated() async {
    try {
      if (!isFirebaseInitialized()) {
        throw Exception('Firebase not initialized. Please restart the app.');
      }

      if (_auth.currentUser == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      // Additional check: verify the user document exists
      try {
        final userDoc =
            await _firestore
                .collection('users')
                .doc(_auth.currentUser!.uid)
                .get();
        if (!userDoc.exists) {
          print(
            'Warning: User document does not exist for UID: ${_auth.currentUser!.uid}',
          );
          // Don't throw error here, just log warning
        }
      } catch (e) {
        print('Warning: Could not verify user document: $e');
        // Don't throw error here, just log warning
      }
    } catch (e) {
      print('Error in ensureAuthenticated: $e');
      rethrow;
    }
  }

  // Check if Firebase is initialized
  bool isFirebaseInitialized() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      print('Error checking Firebase initialization: $e');
      return false;
    }
  }

  // User Management
  Future<void> createUser(UserModel user) async {
    try {
      await ensureAuthenticated();
      final userData = user.toMap();
      print('Creating user with data: $userData');
      await _firestore.collection('users').doc(user.id).set(userData);
      print('User created successfully: ${user.id}');
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      await ensureAuthenticated();
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      await ensureAuthenticated();
      QuerySnapshot query =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      if (query.docs.isNotEmpty) {
        final userData = query.docs.first.data() as Map<String, dynamic>;
        print('Found user data: $userData');
        return UserModel.fromMap(userData);
      }
      print('No user found with email: $email');
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      // If permission denied, try to get user by current user ID
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('Trying to get user by current user ID: ${currentUser.uid}');
          return await getUserById(currentUser.uid);
        }
      } catch (innerError) {
        print('Error getting user by current user ID: $innerError');
      }
      return null;
    }
  }

  Stream<List<UserModel>> getUsersStream({int limit = 50, String? role}) {
    try {
      Query query = _firestore.collection('users');

      // Add role filter if specified
      if (role != null) {
        query = query.where('role', isEqualTo: role);
      }

      // For better performance, try simple ordering first
      try {
        return query
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .snapshots()
            .timeout(
              const Duration(seconds: 20),
            ) // Increased timeout for better reliability
            .map(
              (snapshot) =>
                  snapshot.docs
                      .map(
                        (doc) => UserModel.fromMap(
                          doc.data() as Map<String, dynamic>,
                        ),
                      )
                      .toList(),
            )
            .handleError((error) {
              print('Error in getUsersStream with orderBy: $error');
              // Fallback to simple query without orderBy if index doesn't exist
              return _firestore
                  .collection('users')
                  .where('role', isEqualTo: role ?? 'pasien')
                  .limit(limit)
                  .snapshots()
                  .timeout(
                    const Duration(seconds: 15),
                  ) // Increased fallback timeout
                  .map(
                    (snapshot) =>
                        snapshot.docs
                            .map((doc) => UserModel.fromMap(doc.data()))
                            .toList(),
                  );
            });
      } catch (e) {
        print('Fallback to simple query: $e');
        // Fallback query without complex ordering
        return _firestore
            .collection('users')
            .where('role', isEqualTo: role ?? 'pasien')
            .limit(limit)
            .snapshots()
            .timeout(const Duration(seconds: 15)) // Increased fallback timeout
            .map(
              (snapshot) =>
                  snapshot.docs
                      .map((doc) => UserModel.fromMap(doc.data()))
                      .toList(),
            )
            .handleError((error) {
              print('Error in fallback getUsersStream: $error');
              return <UserModel>[];
            });
      }
    } catch (e) {
      print('Error getting users stream: $e');
      return Stream.value([]);
    }
  }

  // Method for pagination
  Future<List<UserModel>> getUsersPaginated({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      await ensureAuthenticated();

      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get().timeout(const Duration(seconds: 10));

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting users paginated: $e');
      return [];
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await ensureAuthenticated();
      final userData = user.toMap();
      print('Updating user with data: $userData');
      await _firestore.collection('users').doc(user.id).update(userData);
      print('User updated successfully: ${user.id}');
    } catch (e) {
      print('Error updating user: $e');
      // Try to set the document if update fails (document might not exist)
      try {
        await _firestore.collection('users').doc(user.id).set(user.toMap());
        print('User created/updated successfully using set: ${user.id}');
      } catch (setError) {
        print('Error setting user document: $setError');
        rethrow;
      }
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('users').doc(userId).delete();
      print('User deleted successfully: $userId');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Consultation Management
  Future<void> createKonsultasi(KonsultasiModel konsultasi) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('konsultasi')
          .doc(konsultasi.id)
          .set(konsultasi.toMap());
      print('Konsultasi created successfully: ${konsultasi.id}');

      // Send notification to admin about new konsultasi
      try {
        await NotificationIntegrationService.notifyAdminNewKonsultasi(
          konsultasiId: konsultasi.id,
          patientName: konsultasi.pasienNama,
          question: konsultasi.pertanyaan,
          patientId: konsultasi.pasienId,
        );
        print('Konsultasi notification sent to admin');
      } catch (e) {
        print('Error sending konsultasi notification: $e');
        // Don't fail the konsultasi creation if notification fails
      }
    } catch (e) {
      print('Error creating konsultasi: $e');
      rethrow;
    }
  }

  Stream<List<KonsultasiModel>> getKonsultasiStream() {
    try {
      return _firestore
          .collection('konsultasi')
          .orderBy('tanggalKonsultasi', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => KonsultasiModel.fromMap(doc.data()))
                    .toList(),
          )
          .handleError((error) {
            print('Error in getKonsultasiStream: $error');
            return <KonsultasiModel>[];
          });
    } catch (e) {
      print('Error getting konsultasi stream: $e');
      return Stream.value([]);
    }
  }

  Stream<List<KonsultasiModel>> getKonsultasiByPasienStream(String pasienId) {
    try {
      return _firestore
          .collection('konsultasi')
          .where('pasienId', isEqualTo: pasienId)
          .orderBy('tanggalKonsultasi', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => KonsultasiModel.fromMap(doc.data()))
                    .toList(),
          )
          .handleError((error) {
            print('Error in getKonsultasiByPasienStream: $error');
            return <KonsultasiModel>[];
          });
    } catch (e) {
      print('Error getting konsultasi by pasien stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> updateKonsultasi(KonsultasiModel konsultasi) async {
    try {
      await ensureAuthenticated();

      // Get current konsultasi data to check if answer was added
      final currentKonsultasi =
          await _firestore.collection('konsultasi').doc(konsultasi.id).get();

      if (currentKonsultasi.exists) {
        final currentData = currentKonsultasi.data() as Map<String, dynamic>;
        final currentJawaban = currentData['jawaban'];
        final newJawaban = konsultasi.jawaban;

        // Check if answer was added or updated
        if (newJawaban != null &&
            newJawaban.isNotEmpty &&
            (currentJawaban == null || currentJawaban != newJawaban)) {
          // Send notification to patient about answered konsultasi
          try {
            await NotificationIntegrationService.notifyPatientKonsultasiAnswered(
              patientId: konsultasi.pasienId,
              konsultasiId: konsultasi.id,
              adminName: 'Admin',
              answer: newJawaban,
            );
            print('Konsultasi answer notification sent to patient');
          } catch (e) {
            print('Error sending konsultasi answer notification: $e');
          }
        }
      }

      await _firestore
          .collection('konsultasi')
          .doc(konsultasi.id)
          .update(konsultasi.toMap());
      print('Konsultasi updated successfully: ${konsultasi.id}');
    } catch (e) {
      print('Error updating konsultasi: $e');
      rethrow;
    }
  }

  Future<void> deleteKonsultasi(String konsultasiId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('konsultasi').doc(konsultasiId).delete();
      print('Konsultasi deleted successfully: $konsultasiId');
    } catch (e) {
      print('Error deleting konsultasi: $e');
      rethrow;
    }
  }

  // Childbirth Report Management
  Future<void> createPersalinan(PersalinanModel persalinan) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('persalinan')
          .doc(persalinan.id)
          .set(persalinan.toMap());
      print('Persalinan created successfully: ${persalinan.id}');
    } catch (e) {
      print('Error creating persalinan: $e');
      rethrow;
    }
  }

  Stream<List<PersalinanModel>> getPersalinanStream() {
    try {
      return _firestore
          .collection('persalinan')
          .orderBy('createdAt', descending: true)
          .limit(100) // Add limit for better performance
          .snapshots()
          .timeout(
            const Duration(seconds: 20),
          ) // Increased timeout for better reliability
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => PersalinanModel.fromMap(doc.data()))
                    .toList(),
          )
          .handleError((error) {
            print('Error in getPersalinanStream: $error');
            // Fallback to simple query without ordering
            return _firestore
                .collection('persalinan')
                .limit(100)
                .snapshots()
                .timeout(const Duration(seconds: 15))
                .map(
                  (snapshot) =>
                      snapshot.docs
                          .map((doc) => PersalinanModel.fromMap(doc.data()))
                          .toList(),
                )
                .handleError((fallbackError) {
                  print(
                    'Error in fallback getPersalinanStream: $fallbackError',
                  );
                  return <PersalinanModel>[];
                });
          });
    } catch (e) {
      print('Error getting persalinan stream: $e');
      return Stream.value([]);
    }
  }

  Stream<List<PersalinanModel>> getPersalinanByPasienStream(String pasienId) {
    try {
      return _firestore
          .collection('persalinan')
          .where('pasienId', isEqualTo: pasienId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => PersalinanModel.fromMap(doc.data()))
                    .toList(),
          )
          .handleError((error) {
            print('Error in getPersalinanByPasienStream: $error');
            return <PersalinanModel>[];
          });
    } catch (e) {
      print('Error getting persalinan by pasien stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> updatePersalinan(PersalinanModel persalinan) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('persalinan')
          .doc(persalinan.id)
          .update(persalinan.toMap());
      print('Persalinan updated successfully: ${persalinan.id}');
    } catch (e) {
      print('Error updating persalinan: $e');
      rethrow;
    }
  }

  Future<void> deletePersalinan(String persalinanId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('persalinan').doc(persalinanId).delete();
      print('Persalinan deleted successfully: $persalinanId');
    } catch (e) {
      print('Error deleting persalinan: $e');
      rethrow;
    }
  }

  // Chat Management
  Future<void> sendMessage(ChatModel message) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('chats').doc(message.id).set(message.toMap());
      print('Message sent successfully: ${message.id}');

      // Send notification based on sender role
      if (message.senderRole == 'pasien') {
        // Pasien mengirim chat ke admin
        await NotificationIntegrationService.notifyAdminNewChat(
          chatId: message.id,
          patientName: message.senderName,
          message: message.message,
          patientId: message.senderId,
        );
      } else if (message.senderRole == 'admin') {
        // Admin membalas chat ke pasien
        await NotificationIntegrationService.notifyPatientChatReply(
          patientId: message.recipientId,
          chatId: message.id,
          adminName: message.senderName,
          message: message.message,
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<List<ChatModel>> getConversationMessages(String conversationId) {
    try {
      return _firestore
          .collection('chats')
          .where('conversationId', isEqualTo: conversationId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => ChatModel.fromMap(doc.data()))
                    .toList(),
          )
          .handleError((error) {
            print('Error in getConversationMessages: $error');
            return <ChatModel>[];
          });
    } catch (e) {
      print('Error getting conversation messages: $e');
      return Stream.value([]);
    }
  }

  Stream<List<dynamic>> getUserConversations(String userId, String userRole) {
    try {
      if (userRole == 'admin') {
        // For admin, get all conversations
        return _firestore
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) {
              final conversations = <String, Map<String, dynamic>>{};

              for (var doc in snapshot.docs) {
                final chat = ChatModel.fromMap(doc.data());
                if (chat.senderRole == 'pasien') {
                  // Group by patient ID for admin
                  if (!conversations.containsKey(chat.senderId)) {
                    conversations[chat.senderId] = {
                      'conversationId': chat.conversationId,
                      'patientId': chat.senderId,
                      'patientName': chat.senderName,
                      'lastMessage': chat.message,
                      'lastMessageTime': chat.timestamp,
                      'unreadCount': 0,
                    };
                  }
                }
              }

              return conversations.values.toList().cast<Map<String, dynamic>>();
            })
            .handleError((error) {
              print('Error in getUserConversations (admin): $error');
              return <Map<String, dynamic>>[];
            });
      } else {
        // For patient, get their conversation with admin
        return _firestore
            .collection('chats')
            .where('conversationId', isEqualTo: 'admin_$userId')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots()
            .map((snapshot) {
              if (snapshot.docs.isEmpty) {
                return [];
              }

              final lastMessage = ChatModel.fromMap(snapshot.docs.first.data());
              return <Map<String, dynamic>>[
                {
                  'conversationId': lastMessage.conversationId,
                  'adminId': 'admin',
                  'adminName': 'Admin',
                  'lastMessage': lastMessage.message,
                  'lastMessageTime': lastMessage.timestamp,
                  'unreadCount': 0,
                },
              ];
            })
            .handleError((error) {
              print('Error in getUserConversations (patient): $error');
              return <Map<String, dynamic>>[];
            });
      }
    } catch (e) {
      print('Error getting user conversations: $e');
      return Stream.value(<dynamic>[]);
    }
  }

  // Generate conversation ID
  String generateConversationId(String patientId) {
    return 'admin_$patientId';
  }

  // Get unread message count for a user
  Stream<int> getUnreadMessageCount(String userId, String userRole) {
    try {
      if (userRole == 'admin') {
        // For admin, count unread messages from patients
        return _firestore
            .collection('chats')
            .where('senderRole', isEqualTo: 'pasien')
            .where('isRead', isEqualTo: false)
            .snapshots()
            .timeout(const Duration(seconds: 10))
            .map((snapshot) => snapshot.docs.length)
            .handleError((error) {
              print('Error in getUnreadMessageCount (admin): $error');
              return 0;
            });
      } else {
        // For patient, count unread messages from admin in their conversation
        final conversationId = generateConversationId(userId);
        return _firestore
            .collection('chats')
            .where('conversationId', isEqualTo: conversationId)
            .where('senderRole', isEqualTo: 'admin')
            .where('isRead', isEqualTo: false)
            .snapshots()
            .timeout(const Duration(seconds: 10))
            .map((snapshot) => snapshot.docs.length)
            .handleError((error) {
              print('Error in getUnreadMessageCount (patient): $error');
              return 0;
            });
      }
    } catch (e) {
      print('Error getting unread message count: $e');
      return Stream.value(0);
    }
  }

  // Get all unread counts for admin in batch
  Stream<Map<String, int>> getAllUnreadCounts() {
    try {
      return _firestore
          .collection('chats')
          .where('senderRole', isEqualTo: 'pasien')
          .where('isRead', isEqualTo: false)
          .snapshots()
          .timeout(
            const Duration(seconds: 20),
          ) // Increased timeout for better reliability
          .map((snapshot) {
            final counts = <String, int>{};
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final senderId = data['senderId'] as String?;
              if (senderId != null) {
                counts[senderId] = (counts[senderId] ?? 0) + 1;
              }
            }
            return counts;
          })
          .handleError((error) {
            print('Error in getAllUnreadCounts: $error');
            return <String, int>{};
          });
    } catch (e) {
      print('Error getting all unread counts: $e');
      return Stream.value(<String, int>{});
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(
    String conversationId,
    String userId,
    String userRole,
  ) async {
    try {
      await ensureAuthenticated();
      final batch = _firestore.batch();

      if (userRole == 'admin') {
        // Mark messages from patients as read
        final query =
            await _firestore
                .collection('chats')
                .where('conversationId', isEqualTo: conversationId)
                .where('senderRole', isEqualTo: 'pasien')
                .where('isRead', isEqualTo: false)
                .get();

        for (var doc in query.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
      } else {
        // Mark messages from admin as read
        final query =
            await _firestore
                .collection('chats')
                .where('conversationId', isEqualTo: conversationId)
                .where('senderRole', isEqualTo: 'admin')
                .where('isRead', isEqualTo: false)
                .get();

        for (var doc in query.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
      }

      await batch.commit();
      print('Messages marked as read successfully');
    } catch (e) {
      print('Error marking messages as read: $e');
      rethrow;
    }
  }

  // Kehamilanku Management
  Stream<List<Map<String, dynamic>>> getKehamilankuStream(String pasienId) {
    try {
      return _firestore
          .collection('kehamilanku')
          .where('pasienId', isEqualTo: pasienId)
          .orderBy('tanggalPemeriksaan', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print('Error in getKehamilankuStream: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error getting kehamilanku stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> createKehamilanku(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('kehamilanku').doc(data['id']).set(data);
      print('Kehamilanku created successfully: ${data['id']}');
    } catch (e) {
      print('Error creating kehamilanku: $e');
      rethrow;
    }
  }

  Future<void> updateKehamilanku(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('kehamilanku').doc(data['id']).update(data);
      print('Kehamilanku updated successfully: ${data['id']}');
    } catch (e) {
      print('Error updating kehamilanku: $e');
      rethrow;
    }
  }

  Future<void> deleteKehamilanku(String kehamilankuId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('kehamilanku').doc(kehamilankuId).delete();
      print('Kehamilanku deleted successfully: $kehamilankuId');
    } catch (e) {
      print('Error deleting kehamilanku: $e');
      rethrow;
    }
  }

  // Pemeriksaan Ibu Hamil Management
  Stream<List<Map<String, dynamic>>> getPemeriksaanIbuHamilStream() {
    try {
      return _firestore
          .collection('pemeriksaan_ibuhamil')
          .orderBy('tanggalPemeriksaan', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print('Error in getPemeriksaanIbuHamilStream: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error getting pemeriksaan ibuhamil stream: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> getPemeriksaanIbuHamilByPasienStream(
    String pasienId,
  ) {
    try {
      return _firestore
          .collection('pemeriksaan_ibuhamil')
          .where('pasienId', isEqualTo: pasienId)
          .orderBy('tanggalPemeriksaan', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print('Error in getPemeriksaanIbuHamilByPasienStream: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error getting pemeriksaan ibuhamil by pasien stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> createPemeriksaanIbuHamil(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('pemeriksaan_ibuhamil')
          .doc(data['id'])
          .set(data);
      print('Pemeriksaan ibuhamil created successfully: ${data['id']}');
    } catch (e) {
      print('Error creating pemeriksaan ibuhamil: $e');
      rethrow;
    }
  }

  Future<void> updatePemeriksaanIbuHamil(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('pemeriksaan_ibuhamil')
          .doc(data['id'])
          .update(data);
      print('Pemeriksaan ibuhamil updated successfully: ${data['id']}');
    } catch (e) {
      print('Error updating pemeriksaan ibuhamil: $e');
      rethrow;
    }
  }

  Future<void> deletePemeriksaanIbuHamil(String pemeriksaanId) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('pemeriksaan_ibuhamil')
          .doc(pemeriksaanId)
          .delete();
      print('Pemeriksaan ibuhamil deleted successfully: $pemeriksaanId');
    } catch (e) {
      print('Error deleting pemeriksaan ibuhamil: $e');
      rethrow;
    }
  }

  // Jadwal Konsultasi Management
  Stream<List<Map<String, dynamic>>> getJadwalKonsultasiStream() {
    try {
      return _firestore
          .collection('jadwal_konsultasi')
          .orderBy('tanggalKonsultasi', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print('Error in getJadwalKonsultasiStream: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error getting jadwal konsultasi stream: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> getJadwalKonsultasiByPasienStream(
    String pasienId,
  ) {
    try {
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        print('User not authenticated for jadwal konsultasi');
        return Stream.value(<Map<String, dynamic>>[]);
      }

      return _firestore
          .collection('jadwal_konsultasi')
          .where('pasienId', isEqualTo: pasienId)
          .orderBy('tanggalKonsultasi', descending: false)
          .limit(30) // Limit untuk performa
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print('Error getting jadwal konsultasi: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error in getJadwalKonsultasiByPasienStream: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<void> createJadwalKonsultasi(Map<String, dynamic> data) async {
    try {
      // Get current user first
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      // Validate required fields
      if (data['pasienId'] == null || data['pasienId'].toString().isEmpty) {
        throw Exception('Patient ID is required');
      }

      if (data['tanggalKonsultasi'] == null ||
          data['tanggalKonsultasi'].toString().isEmpty) {
        throw Exception('Consultation date is required');
      }

      if (data['keluhan'] == null ||
          data['keluhan'].toString().trim().isEmpty) {
        throw Exception('Complaint is required');
      }

      // Ensure the pasienId matches the current user's ID for security
      if (data['pasienId'] != currentUser.uid) {
        print(
          'Warning: pasienId mismatch. Expected: ${currentUser.uid}, Got: ${data['pasienId']}',
        );
        // Update the pasienId to match the current user
        data['pasienId'] = currentUser.uid;
      }

      // Check for duplicate appointments on the same date
      final selectedDateTime = DateTime.parse(data['tanggalKonsultasi']);
      final startOfDay = DateTime(
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingAppointments =
          await _firestore
              .collection('jadwal_konsultasi')
              .where('pasienId', isEqualTo: data['pasienId'])
              .where(
                'tanggalKonsultasi',
                isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
              )
              .where(
                'tanggalKonsultasi',
                isLessThan: endOfDay.toIso8601String(),
              )
              .get();

      if (existingAppointments.docs.isNotEmpty) {
        throw Exception(
          'Sudah ada janji temu pada tanggal yang sama. Silakan pilih tanggal lain.',
        );
      }

      // Add creation timestamp
      data['createdAt'] = DateTime.now().toIso8601String();
      data['status'] = 'pending'; // Default status

      // Create the document with auto-generated ID
      await _firestore.collection('jadwal_konsultasi').add(data);

      print('Jadwal konsultasi created successfully');
    } catch (e) {
      print('Error creating jadwal konsultasi: $e');
      rethrow;
    }
  }

  // Mark consultation schedule as completed
  Future<void> markConsultationScheduleAsCompleted(String scheduleId) async {
    try {
      await ensureAuthenticated();

      await _firestore.collection('jadwal_konsultasi').doc(scheduleId).update({
        'examinationCompleted': true,
        'completedAt': DateTime.now().toIso8601String(),
      });

      print('Consultation schedule marked as completed: $scheduleId');
    } catch (e) {
      print('Error marking consultation schedule as completed: $e');
      rethrow;
    }
  }

  Future<void> updateJadwalKonsultasi(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();

      // Get current schedule data to check status changes
      final currentSchedule =
          await _firestore
              .collection('jadwal_konsultasi')
              .doc(data['id'])
              .get();

      if (currentSchedule.exists) {
        final currentData = currentSchedule.data() as Map<String, dynamic>;
        final currentStatus = currentData['status'] ?? 'pending';
        final newStatus = data['status'];

        // Check if status changed to accepted or rejected
        if (newStatus != null && newStatus != currentStatus) {
          if (newStatus == 'confirmed' || newStatus == 'accepted') {
            // Send notification to patient about accepted appointment
            try {
              await NotificationIntegrationService.notifyPatientAppointmentAccepted(
                patientId: data['pasienId'] ?? currentData['pasienId'],
                appointmentId: data['id'],
                adminName: 'Admin',
                appointmentType: 'Temu Janji',
                appointmentTime: DateTime.parse(
                  data['tanggalKonsultasi'] ?? currentData['tanggalKonsultasi'],
                ),
              );
              print('Appointment accepted notification sent to patient');
            } catch (e) {
              print('Error sending appointment accepted notification: $e');
            }
          } else if (newStatus == 'rejected') {
            // Send notification to patient about rejected appointment
            try {
              await NotificationIntegrationService.notifyPatientAppointmentRejected(
                patientId: data['pasienId'] ?? currentData['pasienId'],
                appointmentId: data['id'],
                adminName: 'Admin',
                reason:
                    data['rejectionReason'] ??
                    'Tidak ada alasan yang diberikan',
              );
              print('Appointment rejected notification sent to patient');
            } catch (e) {
              print('Error sending appointment rejected notification: $e');
            }
          }
        }
      }

      // Update the schedule
      await _firestore
          .collection('jadwal_konsultasi')
          .doc(data['id'])
          .update(data);
      print('Jadwal konsultasi updated successfully: ${data['id']}');
    } catch (e) {
      print('Error updating jadwal konsultasi: $e');
      rethrow;
    }
  }

  Future<void> deleteJadwalKonsultasi(String jadwalId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('jadwal_konsultasi').doc(jadwalId).delete();
      print('Jadwal konsultasi deleted successfully: $jadwalId');
    } catch (e) {
      print('Error deleting jadwal konsultasi: $e');
      rethrow;
    }
  }

  // Darurat Management
  Stream<List<Map<String, dynamic>>> getDaruratStream(String userId) {
    try {
      return _firestore
          .collection('darurat')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print('Error in getDaruratStream: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error in getDaruratStream: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }

  Future<void> createDarurat(Map<String, dynamic> data) async {
    try {
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      // Add authentication info to data
      data['createdBy'] = _auth.currentUser!.uid;
      data['createdAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('darurat').doc(data['id']).set(data);
      print('Darurat created successfully: ${data['id']}');
    } catch (e) {
      print('Error creating darurat: $e');
      if (e.toString().contains('permission-denied')) {
        throw Exception(
          'Permission denied. Please check your authentication status.',
        );
      }
      rethrow;
    }
  }

  Future<void> updateDarurat(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('darurat').doc(data['id']).update(data);
      print('Darurat updated successfully: ${data['id']}');
    } catch (e) {
      print('Error updating darurat: $e');
      rethrow;
    }
  }

  Future<void> deleteDarurat(String daruratId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('darurat').doc(daruratId).delete();
      print('Darurat deleted successfully: $daruratId');
    } catch (e) {
      print('Error deleting darurat: $e');
      rethrow;
    }
  }

  // Children Management
  Stream<List<Map<String, dynamic>>> getChildrenStream(String userId) {
    try {
      return _firestore
          .collection('children')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print('Error in getChildrenStream: $error');
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      print('Error getting children stream: $e');
      return Stream.value([]);
    }
  }

  Future<void> createChild(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('children').doc(data['id']).set(data);
      print('Child created successfully: ${data['id']}');
    } catch (e) {
      print('Error creating child: $e');
      rethrow;
    }
  }

  Future<void> updateChild(Map<String, dynamic> data) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('children').doc(data['id']).update(data);
      print('Child updated successfully: ${data['id']}');
    } catch (e) {
      print('Error updating child: $e');
      rethrow;
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('children').doc(childId).delete();
      print('Child deleted successfully: $childId');
    } catch (e) {
      print('Error deleting child: $e');
      rethrow;
    }
  }

  Future<void> createChildFromHPHT(String userId, DateTime hpht) async {
    try {
      await ensureAuthenticated();
      // Calculate estimated due date (40 weeks from HPHT)
      final dueDate = hpht.add(const Duration(days: 280));

      // Create child data
      final childData = {
        'id': generateId(),
        'userId': userId,
        'nama': 'Anak dari HPHT',
        'tanggalLahir': dueDate.toIso8601String(),
        'jenisKelamin': 'Belum diketahui',
        'beratLahir': 0.0,
        'panjangLahir': 0.0,
        'hpht': hpht.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('children')
          .doc(childData['id'] as String)
          .set(childData);
      print('Child created from HPHT successfully: ${childData['id']}');
    } catch (e) {
      print('Error creating child from HPHT: $e');
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await ensureAuthenticated();
      await _firestore.collection('chats').doc(messageId).update({
        'isRead': true,
      });
      print('Message marked as read: $messageId');
    } catch (e) {
      print('Error marking message as read: $e');
      rethrow;
    }
  }

  // Get available time slots for a specific date
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all appointments for this date
      final appointments =
          await _firestore
              .collection('jadwal_konsultasi')
              .where(
                'tanggalKonsultasi',
                isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
              )
              .where(
                'tanggalKonsultasi',
                isLessThan: endOfDay.toIso8601String(),
              )
              .get();

      // Create list of all possible time slots (8:00-19:00, every 30 minutes)
      final allTimeSlots = <String>[];
      for (int hour = 8; hour < 19; hour++) {
        allTimeSlots.add('${hour.toString().padLeft(2, '0')}:00');
        allTimeSlots.add('${hour.toString().padLeft(2, '0')}:30');
      }

      // Remove booked time slots
      final bookedSlots = <String>[];
      for (var doc in appointments.docs) {
        final data = doc.data();
        if (data['waktuKonsultasi'] != null) {
          bookedSlots.add(data['waktuKonsultasi']);
        }
      }

      return allTimeSlots.where((slot) => !bookedSlots.contains(slot)).toList();
    } catch (e) {
      print('Error getting available time slots: $e');
      // Return default time slots if there's an error
      return [
        '09:00',
        '09:30',
        '10:00',
        '10:30',
        '11:00',
        '11:30',
        '14:00',
        '14:30',
        '15:00',
        '15:30',
        '16:00',
        '16:30',
      ];
    }
  }

  // Utility methods
  String generateId() => _uuid.v4();

  int calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Security and validation methods
  Future<bool> validateUserPermissions(String userId) async {
    try {
      await ensureAuthenticated();
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Admin can access all data
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['role'] == 'admin') return true;
      }

      // Users can only access their own data
      return currentUser.uid == userId;
    } catch (e) {
      print('Error validating user permissions: $e');
      return false;
    }
  }

  // Performance optimization methods
  Future<void> enableOfflinePersistence() async {
    try {
      if (!isFirebaseInitialized()) {
        print('Firebase not initialized, skipping offline persistence setup');
        return;
      }

      // For web, we need to handle offline persistence differently
      if (kIsWeb) {
        print('Web platform detected, using web-specific offline settings');
        _firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } else {
        _firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
      print('Offline persistence enabled');
    } catch (e) {
      print('Error enabling offline persistence: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      await _firestore.clearPersistence();
      print('Firestore cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Debug method to create test user
  Future<void> createTestUser() async {
    try {
      await ensureAuthenticated();
      final testUser = UserModel(
        id: 'test-user-123',
        email: 'test@example.com',
        password: 'password123',
        nama: 'Test User',
        noHp: '08123456789',
        alamat: 'Test Address',
        tanggalLahir: DateTime(1990, 1, 1),
        umur: 33,
        role: 'pasien',
        createdAt: DateTime.now(),

        // New fields
        namaSuami: 'Test Husband',
        pekerjaanSuami: 'Test Job',
        umurSuami: 35,
        agamaSuami: 'Test Religion',
        agamaPasien: 'Test Religion',
        pekerjaanPasien: 'Test Job',
      );

      await createUser(testUser);
      print('Test user created successfully');
    } catch (e) {
      print('Error creating test user: $e');
    }
  }

  // Debug method to list all users
  Future<void> listAllUsers() async {
    try {
      await ensureAuthenticated();
      final users = await _firestore.collection('users').get();
      print('Total users in database: ${users.docs.length}');
      for (var doc in users.docs) {
        print('User: ${doc.data()}');
      }
    } catch (e) {
      print('Error listing users: $e');
    }
  }

  // ============ LAPORAN PERSALINAN METHODS ============

  // Create laporan persalinan
  Future<void> createLaporanPersalinan(dynamic laporan) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('laporan_persalinan')
          .doc(laporan.id)
          .set(laporan.toMap());
      print('Laporan persalinan created successfully');
    } catch (e) {
      print('Error creating laporan persalinan: $e');
      rethrow;
    }
  }

  // Get laporan persalinan by registrasi ID
  Stream<List<LaporanPersalinanModel>> getLaporanPersalinanByRegistrasiId(
    String registrasiId,
  ) {
    try {
      print('Loading laporan persalinan for registrasi ID: $registrasiId');
      return _firestore
          .collection('laporan_persalinan')
          .where('registrasiPersalinanId', isEqualTo: registrasiId)
          .orderBy('createdAt', descending: true)
          .limit(50) // Add limit to improve performance
          .snapshots()
          .timeout(const Duration(seconds: 20)) // Increase timeout
          .map((snapshot) {
            print(
              'Received ${snapshot.docs.length} laporan persalinan documents',
            );
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return LaporanPersalinanModel.fromMap(data);
            }).toList();
          })
          .handleError((error) {
            print('Error getting laporan persalinan: $error');
            // Return empty stream on error instead of empty list
            return <LaporanPersalinanModel>[];
          });
    } catch (e) {
      print('Error setting up laporan persalinan stream: $e');
      return Stream.value(<LaporanPersalinanModel>[]);
    }
  }

  // ============ LAPORAN PASCA PERSALINAN METHODS ============

  // Create laporan pasca persalinan
  Future<void> createLaporanPascaPersalinan(dynamic laporanPasca) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('laporan_pasca_persalinan')
          .doc(laporanPasca.id)
          .set(laporanPasca.toMap());
      print('Laporan pasca persalinan created successfully');
    } catch (e) {
      print('Error creating laporan pasca persalinan: $e');
      rethrow;
    }
  }

  // Get laporan pasca persalinan by laporan persalinan ID
  Stream<List<LaporanPascaPersalinanModel>>
  getLaporanPascaPersalinanByLaporanId(String laporanId) {
    try {
      print('Loading laporan pasca persalinan for laporan ID: $laporanId');
      return _firestore
          .collection('laporan_pasca_persalinan')
          .where('laporanPersalinanId', isEqualTo: laporanId)
          .orderBy('createdAt', descending: true)
          .limit(50) // Add limit to improve performance
          .snapshots()
          .timeout(const Duration(seconds: 20)) // Increase timeout
          .map((snapshot) {
            print(
              'Received ${snapshot.docs.length} laporan pasca persalinan documents',
            );
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return LaporanPascaPersalinanModel.fromMap(data);
            }).toList();
          })
          .handleError((error) {
            print('Error getting laporan pasca persalinan: $error');
            return <LaporanPascaPersalinanModel>[];
          });
    } catch (e) {
      print('Error setting up laporan pasca persalinan stream: $e');
      return Stream.value(<LaporanPascaPersalinanModel>[]);
    }
  }

  // Create keterangan kelahiran
  Future<void> createKeteranganKelahiran(dynamic keterangan) async {
    try {
      await ensureAuthenticated();
      await _firestore
          .collection('keterangan_kelahiran')
          .doc(keterangan.id)
          .set(keterangan.toMap());
      print('Keterangan kelahiran created successfully');
    } catch (e) {
      print('Error creating keterangan kelahiran: $e');
      rethrow;
    }
  }

  // Get keterangan kelahiran by laporan pasca persalinan ID
  Stream<List<KeteranganKelahiranModel>> getKeteranganKelahiranByLaporanPascaId(
    String laporanPascaId,
  ) {
    try {
      print(
        'Loading keterangan kelahiran for laporan pasca ID: $laporanPascaId',
      );
      return _firestore
          .collection('keterangan_kelahiran')
          .where('laporanPascaPersalinanId', isEqualTo: laporanPascaId)
          .orderBy('createdAt', descending: true)
          .limit(50) // Add limit to improve performance
          .snapshots()
          .timeout(const Duration(seconds: 20)) // Increase timeout
          .map((snapshot) {
            print(
              'Received ${snapshot.docs.length} keterangan kelahiran documents',
            );
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return KeteranganKelahiranModel.fromMap(data);
            }).toList();
          })
          .handleError((error) {
            print('Error getting keterangan kelahiran: $error');
            return <KeteranganKelahiranModel>[];
          });
    } catch (e) {
      print('Error setting up keterangan kelahiran stream: $e');
      return Stream.value(<KeteranganKelahiranModel>[]);
    }
  }

  // Get persalinan by ID (for loading parent data)
  Future<PersalinanModel?> getPersalinanById(String id) async {
    try {
      await ensureAuthenticated();
      final doc = await _firestore.collection('persalinan').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return PersalinanModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting persalinan by ID: $e');
      return null;
    }
  }

  // Article interaction methods
  Future<void> toggleArticleLike(String articleId, String userId) async {
    try {
      await ensureAuthenticated();

      // Get current like status
      final likeDoc =
          await _firestore
              .collection('user_article_likes')
              .doc('${userId}_$articleId')
              .get();

      if (likeDoc.exists) {
        // Unlike: remove the document
        await _firestore
            .collection('user_article_likes')
            .doc('${userId}_$articleId')
            .delete();
        print('Article unliked: $articleId');
      } else {
        // Like: create the document
        await _firestore
            .collection('user_article_likes')
            .doc('${userId}_$articleId')
            .set({
              'userId': userId,
              'articleId': articleId,
              'createdAt': DateTime.now().toIso8601String(),
            });
        print('Article liked: $articleId');
      }
    } catch (e) {
      print('Error toggling article like: $e');
      rethrow;
    }
  }

  Future<void> toggleArticleBookmark(String articleId, String userId) async {
    try {
      await ensureAuthenticated();

      // Get current bookmark status
      final bookmarkDoc =
          await _firestore
              .collection('user_article_bookmarks')
              .doc('${userId}_$articleId')
              .get();

      if (bookmarkDoc.exists) {
        // Remove bookmark: remove the document
        await _firestore
            .collection('user_article_bookmarks')
            .doc('${userId}_$articleId')
            .delete();
        print('Article bookmark removed: $articleId');
      } else {
        // Add bookmark: create the document
        await _firestore
            .collection('user_article_bookmarks')
            .doc('${userId}_$articleId')
            .set({
              'userId': userId,
              'articleId': articleId,
              'createdAt': DateTime.now().toIso8601String(),
            });
        print('Article bookmarked: $articleId');
      }
    } catch (e) {
      print('Error toggling article bookmark: $e');
      rethrow;
    }
  }

  // Get liked articles for a user
  Stream<List<String>> getLikedArticleIds(String userId) {
    try {
      return _firestore
          .collection('user_article_likes')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => doc.data()['articleId'] as String)
                    .toList(),
          );
    } catch (e) {
      print('Error getting liked article IDs: $e');
      return Stream.value([]);
    }
  }

  // Get bookmarked articles for a user
  Stream<List<String>> getBookmarkedArticleIds(String userId) {
    try {
      return _firestore
          .collection('user_article_bookmarks')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => doc.data()['articleId'] as String)
                    .toList(),
          );
    } catch (e) {
      print('Error getting bookmarked article IDs: $e');
      return Stream.value([]);
    }
  }

  // Check if article is liked by user
  Future<bool> isArticleLiked(String articleId, String userId) async {
    try {
      await ensureAuthenticated();
      final doc =
          await _firestore
              .collection('user_article_likes')
              .doc('${userId}_$articleId')
              .get();
      return doc.exists;
    } catch (e) {
      print('Error checking if article is liked: $e');
      return false;
    }
  }

  // Check if article is bookmarked by user
  Future<bool> isArticleBookmarked(String articleId, String userId) async {
    try {
      final doc =
          await _firestore
              .collection('user_article_bookmarks')
              .doc('${userId}_$articleId')
              .get();
      return doc.exists;
    } catch (e) {
      print('Error checking if article is bookmarked: $e');
      return false;
    }
  }

  // Get articles by IDs
  Stream<List<Article>> getArticlesByIds(List<String> articleIds) {
    if (articleIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('articles')
        .where(FieldPath.documentId, whereIn: articleIds)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Article.fromMap({'id': doc.id, ...doc.data()}))
              .toList();
        })
        .handleError((error) {
          print('Error getting articles by IDs: $error');
          return <Article>[];
        });
  }

  // Update pregnancy status
  Future<void> updatePregnancyStatus(
    String userId,
    String status,
    String reason,
    String notes,
    DateTime endDate,
  ) async {
    try {
      await ensureAuthenticated();

      final updateData = {
        'pregnancyStatus': status,
        'pregnancyEndDate': endDate.toIso8601String(),
        'pregnancyEndReason': reason,
        'pregnancyNotes': notes,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(userId).update(updateData);

      print('Pregnancy status updated successfully for user: $userId');
    } catch (e) {
      print('Error updating pregnancy status: $e');
      rethrow;
    }
  }

  // Reset pregnancy status to active (for new pregnancy)
  Future<void> resetPregnancyStatus(String userId) async {
    try {
      await ensureAuthenticated();

      final updateData = {
        'pregnancyStatus': 'active',
        'pregnancyEndDate': null,
        'pregnancyEndReason': null,
        'pregnancyNotes': null,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(userId).update(updateData);

      print('Pregnancy status reset to active for user: $userId');
    } catch (e) {
      print('Error resetting pregnancy status: $e');
      rethrow;
    }
  }

  // Add new HPHT for next pregnancy (for users who had miscarriage)
  Future<void> addNewHPHTForNextPregnancy(
    String userId,
    DateTime newHpht,
  ) async {
    try {
      await ensureAuthenticated();

      // Get current user data to check pregnancy history
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data()!;
      final currentHpht = userData['hpht'];
      final pregnancyStatus = userData['pregnancyStatus'];
      final pregnancyEndDate = userData['pregnancyEndDate'];
      final pregnancyEndReason = userData['pregnancyEndReason'];
      final pregnancyNotes = userData['pregnancyNotes'];

      // Create pregnancy history entry for the previous pregnancy
      final pregnancyHistoryEntry = {
        'hpht': currentHpht,
        'pregnancyStatus': pregnancyStatus,
        'pregnancyEndDate': pregnancyEndDate,
        'pregnancyEndReason': pregnancyEndReason,
        'pregnancyNotes': pregnancyNotes,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Get existing pregnancy history or create new list
      final existingHistory = userData['pregnancyHistory'] ?? [];
      final updatedHistory = List<Map<String, dynamic>>.from(existingHistory);
      updatedHistory.add(pregnancyHistoryEntry);

      // Update user with new HPHT and pregnancy history
      final updateData = {
        'hpht': newHpht.toIso8601String(),
        'newHpht': newHpht.toIso8601String(),
        'pregnancyStatus': 'active',
        'pregnancyEndDate': null,
        'pregnancyEndReason': null,
        'pregnancyNotes': null,
        'pregnancyHistory': updatedHistory,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').doc(userId).update(updateData);

      // Create new child data for the new pregnancy
      await createChildFromHPHT(userId, newHpht);

      print('New HPHT added successfully for user: $userId');
    } catch (e) {
      print('Error adding new HPHT: $e');
      rethrow;
    }
  }

  // Get pregnancy history for a user
  Stream<List<Map<String, dynamic>>> getPregnancyHistory(String userId) {
    try {
      return _firestore.collection('users').doc(userId).snapshots().map((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          final history = data['pregnancyHistory'] ?? [];
          return List<Map<String, dynamic>>.from(history);
        }
        return <Map<String, dynamic>>[];
      });
    } catch (e) {
      print('Error getting pregnancy history: $e');
      return Stream.value(<Map<String, dynamic>>[]);
    }
  }
}
