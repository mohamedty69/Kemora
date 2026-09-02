import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/ai_itinerary.dart';
import '../repositories/i_trip_repository.dart';

class SwapPlaceUseCase {
  final ITripRepository repository;

  SwapPlaceUseCase({required this.repository});

  Future<Either<Failure, ItineraryItem>> call(String currentPlaceName, String preferences) async {
    return await repository.swapPlace(currentPlaceName, preferences);
  }
}
