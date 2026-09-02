import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String receiverId;
  final String receiverName;
  final String? receiverProfilePicture;

  const Message({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.isRead,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.receiverId,
    required this.receiverName,
    this.receiverProfilePicture,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        sentAt,
        isRead,
        senderId,
        senderName,
        senderProfilePicture,
        receiverId,
        receiverName,
        receiverProfilePicture,
      ];
}

class Conversation extends Equatable {
  final String contactId;
  final String contactName;
  final String? contactProfilePicture;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.contactId,
    required this.contactName,
    this.contactProfilePicture,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        contactId,
        contactName,
        contactProfilePicture,
        lastMessage,
        lastMessageAt,
        unreadCount,
      ];
}
