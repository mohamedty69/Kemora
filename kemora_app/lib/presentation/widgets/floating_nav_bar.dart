import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import 'fade_slide_in.dart';
import 'tap_scale.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delayMs: 300,
      durationMs: 500,
      beginOffset: const Offset(0, 1.0), // Slide up from below
      curve: Curves.easeOutCubic,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow/blur behind the nav bar
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 28,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Actual nav bar
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: AppShadows.floatingIsland,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavItem(icon: Icons.home_rounded, index: 0),
                      _buildNavItem(icon: Icons.map_rounded, index: 1),
                      _buildNavItem(icon: Icons.auto_awesome, index: 2),
                      _buildNavItem(icon: Icons.groups_rounded, index: 3),
                      _buildNavItem(icon: Icons.person_rounded, index: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isActive = currentIndex == index;

    return TapScale(
      onTap: () => onTap(index),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 1.0, end: isActive ? 1.15 : 1.0),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isActive ? AppColors.primaryContainer : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.onPrimary : Colors.grey[400],
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}
