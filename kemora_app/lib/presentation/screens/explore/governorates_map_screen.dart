import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/router/page_transitions.dart';
import '../../../domain/entities/place.dart';
import '../../viewmodels/places_view_model.dart';
import '../../widgets/fade_slide_in.dart';
import 'governorate_detail_screen.dart';
import 'governorates_live_map_screen.dart';

/// Explore tab — a scrollable bento grid of governorate cards matching the
/// Stitch "Explore Governorates" design: image cards with a weather chip and a
/// region pill, region filter chips, and an "Interactive Map View" trigger that
/// opens the full-screen live map.
///
/// (Kept the name `GovernoratesMapScreen` so the Explore tab wiring in
/// home_screen.dart stays unchanged, even though it is no longer map-first.)
class GovernoratesMapScreen extends StatefulWidget {
  const GovernoratesMapScreen({super.key});

  @override
  State<GovernoratesMapScreen> createState() => _GovernoratesMapScreenState();
}

class _GovernoratesMapScreenState extends State<GovernoratesMapScreen> {
  static const String _allRegions = 'All Regions';
  String _selectedRegion = _allRegions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PlacesViewModel>();
      if (vm.governorates.isEmpty) {
        vm.loadGovernorates();
      }
    });
  }

  /// Distinct, non-empty region names in the loaded governorates, plus the
  /// leading "All Regions" chip.
  List<String> _regionOptions(List<Governorate> governorates) {
    final regions = governorates
        .map((g) => g.region)
        .whereType<String>()
        .where((r) => r.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return [_allRegions, ...regions];
  }

  List<Governorate> _filtered(List<Governorate> governorates) {
    if (_selectedRegion == _allRegions) return governorates;
    return governorates.where((g) => g.region == _selectedRegion).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PlacesViewModel>(
        builder: (context, vm, child) {
          if (vm.governorates.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final validGovernorates = vm.governorates.where((g) => g.imageUrl != null && g.imageUrl!.isNotEmpty).toList();
          final regions = _regionOptions(validGovernorates);
          final governorates = _filtered(validGovernorates);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  delayMs: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Governorates',
                              style: AppTypography.displaySmall
                                  .copyWith(color: AppColors.primary)),
                          const SizedBox(height: 8),
                          Text(
                            'Embark on a journey across the diverse landscapes of Egypt, from the Mediterranean coast to the heart of the Sahara.',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Region filter chips
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  delayMs: 100,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(regions.length, (index) {
                        final region = regions[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _RegionChip(
                            label: region,
                            selected: region == _selectedRegion,
                            onTap: () => setState(() => _selectedRegion = region),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Bento grid of governorate cards (uniform 2-column grid — a
              // pragmatic stand-in for Stitch's variable spans without pulling
              // in a staggered-grid package).
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final gov = governorates[index];
                      return FadeSlideIn(
                        delayMs: 150 + (index % 6) * 60,
                        child: _GovernorateCard(
                          governorate: gov,
                          temperature: vm.getGovernorateTemperature(gov.id),
                          weather: vm.getGovernorateWeatherCode(gov.id),
                          onTap: () => Navigator.of(context).push(
                            SlidePageRoute(
                              child:
                                  GovernorateDetailScreen(governorate: gov),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: governorates.length,
                  ),
                ),
              ),

              // Interactive Map View trigger
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  delayMs: 250,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    child: _MapTriggerCard(
                      onOpen: () => Navigator.of(context).push(
                        SlidePageRoute(child: const GovernoratesLiveMapScreen()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RegionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.filter_list,
                  size: 18, color: AppColors.onPrimary),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: AppTypography.labelLarge.copyWith(
                    color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _GovernorateCard extends StatelessWidget {
  final Governorate governorate;
  final String temperature;
  final String weather;
  final VoidCallback onTap;

  const _GovernorateCard({
    required this.governorate,
    required this.temperature,
    required this.weather,
    required this.onTap,
  });

  /// Picks a weather glyph from the condition text prefetched for the
  /// governorate (e.g. "Clear", "Clouds", "Rain").
  IconData get _weatherIcon {
    final w = weather.toLowerCase();
    if (w.contains('cloud')) return Icons.cloud;
    if (w.contains('rain') || w.contains('drizzle')) return Icons.water_drop;
    if (w.contains('storm') || w.contains('thunder')) return Icons.thunderstorm;
    if (w.contains('snow')) return Icons.ac_unit;
    return Icons.wb_sunny;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.editorial,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Base image
              if (governorate.imageUrl != null &&
                  governorate.imageUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: governorate.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _placeholder(),
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              else
                _placeholder(),

              // Dark gradient for legibility
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black26,
                      Colors.black87,
                    ],
                    stops: [0.35, 0.65, 1.0],
                  ),
                ),
              ),

              // Weather chip (top-right)
              Positioned(
                top: 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_weatherIcon, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(temperature,
                              style: AppTypography.labelSmall
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Region pill + name (bottom-left)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        governorate.region ?? 'Egypt',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.onPrimaryContainer),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      governorate.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceContainerHigh,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.outline, size: 48),
      ),
    );
  }
}

class _MapTriggerCard extends StatelessWidget {
  final VoidCallback onOpen;
  const _MapTriggerCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.map, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Interactive Map View',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(
            'Explore the full geography of Egypt and jump straight to any governorate.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onOpen,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
            ),
            child: Text('Open Live Map', style: AppTypography.labelLarge),
          ),
        ],
      ),
    );
  }
}
