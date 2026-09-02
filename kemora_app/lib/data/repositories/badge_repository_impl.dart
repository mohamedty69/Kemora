import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/badge.dart';
import '../../domain/repositories/i_badge_repository.dart';
import '../datasources/badge_remote_data_source.dart';

class BadgeRepositoryImpl implements IBadgeRepository {
  final BadgeRemoteDataSource remoteDataSource;

  BadgeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Badge>>> getAllBadges() async {
    try {
      final badges = await remoteDataSource.getAllBadges();
      return Right(badges);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, List<UserBadge>>> getUserBadges(String userId) async {
    try {
      final userBadges = await remoteDataSource.getUserBadges(userId);
      return Right(userBadges);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
