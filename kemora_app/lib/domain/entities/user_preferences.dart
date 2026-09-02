import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String budget;
  final String pace;
  final List<String> interests;

  const UserPreferences({
    required this.budget,
    required this.pace,
    required this.interests,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      budget: json['budget'] as String? ?? 'Mid-Range',
      pace: json['pace'] as String? ?? 'Moderate',
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'budget': budget,
      'pace': pace,
      'interests': interests,
    };
  }

  @override
  List<Object?> get props => [budget, pace, interests];
}
