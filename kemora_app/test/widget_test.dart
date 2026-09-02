import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kemora/core/di/injection_container.dart' as di;
import 'package:kemora/presentation/screens/auth/login_screen.dart';
import 'package:kemora/presentation/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() async {
    // Initialize dependency injection
    await di.init();
  });

  testWidgets('Login screen UI test', (WidgetTester tester) async {
    // Build the LoginScreen widget with necessary providers.
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => di.sl<AuthViewModel>(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Let the widget tree build.
    await tester.pump();

    // Verify the app title
    expect(find.text('KEMORA'), findsOneWidget);

    // Verify the welcome text.
    expect(find.text('Welcome Back'), findsOneWidget);

    // Find TextFields by their hintText.
    expect(find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.hintText == 'Email Address'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.hintText == 'Password'), findsOneWidget);

    // Verify the presence of the login button.
    expect(find.widgetWithText(ElevatedButton, 'SIGN IN TO KEMORA'), findsOneWidget);
  });
}
