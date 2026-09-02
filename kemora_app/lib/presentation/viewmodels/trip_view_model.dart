import 'package:flutter/material.dart';

import '../../domain/entities/trip.dart';
import '../../domain/usecases/trip_usecases.dart';
import '../../domain/usecases/generate_ai_itinerary_usecase.dart';
import '../../domain/usecases/swap_place_usecase.dart';
import '../../domain/usecases/save_ai_plan_usecase.dart';
import '../../domain/usecases/update_place_visited_status_usecase.dart';
import '../../domain/entities/ai_itinerary.dart';
import '../../domain/entities/trip_plan_request.dart';

enum TripState { initial, loading, loaded, error }

class TripViewModel extends ChangeNotifier {
  final GetUserTripsUseCase getUserTripsUseCase;
  final CreateTripPlanUseCase createTripPlanUseCase;
  final GenerateAiItineraryUseCase generateAiItineraryUseCase;
  final SwapPlaceUseCase swapPlaceUseCase;
  final SaveAiPlanUseCase saveAiPlanUseCase;
  final UpdatePlaceVisitedStatusUseCase updatePlaceVisitedStatusUseCase;
  final GetTripDetailsUseCase getTripDetailsUseCase;
  final DeleteTripUseCase deleteTripUseCase;
  final RenameTripUseCase renameTripUseCase;

  TripViewModel({
    required this.getUserTripsUseCase,
    required this.createTripPlanUseCase,
    required this.generateAiItineraryUseCase,
    required this.swapPlaceUseCase,
    required this.saveAiPlanUseCase,
    required this.updatePlaceVisitedStatusUseCase,
    required this.getTripDetailsUseCase,
    required this.deleteTripUseCase,
    required this.renameTripUseCase,
  });

  TripState _state = TripState.initial;
  TripState get state => _state;

  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  AIItinerary? _currentPlan;
  AIItinerary? get currentPlan => _currentPlan;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setCurrentPlan(AIItinerary? plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  Future<void> loadTrips() async {
    _state = TripState.loading;
    _errorMessage = null;
    notifyListeners();

    print('=== LOAD_TRIPS: Calling getUserTripsUseCase ===');
    final result = await getUserTripsUseCase();

    result.fold(
      (failure) {
        print('=== LOAD_TRIPS ERROR: ${failure.message} ===');
        _state = TripState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (tripsList) {
        print('=== LOAD_TRIPS SUCCESS: Got ${tripsList.length} trips ===');
        for (final t in tripsList) {
          print('  Trip: id="${t.id}" title="${t.title}"');
        }
        _trips = tripsList;
        _state = TripState.loaded;
        notifyListeners();
      },
    );
  }

  Future<Trip?> loadTripDetails(String id) async {
    final result = await getTripDetailsUseCase(id);
    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return null;
      },
      (trip) {
        final index = _trips.indexWhere((t) => t.id == id);
        if (index != -1) {
          _trips[index] = trip;
          notifyListeners();
        }
        return trip;
      },
    );
  }

