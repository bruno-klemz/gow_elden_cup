import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor_step.dart';
import 'package:gow_elden_cup/favors/domain/entity/reward.dart';
import 'package:gow_elden_cup/favors/presenter/favor_details/bloc/favor_details_bloc.dart';
import 'package:gow_elden_cup/favors/presenter/favor_details/favor_details_view.dart';

class _MockFavorDetailsBloc
    extends MockBloc<FavorDetailsEvent, FavorDetailsState>
    implements FavorDetailsBloc {}

const _step1 = FavorStep(id: 's1', title: 'Step One', detail: 'First thing.');
const _step2 = FavorStep(id: 's2', title: 'Step Two', detail: 'Second thing.');

const _favor = Favor(
  id: 'f1',
  name: 'Test Favor',
  realm: 'midgard',
  region: 'Wildwoods',
  giver: 'Brok',
  summary: 'Summary here',
  lore: 'Ancient lore text.',
  steps: [_step1, _step2],
  rewards: [Reward(name: 'Hacksilver', quantity: 500)],
);

void main() {
  late _MockFavorDetailsBloc bloc;

  setUpAll(() {
    registerFallbackValue(const Progress());
    registerFallbackValue(const FavorDetailsStarted());
    registerFallbackValue(const FavorStepToggled(''));
  });

  setUp(() {
    bloc = _MockFavorDetailsBloc();
    when(() => bloc.state).thenReturn(const FavorDetailsState());
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSubject() => MaterialApp(
        home: BlocProvider<FavorDetailsBloc>.value(
          value: bloc,
          child: FavorDetailsView(favor: _favor),
        ),
      );

  testWidgets(
    'tapping the first step checkbox dispatches FavorStepToggled',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Initial state: no steps done → seal shows "Não iniciada"
      when(() => bloc.state).thenReturn(const FavorDetailsState());
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Não iniciada'), findsOneWidget);

      // Tap the first step checkbox
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.first);
      await tester.pump();

      // Verify the toggle event was dispatched for step s1
      verify(() => bloc.add(const FavorStepToggled('s1'))).called(1);
    },
  );

  testWidgets(
    'seal text shows "Em progresso 1 de 2" when one step is done',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const progressWithS1 = Progress(completedFavorSteps: {'f1:s1'});
      when(() => bloc.state)
          .thenReturn(const FavorDetailsState(progress: progressWithS1));
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Em progresso 1 de 2'), findsOneWidget);
    },
  );

  testWidgets('shows favor name, realm, and giver in the header', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Test Favor'), findsWidgets);
    expect(find.textContaining('Brok'), findsOneWidget);
    expect(find.text('Hacksilver'), findsOneWidget);
  });

  testWidgets('shows "Completa" seal when all steps are done', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const allDone = Progress(completedFavorSteps: {'f1:s1', 'f1:s2'});
    when(() => bloc.state)
        .thenReturn(const FavorDetailsState(progress: allDone));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Completa'), findsOneWidget);
  });
}
