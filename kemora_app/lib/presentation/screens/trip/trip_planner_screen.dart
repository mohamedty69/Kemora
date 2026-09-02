import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';


class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  bool _isAiPlanner = true;
  double _budget = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan Your Adventure', style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Craft the perfect Egyptian journey.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Segmented Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAiPlanner = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isAiPlanner ? AppColors.surfaceContainerLowest : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _isAiPlanner ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                        ),
                        child: Center(
                          child: Text(
                            'AI Planner',
                            style: AppTypography.labelLarge.copyWith(
                              color: _isAiPlanner ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAiPlanner = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isAiPlanner ? AppColors.surfaceContainerLowest : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: !_isAiPlanner ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                        ),
                        child: Center(
                          child: Text(
                            'Custom Builder',
                            style: AppTypography.labelLarge.copyWith(
                              color: !_isAiPlanner ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Form
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DESTINATION CITY', style: AppTypography.labelSmall),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'e.g. Luxor, Cairo, Aswan',
                      suffixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DURATION', style: AppTypography.labelSmall),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('7', style: AppTypography.titleMedium),
                                  Text('DAYS', style: AppTypography.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BUDGET RANGE', style: AppTypography.labelSmall),
                            const SizedBox(height: 8),
                            Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.primaryContainer,
                                  inactiveTrackColor: AppColors.outlineVariant,
                                  thumbColor: AppColors.primaryContainer,
                                ),
                                child: Slider(
                                  value: _budget,
                                  min: 0,
                                  max: 100,
                                  onChanged: (val) => setState(() => _budget = val),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text('INTERESTS', style: AppTypography.labelSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInterestChip('History', Icons.history, true),
                      _buildInterestChip('Adventure', null, false),
                      _buildInterestChip('Culinary', Icons.restaurant, true),
                      _buildInterestChip('Beaches', null, false),
                      _buildInterestChip('Shopping', null, false),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    // [KEMORA-TODO] TripPlannerScreen is a mock UI — connect to AiStepQuestionsScreen.
                    // TripRoadmapScreen now requires a real AIItinerary from the AI Trip Planner API.
                    onPressed: null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Itinerary'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Drafts', style: AppTypography.titleLarge),
                Text('VIEW ALL', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Draft List
            _buildDraftItem('Pharaohs & Pyramids', '5 Days • Cairo & Giza'),
            const SizedBox(height: 16),
            _buildDraftItem('Nile River Cruise', '4 Days • Aswan to Luxor'),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label, IconData? icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.image, color: AppColors.outlineVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}
