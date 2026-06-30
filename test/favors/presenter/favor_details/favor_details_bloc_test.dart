import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor_step.dart';
import 'package:gow_elden_cup/favors/domain/usecase/toggle_favor_step_usecase.dart';
import 'package:gow_elden_cup/favors/presenter/favor_details/bloc/favor_details_bloc.dart';

class _MockLoadProgress extends Mock implements LoadProgressUsecase {}

class _MockToggleFavorStep extends Mock implements ToggleFavorStepUsecase {}

const _step1 = FavorStep(id: 's1', title: 'Step 1', detail: 'Do this first.');
const _step2 = FavorStep(id: 's2', title: 'Step 2', detail: 'Do this second.');

const _favor = Favor(
  id: 'f1',
  name: 'A Favor',
  realm: 'midgard',
  summary: 'Summary text',
  lore: 'Lore text',
  steps: [_step1, _step2],
);

void main() {
  late _MockLoadProgress loadProgress;
  late _MockToggleFavorStep toggleStep;

  setUpAll(() {
    registerFallbackValue(const Progress());
  });

  setUp(() {
    loadProgress = _MockLoadProgress();
    toggleStep = _MockToggleFavorStep();
  });

  FavorDetailsBloc build() => FavorDetailsBloc(
        favor: _favor,
        loadProgress: loadProgress,
        toggleStep: toggleStep,
      );

  blocTest<FavorDetailsBloc, FavorDetailsState>(
    'FavorDetailsStarted loads progress from the use case',
    setUp: () {
      when(() => loadProgress())
          .thenAnswer((_) async => const Progress());
    },
    build: build,
    act: (bloc) => bloc.add(const FavorDetailsStarted()),
    expect: () => [
      isA<FavorDetailsState>().having(
        (s) => s.completedCount(_favor),
        'completedCount',
        0,
      ),
    ],
  );

  blocTest<FavorDetailsBloc, FavorDetailsState>(
    'FavorStepToggled calls use case and emits state where step is done and '
    'completedCount is incremented',
    setUp: () {
      when(() => toggleStep(any(), any(), any())).thenAnswer(
        (_) async => const Progress(
          completedFavorSteps: {'f1:s1'},
        ),
      );
    },
    build: build,
    act: (bloc) => bloc.add(const FavorStepToggled('s1')),
    expect: () => [
      isA<FavorDetailsState>()
          .having(
            (s) => s.progress.isStepDone('f1', 's1'),
            'isStepDone s1',
            true,
          )
          .having(
            (s) => s.completedCount(_favor),
            'completedCount',
            1,
          )
          .having(
            (s) => s.isComplete(_favor),
            'isComplete',
            false,
          ),
    ],
    verify: (bloc) {
      verify(() => toggleStep(any(), 'f1', 's1')).called(1);
    },
  );

  blocTest<FavorDetailsBloc, FavorDetailsState>(
    'isComplete returns true when all steps are done',
    setUp: () {
      when(() => toggleStep(any(), any(), any())).thenAnswer(
        (_) async => const Progress(
          completedFavorSteps: {'f1:s1', 'f1:s2'},
        ),
      );
    },
    build: build,
    act: (bloc) => bloc.add(const FavorStepToggled('s2')),
    expect: () => [
      isA<FavorDetailsState>().having(
        (s) => s.isComplete(_favor),
        'isComplete',
        true,
      ),
    ],
  );

  group('FavorDetailsState.seal text', () {
    test('returns "Não iniciada" when no steps done', () {
      const state = FavorDetailsState();
      expect(state.sealText(_favor), 'Não iniciada');
    });

    test('returns "Em progresso 1 de 2" when one step done', () {
      const progress = Progress(completedFavorSteps: {'f1:s1'});
      const state = FavorDetailsState(progress: progress);
      expect(state.sealText(_favor), 'Em progresso 1 de 2');
    });

    test('returns "Completa" when all steps done', () {
      const progress = Progress(completedFavorSteps: {'f1:s1', 'f1:s2'});
      const state = FavorDetailsState(progress: progress);
      expect(state.sealText(_favor), 'Completa');
    });
  });
}
