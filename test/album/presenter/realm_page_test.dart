import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/domain/entity/realm.dart';
import 'package:gow_elden_cup/album/presenter/album/widgets/realm_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/settings_bloc_harness.dart';

const _realm = Realm(id: 'midgard', name: 'Midgard', order: 1);

Boss _boss(String id, String name, {int mainOrder = 0}) => Boss(
      id: id,
      name: name,
      realm: 'midgard',
      art: 'a.webp',
      locationName: 'loc',
      mapCoord: const MapCoord(0.1, 0.2),
      lore: 'l',
      mainOrder: mainOrder,
    );

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: withSettings(child)));

void main() {
  testWidgets('shows realm name, progress and bosses', (tester) async {
    await tester.pumpWidget(_host(RealmPage(
      realm: _realm,
      mainBosses: const [],
      otherBosses: [_boss('baldur', 'Baldur')],
      defeatedCount: 0,
      totalCount: 1,
      isDefeated: (_) => false,
      onBossTap: (_) {},
      onQuickDefeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('Midgard'), findsOneWidget);
    expect(find.text('0 de 1 derrotados'), findsOneWidget);
    expect(find.text('BALDUR'), findsOneWidget);
  });

  testWidgets('renders the main-boss section when there are main bosses',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(RealmPage(
      realm: _realm,
      mainBosses: [_boss('odin', 'Odin', mainOrder: 1)],
      otherBosses: [_boss('baldur', 'Baldur')],
      defeatedCount: 0,
      totalCount: 2,
      isDefeated: (_) => false,
      onBossTap: (_) {},
      onQuickDefeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('★ Chefes principais'), findsOneWidget);
    expect(find.text('Demais chefes'), findsOneWidget);
    expect(find.text('ODIN'), findsOneWidget);
    expect(find.text('BALDUR'), findsOneWidget);
  });

  testWidgets('no main section when there are no main bosses', (tester) async {
    await tester.pumpWidget(_host(RealmPage(
      realm: _realm,
      mainBosses: const [],
      otherBosses: [_boss('baldur', 'Baldur')],
      defeatedCount: 0,
      totalCount: 1,
      isDefeated: (_) => false,
      onBossTap: (_) {},
      onQuickDefeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('★ Chefes principais'), findsNothing);
    expect(find.text('Chefes'), findsOneWidget);
  });

  testWidgets('tapping a slot fires onBossTap', (tester) async {
    Boss? tapped;
    await tester.pumpWidget(_host(RealmPage(
      realm: _realm,
      mainBosses: const [],
      otherBosses: [_boss('baldur', 'Baldur')],
      defeatedCount: 0,
      totalCount: 1,
      isDefeated: (_) => false,
      onBossTap: (b) => tapped = b,
      onQuickDefeat: (_) {},
    )));
    await tester.pump();
    await tester.tap(find.text('BALDUR'));
    expect(tapped?.id, 'baldur');
  });
}
