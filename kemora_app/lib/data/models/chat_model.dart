import '../../domain/entities/chat.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.sentAt,
    required super.isRead,
    required super.senderId,
    required super.senderName,
    super.senderProfilePicture,
    required super.receiverId,
    required super.receiverName,
    super.receiverProfilePicture,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['messageID']?.toString() ?? '',
      content: json['content'] as String? ?? '',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      senderId: json['senderID']?.toString() ?? '',
      senderName: json['senderName'] as String? ?? 'Unknown',
      senderProfilePicture: json['senderProfilePicture'] as String?,
      receiverId: json['receiverID']?.toString() ?? '',
      receiverName: json['receiverName'] as String? ?? 'Unknown',
      receiverProfilePicture: json['receiverProfilePicture'] as String?,
    );
  }
}

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.contactId,
    required super.contactName,
    super.contactProfilePicture,
    required super.lastMessage,
    required super.lastMessageAt,
    required super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      contactId: json['contactId']?.toString() ?? '',
      contactName: json['contactName'] as String? ?? 'Unknown',
      contactProfilePicture: json['contactProfilePicture'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt']) : DateTime.now(),
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}
