import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gow_elden_cup/favors/presenter/favor_album/widgets/favor_progress_ring.dart';

void main() {
  testWidgets('renders "0 / 3" when no steps done', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: FavorProgressRing(done: 0, total: 3))),
    ));
    expect(find.text('0 / 3'), findsOneWidget);
  });

  testWidgets('renders "2 / 2" when all steps done', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: FavorProgressRing(done: 2, total: 2))),
    ));
    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('renders "1 / 4" for partial progress', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: FavorProgressRing(done: 1, total: 4))),
    ));
    expect(find.text('1 / 4'), findsOneWidget);
  });

  testWidgets('renders "0 / 0" gracefully for 0-step favor', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: FavorProgressRing(done: 0, total: 0))),
    ));
    expect(find.text('0 / 0'), findsOneWidget);
  });
}
