import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../viewmodels/places_view_model.dart';
import '../explore/place_detail_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KemoraAppBar(
        showBack: true,
        trailing: Text('Saved Places', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
      ),
      body: Consumer<PlacesViewModel>(
        builder: (context, placesViewModel, child) {

          final savedPlaces = placesViewModel.favorites;

          if (savedPlaces.isEmpty) {
            return Center(child: Text('No saved places yet.', style: AppTypography.titleMedium));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: savedPlaces.length,
            itemBuilder: (context, index) {
              final place = savedPlaces[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id, placeName: place.name)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: AppColors.surfaceContainerHigh,
                            child: (place.mainImageUrl ?? place.imageUrl).isNotEmpty
                                ? ((place.mainImageUrl ?? place.imageUrl).startsWith('http')
                                    ? Image.network(place.mainImageUrl ?? place.imageUrl, fit: BoxFit.cover)
                                    : Image.asset(place.mainImageUrl ?? place.imageUrl, fit: BoxFit.cover))
                                : const Icon(Icons.image, color: AppColors.outlineVariant),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place.name, style: AppTypography.titleMedium),
                              const SizedBox(height: 4),
                              Text(place.address ?? place.governorateName ?? 'Egypt', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                  Text('${place.rating}', style: AppTypography.labelSmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            placesViewModel.toggleFavorite(place);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              placesViewModel.isFavorite(place.id) ? Icons.favorite : Icons.favorite_border,
                              color: placesViewModel.isFavorite(place.id) ? AppColors.primaryContainer : AppColors.outlineVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
