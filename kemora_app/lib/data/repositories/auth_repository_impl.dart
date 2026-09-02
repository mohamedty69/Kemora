import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import 'package:image_picker/image_picker.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String fullName, String email, String country, String password) async {
    try {
      final user = await remoteDataSource.register(fullName, email, country, password);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> googleLogin(String idToken) async {
    try {
      final user = await remoteDataSource.googleLogin(idToken);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updatePreferences(UserPreferences preferences) async {
    try {
      final user = await remoteDataSource.updatePreferences(preferences);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // Implement local cache fetch or /api/auth/me logic
    return const Left(CacheFailure('No cached user found'));
  }

  @override
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> changeEmail(String newEmail, String password) async {
    try {
      await remoteDataSource.changeEmail(newEmail, password);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(String fullName, String? bio) async {
    try {
      final user = await remoteDataSource.updateProfile(fullName, bio);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(XFile imageFile) async {
    try {
      final url = await remoteDataSource.uploadProfilePicture(imageFile);
      // We don't update local state here completely because it's usually managed via a user reload,
      // but we return the URL so the ViewModel can use it.
      return Right(url);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }
}
