import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class UpdateProfileUseCase {
  final IAuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(String fullName, String? bio) async {
    return await repository.updateProfile(fullName, bio);
  }
}
