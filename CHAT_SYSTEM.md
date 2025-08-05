# Chat System Documentation

## Overview
The chat system has been improved to enable real-time communication between patients and admin (bidan). The system now uses a conversation-based approach with proper message filtering and real-time updates.

## Key Features

### 1. Conversation-Based Messaging
- Each patient has a unique conversation ID: `admin_{patientId}`
- Messages are grouped by conversation ID for proper filtering
- Admin can select different patients to chat with

### 2. Real-Time Updates
- Messages are delivered in real-time using Firebase Firestore streams
- Auto-scroll to bottom when new messages arrive
- Message status indicators (read/unread)

### 3. Message Status
- Messages show delivery status (single checkmark for sent, double checkmark for read)
- Messages are automatically marked as read when the recipient opens the chat
- Unread message count tracking

## Data Structure

### ChatModel
```dart
class ChatModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'admin' or 'pasien'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String conversationId; // Groups messages between patient and admin
  final String recipientId; // Who the message is intended for
}
```

## Firebase Collections

### chats
- Stores all chat messages
- Indexed by conversationId for efficient querying
- Ordered by timestamp for chronological display

## User Experience

### For Patients
1. Navigate to chat screen from patient dashboard
2. Messages are automatically loaded for their conversation with admin
3. Send messages by typing and pressing send button
4. See message status (sent/read)
5. Messages are marked as read when admin opens the chat

### For Admin
1. Navigate to admin chat screen
2. Select a patient from the patient list
3. View and send messages to the selected patient
4. Switch between different patients
5. See message status and unread counts

## Technical Implementation

### Firebase Service Methods
- `sendMessage(ChatModel chat)` - Send a new message
- `getConversationMessages(String conversationId)` - Get messages for a specific conversation
- `getUnreadMessageCount(String userId, String userRole)` - Get unread message count
- `markMessagesAsRead(String conversationId, String userId, String userRole)` - Mark messages as read
- `generateConversationId(String patientId)` - Generate conversation ID

### Real-Time Features
- Firebase Firestore streams for live updates
- Automatic message marking as read
- Auto-scroll to latest messages
- Error handling and retry mechanisms

## Security Considerations
- Messages are filtered by conversation ID
- Users can only see messages in their conversations
- Admin can only access patient conversations
- Proper authentication required for all operations

## Future Enhancements
- Push notifications for new messages
- File/image sharing
- Message search functionality
- Chat history export
- Typing indicators
- Message reactions 