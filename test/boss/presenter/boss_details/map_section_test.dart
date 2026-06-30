import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/boss/presenter/boss_details/widgets/map_section.dart';

const _boss = Boss(
  id: 'baldur',
  name: 'Baldur',
  realm: 'midgard',
  art: 'images/baldur.webp',
  locationName: 'Floresta de Wildwoods',
  mapCoord: MapCoord(0.6, 0.4),
  lore: 'l',
);

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('locked state shows reveal button and hides location',
      (tester) async {
    var revealed = false;
    await tester.pumpWidget(_host(MapSection(
      boss: _boss,
      realmMapImage: null,
      revealed: false,
      onReveal: () => revealed = true,
      onHide: () {},
      onOpenFullscreen: () {},
    )));
    expect(find.text('👁 Revelar mapa'), findsOneWidget);
    expect(find.text('Floresta de Wildwoods'), findsNothing);

    await tester.tap(find.text('👁 Revelar mapa'));
    expect(revealed, isTrue);
  });

  testWidgets('revealed state shows location and amplify control',
      (tester) async {
    await tester.pumpWidget(_host(MapSection(
      boss: _boss,
      realmMapImage: null,
      revealed: true,
      onReveal: () {},
      onHide: () {},
      onOpenFullscreen: () {},
    )));
    expect(find.text('Floresta de Wildwoods'), findsOneWidget);
    expect(find.textContaining('Ampliar'), findsOneWidget);
  });
}
