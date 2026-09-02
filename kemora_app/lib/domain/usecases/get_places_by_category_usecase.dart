import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/place.dart';
import '../repositories/i_place_repository.dart';

class GetPlacesByCategoryUseCase {
  final IPlaceRepository repository;

  GetPlacesByCategoryUseCase(this.repository);

  Future<Either<Failure, List<Place>>> call(String category) async {
    return await repository.getPlacesByCategory(category);
  }
}
