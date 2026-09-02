import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
