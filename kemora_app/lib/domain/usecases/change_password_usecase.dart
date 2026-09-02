import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class ChangePasswordUseCase {
  final IAuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(String currentPassword, String newPassword) {
    return repository.changePassword(currentPassword, newPassword);
  }
}
