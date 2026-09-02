import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/badge_model.dart';

abstract class BadgeRemoteDataSource {
  Future<List<BadgeModel>> getAllBadges();
  Future<List<UserBadgeModel>> getUserBadges(String userId);
}

class BadgeRemoteDataSourceImpl implements BadgeRemoteDataSource {
  final Dio dio;

  BadgeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final response = await dio.get('/api/v1/badges');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BadgeModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch badges');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<UserBadgeModel>> getUserBadges(String userId) async {
    try {
      final response = await dio.get('/api/v1/my/badges');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserBadgeModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch user badges');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }
}
