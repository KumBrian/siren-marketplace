import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to pump a widget wrapped with necessary providers
///
/// This function wraps the widget in MaterialApp and ProviderScope,
/// making it easy to test widgets that depend on Riverpod providers.
///
/// Example:
/// ```dart
/// await tester.pumpApp(
///   MyWidget(),
///   overrides: [
///     myProvider.overrideWith((ref) => mockValue),
///   ],
/// );
/// ```
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        home: Scaffold(body: widget),
      ),
    ),
  );
}

/// Helper function to pump a widget with router support
///
/// Use this when testing widgets that need navigation/routing.
Future<void> pumpAppWithRouter(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: widget),
    ),
  );
}

/// Extension on WidgetTester for common test operations
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps the widget tree and settles all animations
  Future<void> pumpAndSettleApp(
    Widget widget, {
    List<Override> overrides = const [],
  }) async {
    await pumpApp(this, widget, overrides: overrides);
    await pumpAndSettle();
  }

  /// Finds a widget by its text and taps it
  Future<void> tapText(String text) async {
    await tap(find.text(text));
    await pump();
  }

  /// Finds a widget by its key and taps it
  Future<void> tapByKey(Key key) async {
    await tap(find.byKey(key));
    await pump();
  }
}
