import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gow_elden_cup/boss/data/repository/progress_repository_impl.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('save then load round-trips all three sets', () async {
    final repo = ProgressRepositoryImpl();
    final p = const Progress(
      defeated: {'kratos'},
      revealedMap: {'freyr'},
      completedFavorSteps: {'favor1:s1', 'favor1:s3'},
    );

    await repo.save(p);
    final loaded = await repo.load();

    expect(loaded.isDefeated('kratos'), isTrue);
    expect(loaded.isMapRevealed('freyr'), isTrue);
    expect(loaded.isDefeated('freyr'), isFalse);
    expect(loaded.isStepDone('favor1', 's1'), isTrue);
    expect(loaded.isStepDone('favor1', 's3'), isTrue);
    expect(loaded.isStepDone('favor1', 's2'), isFalse);
  });

  test('load on empty prefs returns empty progress', () async {
    final loaded = await ProgressRepositoryImpl().load();
    expect(loaded.defeated, isEmpty);
    expect(loaded.revealedMap, isEmpty);
    expect(loaded.completedFavorSteps, isEmpty);
  });
}
