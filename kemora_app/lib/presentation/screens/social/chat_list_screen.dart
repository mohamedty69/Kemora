import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_view_model.dart';
import 'chat_detail_screen.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _buildContent(viewModel),
    );
  }

  Widget _buildContent(ChatViewModel viewModel) {
    if (viewModel.state == ChatState.loading && viewModel.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC5A358)));
    }

    if (viewModel.state == ChatState.error && viewModel.conversations.isEmpty) {
      return Center(child: Text(viewModel.errorMessage ?? 'Error loading chats'));
    }

    if (viewModel.conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No messages yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.conversations.length,
      itemBuilder: (context, index) {
        final conv = viewModel.conversations[index];
        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatDetailScreen(conversation: conv)),
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(conv.contactProfilePicture ?? 'https://via.placeholder.com/150'),
                onBackgroundImageError: (_, __) => const Icon(Icons.person),
              ),
              if (conv.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${conv.unreadCount}', 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          title: Text(conv.contactName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(conv.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal)),
          trailing: Text(
            DateFormat('HH:mm').format(conv.lastMessageAt),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        );
      },
    );
  }
}
