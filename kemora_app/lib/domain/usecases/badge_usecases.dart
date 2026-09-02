import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/badge.dart';
import '../repositories/i_badge_repository.dart';

class GetUserBadgesUseCase {
  final IBadgeRepository repository;

  GetUserBadgesUseCase(this.repository);

  Future<Either<Failure, List<UserBadge>>> call(String userId) async {
    return await repository.getUserBadges(userId);
  }
}

class GetAllBadgesUseCase {
  final IBadgeRepository repository;

  GetAllBadgesUseCase(this.repository);

  Future<Either<Failure, List<Badge>>> call() async {
    return await repository.getAllBadges();
  }
}
