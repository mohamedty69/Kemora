// [KEMORA-FIX] Phase 2: Wired to AuthViewModel.register() with all required fields.
// BEFORE: StatelessWidget, no controllers, button hard-navigated to HomeScreen.
// AFTER: StatefulWidget, reads fullName/email/country/password,
//        calls AuthViewModel.register() — backend requires all 4 fields.
//        Navigation handled by AuthGate in main.dart on authenticated state.
//        Error displayed inline at top of form (including 409 duplicate email).
//        Password confirmation field is UI-only and NOT sent to backend.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/kemora_app_bar.dart';
import '../../viewmodels/auth_view_model.dart';

// Full list of countries — trimmed for brevity; commonly needed ones at top
const _countries = [
  'Egypt', 'Saudi Arabia', 'UAE', 'Kuwait', 'Qatar', 'Jordan', 'Lebanon',
  'Morocco', 'Tunisia', 'Libya', 'Iraq', 'Bahrain', 'Oman', 'Sudan',
  'United States', 'United Kingdom', 'France', 'Germany', 'Italy', 'Spain',
  'Canada', 'Australia', 'India', 'China', 'Japan', 'Turkey', 'Russia',
  'Brazil', 'South Africa', 'Nigeria', 'Kenya', 'Pakistan', 'Bangladesh',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // [KEMORA-FIX] Password confirm is UI-only — NOT sent to backend (backend RegisterDto has no confirmPassword)
  final _confirmPasswordController = TextEditingController();
  String? _selectedCountry;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccount() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final country = _selectedCountry ?? '';

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || country.isEmpty) {
      return;
    }
    if (password != confirmPassword) {
      // Show mismatch error via AuthViewModel's error state pattern
      setState(() {}); // trigger rebuild to show local validation
      return;
    }

    // [KEMORA-FIX] Calls POST /api/v1/auth/register with fields: fullName, email, country, password
    // Password confirm is NOT sent to the backend
    await context.read<AuthViewModel>().register(fullName, email, country, password);
    // Navigation handled by AuthGate watching AuthViewModel.state
  }

  bool get _passwordMismatch =>
      _confirmPasswordController.text.isNotEmpty &&
      _passwordController.text != _confirmPasswordController.text;

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isLoading = authVm.state == AuthState.loading;
    final errorMessage = authVm.state == AuthState.error ? authVm.errorMessage : null;

    return Scaffold(
      appBar: const KemoraAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Account', style: AppTypography.headlineLarge),
            const SizedBox(height: 8),
            Text('Join the elite travel circle today.', style: AppTypography.bodyLarge),
            const SizedBox(height: 24),

            // [KEMORA-FIX] Top-of-form error banner for API errors (400 field errors, 409 duplicate)
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.onErrorContainer, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        // [KEMORA-FIX] 409 Duplicate email → show specific message
                        errorMessage.toLowerCase().contains('conflict') ||
                                errorMessage.toLowerCase().contains('already') ||
                                errorMessage.toLowerCase().contains('email')
                            ? 'This email is already registered. Please sign in instead.'
                            : errorMessage.toLowerCase().contains('server') ||
                                    errorMessage.toLowerCase().contains('500')
                                ? 'Registration failed, please try again.'
                                : errorMessage,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text('FULL NAME', style: AppTypography.labelSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 24),
            Text('EMAIL ADDRESS', style: AppTypography.labelSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'name@luxury-travel.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 24),
            Text('PASSWORD', style: AppTypography.labelSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('CONFIRM PASSWORD', style: AppTypography.labelSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                // [KEMORA-FIX] Show mismatch error inline
                errorText: _passwordMismatch ? 'Passwords do not match' : null,
              ),
            ),

            // [KEMORA-FIX] Country — functional dropdown (required by backend RegisterDto)
            const SizedBox(height: 24),
            Text('COUNTRY', style: AppTypography.labelSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.public),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
              ),
              hint: Text('Select your country',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.onSurfaceVariant)),
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCountry = val),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) =>
                        setState(() => _agreedToTerms = val ?? false),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySmall,
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' and '),
                        TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: (isLoading || _passwordMismatch || !_agreedToTerms)
                  ? null
                  : _onCreateAccount,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56)),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Account'),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR SIGN UP WITH', style: AppTypography.labelSmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => context.read<AuthViewModel>().signInWithGoogle(),
              icon: const Icon(Icons.g_mobiledata, color: Colors.black, size: 28),
              label: const Text('Continue with Google',
                  style:
                      TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.bodyMedium,
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                          text: 'Login',
                          style: TextStyle(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
