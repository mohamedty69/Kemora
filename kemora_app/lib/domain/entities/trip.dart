import 'package:equatable/equatable.dart';
import 'place.dart';
import 'ai_itinerary.dart';

class Trip extends Equatable {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<Place> plannedPlaces;
  final AIItinerary? savedItinerary;
  final String location;

  const Trip({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.plannedPlaces = const [],
    this.savedItinerary,
    this.location = 'Egypt',
  });

  @override
  List<Object?> get props => [id, title, startDate, endDate, plannedPlaces, savedItinerary, location];
}
