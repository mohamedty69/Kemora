import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/trip_view_model.dart';
import '../../viewmodels/places_view_model.dart';
import '../../../domain/entities/trip_plan_request.dart';
import '../../../domain/entities/place.dart' show Governorate;
import 'trip_detail_screen.dart';

// ─── Tourism interest option: display label ↔ backend enum value ───────────
class _InterestOption {
  final String label;
  final IconData icon;
  final String backendValue; // Must match backend TourismType enum exactly
  const _InterestOption(this.label, this.icon, this.backendValue);
}

const _interests = [
  _InterestOption('Cultural Heritage', Icons.museum, 'CulturalHeritage'),
  _InterestOption('Leisure & Beaches', Icons.beach_access, 'Leisure'),
  _InterestOption('Adventure', Icons.explore, 'Adventure'),
  _InterestOption('Eco Tourism', Icons.eco, 'EcoTourism'),
  _InterestOption('Religious', Icons.mosque, 'ReligiousPilgrimage'),
  _InterestOption('Culinary', Icons.restaurant, 'Culinary'),
  _InterestOption('Sports', Icons.sports_soccer, 'Sports'),
  _InterestOption('Medical & Wellness', Icons.spa, 'MedicalWellness'),
];

const _budgets = ['Budget', 'Mid-Range', 'Luxury'];
const _companions = ['Solo', 'Couple', 'Family', 'Friends', 'Group Tour'];

// ─── Per-governorate centre coordinates ─────────────────────────────────────
// Used so the backend searches places around the correct map area.
const _govCoords = <String, ({double lat, double lng})>{
  'Cairo':          (lat: 30.0444, lng: 31.2357),
  'Alexandria':     (lat: 31.2001, lng: 29.9187),
  'Giza':           (lat: 29.9870, lng: 31.2118),
  'Luxor':          (lat: 25.6872, lng: 32.6396),
  'Aswan':          (lat: 24.0889, lng: 32.8998),
  'Hurghada':       (lat: 27.2579, lng: 33.8116),
  'Sharm El-Sheikh':(lat: 27.9158, lng: 34.3300),
  'Siwa':           (lat: 29.2031, lng: 25.5195),
  'Dahab':          (lat: 28.5097, lng: 34.5181),
  'Marsa Matrouh':  (lat: 31.3543, lng: 27.2373),
  'Ismailia':       (lat: 30.5965, lng: 32.2715),
  'Port Said':      (lat: 31.2653, lng: 32.3019),
  'Suez':           (lat: 29.9737, lng: 32.5270),
};

class AiStepQuestionsScreen extends StatefulWidget {
  const AiStepQuestionsScreen({super.key});

  @override
  State<AiStepQuestionsScreen> createState() => _AiStepQuestionsScreenState();
}

