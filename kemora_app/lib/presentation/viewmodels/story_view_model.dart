import 'package:flutter/foundation.dart';
import '../../data/datasources/story_remote_data_source.dart';
import '../../data/models/story_model.dart';
import 'package:image_picker/image_picker.dart';

enum StoryState { initial, loading, loaded, error }

class StoryViewModel extends ChangeNotifier {
  final StoryRemoteDataSource _remoteDataSource;

  StoryViewModel({required StoryRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  StoryState _state = StoryState.initial;
  StoryState get state => _state;

  List<UserStoriesGroup> _activeStories = [];
  List<UserStoriesGroup> get activeStories => _activeStories;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadActiveStories() async {
    _state = StoryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _activeStories = await _remoteDataSource.getActiveStories();
      _state = StoryState.loaded;
    } catch (e) {
      _state = StoryState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> createStory(String mediaType, {required XFile mediaFile, int? locationId}) async {
    _state = StoryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _remoteDataSource.createStory(mediaType, mediaFile: mediaFile, locationId: locationId);
      // Reload stories after successful creation
      await loadActiveStories();
    } catch (e) {
      _state = StoryState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteStory(int storyId) async {
    try {
      await _remoteDataSource.deleteStory(storyId);
      await loadActiveStories();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
