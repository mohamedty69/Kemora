import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/token_storage.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/places_remote_data_source.dart';
import '../../data/datasources/trip_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/place_repository_impl.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/badge_repository_impl.dart';
import '../../data/datasources/post_remote_data_source.dart';
import '../../data/datasources/badge_remote_data_source.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_place_repository.dart';
import '../../domain/repositories/i_trip_repository.dart';
import '../../domain/repositories/i_post_repository.dart';
import '../../domain/repositories/i_badge_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/update_preferences_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/change_email_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';
import '../../domain/usecases/get_places_usecase.dart';
import '../../domain/usecases/explore_usecases.dart';
import '../../domain/usecases/trip_usecases.dart';
import '../../domain/usecases/generate_ai_itinerary_usecase.dart';
import '../../domain/usecases/swap_place_usecase.dart';
import '../../domain/usecases/save_ai_plan_usecase.dart';
import '../../domain/usecases/update_place_visited_status_usecase.dart';
import '../../domain/usecases/get_places_by_category_usecase.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/get_place_details_usecase.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';
import '../../domain/usecases/post_usecases.dart';
import '../../domain/usecases/badge_usecases.dart';
import '../../presentation/viewmodels/auth_view_model.dart';
import '../../presentation/viewmodels/places_view_model.dart';
import '../../presentation/viewmodels/trip_view_model.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../presentation/viewmodels/chat_view_model.dart';
import '../../presentation/viewmodels/post_view_model.dart';
import '../../presentation/viewmodels/story_view_model.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/datasources/story_remote_data_source.dart';
import '../../domain/repositories/i_chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../presentation/viewmodels/badge_view_model.dart';

final sl = GetIt.instance;

String resolveApiBaseUrl() {
  if (kIsWeb) {
    return 'https://kemora.tryasp.net';
  }

  // Android emulator cannot reach host loopback via localhost.
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'https://kemora.tryasp.net';
  }

  return 'https://kemora.tryasp.net';
}

Future<void> init() async {
  // Features - Auth
  // ViewModels
  sl.registerFactory(() => AuthViewModel(
        loginUseCase: sl(),
        registerUseCase: sl(),
        googleLoginUseCase: sl(),
        logoutUseCase: sl(),
        updatePreferencesUseCase: sl(),
        changePasswordUseCase: sl(),
        changeEmailUseCase: sl(),
        updateProfileUseCase: sl(),
        uploadProfilePictureUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePreferencesUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => ChangeEmailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfilePictureUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // Features - Places
  // ViewModels
  sl.registerFactory(() => PlacesViewModel(
        getPlacesUseCase: sl(),
        getPlacesByCategoryUseCase: sl(),
        getTopPlacesUseCase: sl(),
        getGovernoratesUseCase: sl(),
        getPlacesByGovernorateUseCase: sl(),
        getFavoritesUseCase: sl(),
        addFavoriteUseCase: sl(),
        removeFavoriteUseCase: sl(),
        getPlaceDetailsUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetPlacesUseCase(sl()));
  sl.registerLazySingleton(() => GetPlacesByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetTopPlacesUseCase(sl()));
  sl.registerLazySingleton(() => GetGovernoratesUseCase(sl()));
  sl.registerLazySingleton(() => GetPlacesByGovernorateUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => AddFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => GetPlaceDetailsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IPlaceRepository>(
    () => PlaceRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSourceImpl(dio: sl()),
  );

  // Features - Trips
  // ViewModels
  sl.registerFactory(() => TripViewModel(
        getUserTripsUseCase: sl(),
        createTripPlanUseCase: sl(),
        generateAiItineraryUseCase: sl(),
        swapPlaceUseCase: sl(),
        saveAiPlanUseCase: sl(),
        updatePlaceVisitedStatusUseCase: sl(),
        getTripDetailsUseCase: sl(),
        deleteTripUseCase: sl(),
        renameTripUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetUserTripsUseCase(sl()));
  sl.registerLazySingleton(() => CreateTripPlanUseCase(sl()));
  sl.registerLazySingleton(() => GenerateAiItineraryUseCase(repository: sl()));
  sl.registerLazySingleton(() => SwapPlaceUseCase(repository: sl()));
  sl.registerLazySingleton(() => SaveAiPlanUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdatePlaceVisitedStatusUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetTripDetailsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTripUseCase(sl()));
  sl.registerLazySingleton(() => RenameTripUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ITripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(dio: sl()),
  );

  // Features - Social (Posts)
  // ViewModels
  sl.registerFactory(() => PostViewModel(
        getFeedUseCase: sl(),
        createPostUseCase: sl(),
        toggleLikeUseCase: sl(),
        addCommentUseCase: sl(),
        getPostCommentsUseCase: sl(),
        deletePostUseCase: sl(),
        updatePostUseCase: sl(),
      ));
  sl.registerFactory(() => ChatViewModel(
        getConversationsUseCase: sl(),
        getConversationMessagesUseCase: sl(),
        sendChatMessageUseCase: sl(),
        markChatAsReadUseCase: sl(),
      ));
  sl.registerFactory(() => StoryViewModel(remoteDataSource: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetFeedUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  sl.registerLazySingleton(() => GetPostCommentsUseCase(sl()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePostUseCase(sl()));

  sl.registerLazySingleton(() => GetConversationsUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkChatAsReadUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IPostRepository>(
      () => PostRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<IChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<PostRemoteDataSource>(
      () => PostRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<StoryRemoteDataSource>(
      () => StoryRemoteDataSourceImpl(dio: sl()));

  // Features - Badges (Gamification)
  // ViewModels
  sl.registerFactory(() => BadgeViewModel(
        getUserBadgesUseCase: sl(),
        getAllBadgesUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetUserBadgesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllBadgesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IBadgeRepository>(
    () => BadgeRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BadgeRemoteDataSource>(
    () => BadgeRemoteDataSourceImpl(dio: sl()),
  );

  // Core - Dio HTTP Client with Auth Interceptor
  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: resolveApiBaseUrl(),
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(
            seconds:
                300), // Increased to 5 minutes (300s) for extremely long AI tasks like trip generation
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // JWT Auth Interceptor — attaches Bearer token to every request
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = TokenStorage.instance.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    // Logging interceptor for debugging — only in debug mode to avoid leaking sensitive data
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: false, // Set to false to prevent UI freezes on large payloads
        error: true,
      ));
    }

    return dio;
  });
}
