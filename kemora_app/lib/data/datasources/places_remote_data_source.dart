import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/place_model.dart';

abstract class PlacesRemoteDataSource {
  Future<List<PlaceModel>> getPlaces({String? search, String? governorateId, String? categoryName});
  Future<List<PlaceModel>> getPlacesByCategory(String category);
  Future<List<PlaceModel>> getTopPlaces();
  Future<List<GovernorateModel>> getGovernorates();
  Future<List<PlaceModel>> getPlacesByGovernorate(String governorateId, {int page = 1, int pageSize = 10});
  Future<PlaceModel> getPlaceDetails(String id);
  Future<List<PlaceModel>> getFavorites();
  Future<void> addFavorite(String placeId);
  Future<void> removeFavorite(String placeId);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final Dio dio;

  PlacesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PlaceModel>> getPlaces({String? search, String? governorateId, String? categoryName}) async {
    try {
      // Build query params, combining search/governorate/category as the backend
      // GET /api/v1/places endpoint accepts all three together. When a governorate
      // is provided alongside a category, the backend hydrates that governorate for
      // the requested category on demand.
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (governorateId != null && governorateId.isNotEmpty) queryParams['governorateId'] = governorateId;
      if (categoryName != null && categoryName.isNotEmpty) queryParams['categoryName'] = categoryName;
      final response = await dio.get('/api/v1/places', queryParameters: queryParams.isEmpty ? null : queryParams);
      if (response.statusCode == 200) {
        final data = response.data['items'] ?? response.data;
        if (data is List) {
          return data.map((json) => PlaceModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw const ServerFailure('Failed to load places');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<PlaceModel>> getPlacesByCategory(String category) async {
    try {
      final response = await dio.get('/api/v1/places', queryParameters: {'categoryName': category});
      if (response.statusCode == 200) {
        final data = response.data['items'] ?? response.data;
        if (data is List) {
          return data.map((json) => PlaceModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw const ServerFailure('Failed to load places by category');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<PlaceModel>> getTopPlaces() async {
    try {
      final response = await dio.get('/api/v1/places/top');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to load top places');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<GovernorateModel>> getGovernorates() async {
    try {
      final response = await dio.get('/api/v1/places/governorates');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => GovernorateModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to load governorates');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<PlaceModel>> getPlacesByGovernorate(String governorateId, {int page = 1, int pageSize = 10}) async {
    try {
      final response = await dio.get('/api/v1/places', queryParameters: {'governorateId': governorateId, 'page': page, 'pageSize': pageSize});
      if (response.statusCode == 200) {
        final data = response.data['items'] ?? response.data;
        if (data is List) {
          return data.map((json) => PlaceModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw const ServerFailure('Failed to load places by governorate');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<PlaceModel> getPlaceDetails(String id) async {
    try {
      final response = await dio.get('/api/v1/places/$id');
      if (response.statusCode == 200) {
        return PlaceModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to load place details');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<PlaceModel>> getFavorites() async {
    try {
      final response = await dio.get('/api/v1/favorites');
      if (response.statusCode == 200) {
        final data = response.data['items'] ?? response.data;
        if (data is List) {
          return data.map((json) => PlaceModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw const ServerFailure('Failed to load favorites');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> addFavorite(String placeId) async {
    try {
      final response = await dio.post('/api/v1/favorites/$placeId');
      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to add favorite');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> removeFavorite(String placeId) async {
    try {
      final response = await dio.delete('/api/v1/favorites/$placeId');
      if (response.statusCode != 200) {
        throw const ServerFailure('Failed to remove favorite');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }
}
