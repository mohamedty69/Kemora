import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../auth/login_screen.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../widgets/floating_nav_bar.dart';
import 'home_content_screen.dart';
import '../explore/governorates_map_screen.dart';
import '../trip/trip_planner_entry_screen.dart';
import '../social/feed_screen.dart';
import '../profile/public_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      HomeContentScreen(
        onSwitchTab: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        },
      ),
      const GovernoratesMapScreen(),
      const TripPlannerEntryScreen(),
      const FeedScreen(),
      const PublicProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthViewModel>().state;

    // Navigate to LoginScreen when user logs out or session expires
    if (authState == AuthState.unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const KemoraAppBar(),
      body: Stack(
        children: [
          // Content with PageView for swipe navigation
          PageView(
            controller: _pageController,
            physics: const PageScrollPhysics(), // Snap to pages, avoid minor scroll conflict
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _buildScreens(),
          ),
          
          // Floating Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: FloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
