import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements IChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final conversations = await remoteDataSource.getConversations();
      return Right(conversations);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getConversation(String contactId, {int page = 1}) async {
    try {
      final messages = await remoteDataSource.getConversation(contactId, page: page);
      return Right(messages);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(String receiverId, String content) async {
    try {
      final message = await remoteDataSource.sendMessage(receiverId, content);
      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String contactId) async {
    try {
      await remoteDataSource.markAsRead(contactId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
