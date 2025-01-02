import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chat_framework/main.dart';
import 'package:chat_framework/themes/app_theme.dart';
import 'package:chat_framework/app.dart';
import 'package:chat_framework/providers/theme_provider.dart';

void main() {
  testWidgets('Chat app renders correctly', (WidgetTester tester) async {
    // Build our app with light theme
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const App(),
      ),
    );

    // Verify app bar title
    expect(find.text('Chat Framework'), findsOneWidget);

    // Verify message input field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify send button exists
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('Dark theme applies correctly', (WidgetTester tester) async {
    // Build our app with dark theme
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider()..setThemeMode(ThemeMode.dark),
        child: const App(),
      ),
    );

    // Verify dark theme is applied
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, isNotNull);
  });
}
