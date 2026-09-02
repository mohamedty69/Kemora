import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/error/failures.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_preferences.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String fullName, String email, String country, String password);
  Future<UserModel> googleLogin(String idToken);
  Future<UserModel> updatePreferences(UserPreferences preferences);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> changeEmail(String newEmail, String password);
  Future<UserModel> updateProfile(String fullName, String? bio);
  Future<String> uploadProfilePicture(XFile imageFile);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  /// Extract a friendly error from a Dio exception
  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      return data['message']?.toString() ??
          data['title']?.toString() ??
          data['error']?.toString() ??
          fallback;
    }
    // No response — show the actual connection error (e.g. "Connection refused")
    final msg = e.message ?? e.type.name;
    return '$fallback\n[Network: $msg]';
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      // Backend returns AuthResponseDto flat at response.data
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Login failed. Please check your credentials.'));
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> googleLogin(String idToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/google-login',
        data: {'idToken': idToken},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Google login failed.'));
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updatePreferences(UserPreferences preferences) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/preferences',
        data: preferences.toJson(),
      );
      // Backend returns { message: ... } — reconstruct user from stored state isn't possible here.
      // Return an empty placeholder that the ViewModel will ignore (preferences updated message is ok)
      if (response.statusCode == 200) {
        return UserModel.fromJson(const {'userId': '', 'email': '', 'fullName': ''});
      }
      throw const ServerFailure('Failed to update preferences');
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Failed to update preferences.'));
    }
  }

  @override
  Future<UserModel> register(String fullName, String email, String country, String password) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'country': country,
          'password': password,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Registration failed.'));
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await dio.post(
        '/api/v1/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Failed to change password.'));
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> changeEmail(String newEmail, String password) async {
    try {
      await dio.post(
        '/api/v1/auth/change-email',
        data: {
          'newEmail': newEmail,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Failed to change email.'));
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile(String fullName, String? bio) async {
    try {
      final response = await dio.put(
        '/api/v1/profile/my',
        data: {
          'fullName': fullName,
          'bio': bio,
        },
      );
      // Backend returns 204 No Content usually. We need to fetch the updated user or assume success.
      // ProfileController returns NoContent() on success.
      if (response.statusCode == 204) {
        // Return a dummy Model, the UI should ideally refresh or we merge state.
        return UserModel(fullName: fullName, bio: bio, id: '', email: '');
      }
      throw const ServerFailure('Failed to update profile.');
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Failed to update profile.'));
    }
  }

  @override
  Future<String> uploadProfilePicture(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: imageFile.name),
      });

      final response = await dio.post(
        '/api/v1/profile/image',
        data: formData,
      );

      if (response.statusCode == 200) {
        return (response.data['profilePictureUrl'] ?? response.data['ProfilePictureUrl']) as String;
      }
      throw const ServerFailure('Failed to upload profile picture.');
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Failed to upload profile picture.'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/api/v1/auth/logout');
    } on DioException catch (e) {
      throw ServerFailure(_extractError(e, 'Failed to logout.'));
    } catch (e) {
      throw ServerFailure('An unexpected error occurred: ${e.toString()}');
    }
  }
}
