import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/boss/domain/repository/progress_repository.dart';
import 'package:gow_elden_cup/favors/domain/usecase/toggle_favor_step_usecase.dart';

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const Progress()));

  late _MockProgressRepository repo;
  late ToggleFavorStepUsecaseImpl usecase;

  setUp(() {
    repo = _MockProgressRepository();
    usecase = ToggleFavorStepUsecaseImpl(repository: repo);
    when(() => repo.save(any())).thenAnswer((_) async {});
  });

  test('call toggles the step from undone to done using fresh load, saves once',
      () async {
    when(() => repo.load()).thenAnswer((_) async => const Progress());

    final result = await usecase(const Progress(), 'the_lost_lindwyrm', 's1');

    expect(result.isStepDone('the_lost_lindwyrm', 's1'), isTrue);
    verify(() => repo.load()).called(1);
    verify(() => repo.save(result)).called(1);
  });

  test('call toggles the step from done to undone using fresh load, saves once',
      () async {
    final loadedBase =
        const Progress().toggleStep('the_lost_lindwyrm', 's1');
    when(() => repo.load()).thenAnswer((_) async => loadedBase);

    // current is irrelevant — use case must use fresh load
    final result = await usecase(const Progress(), 'the_lost_lindwyrm', 's1');

    expect(result.isStepDone('the_lost_lindwyrm', 's1'), isFalse);
    verify(() => repo.load()).called(1);
    verify(() => repo.save(result)).called(1);
  });

  test('call does not mutate the original Progress', () async {
    when(() => repo.load()).thenAnswer((_) async => const Progress());
    const initial = Progress();

    await usecase(initial, 'favor_x', 's2');

    expect(initial.isStepDone('favor_x', 's2'), isFalse);
  });

  // C1 regression: proves the merge-from-fresh behaviour.
  // load() returns a Progress that already has a boss defeated and a separate
  // favor step done; toggling a NEW favor step must preserve ALL pre-existing
  // data — no clobber of defeated or completedFavorSteps from another feature.
  test(
      'C1 regression — toggling a step preserves pre-existing defeated boss '
      'and prior favor step in the saved progress', () async {
    // Simulate: AlbumBloc defeated 'baldur'; FavorBloc completed 'f1:s1'.
    // Both are already persisted. The toggle for 'f1:s2' must not erase them.
    const freshFromDisk = Progress(
      defeated: {'baldur'},
      completedFavorSteps: {'f1:s1'},
    );
    when(() => repo.load()).thenAnswer((_) async => freshFromDisk);

    // current is a stale snapshot that lacks the defeated boss — simulates
    // cross-feature clobber that would have happened before this fix.
    const staleCurrentFromFavorBloc = Progress(completedFavorSteps: {'f1:s1'});

    final result =
        await usecase(staleCurrentFromFavorBloc, 'f1', 's2');

    // The new step must be toggled on.
    expect(result.isStepDone('f1', 's2'), isTrue);
    // The pre-existing favor step must survive.
    expect(result.isStepDone('f1', 's1'), isTrue);
    // The defeated boss must survive — this was the data-loss bug.
    expect(result.isDefeated('baldur'), isTrue);
    verify(() => repo.save(result)).called(1);
  });
}
