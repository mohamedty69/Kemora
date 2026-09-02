import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(String fullName, String email, String country, String password) async {
    return await repository.register(fullName, email, country, password);
  }
}
