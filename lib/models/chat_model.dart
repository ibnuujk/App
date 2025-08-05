class ChatModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'admin' atau 'pasien'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String conversationId; // To group messages between patient and admin
  final String recipientId; // Who the message is intended for

  ChatModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.conversationId,
    required this.recipientId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'conversationId': conversationId,
      'recipientId': recipientId,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      conversationId: map['conversationId'] ?? '',
      recipientId: map['recipientId'] ?? '',
    );
  }

  ChatModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? conversationId,
    String? recipientId,
  }) {
    return ChatModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      conversationId: conversationId ?? this.conversationId,
      recipientId: recipientId ?? this.recipientId,
    );
  }
}
