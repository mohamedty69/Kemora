/// Shared community data models used by both Home and Community tabs.
/// This will be replaced by backend API calls in the future.

class CommunityStory {
  final String id;
  final String userName;
  final String userAvatar; // asset path or first letter
  final String imageAsset;
  final String? caption;
  final String location;
  final DateTime createdAt;

  const CommunityStory({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.imageAsset,
    this.caption,
    required this.location,
    required this.createdAt,
  });

  CommunityStory copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    String? imageAsset,
    String? caption,
    String? location,
    DateTime? createdAt,
  }) {
    return CommunityStory(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      imageAsset: imageAsset ?? this.imageAsset,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommunityComment {
  final String id;
  final String postId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatar; // asset path
  final String location;
  final String content;
  final String hashtags;
  final String? imageAsset;
  final int likes;
  final bool isLikedByMe;
  final List<CommunityComment> comments;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.location,
    required this.content,
    required this.hashtags,
    this.imageAsset,
    required this.likes,
    this.isLikedByMe = false,
    this.comments = const [],
    required this.createdAt,
  });

  CommunityPost copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? location,
    String? content,
    String? hashtags,
    String? imageAsset,
    int? likes,
    bool? isLikedByMe,
    List<CommunityComment>? comments,
    DateTime? createdAt,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      location: location ?? this.location,
      content: content ?? this.content,
      hashtags: hashtags ?? this.hashtags,
      imageAsset: imageAsset ?? this.imageAsset,
      likes: likes ?? this.likes,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ── Seed Data ──────────────────────────────────────────────────────

final List<CommunityStory> seedStories = [
  CommunityStory(
    id: 's1',
    userName: 'Layla',
    userAvatar: 'L',
    imageAsset: 'assets/images/mocked/CommunityStory.jpg',
    caption: 'Luxor Temple at sunset 🌅',
    location: 'Luxor',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  CommunityStory(
    id: 's2',
    userName: 'Omar',
    userAvatar: 'O',
    imageAsset: 'assets/images/mocked/CairoTower.jpg',
    caption: 'Cairo skyline from the Tower',
    location: 'Cairo',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  CommunityStory(
    id: 's3',
    userName: 'Sara',
    userAvatar: 'S',
    imageAsset: 'assets/images/mocked/ThePyramids.png',
    caption: 'The view that never gets old',
    location: 'Giza',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  CommunityStory(
    id: 's4',
    userName: 'Ahmed',
    userAvatar: 'A',
    imageAsset: 'assets/images/mocked/CommunityPost.jpg',
    caption: 'Desert magic ✨',
    location: 'Siwa',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
];

final List<CommunityPost> seedPosts = [
  CommunityPost(
    id: 'cp1',
    authorName: 'Amira Zaki',
    authorAvatar: 'assets/images/mocked/ProfilePhoto.jpg',
    location: 'Pyramids of Giza',
    content:
        'Finally caught the sunrise at the Great Sphinx. Pro tip: Arrive at 7 AM to beat the crowd and get that perfect editorial glow. ✨',
    hashtags: '#EgyptTravel #Giza',
    imageAsset: 'assets/images/mocked/ThePyramids.png',
    likes: 1205,
    comments: [
      CommunityComment(
        id: 'cc1',
        postId: 'cp1',
        userName: 'Omar K.',
        content: 'Stunning shot! What camera did you use?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommunityComment(
        id: 'cc2',
        postId: 'cp1',
        userName: 'Sara M.',
        content: 'Adding this to my bucket list! 😍',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  CommunityPost(
    id: 'cp2',
    authorName: 'Omar K.',
    authorAvatar: 'assets/images/mocked/ProfilePhoto.jpg',
    location: 'Cairo Tower',
    content:
        'The view from Cairo Tower at night is absolutely breathtaking. The city lights stretch endlessly.',
    hashtags: '#CairoNights #CityView',
    imageAsset: 'assets/images/mocked/CairoTower.jpg',
    likes: 842,
    comments: [
      CommunityComment(
        id: 'cc3',
        postId: 'cp2',
        userName: 'Layla',
        content: 'I need to visit again! Last time I went it was cloudy.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  CommunityPost(
    id: 'cp3',
    authorName: 'Sara M.',
    authorAvatar: 'assets/images/mocked/ProfilePhoto.jpg',
    location: 'Siwa Oasis',
    content:
        'Lost in the desert and loving every second. Siwa feels like stepping into another world entirely.',
    hashtags: '#DesertVibes #SiwaOasis',
    imageAsset: 'assets/images/mocked/CommunityPost.jpg',
    likes: 2341,
    comments: [],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
