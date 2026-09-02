import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/place.dart';
import '../../viewmodels/places_view_model.dart';
import '../trip/trip_planner_screen.dart';

class GovernoratePlacesScreen extends StatefulWidget {
  final Governorate governorate;

  const GovernoratePlacesScreen({super.key, required this.governorate});

  @override
  State<GovernoratePlacesScreen> createState() => _GovernoratePlacesScreenState();
}

class _GovernoratePlacesScreenState extends State<GovernoratePlacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesViewModel>().loadPlacesByGovernorate(widget.governorate.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlacesViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.governorate.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.governorate.imageUrl ?? 'https://via.placeholder.com/400', fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _buildList(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildList(PlacesViewModel viewModel) {
    if (viewModel.state == PlacesState.loading) {
      return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFC5A358))));
    }

    if (viewModel.places.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('No places found in this governorate.')));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final place = viewModel.places[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(place.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
              ),
              title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(place.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TripPlannerScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Plan', style: TextStyle(fontSize: 12)),
              ),
              onTap: () {}, // Changed onTap to an empty function as per instruction
            ),
          );
        },
        childCount: viewModel.places.length,
      ),
    );
  }
}
