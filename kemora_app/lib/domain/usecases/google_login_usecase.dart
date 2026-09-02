import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class GoogleLoginUseCase {
  final IAuthRepository repository;

  GoogleLoginUseCase({required this.repository});

  Future<Either<Failure, User>> call(String idToken) async {
    return await repository.googleLogin(idToken);
  }
}
