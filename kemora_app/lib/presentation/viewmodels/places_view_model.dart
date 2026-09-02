import 'package:flutter/material.dart';
import '../../domain/entities/place.dart';
import '../../domain/usecases/explore_usecases.dart';
import '../../domain/usecases/get_places_usecase.dart';
import '../../domain/usecases/get_places_by_category_usecase.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';
import '../../domain/usecases/get_place_details_usecase.dart';
import '../../core/services/weather_service.dart';

class ActivityInfo {
  final IconData icon;
  final String label;

  const ActivityInfo({required this.icon, required this.label});
}

enum PlacesState { initial, loading, loaded, error }

class PlacesViewModel extends ChangeNotifier {
  final GetPlacesUseCase getPlacesUseCase;
  final GetPlacesByCategoryUseCase getPlacesByCategoryUseCase;
  final GetTopPlacesUseCase getTopPlacesUseCase;
  final GetGovernoratesUseCase getGovernoratesUseCase;
  final GetPlacesByGovernorateUseCase getPlacesByGovernorateUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final GetPlaceDetailsUseCase getPlaceDetailsUseCase;
  
  final WeatherService _weatherService = WeatherService();

  PlacesViewModel({
    required this.getPlacesUseCase,
    required this.getPlacesByCategoryUseCase,
    required this.getTopPlacesUseCase,
    required this.getGovernoratesUseCase,
    required this.getPlacesByGovernorateUseCase,
    required this.getFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.getPlaceDetailsUseCase,
  });

  PlacesState _state = PlacesState.initial;
  PlacesState get state => _state;

  List<Place> _places = [];
  List<Place> get places => _places;

  List<Place> _topPlaces = [];
  List<Place> get topPlaces => _topPlaces;

  List<Governorate> _governorates = [];
  List<Governorate> get governorates => _governorates;

  final Map<String, Map<String, String>> _governorateWeather = {};

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentCategory = 'All';
  String get currentCategory => _currentCategory;

  int _currentGovernoratePage = 1;
  bool _hasMoreGovernoratePlaces = true;
  bool _isLoadingMoreGovernoratePlaces = false;

  bool get hasMoreGovernoratePlaces => _hasMoreGovernoratePlaces;
  bool get isLoadingMoreGovernoratePlaces => _isLoadingMoreGovernoratePlaces;

  String getGovernorateTemperature(String id) => _governorateWeather[id]?['temperature'] ?? '--°C';
  String getGovernorateWeatherCode(String id) => _governorateWeather[id]?['weather'] ?? 'Loading...';

  List<ActivityInfo> getGovernorateActivities(String id) {
    // Generate dummy activities based on available places, or fallback to default
    final places = _places; // We assume places are loaded for this governorate
    if (places.isEmpty) {
      return const [
        ActivityInfo(icon: Icons.account_balance, label: 'History'),
        ActivityInfo(icon: Icons.museum, label: 'Museums'),
        ActivityInfo(icon: Icons.restaurant, label: 'Dining'),
        ActivityInfo(icon: Icons.explore, label: 'Adventure'),
      ];
    }
    
    final types = places.map((p) => p.type).where((t) => t != null).toSet();
    final activities = <ActivityInfo>[];
    
    if (types.contains('temple') || types.contains('pyramid')) activities.add(const ActivityInfo(icon: Icons.account_balance, label: 'Ancient'));
    if (types.contains('museum')) activities.add(const ActivityInfo(icon: Icons.museum, label: 'Museums'));
    if (types.contains('restaurant')) activities.add(const ActivityInfo(icon: Icons.restaurant, label: 'Dining'));
    if (types.contains('beach_resort') || types.contains('hotel')) activities.add(const ActivityInfo(icon: Icons.hotel, label: 'Relax'));
    if (types.contains('diving_spot') || types.contains('safari')) activities.add(const ActivityInfo(icon: Icons.explore, label: 'Adventure'));
    if (types.contains('mosque') || types.contains('church')) activities.add(const ActivityInfo(icon: Icons.church, label: 'Religious'));

    if (activities.isEmpty) {
      activities.add(const ActivityInfo(icon: Icons.explore, label: 'Explore'));
    }
    
    return activities;
  }

