import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/place.dart';
import '../repositories/i_place_repository.dart';

class GetPlaceDetailsUseCase {
  final IPlaceRepository repository;
  GetPlaceDetailsUseCase(this.repository);
  Future<Either<Failure, Place>> call(String id) async => await repository.getPlaceDetails(id);
}
