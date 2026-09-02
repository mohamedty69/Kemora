import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/filter_chip_row.dart';
import '../../widgets/editorial_place_card.dart';
import '../../viewmodels/places_view_model.dart';
import '../../../domain/entities/place.dart';
import 'place_detail_screen.dart';

class PlacesScreen extends StatefulWidget {
  final String? governorate;
  final String? initialSearchQuery;
  
  const PlacesScreen({super.key, this.governorate, this.initialSearchQuery});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  int _selectedFilter = 0;

  // (display label, real DB category name). Mirrors the Home screen filters so the
  // categories here match what the backend knows how to hydrate. null = All.
  static const List<({String label, String? category})> _filters = [
    (label: 'All', category: null),
    (label: 'Historical', category: 'Historical'),
    (label: 'Beach', category: 'Beach'),
    (label: 'Cultural', category: 'Cultural'),
    (label: 'Adventure', category: 'Adventure'),
    (label: 'Religious', category: 'Religious'),
    (label: 'Nature', category: 'Nature'),
  ];

  List<String> get _filterLabels => _filters.map((f) => f.label).toList();
  final TextEditingController _searchController = TextEditingController();

  // Resolved governorate id for the active screen (from widget.governorate or a
  // search query that matches a governorate name). When non-null, category chips
  // and searches are scoped to this governorate.
  String? _activeGovernorateId;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<PlacesViewModel>();
      if (vm.governorates.isEmpty) {
        await vm.loadGovernorates();
      }

      // Prefer an explicit governorate, then try to resolve the search query to a
      // governorate name — the governorateId path hydrates from Google when the DB
      // has no places yet, whereas free-text search does not.
      final candidate = widget.governorate ?? widget.initialSearchQuery;
      final govId = candidate != null ? vm.governorateIdByName(candidate.trim()) : null;

      _activeGovernorateId = govId;
      if (govId != null) {
        vm.loadPlacesByGovernorate(govId);
      } else {
        vm.loadPlaces(search: widget.initialSearchQuery);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  /// Runs a search, routing recognised governorate names through the
  /// governorateId path (which hydrates from Google when the DB is empty).
  void _runSearch(String query) {
    final vm = context.read<PlacesViewModel>();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _activeGovernorateId = null;
      _applyCurrentFilter(vm);
      return;
    }
    final govId = vm.governorateIdByName(trimmed);
    _activeGovernorateId = govId;
    if (govId != null) {
      _applyCurrentFilter(vm);
    } else {
      vm.loadPlaces(search: trimmed);
    }
  }

  /// Reloads places for the active category, scoped to the active governorate when
  /// one is set. Keeps the home-style category semantics (null category = All).
  void _applyCurrentFilter(PlacesViewModel vm) {
    final category = _filters[_selectedFilter].category;
    if (_activeGovernorateId != null) {
      vm.loadPlaces(
        category: category ?? 'All',
        governorateId: _activeGovernorateId,
      );
    } else if (category == null) {
      vm.loadPlaces();
    } else {
      vm.loadPlaces(category: category);
    }
  }

  List<Place> _getFilteredPlaces(List<Place> places) {
    // Category filtering is handled server-side (governorateId + categoryName), so
    // here we only apply the in-memory search query as the user types.
    return places.where((place) {
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final govName = place.governorateName?.toLowerCase() ?? '';
        if (!place.name.toLowerCase().contains(query) && !govName.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: Consumer<PlacesViewModel>(
        builder: (context, placesViewModel, child) {
          if (placesViewModel.state == PlacesState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (placesViewModel.state == PlacesState.error) {
            return Center(
              child: Text(
                'Error: ${placesViewModel.errorMessage}',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
              ),
            );
          }

          final results = _getFilteredPlaces(placesViewModel.places);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.governorate != null) ...[
                        Text('DISCOVER', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
                        const SizedBox(height: 8),
                        Text(widget.governorate!, style: AppTypography.headlineLarge),
                        const SizedBox(height: 16),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (query) {
                            _runSearch(query);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search places...',
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    _activeGovernorateId = null;
                                    _applyCurrentFilter(context.read<PlacesViewModel>());
                                  }
                                )
                              : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: FilterChipRow(
                  chips: _filterLabels,
                  selectedIndex: _selectedFilter,
                  onSelected: (i) {
                    setState(() => _selectedFilter = i);
                    _applyCurrentFilter(context.read<PlacesViewModel>());
                  },
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
              if (results.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'No places found matching your criteria.',
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.outline),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final place = results[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 24),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceDetailScreen(placeId: place.id),
                              ),
                            );
                          },
                          child: EditorialPlaceCard(
                            title: place.name,
                            category: place.type ?? 'Place',
                            location: place.address ?? place.governorateName ?? 'Egypt',
                            rating: place.rating.toDouble(),
                            reviewsCount: place.reviews.length,
                            price: place.priceLevel != null ? '\$' * place.priceLevel! : 'Free',
                            distance: 'N/A', // Distance needs location services
                            isFavorite: placesViewModel.isFavorite(place.id),
                            onFavoriteTap: () => placesViewModel.toggleFavorite(place),
                            imageUrl: place.mainImageUrl ?? place.imageUrl,
                          ),
                        ),
                      );
                    },
                    childCount: results.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
