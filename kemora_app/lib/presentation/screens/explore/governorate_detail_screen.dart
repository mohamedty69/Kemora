import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/editorial_place_card.dart';
import '../../viewmodels/places_view_model.dart';
import '../../../domain/entities/place.dart';
import 'place_detail_screen.dart';
import 'places_screen.dart';

/// Detailed view of a single governorate with categorized place sections,
/// matching the Home design style with a sticky search bar.
class GovernorateDetailScreen extends StatefulWidget {
  final Governorate governorate;
  const GovernorateDetailScreen({super.key, required this.governorate});

  @override
  State<GovernorateDetailScreen> createState() => _GovernorateDetailScreenState();
}

class _GovernorateDetailScreenState extends State<GovernorateDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasRetried = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<PlacesViewModel>();
      if (vm.governorates.isEmpty) {
        await vm.loadGovernorates();
      }
      final govId = vm.governorateIdByName(widget.governorate.name);
      if (govId != null) {
        await vm.loadPlacesByGovernorate(govId);
        // Retry once if empty — backend hydration may be async
        if (vm.places.isEmpty && vm.state == PlacesState.loaded && !_hasRetried && mounted) {
          _hasRetried = true;
          setState(() => _isRetrying = true);
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            await vm.loadPlacesByGovernorate(govId);
            setState(() => _isRetrying = false);
          }
        }
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final vm = context.read<PlacesViewModel>();
      final govId = vm.governorateIdByName(widget.governorate.name);
      if (govId != null && vm.hasMoreGovernoratePlaces && !vm.isLoadingMoreGovernoratePlaces) {
        vm.loadPlacesByGovernorate(govId, isLoadMore: true);
      }
    }
  }


  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Place> _getGovPlaces(List<Place> places) {
    return places.where((p) {
      if (_searchController.text.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
  }



  @override
  Widget build(BuildContext context) {
    final placesViewModel = context.watch<PlacesViewModel>();
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: Consumer<PlacesViewModel>(
        builder: (context, placesViewModel, child) {
          if (placesViewModel.state == PlacesState.loading || _isRetrying) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (_isRetrying) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Loading places...',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            );
          }

          final places = _getGovPlaces(placesViewModel.places);

          return RefreshIndicator(
            onRefresh: () async {
              final govId = placesViewModel.governorateIdByName(widget.governorate.name);
              if (govId != null) {
                await placesViewModel.loadPlacesByGovernorate(govId);
              }
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Hero header
                SliverToBoxAdapter(child: _buildHeader()),
                // Sticky search bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    controller: _searchController,
                    onChanged: () => setState(() {}),
                  ),
                ),
                // Categorized sections
                ..._buildSections(places),
                if (placesViewModel.isLoadingMoreGovernoratePlaces)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DISCOVER', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
          const SizedBox(height: 8),
          Text(widget.governorate.name, style: AppTypography.displaySmall),
          const SizedBox(height: 12),
          // Weather row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wb_sunny_rounded, color: AppColors.tertiary, size: 20),
                const SizedBox(width: 8),
                Text(context.read<PlacesViewModel>().getGovernorateTemperature(widget.governorate.id), style: AppTypography.titleMedium),
                const SizedBox(width: 12),
                Text(
                  context.read<PlacesViewModel>().getGovernorateWeatherCode(widget.governorate.id),
                  style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Top Activities
          Builder(builder: (context) {
            final activities = context.read<PlacesViewModel>().getGovernorateActivities(widget.governorate.id);
            return Row(
              children: [
                ...activities.take(2).map((a) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Chip(
                        avatar: Icon(a.icon, size: 16, color: AppColors.primaryContainer),
                        label: Text(a.label),
                        backgroundColor: AppColors.surfaceContainerLowest,
                        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                      ),
                    )),
                if (activities.length > 2)
                  ActionChip(
                    label: Text('Show All (${activities.length})',
                        style: TextStyle(color: AppColors.primaryContainer)),
                    backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    onPressed: () => _showAllActivities(context, activities),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildSections(List<Place> places) {
    final sections = <Widget>[];

    if (places.isEmpty) {
      sections.add(SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No places found for ${widget.governorate.name}.',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.outline),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final vm = context.read<PlacesViewModel>();
                    final govId = vm.governorateIdByName(widget.governorate.name);
                    if (govId != null) {
                      await vm.loadPlacesByGovernorate(govId);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      ));
      return sections;
    }

    final categories = places.map((p) => p.category ?? 'Places').toSet().toList();
    categories.sort();

    for (final categoryName in categories) {
      final categoryPlaces = places.where((p) => (p.category ?? 'Places') == categoryName).toList();
      if (categoryPlaces.isEmpty) continue;

      IconData sectionIcon = Icons.place;
      String lowerCat = categoryName.toLowerCase();
      if (lowerCat.contains('museum') || lowerCat.contains('culture')) sectionIcon = Icons.museum;
      else if (lowerCat.contains('temple') || lowerCat.contains('pyramid') || lowerCat.contains('historic')) sectionIcon = Icons.account_balance;
      else if (lowerCat.contains('hotel') || lowerCat.contains('resort')) sectionIcon = Icons.hotel;
      else if (lowerCat.contains('restaurant') || lowerCat.contains('food')) sectionIcon = Icons.restaurant;
      else if (lowerCat.contains('park') || lowerCat.contains('nature')) sectionIcon = Icons.park;

      sections.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(sectionIcon, size: 20, color: AppColors.primaryContainer),
                  const SizedBox(width: 8),
                  Text(categoryName, style: AppTypography.titleLarge),
                ],
              ),
              if (categoryPlaces.length > 2)
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PlacesScreen(governorate: widget.governorate.name),
                  )),
                  child: Text('See All →',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.primaryContainer)),
                ),
            ],
          ),
        ),
      ));

      sections.add(SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categoryPlaces.length,
            itemBuilder: (context, index) {
              final place = categoryPlaces[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 240,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id))),
                    child: EditorialPlaceCard(
                      title: place.name,
                      category: place.category ?? 'Place',
                      location: place.address ?? place.governorateName ?? 'Egypt',
                      rating: place.rating.toDouble(),
                      reviewsCount: place.reviews.length,
                      price: place.priceLevel != null ? '\$' * place.priceLevel! : 'Free',
                      distance: 'N/A', // Distance needs location services
                      isFavorite: context.watch<PlacesViewModel>().isFavorite(place.id),
                      onFavoriteTap: () => context.read<PlacesViewModel>().toggleFavorite(place),
                      imageUrl: place.mainImageUrl ?? place.imageUrl,
                      aspectRatio: 1.6,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ));
    }

    return sections;
  }

  void _showAllActivities(BuildContext context, List<ActivityInfo> activities) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Activities', style: AppTypography.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activities
                  .map((a) => Chip(
                        avatar: Icon(a.icon, size: 16),
                        label: Text(a.label),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final VoidCallback onChanged;

  _SearchBarDelegate({required this.controller, required this.onChanged});

  @override
  double get minExtent => 72;
  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Search places...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close), onPressed: () { controller.clear(); onChanged(); })
                : null,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => true;
}
