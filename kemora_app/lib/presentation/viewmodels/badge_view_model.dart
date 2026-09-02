import 'package:flutter/material.dart';

import '../../domain/entities/badge.dart' as domain;
import '../../domain/usecases/badge_usecases.dart';

enum BadgeState { initial, loading, loaded, error }

class BadgeViewModel extends ChangeNotifier {
  final GetUserBadgesUseCase getUserBadgesUseCase;
  final GetAllBadgesUseCase getAllBadgesUseCase;

  BadgeViewModel({
    required this.getUserBadgesUseCase,
    required this.getAllBadgesUseCase,
  });

  BadgeState _state = BadgeState.initial;
  BadgeState get state => _state;

  List<domain.UserBadge> _userBadges = [];
  List<domain.UserBadge> get userBadges => _userBadges;

  List<domain.Badge> _allBadges = [];
  List<domain.Badge> get allBadges => _allBadges;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserBadges(String userId) async {
    _state = BadgeState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getUserBadgesUseCase(userId);
    result.fold(
      (failure) {
        _state = BadgeState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (badges) {
        _userBadges = badges;
        _state = BadgeState.loaded;
        notifyListeners();
      },
    );
  }

  Future<void> loadAllBadges() async {
    _state = BadgeState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getAllBadgesUseCase();
    result.fold(
      (failure) {
        _state = BadgeState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (badges) {
        _allBadges = badges;
        _state = BadgeState.loaded;
        notifyListeners();
      },
    );
  }
}
