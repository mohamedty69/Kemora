import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/auth/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../widgets/fade_slide_in.dart';
import '../../../core/router/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2, milliseconds: 500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    // TokenStorage is initialized in main() before runApp() — safe to read synchronously here.
    if (TokenStorage.instance.isAuthenticated) {
      // Valid token found — restore session and go home without showing login.
      Navigator.of(context).pushReplacement(FadePageRoute(child: const HomeScreen()));
      return;
    }

    // No valid token — determine if this is a first launch.
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    if (!onboardingDone) {
      // First launch — show onboarding (which leads to LoginScreen on finish/skip).
      Navigator.of(context).pushReplacement(FadePageRoute(child: const OnboardingScreen()));
    } else {
      // Returning user — go directly to login.
      Navigator.of(context).pushReplacement(FadePageRoute(child: const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Subtle radial gradients — UI unchanged
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryFixedDim.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryFixed.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeSlideIn(
                  delayMs: 0,
                  child: const Icon(Icons.auto_awesome, color: AppColors.primaryContainer, size: 48),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delayMs: 200,
                  child: Text(
                    'KEMORA',
                    style: AppTypography.displayLarge.copyWith(
                      color: AppColors.primaryContainer,
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  delayMs: 400,
                  child: Text(
                    'THE EGYPTIAN ODYSSEY',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeSlideIn(
                  delayMs: 600,
                  child: Container(
                    width: 40,
                    height: 1,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delayMs: 800,
                  child: Text(
                    'CURATING DISCOVERY',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeSlideIn(
              delayMs: 1000,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 24, height: 1, color: AppColors.outlineVariant),
                  const SizedBox(width: 12),
                  Text(
                    'EST. 2024 LUXOR',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 24, height: 1, color: AppColors.outlineVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
