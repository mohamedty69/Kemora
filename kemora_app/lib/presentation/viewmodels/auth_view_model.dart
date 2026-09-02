import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/user.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/update_preferences_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/change_email_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';
import '../../domain/entities/user_preferences.dart';
import '../../core/auth/token_storage.dart';
import '../../services/signalr_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  static const String _cachedUserKey = 'cached_user';

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleLoginUseCase googleLoginUseCase;
  final LogoutUseCase logoutUseCase;
  final UpdatePreferencesUseCase updatePreferencesUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final ChangeEmailUseCase changeEmailUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadProfilePictureUseCase uploadProfilePictureUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleLoginUseCase,
    required this.logoutUseCase,
    required this.updatePreferencesUseCase,
    required this.changePasswordUseCase,
    required this.changeEmailUseCase,
    required this.updateProfileUseCase,
    required this.uploadProfilePictureUseCase,
  }) {
    _restoreSession();
  }

  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  User? _user;
  User? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserJson = prefs.getString(_cachedUserKey);

      if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
        final decoded = jsonDecode(cachedUserJson) as Map<String, dynamic>;
        _user = UserModel.fromJson(decoded);
      }

      _state = TokenStorage.instance.isAuthenticated
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    } catch (_) {
      _state = TokenStorage.instance.isAuthenticated
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> _persistUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      profilePictureUrl: user.profilePictureUrl,
      country: user.country,
      bio: user.bio,
      token: user.token,
      refreshToken: user.refreshToken,
      earnedBadgesCount: user.earnedBadgesCount,
      preferences: user.preferences,
    ).toJson();
    await prefs.setString(_cachedUserKey, jsonEncode(payload));
  }

  Future<void> _clearPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }

  void _onAuthSuccess(User user) {
    _user = user;
    // Persist JWT token so Dio interceptor includes it in all subsequent requests
    if (user.token != null && user.token!.isNotEmpty) {
      TokenStorage.instance.saveTokens(
        token: user.token!,
        refreshToken: user.refreshToken,
      );
    }
    _persistUser(user);
    _state = AuthState.authenticated;
    
    // Initialize real-time notifications
    SignalRService().init();
    
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await loginUseCase(email, password);

    result.fold(
      (failure) {
        _state = AuthState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (user) => _onAuthSuccess(user),
    );
  }

  Future<void> signInWithGoogle() async {
    // Google Sign-In on Web requires a Google OAuth2 Client ID configured
    // in web/index.html. Until it's set up, show a clear message.
    if (kIsWeb) {
      _state = AuthState.error;
      _errorMessage =
          'Google Sign-In is not yet configured for Web. Please use email/password login.';
      notifyListeners();
      return;
    }

    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // GoogleSignIn v7.x: authenticate() returns non-nullable GoogleSignInAccount.
      // It throws GoogleSignInException on cancellation or failure.
      final googleUser = await GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _state = AuthState.error;
        _errorMessage = 'Could not retrieve ID token from Google';
        notifyListeners();
        return;
      }

      final result = await googleLoginUseCase(idToken);

      result.fold(
        (failure) {
          _state = AuthState.error;
          _errorMessage = failure.message;
          notifyListeners();
        },
        (user) {
          final googleName = (googleUser.displayName ?? '').trim();
          final mergedUser = googleName.isNotEmpty
              ? user.copyWith(fullName: googleName)
              : user;
          _onAuthSuccess(mergedUser);
        },
      );
    } on PlatformException catch (e) {
      _state = AuthState.error;
      if ((e.code == 'sign_in_failed' || e.code == '10') &&
          (e.message?.contains('ApiException: 10') ?? false)) {
        _errorMessage =
            'Google Sign-In is not configured correctly for Android (ApiException 10).\n'
            'Ensure OAuth Android client uses your app package and SHA-1, and pass GOOGLE_WEB_CLIENT_ID via --dart-define.';
      } else {
        _errorMessage = 'Google Sign-In Error: ${e.message ?? e.code}';
      }
      notifyListeners();
    } catch (e) {
      // Handles GoogleSignInException (cancellation) and other errors
      _state = AuthState.error;
      _errorMessage = 'Google Sign-In Error: $e';
      notifyListeners();
    }
  }

  Future<void> updatePreferences(UserPreferences prefs) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await updatePreferencesUseCase(prefs);

    result.fold(
      (failure) {
        _state = AuthState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        // Preferences updated — keep existing user but refresh state
        _state = AuthState.authenticated;
        notifyListeners();
      },
    );
  }

  Future<void> register(
      String fullName, String email, String country, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await registerUseCase(fullName, email, country, password);

    result.fold(
      (failure) {
        _state = AuthState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (user) => _onAuthSuccess(user),
    );
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await changePasswordUseCase(currentPassword, newPassword);

    result.fold(
      (failure) {
        _state = AuthState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        _state = AuthState.authenticated;
        notifyListeners();
      },
    );
  }

  Future<void> changeEmail(String newEmail, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await changeEmailUseCase(newEmail, password);

    result.fold(
      (failure) {
        _state = AuthState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        // Assume user object still kept in state, but email changes.
        // We could log them out or just rely on backend to update.
        _state = AuthState.authenticated;
        notifyListeners();
      },
    );
  }

  Future<void> logout() async {
    // Immediately clear state to prevent LoginScreen bounce-back
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();

    // Call the backend API to invalidate the refresh token
    try {
      await logoutUseCase();
    } catch (_) {
      // Ignore errors (e.g. if offline or token already invalid)
    }

    TokenStorage.instance.clearTokens();
    await _clearPersistedUser();
    
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore sign-out failures
    }
    
    // Disconnect real-time notifications
    try {
      await SignalRService().disconnect();
    } catch (_) {
      // Ignore disconnect failures
    }
  }

  Future<void> updateProfile(String fullName, String? bio) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await updateProfileUseCase(fullName, bio);

    result.fold(
      (failure) {
        _state = AuthState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (updatedUser) {
        // Merge updated fields into existing user
        if (_user != null) {
          _user = _user!.copyWith(
            fullName: updatedUser.fullName,
            bio: updatedUser.bio,
          );
          _persistUser(_user!);
        }
        _state = AuthState.authenticated;
        notifyListeners();
      },
    );
  }

  /// Upload profile picture from a file path.
  /// Image picking should be done in the UI layer before calling this.
  Future<void> uploadProfilePicture(XFile imageFile) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await uploadProfilePictureUseCase(imageFile);

    result.fold(
      (failure) {
        _state = AuthState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (imageUrl) {
        if (_user != null) {
          _user = _user!.copyWith(profilePictureUrl: imageUrl);
          _persistUser(_user!);
        }
        _state = AuthState.authenticated;
        notifyListeners();
      },
    );
  }
}
