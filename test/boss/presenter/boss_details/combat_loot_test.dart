import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/damage_type.dart';
import 'package:gow_elden_cup/album/domain/entity/loot_item.dart';
import 'package:gow_elden_cup/boss/presenter/boss_details/widgets/combat_section.dart';
import 'package:gow_elden_cup/boss/presenter/boss_details/widgets/loot_section.dart';

Widget _host(Widget c) => MaterialApp(home: Scaffold(body: c));

void main() {
  testWidgets('combat shows weaknesses, immunities, and labels', (tester) async {
    await tester.pumpWidget(_host(const CombatSection(
      weaknesses: [DamageType.frost],
      immunities: [DamageType.burn],
      strategy: null,
    )));
    expect(find.text('FRAQUEZAS'), findsOneWidget);
    expect(find.text('IMUNE A'), findsOneWidget);
    expect(find.text('Gelo'), findsOneWidget);
    expect(find.text('Queimadura'), findsOneWidget);
  });

  testWidgets('combat shows strategy text when present', (tester) async {
    await tester.pumpWidget(_host(const CombatSection(
      weaknesses: [],
      immunities: [],
      strategy: 'Use o machado para quebrar o escudo.',
    )));
    expect(find.text('Use o machado para quebrar o escudo.'), findsOneWidget);
  });

  testWidgets('combat hides strategy block when null', (tester) async {
    await tester.pumpWidget(_host(const CombatSection(
      weaknesses: [],
      immunities: [],
      strategy: null,
    )));
    expect(find.textContaining('Estratégia'), findsNothing);
  });

  testWidgets('loot lists each item name', (tester) async {
    await tester.pumpWidget(_host(const LootSection(
      loot: [LootItem(name: 'Fragmento de Bruma'), LootItem(name: 'Coração de Gelo')],
    )));
    expect(find.text('Fragmento de Bruma'), findsOneWidget);
    expect(find.text('Coração de Gelo'), findsOneWidget);
  });
}
