import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/i_trip_repository.dart';

class UpdatePlaceVisitedStatusUseCase {
  final ITripRepository repository;

  UpdatePlaceVisitedStatusUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int tripId, int tripPlaceId, bool isVisited) async {
    return await repository.updatePlaceVisitedStatus(tripId, tripPlaceId, isVisited);
  }
}
