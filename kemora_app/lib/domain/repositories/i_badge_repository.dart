import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/badge.dart';

abstract class IBadgeRepository {
  Future<Either<Failure, List<Badge>>> getAllBadges();
  Future<Either<Failure, List<UserBadge>>> getUserBadges(String userId);
}
