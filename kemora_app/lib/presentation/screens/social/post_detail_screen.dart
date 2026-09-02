import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/post.dart';
import '../../viewmodels/post_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _replyingToCommentId;
  String? _replyingToAuthorName;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostViewModel>().loadComments(widget.post.id);
    });
  }

  void _setReply(String commentId, String authorName) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToAuthorName = authorName;
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToAuthorName = null;
    });
  }

  void _onAddComment() {
    if (_commentController.text.trim().isNotEmpty) {
      context.read<PostViewModel>().addComment(
        widget.post.id, 
        _commentController.text.trim(),
        parentCommentId: _replyingToCommentId,
      );
      _commentController.clear();
      _cancelReply();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch PostViewModel to get real-time state for likes/comments
    final viewModel = context.watch<PostViewModel>();
    final post = viewModel.posts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPostContent(post),
                  const Divider(thickness: 1),
                  _buildCommentsList(post.id),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostContent(Post post) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(post.authorProfilePicture),
                onBackgroundImageError: (_, __) => const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      Text(
                        timeago.format(post.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      if (post.locationName != null && post.locationName!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          post.locationName!,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(post.content, style: const TextStyle(fontSize: 16, height: 1.5)),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(post.imageUrl!, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text('${post.likesCount} likes', style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(width: 16),
              const Icon(Icons.comment, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text('${post.commentsCount} comments', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(String postId) {
    return Consumer<PostViewModel>(
      builder: (context, viewModel, child) {
        final comments = viewModel.getComments(postId);
        
        if (comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('No comments yet. Start the conversation!', 
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const Divider(indent: 72, endIndent: 16),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return _buildCommentNode(comment);
          },
        );
      },
    );
  }

  Widget _buildCommentNode(Comment comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 50.0 : 12.0, right: 12.0, top: 12.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundImage: NetworkImage(comment.authorProfilePicture),
                onBackgroundImageError: (_, __) => const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          timeago.format(comment.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    if (!isReply)
                      GestureDetector(
                        onTap: () => _setReply(comment.id, comment.authorName),
                        child: const Text('Reply', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty)
            ...comment.replies.map((reply) => _buildCommentNode(reply, isReply: true)),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyingToAuthorName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Replying to $_replyingToAuthorName', style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                GestureDetector(
                  onTap: _cancelReply,
                  child: const Icon(Icons.close, size: 16, color: Colors.black54),
                )
              ],
            ),
          ),
        Container(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 8, 
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
                  controller: _commentController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _onAddComment,
                icon: const Icon(Icons.send, color: Color(0xFFC5A358)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
