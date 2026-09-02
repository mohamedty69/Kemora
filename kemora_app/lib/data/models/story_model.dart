class StoryModel {
  final int id;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String authorId;
  final String authorName;
  final String? authorProfilePicture;
  final int? locationId;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  StoryModel({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
    required this.authorId,
    required this.authorName,
    this.authorProfilePicture,
    this.locationId,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['storyID'] as int,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
      createdAt: DateTime.parse(json['createdAt'].toString().endsWith('Z') ? json['createdAt'] : '${json['createdAt']}Z').toLocal(),
      expiresAt: DateTime.parse(json['expiresAt'].toString().endsWith('Z') ? json['expiresAt'] : '${json['expiresAt']}Z').toLocal(),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorProfilePicture: json['authorProfilePicture'] as String?,
      locationId: json['locationId'] as int?,
      locationName: json['locationName'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}

class UserStoriesGroup {
  final String userId;
  final String userName;
  final String? userProfilePicture;
  final List<StoryModel> stories;

  UserStoriesGroup({
    required this.userId,
    required this.userName,
    this.userProfilePicture,
    required this.stories,
  });

  factory UserStoriesGroup.fromJson(Map<String, dynamic> json) {
    return UserStoriesGroup(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfilePicture: json['userProfilePicture'] as String?,
      stories: (json['stories'] as List<dynamic>)
          .map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
