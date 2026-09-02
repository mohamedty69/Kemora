import 'package:equatable/equatable.dart';

class TripPlanRequest extends Equatable {
  final double latitude;
  final double longitude;
  final double minRadiusKm;
  final double maxRadiusKm;
  final int durationDays;
  final String? budget;
  final String? location;
  final String? preferences;
  final int? centerPlaceId;
  final int alternativeIndex;
  final List<String>? tourismTypes;

  const TripPlanRequest({
    required this.latitude,
    required this.longitude,
    this.minRadiusKm = 0,
    this.maxRadiusKm = 5,
    this.durationDays = 3,
    this.budget,
    this.location,
    this.preferences,
    this.centerPlaceId,
    this.alternativeIndex = 1,
    this.tourismTypes,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'minRadiusKm': minRadiusKm,
      'maxRadiusKm': maxRadiusKm,
      'durationDays': durationDays,
      'budget': budget,
      'location': location,
      'preferences': preferences,
      'centerPlaceId': centerPlaceId,
      'alternativeIndex': alternativeIndex,
      'tourismTypes': tourismTypes,
    };
  }

  TripPlanRequest copyWith({
    double? latitude,
    double? longitude,
    double? minRadiusKm,
    double? maxRadiusKm,
    int? durationDays,
    String? budget,
    String? location,
    String? preferences,
    int? centerPlaceId,
    int? alternativeIndex,
    List<String>? tourismTypes,
  }) {
    return TripPlanRequest(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      minRadiusKm: minRadiusKm ?? this.minRadiusKm,
      maxRadiusKm: maxRadiusKm ?? this.maxRadiusKm,
      durationDays: durationDays ?? this.durationDays,
      budget: budget ?? this.budget,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      centerPlaceId: centerPlaceId ?? this.centerPlaceId,
      alternativeIndex: alternativeIndex ?? this.alternativeIndex,
      tourismTypes: tourismTypes ?? this.tourismTypes,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        minRadiusKm,
        maxRadiusKm,
        durationDays,
        budget,
        location,
        preferences,
        centerPlaceId,
        alternativeIndex,
        tourismTypes,
      ];
}
