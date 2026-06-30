import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/boss/domain/repository/progress_repository.dart';
import 'package:gow_elden_cup/boss/domain/usecase/set_map_revealed_usecase.dart';

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const Progress()));

  late _MockProgressRepository repo;
  late SetMapRevealedUsecaseImpl usecase;

  setUp(() {
    repo = _MockProgressRepository();
    usecase = SetMapRevealedUsecaseImpl(repository: repo);
    when(() => repo.save(any())).thenAnswer((_) async {});
  });

  test('call reveals a map using fresh load and saves once', () async {
    when(() => repo.load()).thenAnswer((_) async => const Progress());

    final result =
        await usecase(const Progress(), 'baldur', revealed: true);

    expect(result.isMapRevealed('baldur'), isTrue);
    verify(() => repo.load()).called(1);
    verify(() => repo.save(result)).called(1);
  });

  test('call hides a map using fresh load and saves once', () async {
    final loadedBase = const Progress(revealedMap: {'baldur'});
    when(() => repo.load()).thenAnswer((_) async => loadedBase);

    final result =
        await usecase(const Progress(), 'baldur', revealed: false);

    expect(result.isMapRevealed('baldur'), isFalse);
    verify(() => repo.load()).called(1);
    verify(() => repo.save(result)).called(1);
  });

  // C1 regression: revealing a map must preserve pre-existing favor steps.
  test(
      'C1 regression — revealing a map preserves pre-existing favor steps '
      'in the saved progress', () async {
    const freshFromDisk = Progress(
      completedFavorSteps: {'f1:s1'},
    );
    when(() => repo.load()).thenAnswer((_) async => freshFromDisk);

    // Stale current from BossDetailsBloc lacks the favor steps.
    const staleCurrentFromBossBloc = Progress();

    final result =
        await usecase(staleCurrentFromBossBloc, 'baldur', revealed: true);

    expect(result.isMapRevealed('baldur'), isTrue);
    // Favor steps must survive — this was the data-loss bug.
    expect(result.isStepDone('f1', 's1'), isTrue);
    verify(() => repo.save(result)).called(1);
  });
}
