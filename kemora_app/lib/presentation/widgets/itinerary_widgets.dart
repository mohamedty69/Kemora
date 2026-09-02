import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/ai_itinerary.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';

class DayHeader extends StatelessWidget {
  final TripDay day;
  const DayHeader({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Day ${day.dayNumber}",
                style: const TextStyle(
                  color: AppTheme.primarySand,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: AppTheme.primarySand, thickness: 2)),
          ],
        ),
        if (day.dailySummary != null && day.dailySummary!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primarySand.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    day.dailySummary!,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.primaryBlue,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (day.transportTips != null && day.transportTips!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentOasis.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.directions_bus, color: AppTheme.accentOasis, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    day.transportTips!,
                    style: const TextStyle(
                      color: AppTheme.accentOasis,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class ActivityTimelineTile extends StatelessWidget {
  final ItineraryItem activity;
  final bool isLast;
  const ActivityTimelineTile({
    super.key,
    required this.activity,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline logic
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.primaryContainer,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: PremiumActivityCard(activity: activity),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumActivityCard extends StatelessWidget {
  final ItineraryItem activity;
  const PremiumActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Slot Header
          if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: CachedNetworkImage(
                imageUrl: activity.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 150,
                  color: AppTheme.primarySand.withValues(alpha: 0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 150,
                  color: AppTheme.primarySand,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: AppTheme.primaryGold, size: 40),
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      activity.timeOfDay.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    if (activity.suggestedHours != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        "• ${activity.suggestedHours}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                    const Spacer(),
                    if (activity.rating != null && activity.rating! > 0) ...[
                      const Icon(Icons.star, color: AppTheme.primaryGold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        activity.rating!.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                if (activity.price != null && activity.price!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 14, color: AppTheme.accentOasis),
                      const SizedBox(width: 4),
                      Text(
                        activity.price!,
                        style: const TextStyle(
                          color: AppTheme.accentOasis,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                // Pro Tip Callout?
                // For now, let's just keep it at this.
              ],
            ),
          ),
        ],
      ),
    );
  }
}
