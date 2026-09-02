import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../viewmodels/places_view_model.dart';
import '../../../domain/entities/place.dart';

class CustomRoadmapScreen extends StatefulWidget {
  const CustomRoadmapScreen({super.key});

  @override
  State<CustomRoadmapScreen> createState() => _CustomRoadmapScreenState();
}

class _CustomRoadmapScreenState extends State<CustomRoadmapScreen> {
  int _selectedDay = 0;
  final TextEditingController _titleController = TextEditingController(text: 'My Egyptian Odyssey');
  
  // State: list of days, each day has a list of Place
  final List<List<Place>> _roadmap = [
    [], // Day 1
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PlacesViewModel>();
      if (vm.places.isEmpty) {
        vm.loadPlaces();
      }
    });
  }

  void _addDay() {
    setState(() {
      _roadmap.add([]);
      _selectedDay = _roadmap.length - 1;
    });
  }

  void _showAddPlaceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddPlaceSheet(
          onAddPlace: (place) {
            setState(() {
              _roadmap[_selectedDay].add(place);
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BUILD YOUR ROADMAP', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: AppTypography.headlineLarge,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          
          // Day Selector
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _roadmap.length + 1,
              itemBuilder: (context, index) {
                if (index == _roadmap.length) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      label: const Icon(Icons.add, size: 20),
                      onPressed: _addDay,
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide.none,
                    ),
                  );
                }
                final isSelected = index == _selectedDay;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Day ${index + 1}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedDay = index);
                    },
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Places List
          Expanded(
            child: _roadmap[_selectedDay].isEmpty
                ? Center(
                    child: Text(
                      'No places added yet.\nTap + to add a destination.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.outline),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: _roadmap[_selectedDay].length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = _roadmap[_selectedDay].removeAt(oldIndex);
                        _roadmap[_selectedDay].insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final place = _roadmap[_selectedDay][index];
                      return Card(
                        key: ValueKey('${place.id}_$index'),
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: AppColors.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: place.mainImageUrl != null && place.mainImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(place.mainImageUrl!, fit: BoxFit.cover, width: 48, height: 48),
                                  )
                                : const Icon(Icons.image, color: AppColors.outlineVariant),
                          ),
                          title: Text(place.name, style: AppTypography.titleMedium),
                          subtitle: Text(place.type ?? 'Place', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                                onPressed: () {
                                  setState(() {
                                    _roadmap[_selectedDay].removeAt(index);
                                  });
                                },
                              ),
                              const Icon(Icons.drag_handle, color: AppColors.outline),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryContainer,
        onPressed: _showAddPlaceBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save Draft'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                // [KEMORA-TODO] TripRoadmapScreen now requires a real AIItinerary.
                // Connect this to the AI planner flow to preview a generated plan.
                onPressed: null,
                child: const Text('Preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlaceSheet extends StatefulWidget {
  final Function(Place) onAddPlace;
  const _AddPlaceSheet({required this.onAddPlace});

  @override
  State<_AddPlaceSheet> createState() => _AddPlaceSheetState();
}

class _AddPlaceSheetState extends State<_AddPlaceSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<PlacesViewModel>(
      builder: (context, placesViewModel, child) {
        final places = placesViewModel.places;
        final filteredPlaces = places
            .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
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
              Text('Add Destination', style: AppTypography.headlineMedium),
              const SizedBox(height: 16),
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search places...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: place.mainImageUrl != null && place.mainImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(place.mainImageUrl!, fit: BoxFit.cover, width: 48, height: 48),
                              )
                            : const Icon(Icons.image, color: AppColors.outlineVariant),
                      ),
                      title: Text(place.name, style: AppTypography.titleMedium),
                      subtitle: Text(place.address ?? place.governorateName ?? 'Egypt', style: AppTypography.bodySmall),
                      trailing: ElevatedButton(
                        onPressed: () => widget.onAddPlace(place),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.1),
                          foregroundColor: AppColors.primaryContainer,
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
