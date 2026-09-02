import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/post_usecases.dart';

enum PostState { initial, loading, loaded, error }

class PostViewModel extends ChangeNotifier {
  final GetFeedUseCase getFeedUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final AddCommentUseCase addCommentUseCase;
  final GetPostCommentsUseCase getPostCommentsUseCase;
  final DeletePostUseCase deletePostUseCase;
  final UpdatePostUseCase updatePostUseCase;

  PostViewModel({
    required this.getFeedUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
    required this.addCommentUseCase,
    required this.getPostCommentsUseCase,
    required this.deletePostUseCase,
    required this.updatePostUseCase,
  });

  PostState _state = PostState.initial;
  PostState get state => _state;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  final Map<String, List<Comment>> _postComments = {};
  List<Comment> getComments(String postId) => _postComments[postId] ?? [];

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadFeed() async {
    _state = PostState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getFeedUseCase();
    result.fold(
      (failure) {
        _state = PostState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (postsList) {
        _posts = List<Post>.from(postsList);
        _state = PostState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    // Save backup for graceful rollback
    final originalPost = _posts[index];
    final isLiked = originalPost.isLikedByMe;

    final newList = List<Post>.from(_posts);
    newList[index] = Post(
      id: originalPost.id,
      authorId: originalPost.authorId,
      authorName: originalPost.authorName,
      authorProfilePicture: originalPost.authorProfilePicture,
      content: originalPost.content,
      imageUrl: originalPost.imageUrl,
      locationId: originalPost.locationId,
      locationName: originalPost.locationName,
      createdAt: originalPost.createdAt,
      likesCount: isLiked ? originalPost.likesCount - 1 : originalPost.likesCount + 1,
      commentsCount: originalPost.commentsCount,
      isLikedByMe: !isLiked,
      recommendedTripId: originalPost.recommendedTripId,
      recommendedTripTitle: originalPost.recommendedTripTitle,
    );
    _posts = newList;
    notifyListeners();

    final result = await toggleLikeUseCase(postId);
    result.fold(
      (failure) {
        // Rollback gracefully on failure
        final currentIndex = _posts.indexWhere((p) => p.id == postId);
        if (currentIndex != -1) {
          final revertedList = List<Post>.from(_posts);
          revertedList[currentIndex] = originalPost;
          _posts = revertedList;
        }
        _errorMessage = failure.message;
        debugPrint('Like POST error (DioException handled): ${failure.message}');
        notifyListeners();
      },
      (_) => null,
    );
  }

  Future<void> loadComments(String postId) async {
    final result = await getPostCommentsUseCase(postId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (comments) {
        comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _postComments[postId] = comments;
        notifyListeners();
      },
    );
  }

  Future<void> addComment(String postId, String content, {String? parentCommentId}) async {
    final result = await addCommentUseCase(postId, content, parentCommentId: parentCommentId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (comment) {
        if (!_postComments.containsKey(postId)) {
          _postComments[postId] = [];
        }

        if (parentCommentId != null) {
          // Find the parent comment and add the reply
          final index = _postComments[postId]!.indexWhere((c) => c.id == parentCommentId);
          if (index != -1) {
            final parent = _postComments[postId]![index];
            final updatedReplies = List<Comment>.from(parent.replies)..insert(0, comment);
            _postComments[postId]![index] = Comment(
              id: parent.id,
              postId: parent.postId,
              authorId: parent.authorId,
              authorName: parent.authorName,
              authorProfilePicture: parent.authorProfilePicture,
              content: parent.content,
              createdAt: parent.createdAt,
              parentCommentId: parent.parentCommentId,
              replies: updatedReplies,
            );
          }
        } else {
          _postComments[postId]!.insert(0, comment);
        }
        
        // Update comment count in post list
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          final newList = List<Post>.from(_posts);
          newList[index] = Post(
            id: post.id,
            authorId: post.authorId,
            authorName: post.authorName,
            authorProfilePicture: post.authorProfilePicture,
            content: post.content,
            imageUrl: post.imageUrl,
            locationId: post.locationId,
            locationName: post.locationName,
            createdAt: post.createdAt,
            likesCount: post.likesCount,
            commentsCount: post.commentsCount + 1,
            isLikedByMe: post.isLikedByMe,
            recommendedTripId: post.recommendedTripId,
            recommendedTripTitle: post.recommendedTripTitle,
          );
          _posts = newList;
        }
        notifyListeners();
      },
    );
  }

  Future<void> createPost(String content, {XFile? imageFile, int? locationId, String? recommendedTripId, String? recommendedTripTitle}) async {
    _state = PostState.loading;
    _errorMessage = null;
    notifyListeners();

    // Note: Assuming createPostUseCase is updated internally or we'll update it next if needed
    final result = await createPostUseCase(content, imageFile: imageFile, locationId: locationId);
    result.fold(
      (failure) {
        _state = PostState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (post) {
        // We manually add the recommended info if the server doesn't return it yet (mocking behavior)
        final finalPost = Post(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorProfilePicture: post.authorProfilePicture,
          content: post.content,
          imageUrl: post.imageUrl,
          locationId: post.locationId,
          locationName: post.locationName,
          createdAt: post.createdAt,
          likesCount: post.likesCount,
          commentsCount: post.commentsCount,
          isLikedByMe: post.isLikedByMe,
          recommendedTripId: recommendedTripId,
          recommendedTripTitle: recommendedTripTitle,
        );
        
        _posts = List<Post>.from(_posts)..insert(0, finalPost);
        _state = PostState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> deletePost(String postId) async {
    final result = await deletePostUseCase(postId);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
      },
    );
  }

  Future<void> updatePost(String postId, String newContent) async {
    final result = await updatePostUseCase(postId, newContent);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          final newList = List<Post>.from(_posts);
          newList[index] = Post(
            id: post.id,
            authorId: post.authorId,
            authorName: post.authorName,
            authorProfilePicture: post.authorProfilePicture,
            content: newContent,
            imageUrl: post.imageUrl,
            locationId: post.locationId,
            locationName: post.locationName,
            createdAt: post.createdAt,
            likesCount: post.likesCount,
            commentsCount: post.commentsCount,
            isLikedByMe: post.isLikedByMe,
            recommendedTripId: post.recommendedTripId,
            recommendedTripTitle: post.recommendedTripTitle,
          );
          _posts = newList;
          notifyListeners();
        }
      },
    );
  }

}
