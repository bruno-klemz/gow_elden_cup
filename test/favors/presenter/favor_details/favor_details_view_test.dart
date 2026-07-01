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
import 'package:gow_elden_cup/favors/presenter/favor_details/widgets/step_entry.dart';

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
          child: const FavorDetailsView(favor: _favor),
        ),
      );

  void sizeTall(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('tapping the first step dispatches FavorStepToggled',
      (tester) async {
    sizeTall(tester);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // Status badge uppercases the seal text.
    expect(find.text('NÃO INICIADA'), findsOneWidget);

    // Steps are tappable rows (no Checkbox). Tap the first one.
    await tester.tap(find.byType(StepEntry).first);
    await tester.pump();

    verify(() => bloc.add(const FavorStepToggled('s1'))).called(1);
  });

  testWidgets('badge shows "EM PROGRESSO 1 DE 2" when one step is done',
      (tester) async {
    sizeTall(tester);

    const progressWithS1 = Progress(completedFavorSteps: {'f1:s1'});
    when(() => bloc.state)
        .thenReturn(const FavorDetailsState(progress: progressWithS1));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('EM PROGRESSO 1 DE 2'), findsOneWidget);
  });

  testWidgets('shows favor name, giver, and rewards', (tester) async {
    sizeTall(tester);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Test Favor'), findsWidgets);
    expect(find.textContaining('Brok'), findsOneWidget);
    expect(find.text('Hacksilver'), findsOneWidget);
  });

  testWidgets('shows completion badge when all steps are done', (tester) async {
    sizeTall(tester);

    const allDone = Progress(completedFavorSteps: {'f1:s1', 'f1:s2'});
    when(() => bloc.state)
        .thenReturn(const FavorDetailsState(progress: allDone));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('✦ FAVOR CONCLUÍDO ✦'), findsOneWidget);
  });
}
