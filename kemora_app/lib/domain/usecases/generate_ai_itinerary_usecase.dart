import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/ai_itinerary.dart';
import '../entities/trip_plan_request.dart';
import '../repositories/i_trip_repository.dart';

class GenerateAiItineraryUseCase {
  final ITripRepository repository;

  GenerateAiItineraryUseCase({required this.repository});

  Future<Either<Failure, AIItinerary>> call(TripPlanRequest request) async {
    return await repository.generateItinerary(request);
  }
}
