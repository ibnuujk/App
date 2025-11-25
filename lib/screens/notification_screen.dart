import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';
import '../routes/route_helper.dart';

class NotificationScreen extends StatefulWidget {
  final UserModel? user;

  const NotificationScreen({super.key, this.user});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationModel> _allNotifications = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoreNotifications();
    });
  }

  Future<void> _loadInitialNotifications() async {
    setState(() {
      _isInitialLoad = true;
      _allNotifications.clear();
      _lastDocument = null;
      _hasMore = true;
    });
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final currentUserId =
          widget.user?.id ?? FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        setState(() {
          _isLoadingMore = false;
          _isInitialLoad = false;
        });
        return;
      }

      List<QueryDocumentSnapshot> docsToProcess = [];

      // Try with orderBy first (requires index)
      try {
        Query query = FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .limit(20);

        if (_lastDocument != null) {
          query = query.startAfterDocument(_lastDocument!);
        }

        final snapshot = await query.get();
        docsToProcess = snapshot.docs;
        print('Query with orderBy found ${docsToProcess.length} notifications');
      } catch (e) {
        // Fallback: query without orderBy if index doesn't exist
        print('Index error, using fallback query: $e');
        print('Current user ID: $currentUserId');

        try {
          // Try query with receiverId first
          Query query = FirebaseFirestore.instance
              .collection('notifications')
              .where('receiverId', isEqualTo: currentUserId)
              .limit(100); // Get more to sort in memory

          var snapshot = await query.get();
          print(
            'Fallback query (receiverId) found ${snapshot.docs.length} notifications',
          );

          // If no results with receiverId, try with userId (for backward compatibility)
          if (snapshot.docs.isEmpty) {
            print('No notifications with receiverId, trying userId...');
            query = FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: currentUserId)
                .limit(100);
            snapshot = await query.get();
            print(
              'Fallback query (userId) found ${snapshot.docs.length} notifications',
            );
          }

          final allDocs = snapshot.docs;

          // Sort by createdAt in memory
          final sortedDocs = List<QueryDocumentSnapshot>.from(allDocs);
          sortedDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = aData['createdAt'];
            final bTime = bData['createdAt'];

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            DateTime aDate, bDate;
            if (aTime is Timestamp) {
              aDate = aTime.toDate();
            } else if (aTime is String) {
              try {
                aDate = DateTime.parse(aTime);
              } catch (e) {
                return 1;
              }
            } else {
              return 1;
            }

            if (bTime is Timestamp) {
              bDate = bTime.toDate();
            } else if (bTime is String) {
              try {
                bDate = DateTime.parse(bTime);
              } catch (e) {
                return -1;
              }
            } else {
              return -1;
            }

            return bDate.compareTo(aDate); // Descending
          });

          // Skip already loaded notifications
          final existingIds = _allNotifications.map((n) => n.id).toSet();
          docsToProcess =
              sortedDocs
                  .where((doc) => !existingIds.contains(doc.id))
                  .take(20)
                  .toList();
        } catch (fallbackError) {
          print('Fallback query also failed: $fallbackError');
          docsToProcess = [];
        }
      }

      print('Processing ${docsToProcess.length} notifications');

      if (docsToProcess.isEmpty) {
        print('No notifications found for user: $currentUserId');
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
          _isInitialLoad = false;
        });
        return;
      }

      final newNotifications =
          docsToProcess
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  return NotificationModel.fromMap({'id': doc.id, ...data});
                } catch (e) {
                  print('Error parsing notification: $e');
                  return null;
                }
              })
              .whereType<NotificationModel>()
              .toList();

      // Remove duplicates
      final existingIds = _allNotifications.map((n) => n.id).toSet();
      final uniqueNotifications =
          newNotifications.where((n) => !existingIds.contains(n.id)).toList();

      setState(() {
        _allNotifications.addAll(uniqueNotifications);
        // Sort all notifications by createdAt descending
        _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (docsToProcess.isNotEmpty) {
          _lastDocument = docsToProcess.last;
        }
        _hasMore = docsToProcess.length >= 20;
        _isLoadingMore = false;
        _isInitialLoad = false;
      });
    } catch (e) {
      print('Error loading more notifications: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        _isLoadingMore = false;
        _isInitialLoad = false;
      });

      // Show error to user if in mounted state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat notifikasi: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadMoreNotifications,
            ),
          ),
        );
      }
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadInitialNotifications();
    await _loadMoreNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC407A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          StreamBuilder<int>(
            stream: NotificationService.getUnreadCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              if (unreadCount == 0) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'mark_all_read':
                  await NotificationService.markAllAsRead();
                  break;
                case 'clear_all':
                  await NotificationService.clearAllNotifications();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        const Icon(Icons.mark_email_read, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'Tandai Semua Dibaca',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.clear_all,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hapus Semua',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _buildNotificationList(),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    final isUnread = !notification.isRead;
    final timeAgo = _getTimeAgo(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? const Color(0xFFEC407A) : Colors.grey[200]!,
          width: isUnread ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
            color: isUnread ? const Color(0xFF2D3748) : Colors.grey[700],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC407A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'BARU',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'mark_read':
                if (isUnread) {
                  await NotificationService.markAsRead(notification.id);
                }
                break;
              case 'delete':
                await NotificationService.deleteNotification(notification.id);
                break;
            }
          },
          itemBuilder:
              (context) => [
                if (isUnread)
                  PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        const Icon(Icons.mark_email_read, size: 18),
                        const SizedBox(width: 12),
                        Text('Tandai Dibaca', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 18, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(
                        'Hapus',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
          icon: const Icon(Icons.more_vert, color: Colors.grey),
        ),
        onTap: () async {
          if (isUnread) {
            await NotificationService.markAsRead(notification.id);
          }
          // TODO: Navigate to related screen based on notification type
          _handleNotificationTap(context, notification);
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'appointment':
        return const Color(0xFF4CAF50); // Green
      case 'chat':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFFEC407A); // Pink
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'chat':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  Widget _buildNotificationList() {
    if (_isInitialLoad) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFEC407A)),
            SizedBox(height: 16),
            Text(
              'Memuat notifikasi...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_allNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada notifikasi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allNotifications.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _allNotifications.length) {
          // Load more button
          return _buildLoadMoreButton();
        }
        return _buildNotificationCard(context, _allNotifications[index]);
      },
    );
  }

  Widget _buildLoadMoreButton() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFEC407A)),
        ),
      );
    }

    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Tidak ada notifikasi lagi',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: _loadMoreNotifications,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEC407A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Muat Lebih Banyak',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'appointment':
      case 'appointment_accepted':
      case 'appointment_rejected':
        // Navigate to jadwal pasien
        if (widget.user!.role == 'pasien') {
          RouteHelper.navigateToJadwalPasien(context, widget.user!);
        } else {
          RouteHelper.navigateToJadwalKonsultasi(context, widget.user!);
        }
        break;

      case 'chat':
        // Navigate to chat
        if (widget.user!.role == 'pasien') {
          RouteHelper.navigateToChatPasien(context, widget.user!);
        } else {
          RouteHelper.navigateToChatAdmin(context, widget.user!);
        }
        break;

      case 'konsultasi':
      case 'konsultasi_answered':
        // Navigate to konsultasi
        if (widget.user!.role == 'pasien') {
          RouteHelper.navigateToKonsultasiPasien(context, widget.user!);
        }
        break;

      default:
        // Show snackbar for unknown types
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka: ${notification.title}'),
            backgroundColor: const Color(0xFFEC407A),
          ),
        );
    }
  }
}
