import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/chat.dart';
import '../repositories/i_chat_repository.dart';

class GetConversationsUseCase {
  final IChatRepository repository;
  GetConversationsUseCase(this.repository);
  Future<Either<Failure, List<Conversation>>> call() async => await repository.getConversations();
}

class GetConversationMessagesUseCase {
  final IChatRepository repository;
  GetConversationMessagesUseCase(this.repository);
  Future<Either<Failure, List<Message>>> call(String contactId, {int page = 1}) async => await repository.getConversation(contactId, page: page);
}

class SendChatMessageUseCase {
  final IChatRepository repository;
  SendChatMessageUseCase(this.repository);
  Future<Either<Failure, Message>> call(String receiverId, String content) async => await repository.sendMessage(receiverId, content);
}

class MarkChatAsReadUseCase {
  final IChatRepository repository;
  MarkChatAsReadUseCase(this.repository);
  Future<Either<Failure, void>> call(String contactId) async => await repository.markAsRead(contactId);
}
