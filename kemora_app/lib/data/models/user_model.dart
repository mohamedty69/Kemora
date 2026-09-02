import '../../domain/entities/user.dart';
import '../../domain/entities/user_preferences.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.profilePictureUrl,
    super.country,
    super.bio,
    super.token,
    super.refreshToken,
    super.earnedBadgesCount,
    super.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Backend AuthResponseDto field: userId
      id: json['userId'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      // Backend AuthResponseDto field: fullName
      fullName: json['fullName'] as String? ?? json['username'] as String? ?? '',
      profilePictureUrl: (json['profilePictureUrl'] ?? json['ProfilePictureUrl']) as String?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      earnedBadgesCount: json['earnedBadgesCount'] as int? ?? 0,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'email': email,
      'fullName': fullName,
      'profilePictureUrl': profilePictureUrl,
      'country': country,
      'bio': bio,
      'token': token,
      'refreshToken': refreshToken,
      'earnedBadgesCount': earnedBadgesCount,
      'preferences': preferences?.toJson(),
    };
  }
}
