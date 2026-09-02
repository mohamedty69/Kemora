import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_shadows.dart';
import 'glassmorphism_container.dart';

import '../../core/di/injection_container.dart';

class EditorialPlaceCard extends StatelessWidget {
  final String title;
  final String category;
  final String location;
  final double rating;
  final int reviewsCount;
  final String price;
  final String? distance;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final double aspectRatio;
  final String? imageAsset;
  final String? imageUrl;

  const EditorialPlaceCard({
    super.key,
    required this.title,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    this.distance,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.aspectRatio = 0.56,
    this.imageAsset,
    this.imageUrl,
  });

  String get _fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    final baseUrl = resolveApiBaseUrl();
    if (imageUrl!.startsWith('/')) {
      return '$baseUrl$imageUrl';
    }
    return '$baseUrl/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio > 1 ? aspectRatio : 1 / (1 / aspectRatio),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.ambient,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image or Placeholder
                if (_fullImageUrl.isNotEmpty && _fullImageUrl.startsWith('http'))
                  Image.network(
                    _fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                else if (imageAsset != null)
                  Image.asset(
                    imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                else
                  _buildPlaceholder(),
                
                // Gradient Overlay (Soft Lapis-to-transparent)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.secondary.withOpacity(0.9),
                        AppColors.secondary.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 0.8],
                    ),
                  ),
                ),
                
                // Category Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSecondaryFixed,
                      ),
                    ),
                  ),
                ),
                
                // Favorite Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: GlassmorphismContainer(
                      opacity: 0.2,
                      blurRadius: 10,
                      borderRadius: BorderRadius.circular(999),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.primaryFixed : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Content Overlay at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppTypography.titleLarge.copyWith(color: AppColors.onPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.primaryContainer, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.onPrimary),
                            ),
                            Text(
                              ' (${_formatCount(reviewsCount)})',
                              style: AppTypography.labelMedium.copyWith(color: AppColors.onPrimary.withOpacity(0.7)),
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  price,
                                  style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer),
                                ),
                                Text(
                                  ' / entry',
                                  style: AppTypography.labelMedium.copyWith(color: AppColors.onPrimary.withOpacity(0.7)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primaryFixed, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.onPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (distance != null)
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  const Icon(Icons.near_me_outlined, color: AppColors.primaryFixed, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    distance!,
                                    style: AppTypography.labelMedium.copyWith(color: AppColors.onPrimary),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}k';
    }
    return '$count';
  }

  Widget _buildPlaceholder() {    return Container(
      color: AppColors.surfaceContainer,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.outline, size: 48),
      ),
    );
  }
}
