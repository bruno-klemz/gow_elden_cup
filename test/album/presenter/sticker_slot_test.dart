import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/presenter/album/widgets/reveal_overlay.dart';
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

  testWidgets('animateReveal plays the reveal and calls onRevealDone',
      (tester) async {
    var done = false;
    await tester.pumpWidget(_host(StickerSlot(
      boss: _boss,
      defeated: true,
      animateReveal: true,
      onTap: () {},
      onRevealDone: () => done = true,
    )));
    // the reveal overlay is mounted while animating
    expect(find.byType(RevealOverlay), findsOneWidget);
    // animation finishes -> onRevealDone fires
    await tester.pumpAndSettle();
    expect(done, isTrue);
  });

  testWidgets('without animateReveal there is no reveal overlay',
      (tester) async {
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: true, onTap: () {})));
    expect(find.byType(RevealOverlay), findsNothing);
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

  testWidgets('main boss shows a crown only when defeated', (tester) async {
    // defeated main -> crown
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: true, isMain: true, onTap: () {})));
    expect(find.text('👑'), findsOneWidget);

    // pending main -> no crown (no gold reward while locked)
    await tester.pumpWidget(_host(
        StickerSlot(boss: _boss, defeated: false, isMain: true, onTap: () {})));
    expect(find.text('👑'), findsNothing);
  });

  testWidgets('TypeBadge shows on a defeated slot and is hidden on a pending slot',
      (tester) async {
    // ARRANGE + ACT: defeated (revealed) slot — defeated: true, animateReveal defaults to false
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
