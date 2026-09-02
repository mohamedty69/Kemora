import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/i_place_repository.dart';

class RemoveFavoriteUseCase {
  final IPlaceRepository repository;

  RemoveFavoriteUseCase(this.repository);

  Future<Either<Failure, void>> call(String placeId) async {
    return await repository.removeFavorite(placeId);
  }
}
