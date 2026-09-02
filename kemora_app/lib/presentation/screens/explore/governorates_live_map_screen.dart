import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/router/page_transitions.dart';
import '../../viewmodels/places_view_model.dart';
import '../../widgets/kemora_app_bar.dart';
import 'governorate_detail_screen.dart';

/// Full-screen interactive map of Egypt with a marker per governorate, opened
/// from the "Open Live Map" trigger on the Explore grid. Tapping a marker's
/// info window opens that governorate's detail screen.
import 'package:permission_handler/permission_handler.dart';

class GovernoratesLiveMapScreen extends StatefulWidget {
  const GovernoratesLiveMapScreen({super.key});

  @override
  State<GovernoratesLiveMapScreen> createState() =>
      _GovernoratesLiveMapScreenState();
}

class _GovernoratesLiveMapScreenState extends State<GovernoratesLiveMapScreen> {
  // Roughly centers the viewport on Egypt.
  static const CameraPosition _egypt = CameraPosition(
    target: LatLng(26.8, 30.8),
    zoom: 5.3,
  );

  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (mounted && status.isGranted) {
      setState(() {
        _locationGranted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<PlacesViewModel>();

    final markers = vm.governorates
        .where((g) => g.latitude != 0 || g.longitude != 0)
        .map(
          (g) => Marker(
            markerId: MarkerId(g.id),
            position: LatLng(g.latitude, g.longitude),
            infoWindow: InfoWindow(
              title: g.name,
              snippet: g.region ?? 'Egypt',
              onTap: () => Navigator.of(context).push(
                SlidePageRoute(
                  child: GovernorateDetailScreen(governorate: g),
                ),
              ),
            ),
          ),
        )
        .toSet();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const KemoraAppBar(showBack: true),
      body: GoogleMap(
        initialCameraPosition: _egypt,
        markers: markers,
        myLocationEnabled: _locationGranted,
        myLocationButtonEnabled: _locationGranted,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
