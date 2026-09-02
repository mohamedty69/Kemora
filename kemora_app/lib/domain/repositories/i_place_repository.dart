import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/place.dart';

abstract class IPlaceRepository {
  Future<Either<Failure, List<Place>>> getPlaces({String? search, String? governorateId, String? categoryName});
  Future<Either<Failure, List<Place>>> getPlacesByCategory(String category);
  Future<Either<Failure, List<Place>>> getTopPlaces();
  Future<Either<Failure, List<Governorate>>> getGovernorates();
  Future<Either<Failure, List<Place>>> getPlacesByGovernorate(String governorateId, {int page = 1, int pageSize = 10});
  Future<Either<Failure, Place>> getPlaceDetails(String id);
  Future<Either<Failure, List<Place>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(String placeId);
  Future<Either<Failure, void>> removeFavorite(String placeId);
}
