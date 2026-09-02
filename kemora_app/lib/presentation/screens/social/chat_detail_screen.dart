import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/chat.dart';
import '../../viewmodels/chat_view_model.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ChatViewModel>();
      viewModel.loadMessages(widget.conversation.contactId);
      viewModel.markAsRead(widget.conversation.contactId);
    });
  }

  void _onSendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatViewModel>().sendMessage(
        widget.conversation.contactId, 
        _messageController.text.trim()
      );
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.conversation.contactProfilePicture ?? 'https://via.placeholder.com/150'),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.conversation.contactName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        final messages = viewModel.getMessages(widget.conversation.contactId);
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId != widget.conversation.contactId;
            
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFC5A358) : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(msg.sentAt),
                      style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 10, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _onSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFFC5A358),
            child: IconButton(
              onPressed: _onSendMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
