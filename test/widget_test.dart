import 'package:flutter_test/flutter_test.dart';

import 'package:gow_elden_cup/main.dart';

void main() {
  testWidgets('GoW Album smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GowAlbumApp());

    expect(find.text('GoW Album'), findsOneWidget);
  });
}
