import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/badge.dart' as entity;
import '../../viewmodels/badge_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/badge_medallion.dart';
// inline points display

class BadgesScreen extends StatefulWidget {
  final String userId;

  const BadgesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<BadgeViewModel>();
      vm.loadUserBadges(widget.userId);
      vm.loadAllBadges(); // Assuming BadgeViewModel has this
      // vm.loadPoints(); // Let's ensure this exists or skip
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Achievements', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<BadgeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == BadgeState.loading && viewModel.allBadges.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer));
          }

          if (viewModel.state == BadgeState.error && viewModel.allBadges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage ?? 'Could not load badges', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.loadAllBadges();
                      viewModel.loadUserBadges(widget.userId);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: Colors.white),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildPointsSummary(viewModel),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    'All Badges',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildBadgesGrid(viewModel),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPointsSummary(BadgeViewModel viewModel) {
    // Determine the user's total points. You might need to add points to BadgeViewModel
    final totalPoints = viewModel.userBadges.fold<int>(0, (sum, ub) => sum + ub.badge.pointsReward);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            const Text('Total Points', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalPoints',
                  style: const TextStyle(color: AppColors.primaryContainer, fontSize: 48, fontWeight: FontWeight.bold, height: 1),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('pts', style: TextStyle(color: Colors.white70, fontSize: 18)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Keep exploring to earn more badges and rise on the leaderboard!', 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid(BadgeViewModel viewModel) {
    if (viewModel.allBadges.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(
            child: Text('No badges available yet.', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }

    // Sort: Earned first, then Unearned
    final sortedBadges = List<entity.Badge>.from(viewModel.allBadges);
    sortedBadges.sort((a, b) {
      final aEarned = viewModel.userBadges.any((ub) => ub.badge.id == a.id);
      final bEarned = viewModel.userBadges.any((ub) => ub.badge.id == b.id);
      if (aEarned && !bEarned) return -1;
      if (!aEarned && bEarned) return 1;
      return a.id.compareTo(b.id);
    });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75, // Adjust for taller cards
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final badge = sortedBadges[index];
            final userBadge = viewModel.userBadges.where((ub) => ub.badge.id == badge.id).firstOrNull;
            final isEarned = userBadge != null;
            
            // Optional progress tracker from backend, if available via UI
            final progress = isEarned ? null : null; // In real app, might read from UserBadge.progress
            
            return _buildBadgeCard(badge, isEarned, userBadge?.earnedAt, progress);
          },
          childCount: sortedBadges.length,
        ),
      ),
    );
  }

  Widget _buildBadgeCard(entity.Badge badge, bool isEarned, DateTime? earnedAt, int? progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isEarned ? AppColors.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: isEarned ? 1.0 : 0.85,
                  child: BadgeMedallion(
                    name: badge.name,
                    criteria: badge.criteria,
                    earned: isEarned,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isEarned ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEarned ? (earnedAt != null ? DateFormat('MMM d, yyyy').format(earnedAt) : 'Earned!') : badge.criteria,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isEarned ? AppColors.primaryContainer : Colors.grey,
                    fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (!isEarned) ...[
                  const Spacer(),
                  _buildProgressBar(badge),
                ]
              ],
            ),
          ),
          if (isEarned)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(entity.Badge badge) {
    // Basic mock progress based on badge requirements
    double progress = 0.2; // Default
    if (badge.name.contains('Reviewer')) progress = 0.4;
    if (badge.name.contains('Social')) progress = 0.1;
    if (badge.name.contains('Lover')) progress = 0.6;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).toInt()}% progress', style: const TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    );
  }
}
