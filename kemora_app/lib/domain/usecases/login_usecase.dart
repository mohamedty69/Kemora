import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