  Future<void> loadPlaces({String category = 'All', String? search, String? governorateId}) async {
    _state = PlacesState.loading;
    _currentCategory = category;
    _errorMessage = null;
    notifyListeners();

    // When scoped to a governorate, send both the governorateId and the category
    // to the backend (GET /api/v1/places) so it returns places in that governorate
    // for that category, hydrating from Google on demand if the DB is empty.
    final result = category == 'All'
        ? await getPlacesUseCase(search: search, governorateId: governorateId)
        : (governorateId != null
            ? await getPlacesUseCase(search: search, governorateId: governorateId, categoryName: category)
            : await getPlacesByCategoryUseCase(category));

    result.fold(
      (failure) {
        _state = PlacesState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (placesList) {
        _places = placesList;
        _state = PlacesState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> loadTopPlaces() async {
    final result = await getTopPlacesUseCase();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) => _topPlaces = list,
    );
    notifyListeners();
  }

  Future<void> loadGovernorates() async {
    final result = await getGovernoratesUseCase();
    result.fold(
      (failure) => _errorMessage = failure.message,
      (list) {
        // Filter out governorates that use Wikipedia fallback images
        _governorates = list.where((g) => g.imageUrl == null || !g.imageUrl!.contains('wikipedia.org')).toList();
        // Prefetch weather for all governorates silently
        for (var gov in _governorates) {
          _fetchWeatherForGovernorate(gov);
        }
      },
    );
    notifyListeners();
  }

  Future<void> _fetchWeatherForGovernorate(Governorate gov) async {
    if (_governorateWeather.containsKey(gov.id)) return;
    if (gov.latitude == 0 && gov.longitude == 0) return;
    
    final weather = await _weatherService.getCurrentWeather(gov.latitude, gov.longitude);
    _governorateWeather[gov.id] = weather;
    notifyListeners();
  }

  Future<void> loadPlacesByGovernorate(String governorateId, {bool isLoadMore = false}) async {
    if (!isLoadMore) {
      _currentGovernoratePage = 1;
      _hasMoreGovernoratePlaces = true;
      _state = PlacesState.loading;
      notifyListeners();
    } else {
      if (!_hasMoreGovernoratePlaces || _isLoadingMoreGovernoratePlaces) return;
      _isLoadingMoreGovernoratePlaces = true;
      notifyListeners();
    }
    
    final result = await getPlacesByGovernorateUseCase(governorateId, page: _currentGovernoratePage, pageSize: 10);
    result.fold(
      (failure) {
        if (!isLoadMore) {
          _state = PlacesState.error;
          _errorMessage = failure.message;
        }
        _isLoadingMoreGovernoratePlaces = false;
        notifyListeners();
      },
      (list) {
        if (list.length < 10) {
          _hasMoreGovernoratePlaces = false;
        }
        if (!isLoadMore) {
          _places = list;
          _state = PlacesState.loaded;
        } else {
          _places.addAll(list);
        }
        _currentGovernoratePage++;
        _isLoadingMoreGovernoratePlaces = false;
        notifyListeners();
      },
    );
  }

  List<Place> _favorites = [];
  List<Place> get favorites => _favorites;

  Future<void> loadFavorites() async {
    _state = PlacesState.loading;
    notifyListeners();
    
    final result = await getFavoritesUseCase();
    result.fold(
      (failure) {
        _state = PlacesState.error;
        _errorMessage = failure.message;
      },
      (list) {
        _favorites = list;
        _state = PlacesState.loaded;
      },
    );
    notifyListeners();
  }

  bool isFavorite(String placeId) {
    return _favorites.any((p) => p.id == placeId);
  }

  Future<void> toggleFavorite(Place place) async {
    final currentlyFavorite = isFavorite(place.id);
    if (currentlyFavorite) {
      // Optimistic update
      _favorites.removeWhere((p) => p.id == place.id);
      notifyListeners();
      
      final result = await removeFavoriteUseCase(place.id);
      result.fold(
        (failure) {
          // Revert on failure
          _favorites.add(place);
          _errorMessage = failure.message;
          notifyListeners();
        },
        (_) {},
      );
    } else {
      // Optimistic update
      _favorites.add(place);
      notifyListeners();

      final result = await addFavoriteUseCase(place.id);
      result.fold(
        (failure) {
          // Revert on failure
          _favorites.removeWhere((p) => p.id == place.id);
          _errorMessage = failure.message;
          notifyListeners();
        },
        (_) {},
      );
    }
  }

  /// Fetches place details from the API to ensure full details (like reviews) are loaded.
  Future<Place?> getPlaceById(String id) async {
    final result = await getPlaceDetailsUseCase(id);
    return result.fold(
      (failure) {
        // Fallback to cache if API fails
        try {
          return _topPlaces.firstWhere((p) => p.id == id);
        } catch (_) {}
        try {
          return _places.firstWhere((p) => p.id == id);
        } catch (_) {}
        return null;
      },
      (place) => place,
    );
  }

  /// Helper to get governorate ID by name
  String? governorateIdByName(String name) {
    try {
      return _governorates.firstWhere((g) => g.name.toLowerCase() == name.toLowerCase()).id;
    } catch (_) {
      return null;
    }
  }
}
