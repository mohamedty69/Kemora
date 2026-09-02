import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/place.dart';
import '../repositories/i_place_repository.dart';

class GetTopPlacesUseCase {
  final IPlaceRepository repository;
  GetTopPlacesUseCase(this.repository);
  Future<Either<Failure, List<Place>>> call() async => await repository.getTopPlaces();
}

class GetGovernoratesUseCase {
  final IPlaceRepository repository;
  GetGovernoratesUseCase(this.repository);
  Future<Either<Failure, List<Governorate>>> call() async => await repository.getGovernorates();
}

class GetPlacesByGovernorateUseCase {
  final IPlaceRepository repository;
  GetPlacesByGovernorateUseCase(this.repository);
  Future<Either<Failure, List<Place>>> call(String governorateId, {int page = 1, int pageSize = 10}) async => await repository.getPlacesByGovernorate(governorateId, page: page, pageSize: pageSize);
}

class GetPlaceDetailUseCase {
  final IPlaceRepository repository;
  GetPlaceDetailUseCase(this.repository);
  Future<Either<Failure, Place>> call(String id) async => await repository.getPlaceDetails(id);
}
