import 'package:flutter/material.dart';
import '../data/local/trip_mock_data.dart';

/// Local-only trip state management.
/// Bypasses the backend-dependent TripViewModel for frontend-only mode.
class TripLocalProvider with ChangeNotifier {
  List<LocalTrip> _trips = List.from(seedTrips);

  List<LocalTrip> get trips => _trips;

  LocalTrip? getTripById(String id) {
    final index = _trips.indexWhere((t) => t.id == id);
    return index == -1 ? null : _trips[index];
  }

  void addTrip(LocalTrip trip) {
    _trips.insert(0, trip);
    notifyListeners();
  }

  void removeTrip(String tripId) {
    _trips.removeWhere((t) => t.id == tripId);
    notifyListeners();
  }

  void addStopToDay(String tripId, int dayNumber, TripStop stop) {
    final tripIndex = _trips.indexWhere((t) => t.id == tripId);
    if (tripIndex == -1) return;

    final trip = _trips[tripIndex];
    final dayIndex = trip.days.indexWhere((d) => d.dayNumber == dayNumber);
    if (dayIndex == -1) return;

    final day = trip.days[dayIndex];
    final updatedStops = List<TripStop>.from(day.stops)..add(stop);
    final updatedDay = day.copyWith(stops: updatedStops);

    final updatedDays = List<TripDay>.from(trip.days);
    updatedDays[dayIndex] = updatedDay;

    _trips[tripIndex] = trip.copyWith(days: updatedDays);
    notifyListeners();
  }

  void removeStop(String tripId, int dayNumber, int stopIndex) {
    final tripIndex = _trips.indexWhere((t) => t.id == tripId);
    if (tripIndex == -1) return;

    final trip = _trips[tripIndex];
    final dayIndex = trip.days.indexWhere((d) => d.dayNumber == dayNumber);
    if (dayIndex == -1) return;

    final day = trip.days[dayIndex];
    final updatedStops = List<TripStop>.from(day.stops)..removeAt(stopIndex);
    final updatedDay = day.copyWith(stops: updatedStops);

    final updatedDays = List<TripDay>.from(trip.days);
    updatedDays[dayIndex] = updatedDay;

    _trips[tripIndex] = trip.copyWith(days: updatedDays);
    notifyListeners();
  }

  void toggleStopCompleted(String tripId, int dayNumber, int stopIndex) {
    final tripIndex = _trips.indexWhere((t) => t.id == tripId);
    if (tripIndex == -1) return;

    final trip = _trips[tripIndex];
    final dayIndex = trip.days.indexWhere((d) => d.dayNumber == dayNumber);
    if (dayIndex == -1) return;

    final day = trip.days[dayIndex];
    final stop = day.stops[stopIndex];
    final updatedStop = stop.copyWith(isCompleted: !stop.isCompleted);

    final updatedStops = List<TripStop>.from(day.stops);
    updatedStops[stopIndex] = updatedStop;

    final updatedDay = day.copyWith(stops: updatedStops);
    final updatedDays = List<TripDay>.from(trip.days);
    updatedDays[dayIndex] = updatedDay;

    _trips[tripIndex] = trip.copyWith(days: updatedDays);
    notifyListeners();
  }

}
