// Smoke test: the app boots, finishes loading, and shows the tracker buttons.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kisses_app/main.dart';
import 'package:kisses_app/state/app_state.dart';

void main() {
  testWidgets('boots and shows the tracker buttons (default uk locale)',
      (WidgetTester tester) async {
    // AppState reads from SharedPreferences on startup; provide an empty store.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const KissesApp(),
      ),
    );

    // Allow the async load to complete and the loading spinner to clear.
    await tester.pumpAndSettle();

    // Default language is Ukrainian.
    expect(find.text('Цьомчики'), findsOneWidget);
    expect(find.text('Семкс'), findsOneWidget);
  });
}
