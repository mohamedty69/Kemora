import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/chat.dart';

abstract class IChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();
  Future<Either<Failure, List<Message>>> getConversation(String contactId, {int page = 1});
  Future<Either<Failure, Message>> sendMessage(String receiverId, String content);
  Future<Either<Failure, void>> markAsRead(String contactId);
}
