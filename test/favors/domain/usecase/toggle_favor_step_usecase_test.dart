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

  test('call toggles the step from undone to done and saves once', () async {
    const initial = Progress();

    final result = await usecase(initial, 'the_lost_lindwyrm', 's1');

    expect(result.isStepDone('the_lost_lindwyrm', 's1'), isTrue);
    verify(() => repo.save(result)).called(1);
  });

  test('call toggles the step from done to undone and saves once', () async {
    final alreadyDone = const Progress().toggleStep('the_lost_lindwyrm', 's1');

    final result = await usecase(alreadyDone, 'the_lost_lindwyrm', 's1');

    expect(result.isStepDone('the_lost_lindwyrm', 's1'), isFalse);
    verify(() => repo.save(result)).called(1);
  });

  test('call does not mutate the original Progress', () async {
    const initial = Progress();

    await usecase(initial, 'favor_x', 's2');

    expect(initial.isStepDone('favor_x', 's2'), isFalse);
  });
}
