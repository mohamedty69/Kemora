import 'package:flutter/material.dart';
import '../../domain/entities/chat.dart';
import '../../domain/usecases/chat_usecases.dart';

enum ChatState { initial, loading, loaded, error }

class ChatViewModel extends ChangeNotifier {
  final GetConversationsUseCase getConversationsUseCase;
  final GetConversationMessagesUseCase getConversationMessagesUseCase;
  final SendChatMessageUseCase sendChatMessageUseCase;
  final MarkChatAsReadUseCase markChatAsReadUseCase;

  ChatViewModel({
    required this.getConversationsUseCase,
    required this.getConversationMessagesUseCase,
    required this.sendChatMessageUseCase,
    required this.markChatAsReadUseCase,
  });

  ChatState _state = ChatState.initial;
  ChatState get state => _state;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  final Map<String, List<Message>> _messages = {};
  List<Message> getMessages(String contactId) => _messages[contactId] ?? [];

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadConversations() async {
    _state = ChatState.loading;
    notifyListeners();

    final result = await getConversationsUseCase();
    result.fold(
      (failure) {
        _state = ChatState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (convs) {
        _conversations = convs;
        _state = ChatState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> loadMessages(String contactId) async {
    final result = await getConversationMessagesUseCase(contactId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (msgs) {
        _messages[contactId] = msgs.reversed.toList(); // Newest last for ListView
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(String contactId, String content) async {
    // Optimistic UI update could be done here
    
    final result = await sendChatMessageUseCase(contactId, content);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (msg) {
        if (_messages.containsKey(contactId)) {
          _messages[contactId]!.add(msg);
        } else {
          _messages[contactId] = [msg];
        }
        
        // Update conversation list locally
        final index = _conversations.indexWhere((c) => c.contactId == contactId);
        if (index != -1) {
          final old = _conversations[index];
          _conversations.removeAt(index);
          _conversations.insert(0, Conversation(
            contactId: contactId,
            contactName: old.contactName,
            contactProfilePicture: old.contactProfilePicture,
            lastMessage: content,
            lastMessageAt: DateTime.now().toUtc(),
            unreadCount: old.unreadCount,
          ));
        }
        
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String contactId) async {
    await markChatAsReadUseCase(contactId);
    final index = _conversations.indexWhere((c) => c.contactId == contactId);
    if (index != -1) {
      final old = _conversations[index];
      _conversations[index] = Conversation(
        contactId: contactId,
        contactName: old.contactName,
        contactProfilePicture: old.contactProfilePicture,
        lastMessage: old.lastMessage,
        lastMessageAt: old.lastMessageAt,
        unreadCount: 0,
      );
      notifyListeners();
    }
  }
}
