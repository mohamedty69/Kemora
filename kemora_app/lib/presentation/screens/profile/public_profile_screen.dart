import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/place.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/router/page_transitions.dart';
import '../../../providers/voucher_provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/badge_view_model.dart';
import '../../viewmodels/places_view_model.dart';
import '../../viewmodels/trip_view_model.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/tap_scale.dart';
import '../explore/place_detail_screen.dart';
import '../auth/login_screen.dart';
import 'all_achievements_screen.dart';
import 'redeemed_vouchers_screen.dart';
import 'saved_places_screen.dart';
import 'settings_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!context.mounted) return;
      await context.read<AuthViewModel>().uploadProfilePicture(image);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final placesVM = context.read<PlacesViewModel>();
      final authVM = context.read<AuthViewModel>();
      final tripVM = context.read<TripViewModel>();
      // Load favorites for the saved-places stat + horizontal scroll
      placesVM.loadFavorites();
      // Load trips for the trips stat
      tripVM.loadTrips();
      // Refresh badges for accurate points & badge count
      if (authVM.user != null) {
        context.read<BadgeViewModel>().loadUserBadges(authVM.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final voucherProvider = context.watch<VoucherProvider>();
    final int availablePoints = voucherProvider.availablePoints(context);
    final badgeVM = context.watch<BadgeViewModel>();
    final placesVM = context.watch<PlacesViewModel>();
    final tripVM = context.watch<TripViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user;
    final userName = user?.fullName ?? 'Traveler';
    final userLocation = user?.country ?? 'Egypt';
    final profilePic = user?.profilePictureUrl;

    // Dynamic data for stats
    final int savedPlacesCount = placesVM.favorites.length;
    final int tripsCount = tripVM.trips.length;
    final int badgesCount = badgeVM.userBadges.length;
    final int redeemedCount = voucherProvider.redeemedVouchers.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delayMs: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  children: [
                    // Avatar with camera button
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryContainer,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryContainer
                                    .withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: profilePic != null && profilePic.isNotEmpty
                                ? Image.network(
                                    profilePic,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.person,
                                            size: 48,
                                            color: AppColors.outlineVariant),
                                  )
                                : const Icon(Icons.person,
                                    size: 48, color: AppColors.outlineVariant),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _pickImage(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(userName, style: AppTypography.headlineMedium),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(userLocation,
                            style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Stats Row ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delayMs: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.favorite,
                        value: savedPlacesCount.toString(),
                        label: 'Saved',
                        color: AppColors.tertiary,
                        onTap: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(
                                child: const SavedPlacesScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.luggage,
                        value: tripsCount.toString(),
                        label: 'Trips',
                        color: AppColors.secondary,
                        onTap: null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.emoji_events,
                        value: badgesCount.toString(),
                        label: 'Badges',
                        color: AppColors.primaryContainer,
                        onTap: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(
                                child: const AllAchievementsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.card_giftcard,
                        value: redeemedCount.toString(),
                        label: 'Vouchers',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(
                                child: const RedeemedVouchersScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Points & Redeem Card ────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delayMs: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFc5a021),
                        Color(0xFF745b00),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Loyalty Points',
                                style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.8))),
                            const SizedBox(height: 4),
                            Text('$availablePoints',
                                style: GoogleFonts.ebGaramond(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )),
                            Text('points earned',
                                style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showRedeemModal(
                            context, voucherProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                          elevation: 0,
                        ),
                        child: Text('REDEEM',
                            style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── Saved Places Section ───────────────────────────────────
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delayMs: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saved Places', style: AppTypography.titleLarge),
                        if (savedPlacesCount > 1)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlidePageRoute(child: const SavedPlacesScreen()),
                              );
                            },
                            child: Text('View All', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryContainer)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (savedPlacesCount == 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.outlineVariant
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.favorite_border,
                                size: 40, color: AppColors.outlineVariant),
                            const SizedBox(height: 12),
                            Text('No saved places yet',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text(
                                'Tap the heart icon on any place to save it here',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.outline)),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: savedPlacesCount,
                          itemBuilder: (context, index) {
                            final place = placesVM.favorites[index];
                            return _buildSavedPlaceCard(place, placesVM);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // ── Menu Items ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeSlideIn(
              delayMs: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.card_giftcard,
                      title: 'Redeemed Vouchers',
                      subtitle: redeemedCount > 0
                          ? '$redeemedCount voucher${redeemedCount > 1 ? 's' : ''}'
                          : 'No vouchers redeemed',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                              child: const RedeemedVouchersScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.emoji_events,
                      title: 'Achievements',
                      subtitle:
                          '$badgesCount badge${badgesCount > 1 ? 's' : ''} earned',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(
                              child: const AllAchievementsScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'Account & preferences',
                      onTap: () {
                        Navigator.push(
                          context,
                          SlidePageRoute(child: const SettingsScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Log Out',
                      subtitle: null,
                      onTap: () {
                        // Immediately clear state and trigger background network logout.
                        // HomeScreen will detect the state change and handle navigation.
                        context.read<AuthViewModel>().logout();
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── Stat Card ──────────────────────────────────────────────────────

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return TapScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: AppTypography.headlineSmall
                      .copyWith(color: AppColors.onSurface)),
              const SizedBox(height: 2),
              Text(label,
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Saved Place Card (horizontal scroll item) ──────────────────────

  Widget _buildSavedPlaceCard(Place place, PlacesViewModel placesVM) {
    final imageUrl = place.mainImageUrl ?? place.imageUrl;
    final resolvedUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http')
        ? imageUrl
        : imageUrl.isNotEmpty && imageUrl.startsWith('/')
            ? '${resolveApiBaseUrl()}$imageUrl'
            : imageUrl.isNotEmpty
                ? '${resolveApiBaseUrl()}/$imageUrl'
                : null;

    return TapScale(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailScreen(
                  placeId: place.id, placeName: place.name),
            ),
          );
        },
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.ambient,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Place image
                resolvedUrl != null
                    ? Image.network(
                        resolvedUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.image,
                              color: AppColors.outlineVariant),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Icon(Icons.image,
                            color: AppColors.outlineVariant),
                      ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),

                // Heart icon (top-right) — always red since it's a saved place
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => placesVM.toggleFavorite(place),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Place name (bottom)
                Positioned(
                  bottom: 8,
                  left: 10,
                  right: 10,
                  child: Text(
                    place.name,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Menu Item ─────────────────────────────────────────────────────

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color iconColor =
        isDestructive ? AppColors.error : AppColors.primaryContainer;
    final Color titleColor =
        isDestructive ? AppColors.error : AppColors.onSurface;

    return TapScale(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTypography.titleMedium
                            .copyWith(color: titleColor)),
                    if (subtitle != null)
                      Text(subtitle,
                          style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.outlineVariant, size: 20),
            ],
          ),
        ),
      );
  }

  // ── Redeem Modal ───────────────────────────────────────────────────

  void _showRedeemModal(BuildContext context, VoucherProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(24).copyWith(
                  bottom: MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Redeem Rewards',
                          style: AppTypography.headlineMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                            '${provider.availablePoints(context)} pts',
                            style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primaryContainer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: availableRewards.map((reward) {
                          final canAfford = provider.canAfford(
                              context, reward.pointsCost);
                          return _buildRewardItem(context, setState,
                              provider, reward, canAfford);
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRewardItem(BuildContext context, StateSetter setState,
      VoucherProvider provider, RewardItem reward, bool canAfford) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: canAfford
            ? () {
                final voucher = provider.redeemVoucher(context, reward);
                if (voucher != null) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Redeemed ${reward.title}! Check your vouchers.')),
                  );
                }
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: canAfford
                    ? AppColors.primaryContainer.withValues(alpha: 0.5)
                    : AppColors.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: canAfford
                ? [
                    BoxShadow(
                      color:
                          AppColors.primaryContainer.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canAfford
                      ? AppColors.primaryContainer.withValues(alpha: 0.1)
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(reward.icon,
                    color: canAfford
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reward.title,
                        style: AppTypography.titleMedium.copyWith(
                            color: canAfford
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant)),
                    Text(reward.partner,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.outline)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canAfford
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${reward.pointsCost} pts',
                    style: AppTypography.labelSmall.copyWith(
                        color: canAfford
                            ? Colors.white
                            : AppColors.outline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
