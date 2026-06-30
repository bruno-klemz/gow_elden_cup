import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/boss/domain/repository/progress_repository.dart';
import 'package:gow_elden_cup/boss/domain/usecase/toggle_defeated_usecase.dart';

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const Progress()));

  late _MockProgressRepository repo;
  late ToggleDefeatedUsecaseImpl usecase;

  setUp(() {
    repo = _MockProgressRepository();
    usecase = ToggleDefeatedUsecaseImpl(repository: repo);
    when(() => repo.save(any())).thenAnswer((_) async {});
  });

  test('call marks a pending boss as defeated using fresh load and saves once',
      () async {
    when(() => repo.load()).thenAnswer((_) async => const Progress());

    final result = await usecase(const Progress(), 'baldur');

    expect(result.isDefeated('baldur'), isTrue);
    verify(() => repo.load()).called(1);
    verify(() => repo.save(result)).called(1);
  });

  test('call toggles a defeated boss back to pending using fresh load', () async {
    final loadedBase = const Progress(defeated: {'baldur'});
    when(() => repo.load()).thenAnswer((_) async => loadedBase);

    final result = await usecase(const Progress(), 'baldur');

    expect(result.isDefeated('baldur'), isFalse);
    verify(() => repo.load()).called(1);
    verify(() => repo.save(result)).called(1);
  });

  // C1 regression: defeating a boss must preserve pre-existing favor steps
  // that a sibling FavorBloc wrote — simulates the cross-feature clobber bug.
  test(
      'C1 regression — defeating a boss preserves pre-existing favor steps '
      'in the saved progress', () async {
    const freshFromDisk = Progress(
      completedFavorSteps: {'f1:s1', 'f1:s2'},
    );
    when(() => repo.load()).thenAnswer((_) async => freshFromDisk);

    // Stale current from AlbumBloc lacks the favor steps entirely.
    const staleCurrentFromAlbumBloc = Progress();

    final result = await usecase(staleCurrentFromAlbumBloc, 'baldur');

    expect(result.isDefeated('baldur'), isTrue);
    // Favor steps must survive — this was the data-loss bug.
    expect(result.isStepDone('f1', 's1'), isTrue);
    expect(result.isStepDone('f1', 's2'), isTrue);
    verify(() => repo.save(result)).called(1);
  });
}
