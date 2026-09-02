import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class ChangeEmailUseCase {
  final IAuthRepository repository;

  ChangeEmailUseCase(this.repository);

  Future<Either<Failure, void>> call(String newEmail, String password) {
    return repository.changeEmail(newEmail, password);
  }
}
