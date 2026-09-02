import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/badge_medallion.dart';
import '../../viewmodels/badge_view_model.dart';
import '../../viewmodels/auth_view_model.dart';

class AllAchievementsScreen extends StatefulWidget {
  const AllAchievementsScreen({super.key});

  @override
  State<AllAchievementsScreen> createState() => _AllAchievementsScreenState();
}

class _AllAchievementsScreenState extends State<AllAchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final badgeVM = Provider.of<BadgeViewModel>(context, listen: false);
      
      badgeVM.loadAllBadges();
      if (authVM.user != null) {
        badgeVM.loadUserBadges(authVM.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: Consumer<BadgeViewModel>(
        builder: (context, badgeVM, child) {
          if (badgeVM.state == BadgeState.loading && badgeVM.allBadges.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBadges = badgeVM.allBadges;
          final userBadges = badgeVM.userBadges;
          
          final earnedBadgeIds = userBadges.map((ub) => ub.badge.id).toSet();
          
          int totalPoints = userBadges.fold(0, (sum, ub) => sum + ub.badge.pointsReward);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR LEGACY', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('All Achievements', style: AppTypography.headlineLarge),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: AppColors.primaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('$totalPoints Points Earned', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (badgeVM.state == BadgeState.error)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(badgeVM.errorMessage ?? 'Error loading badges', style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final badge = allBadges[index];
                        final isEarned = earnedBadgeIds.contains(badge.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAchievementBento(badge, isEarned),
                        );
                      },
                      childCount: allBadges.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementBento(dynamic badge, bool isEarned) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isEarned ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: isEarned ? Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)) : null,
        boxShadow: isEarned ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)] : null,
      ),
      child: Row(
        children: [
          BadgeMedallion(
            name: badge.name,
            criteria: badge.criteria,
            earned: isEarned,
            size: 56,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: isEarned ? AppColors.onSurface : AppColors.outlineVariant,
                  ),
                ),
                Text(
                  badge.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isEarned ? AppColors.onSurfaceVariant : AppColors.outlineVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isEarned) const Icon(Icons.lock, size: 16, color: AppColors.outlineVariant),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${badge.pointsReward} pts', style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
