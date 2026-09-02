import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../entities/user_preferences.dart';

import 'package:image_picker/image_picker.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(String fullName, String email, String country, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> googleLogin(String idToken);
  Future<Either<Failure, User>> updatePreferences(UserPreferences preferences);
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);
  Future<Either<Failure, void>> changeEmail(String newEmail, String password);
  Future<Either<Failure, User>> updateProfile(String fullName, String? bio);
  Future<Either<Failure, String>> uploadProfilePicture(XFile imageFile);
}
