import '../../domain/entities/post.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.authorId,
    required super.authorName,
    required super.authorProfilePicture,
    required super.content,
    required super.createdAt,
    super.parentCommentId,
    super.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, String postId) {
    return CommentModel(
      id: json['commentID']?.toString() ?? '',
      postId: postId,
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName'] as String? ?? 'Unknown User',
      authorProfilePicture: json['authorProfilePicture'] as String? ?? 'https://picsum.photos/150',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString().endsWith('Z') ? json['createdAt'] : '${json['createdAt']}Z').toLocal() : DateTime.now(),
      parentCommentId: json['parentCommentId']?.toString(),
      replies: json['replies'] != null 
          ? (json['replies'] as List).map((r) => CommentModel.fromJson(r, postId)).toList() 
          : [],
    );
  }
}

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.authorProfilePicture,
    required super.content,
    super.imageUrl,
    super.locationId,
    super.locationName,
    required super.createdAt,
    super.likesCount,
    super.commentsCount,
    super.isLikedByMe,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Media handling: assuming one image for simplicity in the basic model
    String? imageUrl;
    if (json['media'] != null && (json['media'] as List).isNotEmpty) {
      final firstMedia = json['media'][0];
      imageUrl = firstMedia['mediaURL'] ?? firstMedia['mediaUrl'] ?? firstMedia['MediaURL'];
    }

    return PostModel(
      id: json['postID']?.toString() ?? '',
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName'] as String? ?? 'Unknown Author',
      authorProfilePicture: json['authorProfilePicture'] as String? ?? 'https://picsum.photos/150',
      content: json['content'] as String? ?? '',
      imageUrl: imageUrl,
      locationId: json['linkedTripId']?.toString(), // Example mapping
      locationName: null, // Would need more backend data for this
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString().endsWith('Z') ? json['createdAt'] : '${json['createdAt']}Z').toLocal() : DateTime.now(),
      likesCount: json['reactionCount'] as int? ?? 0,
      commentsCount: json['commentCount'] as int? ?? 0,
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    );
  }
}
