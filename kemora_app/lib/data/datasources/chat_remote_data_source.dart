import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getConversation(String contactId, {int page = 1});
  Future<MessageModel> sendMessage(String receiverId, String content);
  Future<void> markAsRead(String contactId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await dio.get('/api/v1/chats/conversations');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ConversationModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch conversations');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<MessageModel>> getConversation(String contactId, {int page = 1}) async {
    try {
      final response = await dio.get('/api/v1/chats/conversation/$contactId', queryParameters: {'page': page});
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch messages');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<MessageModel> sendMessage(String receiverId, String content) async {
    try {
      final response = await dio.post('/api/v1/chats/send', data: {
        'receiverID': receiverId,
        'content': content,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to send message');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> markAsRead(String contactId) async {
    try {
      await dio.post('/api/v1/chats/read/$contactId');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }
}
