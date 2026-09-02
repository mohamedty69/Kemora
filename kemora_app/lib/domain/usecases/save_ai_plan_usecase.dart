import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/trip.dart';
import '../entities/ai_itinerary.dart';
import '../repositories/i_trip_repository.dart';

class SaveAiPlanUseCase {
  final ITripRepository repository;

  SaveAiPlanUseCase({required this.repository});

  Future<Either<Failure, Trip>> call(AIItinerary itinerary, DateTime startDate, DateTime endDate) async {
    return await repository.saveAIPlan(itinerary, startDate, endDate);
  }
}
