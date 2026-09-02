import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../presentation/viewmodels/trip_view_model.dart';
import 'ai_step_questions_screen.dart';
import 'trip_detail_screen.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/tap_scale.dart';
import '../../../core/router/page_transitions.dart';

class TripPlannerEntryScreen extends StatefulWidget {
  const TripPlannerEntryScreen({super.key});

  @override
  State<TripPlannerEntryScreen> createState() => _TripPlannerEntryScreenState();
}

class _TripPlannerEntryScreenState extends State<TripPlannerEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripViewModel>().loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 100, bottom: 100, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header text
          FadeSlideIn(
            delayMs: 0,
            child: RichText(
              text: TextSpan(
                style: AppTypography.displaySmall.copyWith(color: AppColors.onSurface),
                children: const [
                  TextSpan(text: 'Begin Your\n'),
                  TextSpan(
                    text: 'Odyssey',
                    style: TextStyle(color: AppColors.primaryContainer),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Subtext
          FadeSlideIn(
            delayMs: 100,
            child: Text(
              'Craft the perfect Egyptian journey from the Nile to the Red Sea.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),

          const SizedBox(height: 40),

          // AI Planner Card
          FadeSlideIn(
            delayMs: 200,
            child: TapScale(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.ambient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: AppColors.primaryContainer),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'INTELLIGENT',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('AI Trip Planner', style: AppTypography.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Let our AI curate a personalized itinerary based on your interests and time.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(SlidePageRoute(child: const AiStepQuestionsScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Generate My Journey →'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

           // Removed Custom Builder Card


          // Recent Inspiration
          FadeSlideIn(
            delayMs: 500,
            child: Builder(
              builder: (context) {
                final tripVM = context.watch<TripViewModel>();
                final trips = tripVM.trips;
                final isLoading = tripVM.state == TripState.loading && trips.isEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Inspiration', style: AppTypography.titleLarge),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (trips.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.explore_outlined, size: 48, color: AppColors.outlineVariant),
                            const SizedBox(height: 12),
                            Text('No trips yet. Start planning!',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final trip = trips[index];
                            final durationDays = trip.endDate.difference(trip.startDate).inDays + 1;
                            final displayDuration = durationDays > 0 ? durationDays : 1;
                            return GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip))),
                              child: Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryContainer.withValues(alpha: 0.8),
                                      AppColors.primaryContainer,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, color: Colors.white70),
                                          onSelected: (value) {
                                            if (value == 'rename') {
                                              _showRenameDialog(context, trip);
                                            } else if (value == 'delete') {
                                              _confirmDeleteTrip(context, trip);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'rename',
                                              child: Text('Rename Trip'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete Trip', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('$displayDuration DAYS',
                                            style: AppTypography.labelSmall.copyWith(color: Colors.white)),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(trip.title,
                                          style: AppTypography.titleLarge.copyWith(color: Colors.white)),
                                      Text(trip.location,
                                          style: AppTypography.labelMedium.copyWith(color: Colors.white70)),
                                      ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
  void _showRenameDialog(BuildContext context, trip) {
    String newName = trip.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Trip'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Trip Name'),
          controller: TextEditingController(text: newName),
          onChanged: (val) => newName = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (newName.trim().isNotEmpty && newName.trim() != trip.title) {
                context.read<TripViewModel>().renameTrip(trip.id, newName.trim());
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTrip(BuildContext context, trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to permanently delete this trip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TripViewModel>().deleteTrip(trip.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
