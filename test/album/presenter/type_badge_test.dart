import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/presenter/album/widgets/type_badge.dart';

void main() {
  testWidgets('renders the BossType label text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TypeBadge(type: BossType.berserker),
      ),
    ));

    expect(find.text('Berserker'), findsOneWidget);
  });

  testWidgets('renders a different type label', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TypeBadge(type: BossType.valkyrie),
      ),
    ));

    expect(find.text('Valquíria'), findsOneWidget);
  });
}
