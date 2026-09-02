import 'package:flutter/material.dart';
import '../data/local/community_data.dart';

/// Central state management for all community data.
/// Shared between Home tab (stories) and Community tab (posts + stories).
class CommunityProvider with ChangeNotifier {
  List<CommunityStory> _stories = List.from(seedStories);
  List<CommunityPost> _posts = List.from(seedPosts);

  List<CommunityStory> get stories => _stories;
  List<CommunityPost> get posts => _posts;

  // ── Stories ───────────────────────────────────────────────────────

  void addStory(CommunityStory story) {
    _stories.insert(0, story);
    notifyListeners();
  }

  void removeStory(String storyId) {
    _stories.removeWhere((s) => s.id == storyId);
    notifyListeners();
  }

  // ── Posts ──────────────────────────────────────────────────────────

  void addPost(CommunityPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void removePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    _posts[index] = post.copyWith(
      isLikedByMe: !post.isLikedByMe,
      likes: post.isLikedByMe ? post.likes - 1 : post.likes + 1,
    );
    notifyListeners();
  }

  // ── Comments ──────────────────────────────────────────────────────

  void addComment(String postId, String userName, String content) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final newComment = CommunityComment(
      id: 'cc_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
    );

    _posts[index] = post.copyWith(
      comments: [newComment, ...post.comments],
    );
    notifyListeners();
  }

  List<CommunityComment> getComments(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return [];
    return _posts[index].comments;
  }
}
