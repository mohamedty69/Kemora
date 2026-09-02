import '../../domain/entities/badge.dart';

class BadgeModel extends Badge {
  const BadgeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.criteria,
    required super.pointsReward,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['badgeID']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Badge',
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? 'https://via.placeholder.com/150',
      criteria: json['criteria'] as String? ?? '',
      pointsReward: json['pointsReward'] as int? ?? 0,
    );
  }
}

class UserBadgeModel extends UserBadge {
  const UserBadgeModel({
    required super.id,
    required super.userId,
    required super.badge,
    required super.earnedAt,
  });

  // [KEMORA-MIGRATION] Backend UserBadgeResponseDto is flat — no nested 'badge' object.
  // Fields: badgeID, badgeName, badgeDescription, iconUrl, criteria, pointsReward, earnedAt
  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    // Build the nested BadgeModel from the flat fields at root level
    final badge = BadgeModel(
      id: json['badgeID']?.toString() ?? '',
      name: json['badgeName'] as String? ?? json['name'] as String? ?? 'Unknown Badge',
      description: json['badgeDescription'] as String? ?? json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String? ?? 'https://via.placeholder.com/150',
      criteria: json['criteria'] as String? ?? '',
      pointsReward: json['pointsReward'] as int? ?? 0,
    );
    return UserBadgeModel(
      id: json['badgeID']?.toString() ?? '',
      userId: '',  // Not returned by backend in this DTO
      badge: badge,
      earnedAt: json['earnedAt'] != null ? DateTime.parse(json['earnedAt'].toString()) : DateTime.now(),
    );
  }
}
