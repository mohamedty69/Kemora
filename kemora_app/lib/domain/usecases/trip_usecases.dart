import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/trip.dart';
import '../repositories/i_trip_repository.dart';

class CreateTripPlanUseCase {
  final ITripRepository repository;

  CreateTripPlanUseCase(this.repository);

  Future<Either<Failure, Trip>> call(String title, DateTime startDate, DateTime endDate, List<String> placeIds) async {
    return await repository.createTripPlan(title, startDate, endDate, placeIds);
  }
}

class GetUserTripsUseCase {
  final ITripRepository repository;

  GetUserTripsUseCase(this.repository);

  Future<Either<Failure, List<Trip>>> call() async {
    return await repository.getUserTrips();
  }
}

class GetTripDetailsUseCase {
  final ITripRepository repository;

  GetTripDetailsUseCase(this.repository);

  Future<Either<Failure, Trip>> call(String id) async {
    return await repository.getTripDetails(id);
  }
}

class DeleteTripUseCase {
  final ITripRepository repository;

  DeleteTripUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.deleteTrip(id);
  }
}

class RenameTripUseCase {
  final ITripRepository repository;

  RenameTripUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id, String newName) async {
    return await repository.renameTrip(id, newName);
  }
}
