import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class KemoraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onMenuPressed;
  const KemoraAppBar({
    super.key,
    this.showBack = false,
    this.trailing,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Leading
                  if (showBack)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryContainer,
                        size: 24,
                      ),
                    )
                  else
                    const SizedBox(width: 24),

                  // Center
                  Text(
                    'KEMORA',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primaryContainer,
                      letterSpacing: 2.0, // Widest tracking
                    ),
                  ),

                  // Trailing
                  if (trailing != null)
                    trailing!
                  else
                    const SizedBox(width: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
