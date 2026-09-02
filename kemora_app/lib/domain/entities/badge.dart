import 'package:equatable/equatable.dart';

class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String criteria;
  final int pointsReward;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.criteria,
    required this.pointsReward,
  });

  @override
  List<Object?> get props => [id, name, description, iconUrl, criteria, pointsReward];
}

class UserBadge extends Equatable {
  final String id;
  final String userId;
  final Badge badge;
  final DateTime earnedAt;

  const UserBadge({
    required this.id,
    required this.userId,
    required this.badge,
    required this.earnedAt,
  });

  @override
  List<Object?> get props => [id, userId, badge, earnedAt];
}
