import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../viewmodels/auth_view_model.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    await context.read<AuthViewModel>().login(email, password);
    // Navigation is handled in build() via post-frame callback on AuthState.authenticated
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isLoading = authVm.state == AuthState.loading;
    final errorMessage = authVm.state == AuthState.error ? authVm.errorMessage : null;

    // Navigate to HomeScreen when login succeeds — clears back stack so pressing back won't return to login
    if (authVm.state == AuthState.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.surfaceContainerHigh,
                    child: Image.asset(
                      'assets/images/mocked/ThePyramids.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.8)
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('KEMORA',
                            style: AppTypography.displaySmall.copyWith(
                                color: Colors.white, letterSpacing: 4.0)),
                        const SizedBox(height: 8),
                        Text('THE MODERN ARCHIVIST',
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryFixedDim,
                                letterSpacing: 2.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back',
                      style: AppTypography.headlineLarge
                          .copyWith(color: AppColors.primaryContainer)),
                  const SizedBox(height: 8),
                  Text('Sign in to continue your journey.',
                      style: AppTypography.bodyLarge),
                  const SizedBox(height: 48),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onSignIn(),
                    decoration: InputDecoration(
                      hintText: 'Password',
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

                  // [KEMORA-FIX] Error message display — shown inline below password field
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.onErrorContainer, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // Mock forgot password flow
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            final emailCtrl = TextEditingController(text: _emailController.text);
                            return AlertDialog(
                              title: Text('Reset Password', style: AppTypography.titleLarge),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Enter your email to receive a password reset link.', style: AppTypography.bodyMedium),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: emailCtrl,
                                    decoration: const InputDecoration(
                                      hintText: 'Email Address',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Password reset link sent to ${emailCtrl.text}'),
                                        backgroundColor: AppColors.primaryContainer,
                                      ),
                                    );
                                  },
                                  child: const Text('Send Link'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Forgot Password?',
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.primaryContainer)),
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _onSignIn,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56)),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('SIGN IN TO KEMORA'),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('DISCOVERY LOGIN',
                            style: AppTypography.labelSmall),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          // [KEMORA-FIX] Google login via AuthViewModel.signInWithGoogle()
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<AuthViewModel>()
                                  .signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata,
                              color: Colors.black, size: 28),
                          label: const Text('Continue with Google',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: GestureDetector(
                      key: const Key('create_account_link'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const RegisterScreen()));
                      },
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodyMedium,
                          children: [
                            const TextSpan(text: 'New to the archives? '),
                            TextSpan(
                                text: 'Create an account',
                                style: TextStyle(
                                    color: AppColors.primaryContainer,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
