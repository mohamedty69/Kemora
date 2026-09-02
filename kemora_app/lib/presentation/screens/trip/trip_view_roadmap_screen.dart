import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';

class TripViewRoadmapScreen extends StatelessWidget {
  const TripViewRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT EXPEDITION', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Valley of Kings', style: AppTypography.displaySmall),
            const SizedBox(height: 32),

            // Big Active Node Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Center(child: Icon(Icons.image, size: 64, color: AppColors.outlineVariant)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tomb of Tutankhamun', style: AppTypography.titleLarge),
                            Text('Current Location', style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryContainer)),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Leave Review'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Stats Bento Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.white),
                        const SizedBox(height: 16),
                        Text('12.4', style: AppTypography.headlineLarge.copyWith(color: Colors.white)),
                        Text('KM WALKED', style: AppTypography.labelSmall.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.photo_library, color: AppColors.primaryContainer),
                        const SizedBox(height: 16),
                        Text('48', style: AppTypography.headlineLarge),
                        Text('MEMORIES', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Map Snippet
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.map, size: 48, color: AppColors.outlineVariant)),
                  Center(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('Live Progress', style: AppTypography.labelSmall),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
