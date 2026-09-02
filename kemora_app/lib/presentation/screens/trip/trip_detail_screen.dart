import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../../domain/entities/trip.dart';
import '../explore/place_detail_screen.dart';
import '../../../domain/entities/ai_itinerary.dart' as ai;
import '../../../domain/entities/trip_plan_request.dart';
import '../../viewmodels/trip_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import 'ai_step_questions_screen.dart';

enum _SaveState { idle, loading, saved, error }

class TripDetailScreen extends StatefulWidget {
  final Trip? trip;
  final ai.AIItinerary? aiItinerary;
  final TripPlanRequest? request;

  const TripDetailScreen({super.key, this.trip, this.aiItinerary, this.request});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  _SaveState _saveState = _SaveState.idle;
  bool _isLoadingDetails = false;
  Trip? _fullTrip;

  Trip? get activeTrip => _fullTrip ?? widget.trip;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null && widget.trip!.savedItinerary == null) {
      _isLoadingDetails = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final fullTrip = await context.read<TripViewModel>().loadTripDetails(widget.trip!.id);
        if (mounted && fullTrip != null) {
          setState(() {
            _fullTrip = fullTrip;
            _isLoadingDetails = false;
          });
          if (fullTrip.savedItinerary != null) {
            context.read<TripViewModel>().setCurrentPlan(fullTrip.savedItinerary!);
          }
        } else if (mounted) {
          setState(() => _isLoadingDetails = false);
        }
      });
    } else {
      _fullTrip = widget.trip;
      if (_fullTrip?.savedItinerary != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<TripViewModel>().setCurrentPlan(_fullTrip!.savedItinerary!);
        });
      }
    }
  }

  bool get isAi => widget.aiItinerary != null || activeTrip?.savedItinerary != null;

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TripViewModel>().setCurrentPlan(null);
    });
    super.dispose();
  }

  ai.AIItinerary _getCurrentAiItinerary(BuildContext context, {bool listen = true}) {
    if (!isAi) throw Exception('Not AI itinerary');
    final tripVM = listen ? context.watch<TripViewModel>() : context.read<TripViewModel>();
    return tripVM.currentPlan ?? widget.aiItinerary ?? activeTrip!.savedItinerary!;
  }

  Future<void> _onSaveTrip() async {
    final authVM = context.read<AuthViewModel>();
    if (authVM.state != AuthState.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save your trip.')),
      );
      return;
    }

    setState(() => _saveState = _SaveState.loading);

    final currentItinerary = _getCurrentAiItinerary(context, listen: false);
    // Use today as start date, compute end from itinerary length (no date picker)
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: currentItinerary.days.length > 0 ? currentItinerary.days.length - 1 : 0));

    final tripVM = context.read<TripViewModel>();
    final success = await tripVM.savePlan(startDate, endDate);

    if (!mounted) return;

    if (success) {
      setState(() => _saveState = _SaveState.saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip saved successfully! ✓'),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
    } else {
      setState(() => _saveState = _SaveState.error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tripVM.errorMessage ?? 'Could not save trip. Try again.'),
          action: SnackBarAction(label: 'Retry', onPressed: _onSaveTrip),
        ),
      );
    }
  }

  void _onSwapPlace(String currentPlaceName) async {
    final preferences = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Swap Place'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Any specific preferences? (e.g. food)'),
            onChanged: (val) => input = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, input), child: const Text('Swap')),
          ],
        );
      },
    );

    if (preferences != null) {
      if (!mounted) return;
      context.read<TripViewModel>().swapPlace(currentPlaceName, preferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDetails) {
      return Scaffold(
        appBar: KemoraAppBar(showBack: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentItinerary = isAi ? _getCurrentAiItinerary(context) : null;
    final title = isAi ? currentItinerary!.title : activeTrip!.title;
    
    // Fallback description based on the title/location
    final description = isAi 
        ? 'A beautiful journey curated especially for you, filled with unforgettable moments and hidden gems.' 
        : 'Your planned expedition and itinerary details.';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6), // Cream background from design
      appBar: KemoraAppBar(
        showBack: true,
        trailing: isAi && _saveState != _SaveState.saved
            ? GestureDetector(
                onTap: _saveState == _SaveState.loading ? null : _onSaveTrip,
                child: _saveState == _SaveState.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Save Trip', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryContainer)),
              )
            : null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAi) ...[
                  Text(
                    'CURATED BY AI',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF8C713B),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 36,
                    height: 1.1,
                    fontFamily: 'PlayfairDisplay', // Or whatever serif font is configured
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 40),
                if (isAi)
                  ..._getCurrentAiItinerary(context).days.asMap().entries.map((entry) => _buildAiDaySection(context, entry.key, entry.value))
                else
                  _buildTripPlacesSection(context, activeTrip!.plannedPlaces),
              ],
            ),
          ),
          
          // Fixed Bottom Button — "Done": returns the user to the AI trip
          // planner wizard so they can start a new plan with a clean stack.
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AiStepQuestionsScreen()),
                  (route) => route.isFirst,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B611C), // Deep olive/gold
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
                shadowColor: const Color(0xFF7B611C).withValues(alpha: 0.4),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripPlacesSection(BuildContext context, List<dynamic> places) {
    if (places.isEmpty) return const Text('No places planned yet.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Planned Places', style: AppTypography.titleLarge),
        const SizedBox(height: 16),
        ...List.generate(places.length, (index) {
          final place = places[index];
          final isLast = index == places.length - 1;
          return _buildTimelineStop(context, place, isLast);
        }),
      ],
    );
  }

  Widget _buildAiDaySection(BuildContext context, int dayIndex, ai.TripDay day) {
    // Generate a mock date for the UI display based on today + dayIndex
    final date = DateTime.now().add(Duration(days: dayIndex));
    final dateString = _formatDate(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF7B611C), // Deep olive/gold
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${day.dayNumber}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dailySummary ?? 'Day ${day.dayNumber} Exploration',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateString,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: day.activities.length,
          onReorder: (oldIndex, newIndex) {
            context.read<TripViewModel>().reorderPlace(dayIndex, oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final isLast = index == day.activities.length - 1;
            return Container(
              key: ValueKey(day.activities[index].name + index.toString()),
              child: _buildAiTimelineStop(context, dayIndex, index, day.activities[index], isLast),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTimelineStop(BuildContext context, dynamic place, bool isLast) {
    return _buildStopBase(
      context: context,
      isLast: isLast,
      name: place.name,
      time: '',
      description: place.description ?? '',
      imageUrl: place.mainImageUrl,
      isNetworkImage: true,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: place.id, placeName: place.name)));
      },
    );
  }

  Widget _buildAiTimelineStop(BuildContext context, int dayIndex, int activityIndex, ai.ItineraryItem stop, bool isLast) {
    final timeLabel = (stop.time != null && stop.time!.isNotEmpty)
        ? stop.time!
        : stop.timeOfDay;

    return _buildStopBase(
      context: context,
      isLast: isLast,
      name: stop.name,
      time: timeLabel,
      description: stop.description,
      imageUrl: stop.imageUrl,
      isNetworkImage: true,
      category: stop.category,
      rating: stop.rating,
      itineraryReview: stop.itineraryReview,
      onRefreshTap: () => _onSwapPlace(stop.name),
      onTap: stop.dbPlaceId != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlaceDetailScreen(placeId: stop.dbPlaceId.toString(), placeName: stop.name),
                ),
              )
          : null,
    );
  }

  Widget _buildStopBase({
    required BuildContext context,
    required bool isLast,
    required String name,
    required String time,
    required String description,
    String? imageUrl,
    bool isNetworkImage = false,
    String? category,
    double? rating,
    String? itineraryReview,
    VoidCallback? onTap,
    VoidCallback? onRefreshTap,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 48), // Push circle down to align with card center (approx)
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: const Color(0xFF7B611C), width: 3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFD4C8B8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Main Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section with Time Pill
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(24)),
                            child: _buildImage(imageUrl, isNetworkImage),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                time,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Text Section
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'PlayfairDisplay',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                if (onRefreshTap != null)
                                  GestureDetector(
                                    onTap: onRefreshTap,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF6EE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.refresh, size: 18, color: Color(0xFFB59351)),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (description.isNotEmpty)
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B6B6B),
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (itineraryReview != null && itineraryReview.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF6EE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.format_quote, size: 16, color: Color(0xFFB59351)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        itineraryReview,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF8C713B),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Category & Rating Row
                            Row(
                              children: [
                                if (category != null && category.isNotEmpty) ...[
                                  Icon(_categoryIcon(category), size: 16, color: const Color(0xFF8C713B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    category,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF8C713B), fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                if (rating != null && rating > 0) ...[
                                  const Icon(Icons.star_border, size: 16, color: Color(0xFF8C713B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$rating Rating',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF8C713B), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imageUrl, bool isNetwork) {
    const double height = 180;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFE8E4DB),
        child: const Icon(Icons.landscape, size: 64, color: Color(0xFFC4BBAF)),
      );
    }
    
    // Some Cloudinary URLs might be missing https:// prefix in DB, though unlikely.
    String url = imageUrl;
    if (url.startsWith('//')) {
      url = 'https:$url';
    }

    if (isNetwork) {
      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: double.infinity,
            color: const Color(0xFFE8E4DB),
            child: const Icon(Icons.broken_image, size: 64, color: Color(0xFFC4BBAF)),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: double.infinity,
            color: const Color(0xFFE8E4DB),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFB59351)),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: height,
          width: double.infinity,
          color: const Color(0xFFE8E4DB),
          child: const Icon(Icons.broken_image, size: 64, color: Color(0xFFC4BBAF)),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    String daySuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1: return 'st';
        case 2: return 'nd';
        case 3: return 'rd';
        default: return 'th';
      }
    }
    
    return '${months[date.month - 1]} ${date.day}${daySuffix(date.day)}, ${date.year}';
  }

  IconData _categoryIcon(String? category) {
    if (category == null) return Icons.place;
    final c = category.toLowerCase();
    if (c.contains('histor') || c.contains('ancient') || c.contains('ruin') ||
        c.contains('temple') || c.contains('pyramid') || c.contains('monument')) {
      return Icons.account_balance;
    }
    if (c.contains('museum') || c.contains('cultur')) return Icons.museum;
    if (c.contains('hotel') || c.contains('resort') || c.contains('accommodation')) return Icons.hotel;
    if (c.contains('restaurant') || c.contains('food') || c.contains('dining') ||
        c.contains('cuisine') || c.contains('cafe') || c.contains('culinary')) return Icons.restaurant;
    if (c.contains('beach') || c.contains('sea')) return Icons.beach_access;
    if (c.contains('adventure') || c.contains('safari') || c.contains('desert')) return Icons.terrain;
    if (c.contains('religi') || c.contains('mosque') || c.contains('church')) return Icons.church;
    if (c.contains('nature') || c.contains('park')) return Icons.park;
    if (c.contains('shop') || c.contains('market') || c.contains('bazaar')) return Icons.shopping_bag;
    return Icons.place;
  }
}
