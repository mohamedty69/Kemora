import 'package:equatable/equatable.dart';
import './user_preferences.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? profilePictureUrl;
  final String? country;
  final String? bio;
  final String? token;
  final String? refreshToken;
  final int earnedBadgesCount;
  final UserPreferences? preferences;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.profilePictureUrl,
    this.country,
    this.bio,
    this.token,
    this.refreshToken,
    this.earnedBadgesCount = 0,
    this.preferences,
  });

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profilePictureUrl,
    String? country,
    String? bio,
    String? token,
    String? refreshToken,
    int? earnedBadgesCount,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      earnedBadgesCount: earnedBadgesCount ?? this.earnedBadgesCount,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        profilePictureUrl,
        country,
        bio,
        token,
        refreshToken,
        earnedBadgesCount,
        preferences,
      ];
}