class _AiStepQuestionsScreenState extends State<AiStepQuestionsScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  Governorate? _selectedGovernorate;
  double _durationSlider = 3.0; // 1-7 slider matching master project
  String? _selectedBudget;
  final Set<String> _selectedInterestValues = {}; // stores backendValue strings
  String? _selectedCompanion;

  @override
  void initState() {
    super.initState();
    // Load governorates from API (same as master project)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesViewModel>().loadGovernorates();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ({double lat, double lng}) _coordsForGovernorate(Governorate gov) {
    // Try known coords first, fall back to governorate entity's own coords if available
    final known = _govCoords[gov.name];
    if (known != null) return known;
    // Fallback: Cairo centre
    return (lat: 30.0444, lng: 31.2357);
  }

  Future<void> _submit() async {
    final gov = _selectedGovernorate;
    if (gov == null) return;

    final coords = _coordsForGovernorate(gov);
    final tripVM = context.read<TripViewModel>();

    final request = TripPlanRequest(
      latitude: coords.lat,
      longitude: coords.lng,
      location: gov.name,
      durationDays: _durationSlider.round(),
      budget: _selectedBudget ?? 'Mid-Range',
      // tourismTypes uses exact backend enum strings (CulturalHeritage, Leisure…)
      tourismTypes: _selectedInterestValues.isNotEmpty
          ? _selectedInterestValues.toList()
          : null,
      preferences: _selectedCompanion != null
          ? 'Traveling as: $_selectedCompanion'
          : null,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryContainer)),
    );

    await tripVM.generateAiItinerary(request);

    if (!mounted) return;
    Navigator.pop(context); // dismiss loading

    if (tripVM.state == TripState.loaded && tripVM.currentPlan != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TripDetailScreen(
            aiItinerary: tripVM.currentPlan!,
            request: request,
          ),
        ),
      );
    } else {
      final errMsg = tripVM.errorMessage ?? '';
      final String userMessage;
      if (errMsg.toLowerCase().contains('timeout') ||
          errMsg.toLowerCase().contains('connection')) {
        userMessage =
            'This is taking longer than expected. Please check your connection.';
      } else if (errMsg.isEmpty) {
        userMessage =
            'No plan was returned. Please adjust your answers and try again.';
      } else {
        userMessage = 'Could not generate your trip plan. Please try again.\n$errMsg';
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Trip Generation Failed'),
          content: Text(userMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Adjust Answers'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _submit();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _submit();
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: return _selectedGovernorate != null;
      case 1: return true; // slider always has a value
      case 2: return _selectedBudget != null;
      case 3: return _selectedInterestValues.isNotEmpty;
      case 4: return _selectedCompanion != null;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress dots ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(_totalSteps, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _currentStep
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Pages ──────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildDestinationStep(),
                  _buildDurationStep(),
                  _buildBudgetStep(),
                  _buildInterestsStep(),
                  _buildCompanionsStep(),
                ],
              ),
            ),

            // ── CTA button ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Consumer<TripViewModel>(
                builder: (_, tripVM, __) {
                  final isLoading = tripVM.state == TripState.loading;
                  return ElevatedButton(
                    onPressed: (_canProceed() && !isLoading) ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56)),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? 'Generate My Trip ✨'
                                : 'Next Step →',
                            style: const TextStyle(fontSize: 16)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Destination (governorates from API, matching master project) ──
  Widget _buildDestinationStep() {
    return Consumer<PlacesViewModel>(builder: (_, placesVM, __) {
      final govs = placesVM.governorates;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where do you want to go?', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text('Select a destination governorate',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            Expanded(
              child: govs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: govs.length,
                      itemBuilder: (_, i) {
                        final gov = govs[i];
                        final sel = _selectedGovernorate?.id == gov.id;
                        return _optionTile(
                          label: gov.name,
                          isSelected: sel,
                          onTap: () =>
                              setState(() => _selectedGovernorate = gov),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  // ── Step 2: Duration (slider 1-7 days, matching master project) ───────────
  Widget _buildDurationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How long is your trip?', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('Drag the slider to set duration',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 48),
          // Duration display
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                border:
                    Border.all(color: AppColors.primaryContainer, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_durationSlider.round()} Day${_durationSlider.round() == 1 ? '' : 's'}',
                style: AppTypography.displaySmall.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryContainer,
              thumbColor: AppColors.primaryContainer,
              inactiveTrackColor:
                  AppColors.primaryContainer.withValues(alpha: 0.2),
              overlayColor: AppColors.primaryContainer.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _durationSlider,
              min: 1,
              max: 7,
              divisions: 6,
              label: '${_durationSlider.round()} days',
              onChanged: (val) => setState(() => _durationSlider = val),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 Day', style: AppTypography.labelSmall),
              Text('7 Days', style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 3: Budget ────────────────────────────────────────────────────────
  Widget _buildBudgetStep() {
    const icons = [Icons.account_balance_wallet, Icons.star, Icons.diamond];
    const descriptions = [
      'Affordable options, local transport, budget stays',
      'Comfortable hotels, mix of local and tourist spots',
      'Premium hotels, private tours, fine dining',
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What\'s your budget tier?', style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('Choose a budget that suits your travel style',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24),
          ...List.generate(_budgets.length, (i) {
            final b = _budgets[i];
            final sel = _selectedBudget == b;
            return GestureDetector(
              onTap: () => setState(() => _selectedBudget = b),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryContainer.withValues(alpha: 0.1)
                      : AppColors.surfaceContainerLowest,
                  border: Border.all(
                      color: sel
                          ? AppColors.primaryContainer
                          : AppColors.outlineVariant,
                      width: sel ? 2 : 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(icons[i], size: 28, color: sel ? AppColors.primaryContainer : AppColors.onSurfaceVariant),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b,
                              style: AppTypography.titleMedium.copyWith(
                                  color: sel
                                      ? AppColors.primaryContainer
                                      : AppColors.onSurface,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(descriptions[i],
                              style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (sel)
                      const Icon(Icons.check_circle,
                          color: AppColors.primaryContainer),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Step 4: Interests (mapped to backend enum values) ─────────────────────
  Widget _buildInterestsStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are you interested in?',
              style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('Select one or more types of experience',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: _interests.map((opt) {
                final sel =
                    _selectedInterestValues.contains(opt.backendValue);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) {
                      _selectedInterestValues.remove(opt.backendValue);
                    } else {
                      _selectedInterestValues.add(opt.backendValue);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerLowest,
                      border: Border.all(
                          color: sel
                              ? AppColors.primaryContainer
                              : AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(opt.icon,
                            size: 20,
                            color: sel ? AppColors.onPrimary : AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(opt.label,
                              style: AppTypography.labelMedium.copyWith(
                                  color: sel
                                      ? AppColors.onPrimary
                                      : AppColors.onSurface),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 5: Companions ────────────────────────────────────────────────────
  Widget _buildCompanionsStep() {
    const icons = [Icons.person, Icons.favorite, Icons.family_restroom, Icons.group, Icons.directions_bus];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Who are you traveling with?',
              style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text('This helps the AI tailor the experience',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _companions.length,
              itemBuilder: (_, i) => _optionTile(
                label: _companions[i],
                icon: icons[i],
                isSelected: _selectedCompanion == _companions[i],
                onTap: () =>
                    setState(() => _selectedCompanion = _companions[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared tile widget ────────────────────────────────────────────────────
  Widget _optionTile({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.1)
              : AppColors.surfaceContainerLowest,
          border: Border.all(
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant,
              width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.onSurface),
                ),
              ],
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppColors.primaryContainer),
          ],
        ),
      ),
    );
  }
}
