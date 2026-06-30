import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gow_elden_cup/main.dart';
import 'package:gow_elden_cup/service_locator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await locator.reset();
    setupLocator();
  });

  testWidgets('GoW Album smoke test — app builds with the nav bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GowAlbumApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // The NavigationBar destinations confirm the app shell rendered.
    expect(find.text('Chefes'), findsWidgets);
    expect(find.text('Favores'), findsWidgets);
    expect(find.text('Busca'), findsWidgets);
  });
}
