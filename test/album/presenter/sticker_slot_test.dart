import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/presenter/album/widgets/main_boss_border.dart';
import 'package:gow_elden_cup/album/presenter/album/widgets/sticker_slot.dart';
import 'package:gow_elden_cup/album/presenter/album/widgets/type_badge.dart';

import '../../support/settings_bloc_harness.dart';

const _boss = Boss(
  id: 'baldur', name: 'Baldur', realm: 'midgard',
  art: 'images/baldur.webp', locationName: 'loc',
  mapCoord: MapCoord(0.6, 0.4), lore: 'l',
);

const _typedBoss = Boss(
  id: 'thor', name: 'Thor', realm: 'midgard',
  type: BossType.berserker,
  art: 'images/thor.webp', locationName: 'loc',
  mapCoord: MapCoord(0.5, 0.5), lore: 'l',
);

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: withSettings(child)));

void main() {
  testWidgets('shows name in both states', (tester) async {
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () {})));
    expect(find.text('BALDUR'), findsOneWidget);
  });

  testWidgets('tap fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, onTap: () => tapped = true)));
    await tester.tap(find.byType(StickerSlot));
    expect(tapped, isTrue);
  });

  testWidgets('while revealing, a defeated slot keeps the pending look',
      (tester) async {
    // A defeated+revealing typed boss must NOT show its colored reward yet: the
    // full-screen overlay owns the animation and the slot "sticks" it only when
    // revealing clears. The TypeBadge (a defeated-only marker) is the tell.
    await tester.pumpWidget(_host(StickerSlot(
      boss: _typedBoss,
      defeated: true,
      revealing: true,
      onTap: () {},
    )));
    expect(find.byType(TypeBadge), findsNothing);

    // once the reveal finishes (revealing = false), the reward shows
    await tester.pumpWidget(_host(StickerSlot(
      boss: _typedBoss,
      defeated: true,
      onTap: () {},
    )));
    expect(find.byType(TypeBadge), findsOneWidget);
  });

  testWidgets('pending slot shows quick-check button that fires onQuickDefeat',
      (tester) async {
    var quick = false;
    await tester.pumpWidget(_host(StickerSlot(
      boss: _boss,
      defeated: false,
      onTap: () {},
      onQuickDefeat: () => quick = true,
    )));
    final btn = find.byKey(const Key('slot-quick-check'));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    expect(quick, isTrue);
  });

  testWidgets('defeated slot has no quick-check button', (tester) async {
    await tester.pumpWidget(_host(StickerSlot(
      boss: _boss,
      defeated: true,
      onTap: () {},
      onQuickDefeat: () {},
    )));
    expect(find.byKey(const Key('slot-quick-check')), findsNothing);
  });

  testWidgets('defeated main boss gets the living border; pending does not',
      (tester) async {
    // defeated main -> living MainBossBorder (the headline reward)
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: true, isMain: true, onTap: () {})));
    expect(find.byType(MainBossBorder), findsOneWidget);

    // pending main -> no reward frame while still locked
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, isMain: true, onTap: () {})));
    expect(find.byType(MainBossBorder), findsNothing);

    // and a defeated regular boss never gets it either
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: true, onTap: () {})));
    expect(find.byType(MainBossBorder), findsNothing);
  });

  testWidgets('main-boss living border paints across the whole pulse/glint cycle',
      (tester) async {
    // The glint builds LinearGradient stops from an animated value; bad stops
    // (non-monotonic) throw during paint. Pump through a full cycle to catch it.
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: true, isMain: true, onTap: () {})));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(tester.takeException(), isNull);
    expect(find.byType(MainBossBorder), findsOneWidget);
  });

  testWidgets('TypeBadge shows on a defeated slot and is hidden on a pending slot',
      (tester) async {
    // ARRANGE + ACT: defeated (revealed) slot — defeated: true, revealing defaults to false
    await tester.pumpWidget(_host(
        StickerSlot(boss: _typedBoss, defeated: true, onTap: () {})));
    // ASSERT: badge is visible on a revealed slot
    expect(find.byType(TypeBadge), findsOneWidget);

    // ACT: pending slot — defeated: false
    await tester.pumpWidget(_host(
        StickerSlot(boss: _typedBoss, defeated: false, onTap: () {})));
    // ASSERT: badge is absent on a pending (spoiler-safe) slot
    expect(find.byType(TypeBadge), findsNothing);
  });
}
