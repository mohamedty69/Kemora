import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/story_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class StoryRemoteDataSource {
  Future<List<UserStoriesGroup>> getActiveStories();
  Future<List<StoryModel>> getUserStories(String userId);
  Future<StoryModel> createStory(String mediaType, {required XFile mediaFile, int? locationId});
  Future<void> deleteStory(int storyId);
}

class StoryRemoteDataSourceImpl implements StoryRemoteDataSource {
  final Dio dio;

  StoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserStoriesGroup>> getActiveStories() async {
    try {
      final response = await dio.get('/api/v1/stories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UserStoriesGroup.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch active stories');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<List<StoryModel>> getUserStories(String userId) async {
    try {
      final response = await dio.get('/api/v1/stories/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StoryModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch user stories');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<StoryModel> createStory(String mediaType, {required XFile mediaFile, int? locationId}) async {
    try {
      final bytes = await mediaFile.readAsBytes();
      final formDataMap = <String, dynamic>{
        'mediaFile': MultipartFile.fromBytes(bytes, filename: mediaFile.name),
        'mediaType': mediaType,
      };
      
      if (locationId != null) {
        formDataMap['locationId'] = locationId.toString();
      }

      final formData = FormData.fromMap(formDataMap);
      
      final response = await dio.post('/api/v1/stories', data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StoryModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create story');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> deleteStory(int storyId) async {
    try {
      final response = await dio.delete('/api/v1/stories/$storyId');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw const ServerFailure('Failed to delete story');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Server Error');
    }
  }
}
