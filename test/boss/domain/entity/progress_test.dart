import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';

void main() {
  test('toggleDefeated adds then removes immutably', () {
    const p0 = Progress();
    final p1 = p0.toggleDefeated('kratos');
    expect(p0.isDefeated('kratos'), isFalse); // original untouched
    expect(p1.isDefeated('kratos'), isTrue);
    final p2 = p1.toggleDefeated('kratos');
    expect(p2.isDefeated('kratos'), isFalse);
  });

  test('defeated boss is implicitly map-revealed', () {
    final p = const Progress().toggleDefeated('freyr');
    expect(p.isMapRevealed('freyr'), isTrue);
  });

  test('revealMap / hideMap toggle reveal for pending boss', () {
    final p = const Progress().revealMap('odin');
    expect(p.isMapRevealed('odin'), isTrue);
    expect(p.hideMap('odin').isMapRevealed('odin'), isFalse);
  });

  test('defeatedCountIn counts only matching defeated ids', () {
    final p = const Progress().toggleDefeated('a').toggleDefeated('c');
    expect(p.defeatedCountIn(['a', 'b', 'c']), 2);
  });

  test('toggleStep adds then removes a favorId:stepId key', () {
    const p = Progress();
    final a = p.toggleStep('favor1', 's1');
    expect(a.isStepDone('favor1', 's1'), isTrue);
    final b = a.toggleStep('favor1', 's1');
    expect(b.isStepDone('favor1', 's1'), isFalse);
  });

  test('completedStepCount counts only done steps of that favor', () {
    final p = const Progress().toggleStep('favor1', 's1').toggleStep('favor1', 's3');
    expect(p.completedStepCount('favor1', ['s1', 's2', 's3']), 2);
  });
}
