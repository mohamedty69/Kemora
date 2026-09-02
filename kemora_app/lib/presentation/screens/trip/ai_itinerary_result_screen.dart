// [KEMORA-DEPRECATED] Old trip result screen — replaced by TripRoadmapScreen.
// Navigation from AI Trip Planner now goes to: TripRoadmapScreen(itinerary: ..., request: ...)
// Do NOT navigate here. Kept for reference only.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/ai_itinerary.dart';

import '../../../domain/entities/trip_plan_request.dart';
import '../../viewmodels/trip_view_model.dart';

class AIItineraryResultScreen extends StatefulWidget {
  final AIItinerary itinerary;
  final TripPlanRequest request;

  const AIItineraryResultScreen({
    super.key,
    required this.itinerary,
    required this.request,
  });

  @override
  State<AIItineraryResultScreen> createState() => _AIItineraryResultScreenState();
}

class _AIItineraryResultScreenState extends State<AIItineraryResultScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tripVM = context.watch<TripViewModel>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Your AI Plan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          _buildAlternativeSelector(tripVM),
        ],
      ),
      body: tripVM.state == TripState.loading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC5A358)))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: widget.itinerary.days.length,
              itemBuilder: (context, index) {
                final day = widget.itinerary.days[index];
                return _buildDayVerticalView(day);
              },
            ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAlternativeSelector(TripViewModel tripVM) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.alt_route, color: Color(0xFFC5A358)),
      onSelected: (index) async {
        final newRequest = widget.request.copyWith(alternativeIndex: index);
        await tripVM.generateAiItinerary(newRequest);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: Text('Alternative 1 (Primary)')),
        const PopupMenuItem(value: 2, child: Text('Alternative 2')),
        const PopupMenuItem(value: 3, child: Text('Alternative 3')),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Discard', style: TextStyle(color: Colors.black87)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onSavePlan(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayVerticalView(TripDay day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Day ${day.dayNumber}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC5A358),
            ),
          ),
        ),
        ...day.activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTimeline(index, day.activities.length),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActivityCard(activity)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeline(int index, int total) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(color: Color(0xFFC5A358), shape: BoxShape.circle),
        ),
        if (index != total - 1)
          Expanded(
            child: Container(
              width: 2,
              color: Colors.grey[300],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityCard(ItineraryItem activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: activity.imageUrl != null 
                  ? Image.network(activity.imageUrl!, height: 160, width: double.infinity, fit: BoxFit.cover)
                  : Container(height: 160, color: Colors.grey[100], child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black87.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    activity.timeOfDay.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFFC5A358), size: 20),
                      onPressed: () => _onSwapPlace(activity),
                      tooltip: 'Swap this place',
                    ),
                  ],
                ),
                Text(
                  activity.description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                ),
                if (activity.itineraryReview != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '💡 Tip: ${activity.itineraryReview!}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFC5A358), fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSwapPlace(ItineraryItem activity) async {
    final tripVM = context.read<TripViewModel>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFC5A358)),
                SizedBox(height: 20),
                Text('Swapping with something better...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    await tripVM.swapPlace(activity.name, widget.request.preferences ?? '');

    if (mounted) {
      Navigator.pop(context);
      if (tripVM.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tripVM.errorMessage!)));
      }
    }
  }

  void _onSavePlan(BuildContext context) async {
    final tripVM = context.read<TripViewModel>();
    
    final DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'When does your journey start?',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC5A358),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (startDate == null) return;

    final DateTime endDate = startDate.add(Duration(days: widget.itinerary.days.length - 1));

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFC5A358)),
                SizedBox(height: 20),
                Text('Saving your dream trip...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await tripVM.savePlan(startDate, endDate);

    if (context.mounted) {
      Navigator.pop(context); // Pop loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan saved successfully! Check My Trips.'),
            backgroundColor: Color(0xFFC5A358),
          ),
        );
        // Navigate back to the main trip planner screen
        Navigator.pop(context); // Pop result screen
        Navigator.pop(context); // Pop generate screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tripVM.errorMessage ?? 'Failed to save plan')),
        );
      }
    }
  }
}
