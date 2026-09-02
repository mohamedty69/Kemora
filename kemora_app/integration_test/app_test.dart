import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:kemora/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kemora/core/auth/token_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End full user journey', (WidgetTester tester) async {
    // Clear preferences to ensure a clean state (not logged in, onboarding not seen)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Also clear TokenStorage since it's a singleton and might retain state across test hot-restarts
    TokenStorage.instance.clearTokens();

    // Start the app and wait for it to initialize completely
    app.main();
    
    // We need to pump a frame to get runApp() to render the first frame
    await tester.pump();
    
    // Splash screen uses Future.delayed for 2.5 seconds, so we need to pump time
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 1. Handle Onboarding Screen (if first time launch)
    final skipFinder = find.text('SKIP');
    if (skipFinder.evaluate().isNotEmpty) {
      print('Found SKIP button, tapping...');
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();
    } else {
      print('SKIP button not found. Assuming we are already on Login screen.');
    }

    // Now we should be on the Login screen
    expect(find.text('KEMORA'), findsWidgets, reason: 'Expected KEMORA logo on login screen');
    expect(find.text('Welcome Back'), findsWidgets, reason: 'Expected Welcome Back on login screen');

    // 2. Go to Register Screen
    final createAccountLink = find.byKey(const Key('create_account_link'));
    await tester.dragUntilVisible(
      createAccountLink,
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.tap(createAccountLink);
    await tester.pumpAndSettle();

    // 3. Register a new user
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'testuser_$timestamp@example.com';
    final testPassword = 'Password123!';

    // Find TextFields by hint text since the UI uses uppercase text above it and hint text inside
    await tester.enterText(
        find.widgetWithText(TextField, 'Enter your full name'), 'E2E Test User');
    await tester.enterText(
        find.widgetWithText(TextField, 'name@luxury-travel.com'), testEmail);
    final passwordFields = find.widgetWithText(TextField, '••••••••');
    await tester.enterText(passwordFields.first, testPassword);
    
    // In RegisterScreen, confirm password might need scroll to become visible
    final confirmPasswordField = passwordFields.last;
    await tester.ensureVisible(confirmPasswordField);
    await tester.enterText(confirmPasswordField, testPassword);

    // Check the Terms & Conditions checkbox
    final checkbox = find.byType(Checkbox);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Select a country
    final countryDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Select your country');
    await tester.ensureVisible(countryDropdown);
    await tester.tap(countryDropdown);
    await tester.pumpAndSettle();
    
    final countryItem = find.text('Egypt').last;
    await tester.ensureVisible(countryItem);
    await tester.tap(countryItem);
    await tester.pumpAndSettle();

    final createAccountBtn = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(createAccountBtn);
    await tester.tap(createAccountBtn);
    
    // Wait for the API call and navigation
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // 4. Verify we are on the Home Screen (Explore Tab)
    expect(find.byType(PageView), findsOneWidget);
    expect(find.textContaining('Hello, E2E Test User'), findsWidgets);

    // Let places load
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 5. Navigate to Social Tab
    final socialTab = find.byIcon(Icons.groups_rounded);
    await tester.tap(socialTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Create a new post
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello from E2E integration test!');
      await tester.tap(find.text('POST'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify post appears in the feed
      expect(find.text('Hello from E2E integration test!'), findsWidgets);
    }

    // 6. Navigate to Trip Tab
    final tripTab = find.byIcon(Icons.auto_awesome);
    await tester.tap(tripTab);
    await tester.pumpAndSettle();

    // Fill in AI Trip form
    final destinationInput = find.widgetWithText(TextField, 'Where do you want to go?');
    if (destinationInput.evaluate().isNotEmpty) {
      await tester.enterText(destinationInput, 'Cairo');
      
      final generateBtn = find.widgetWithText(ElevatedButton, 'Generate Magic Itinerary');
      if (generateBtn.evaluate().isNotEmpty) {
        await tester.tap(generateBtn);
        // Generation can take a while, up to 10 seconds.
        await tester.pumpAndSettle(const Duration(seconds: 15));
        
        // Verify itinerary loaded
        expect(find.textContaining('Day 1'), findsWidgets);
        
        // Click Save Plan
        final savePlanBtn = find.text('Save Plan');
        if (savePlanBtn.evaluate().isNotEmpty) {
            await tester.ensureVisible(savePlanBtn);
            await tester.tap(savePlanBtn);
            await tester.pumpAndSettle();
            
            // The Save Plan button opens a date picker, tap OK
            final okButton = find.text('OK');
            if (okButton.evaluate().isNotEmpty) {
                await tester.tap(okButton);
                await tester.pumpAndSettle(const Duration(seconds: 5));
            }
            
            // Verify success snackbar
            expect(find.textContaining('Plan saved successfully'), findsWidgets);
        } else {
            // Navigate back
            final backButton = find.byTooltip('Back');
            if (backButton.evaluate().isNotEmpty) {
                await tester.tap(backButton);
                await tester.pumpAndSettle();
            }
        }
      }
    }

    // 7. Navigate to Profile Tab
    final profileTab = find.byIcon(Icons.person_rounded);
    await tester.tap(profileTab);
    await tester.pumpAndSettle();

    // Verify profile data
    expect(find.text('E2E Test User'), findsWidgets);
    expect(find.text(testEmail), findsWidgets);

    // 8. Logout
    final logoutBtn = find.text('Logout');
    if (logoutBtn.evaluate().isNotEmpty) {
        await tester.tap(logoutBtn);
        await tester.pumpAndSettle();
        
        // Verify we are back to login screen
        expect(find.text('Welcome Back'), findsWidgets);
    }
  });
}