  Future<bool> deleteTrip(String id) async {
    print('=== VM.deleteTrip: id="$id" ===');
    final result = await deleteTripUseCase(id);
    return result.fold(
      (failure) {
        print('=== VM.deleteTrip ERROR: ${failure.message} ===');
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        print('=== VM.deleteTrip SUCCESS ===');
        _trips.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> renameTrip(String id, String newName) async {
    print('=== VM.renameTrip: id="$id" newName="$newName" ===');
    final result = await renameTripUseCase(id, newName);
    return result.fold(
      (failure) {
        print('=== VM.renameTrip ERROR: ${failure.message} ===');
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        print('=== VM.renameTrip SUCCESS ===');
        final index = _trips.indexWhere((t) => t.id == id);
        if (index != -1) {
          final oldTrip = _trips[index];
          _trips[index] = Trip(
            id: oldTrip.id,
            title: newName,
            startDate: oldTrip.startDate,
            endDate: oldTrip.endDate,
            plannedPlaces: oldTrip.plannedPlaces,
            savedItinerary: oldTrip.savedItinerary,
            location: oldTrip.location,
          );
          notifyListeners();
        }
        return true;
      },
    );
  }

  Future<void> generateAiItinerary(TripPlanRequest request) async {
    _state = TripState.loading;
    _errorMessage = null;
    _currentPlan = null;
    notifyListeners();

    final result = await generateAiItineraryUseCase(request);

    result.fold(
      (failure) {
        _state = TripState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (itinerary) {
        final locationTitle = (request.location?.isNotEmpty == true) ? 'Trip to ${request.location}' : 'AI Trip Plan';
        _currentPlan = AIItinerary(
          title: itinerary.title == 'AI Trip Plan' || itinerary.title.isEmpty ? locationTitle : itinerary.title,
          duration: itinerary.duration,
          days: itinerary.days,
        );
        _state = TripState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> swapPlace(String currentPlaceName, String preferences) async {
    if (_currentPlan == null) return;
    
    final result = await swapPlaceUseCase(currentPlaceName, preferences);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (newItem) {
        final updatedDays = _currentPlan!.days.map((day) {
          final updatedActivities = day.activities.map((activity) {
            if (activity.name == currentPlaceName) {
              return newItem;
            }
            return activity;
          }).toList();
          // Forward dailySummary/transportTips — they were being dropped here.
          return TripDay(
            dayNumber: day.dayNumber,
            activities: updatedActivities,
            dailySummary: day.dailySummary,
            transportTips: day.transportTips,
          );
        }).toList();

        _currentPlan = AIItinerary(
          title: _currentPlan!.title,
          duration: _currentPlan!.duration,
          days: updatedDays,
        );
        notifyListeners();
      },
    );
  }

  void removePlace(int dayIndex, int activityIndex) {
    if (_currentPlan == null) return;

    final updatedDays = List<TripDay>.from(_currentPlan!.days);
    if (dayIndex >= 0 && dayIndex < updatedDays.length) {
      final updatedActivities = List<ItineraryItem>.from(updatedDays[dayIndex].activities);
      if (activityIndex >= 0 && activityIndex < updatedActivities.length) {
        updatedActivities.removeAt(activityIndex);
        updatedDays[dayIndex] = TripDay(
          dayNumber: updatedDays[dayIndex].dayNumber,
          activities: updatedActivities,
          dailySummary: updatedDays[dayIndex].dailySummary,
          transportTips: updatedDays[dayIndex].transportTips,
        );

        _currentPlan = AIItinerary(
          title: _currentPlan!.title,
          duration: _currentPlan!.duration,
          days: updatedDays,
        );
        notifyListeners();
      }
    }
  }

  void reorderPlace(int dayIndex, int oldIndex, int newIndex) {
    if (_currentPlan == null) return;

    final updatedDays = List<TripDay>.from(_currentPlan!.days);
    if (dayIndex >= 0 && dayIndex < updatedDays.length) {
      final updatedActivities = List<ItineraryItem>.from(updatedDays[dayIndex].activities);
      if (oldIndex >= 0 && oldIndex < updatedActivities.length) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = updatedActivities.removeAt(oldIndex);
        updatedActivities.insert(newIndex, item);

        updatedDays[dayIndex] = TripDay(
          dayNumber: updatedDays[dayIndex].dayNumber,
          activities: updatedActivities,
          dailySummary: updatedDays[dayIndex].dailySummary,
          transportTips: updatedDays[dayIndex].transportTips,
        );

        _currentPlan = AIItinerary(
          title: _currentPlan!.title,
          duration: _currentPlan!.duration,
          days: updatedDays,
        );
        notifyListeners();
      }
    }
  }

  Future<bool> savePlan(DateTime startDate, DateTime endDate) async {
    if (_currentPlan == null) return false;

    _state = TripState.loading;
    _errorMessage = null;
    notifyListeners();

    print('=== VM.savePlan: title="${_currentPlan!.title}" ===');
    final result = await saveAiPlanUseCase(_currentPlan!, startDate, endDate);

    return result.fold(
      (failure) {
        print('=== VM.savePlan ERROR: ${failure.message} ===');
        _state = TripState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (trip) {
        print('=== VM.savePlan SUCCESS: tripId="${trip.id}" title="${trip.title}" ===');
        _trips.add(trip);
        _state = TripState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> createTrip(
      String title, DateTime start, DateTime end, List<String> places) async {
    _state = TripState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await createTripPlanUseCase(title, start, end, places);

    return result.fold(
      (failure) {
        _state = TripState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (trip) {
        _trips.add(trip);
        _state = TripState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> toggleVisitedStatus(String tripId, int dayIndex, int activityIndex) async {
    if (_currentPlan == null) return;

    final updatedDays = List<TripDay>.from(_currentPlan!.days);
    final day = updatedDays[dayIndex];
    final activities = List<ItineraryItem>.from(day.activities);
    final activity = activities[activityIndex];

    final newVisitedStatus = !activity.isVisited;

    // Optimistic UI update
    activities[activityIndex] = activity.copyWith(isVisited: newVisitedStatus);
    updatedDays[dayIndex] = TripDay(
      dayNumber: day.dayNumber,
      activities: activities,
      dailySummary: day.dailySummary,
      transportTips: day.transportTips,
    );

    _currentPlan = AIItinerary(
      title: _currentPlan!.title,
      duration: _currentPlan!.duration,
      days: updatedDays,
    );
    notifyListeners();

    // Call backend if tripPlaceId is available
    if (activity.tripPlaceId != null) {
      final parsedTripId = int.tryParse(tripId);
      if (parsedTripId != null) {
        await updatePlaceVisitedStatusUseCase(parsedTripId, activity.tripPlaceId!, newVisitedStatus);
        // Note: we don't rollback on error for now to keep it simple, but we could handle it.
      }
    }
  }
}
