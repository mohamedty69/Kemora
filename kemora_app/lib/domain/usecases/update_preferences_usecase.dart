import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/user_preferences.dart';
import '../repositories/i_auth_repository.dart';

class UpdatePreferencesUseCase {
  final IAuthRepository repository;

  UpdatePreferencesUseCase({required this.repository});

  Future<Either<Failure, User>> call(UserPreferences preferences) async {
    return await repository.updatePreferences(preferences);
  }
}
