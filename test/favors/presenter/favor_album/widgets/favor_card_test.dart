import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gow_elden_cup/favors/domain/entity/favor.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor_step.dart';
import 'package:gow_elden_cup/favors/presenter/favor_album/widgets/favor_card.dart';

const _stepA = FavorStep(id: 'sa', title: 'A', detail: 'd');
const _stepB = FavorStep(id: 'sb', title: 'B', detail: 'd');

const _favor = Favor(
  id: 'fav-test',
  name: 'The Weight of Chains',
  realm: 'svartalfheim',
  region: 'The Forge',
  giver: 'Sindri',
  summary: 'Find the chains.',
  lore: 'Long lore.',
  steps: [_stepA, _stepB],
);

void main() {
  testWidgets('renders favor name', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FavorCard(favor: _favor, done: 1, onTap: () {}),
      ),
    ));
    expect(find.text('The Weight of Chains'), findsOneWidget);
  });

  testWidgets('renders realm and region', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FavorCard(favor: _favor, done: 1, onTap: () {}),
      ),
    ));
    expect(find.textContaining('The Forge'), findsOneWidget);
  });

  testWidgets('renders giver', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FavorCard(favor: _favor, done: 1, onTap: () {}),
      ),
    ));
    expect(find.textContaining('Sindri'), findsOneWidget);
  });

  testWidgets('renders progress as "1 / 2"', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FavorCard(favor: _favor, done: 1, onTap: () {}),
      ),
    ));
    expect(find.text('1 / 2'), findsOneWidget);
  });

  testWidgets('invokes onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FavorCard(favor: _favor, done: 0, onTap: () => tapped = true),
      ),
    ));
    await tester.tap(find.byType(FavorCard));
    expect(tapped, isTrue);
  });
}
