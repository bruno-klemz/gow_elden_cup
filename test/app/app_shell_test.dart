import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gow_elden_cup/main.dart';
import 'package:gow_elden_cup/service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Reset the locator between tests so registrations do not accumulate.
    await locator.reset();
    setupLocator();
  });

  group('AppShell', () {
    testWidgets('shows the NavigationBar with three destinations',
        (tester) async {
      await tester.pumpWidget(const GowAlbumApp());
      // Pump a few frames to let initial async loads settle without waiting
      // for perpetual animations (e.g. CircularProgressIndicator).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // NavigationBar destination labels appear in the nav bar.
      expect(find.text('Chefes'), findsWidgets);
      expect(find.text('Favors'), findsWidgets);
      expect(find.text('Busca'), findsWidgets);
    });

    testWidgets('starts on the Chefes (album) tab — Favores AppBar not shown',
        (tester) async {
      await tester.pumpWidget(const GowAlbumApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // FavorAlbumView renders 'Favores' in its AppBar. On the album tab it
      // is off-screen (IndexedStack keeps it alive but not visible).
      expect(find.text('Favores'), findsNothing);
    });

    testWidgets('tapping Favors destination shows the favor album AppBar',
        (tester) async {
      await tester.pumpWidget(const GowAlbumApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the 'Favors' NavigationDestination label.
      await tester.tap(find.text('Favors').first);
      // Pump instead of pumpAndSettle to avoid timing out on ongoing
      // animations (CircularProgressIndicator during async data load).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // FavorAlbumView renders 'Favores' in its AppBar — now visible.
      expect(find.text('Favores'), findsOneWidget);
    });
  });
}
