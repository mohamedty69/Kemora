import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  /// Magazine-style shadow for editorial cards
  static List<BoxShadow> get editorial => [
        BoxShadow(
          offset: const Offset(0, 8),
          blurRadius: 24,
          color: AppColors.onSurface.withValues(alpha: 0.06),
        ),
      ];

  /// Tinted shadow for the floating navigation island
  static List<BoxShadow> get floatingIsland => [
        BoxShadow(
          offset: const Offset(0, 25),
          blurRadius: 50,
          color: AppColors.primaryContainer.withValues(alpha: 0.15),
        ),
      ];

  /// Subtle ambient shadow for subtle elevation without lines
  static List<BoxShadow> get ambient => [
        BoxShadow(
          offset: const Offset(0, 20),
          blurRadius: 40,
          color: Colors.black.withValues(alpha: 0.03),
        ),
      ];
}
