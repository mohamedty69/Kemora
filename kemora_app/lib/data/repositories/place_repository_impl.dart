import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/i_place_repository.dart';
import '../datasources/places_remote_data_source.dart';

class PlaceRepositoryImpl implements IPlaceRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlaceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Place>>> getPlaces({String? search, String? governorateId, String? categoryName}) async {
    try {
      final places = await remoteDataSource.getPlaces(search: search, governorateId: governorateId, categoryName: categoryName);
      return Right(places);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getPlacesByCategory(String category) async {
    try {
      final places = await remoteDataSource.getPlacesByCategory(category);
      return Right(places);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getTopPlaces() async {
    try {
      final places = await remoteDataSource.getTopPlaces();
      return Right(places);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Governorate>>> getGovernorates() async {
    try {
      final governorates = await remoteDataSource.getGovernorates();
      return Right(governorates);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getPlacesByGovernorate(String governorateId, {int page = 1, int pageSize = 10}) async {
    try {
      final places = await remoteDataSource.getPlacesByGovernorate(governorateId, page: page, pageSize: pageSize);
      return Right(places);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Place>> getPlaceDetails(String id) async {
    try {
      final place = await remoteDataSource.getPlaceDetails(id);
      return Right(place);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> getFavorites() async {
    try {
      final places = await remoteDataSource.getFavorites();
      return Right(places);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String placeId) async {
    try {
      await remoteDataSource.addFavorite(placeId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String placeId) async {
    try {
      await remoteDataSource.removeFavorite(placeId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
