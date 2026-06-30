import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/damage_type.dart';
import 'package:gow_elden_cup/album/domain/entity/loot_item.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/boss/presenter/boss_details/bloc/boss_details_bloc.dart';
import 'package:gow_elden_cup/boss/presenter/boss_details/boss_details_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/settings_bloc_harness.dart';

class _MockBossDetailsBloc
    extends MockBloc<BossDetailsEvent, BossDetailsState>
    implements BossDetailsBloc {}

const _boss = Boss(
  id: 'baldur',
  name: 'Baldur',
  realm: 'midgard',
  art: 'images/baldur.webp',
  locationName: 'Floresta de Wildwoods',
  mapCoord: MapCoord(0.5, 0.5),
  weaknesses: [DamageType.frost],
  immunities: [DamageType.burn],
  strategy: 'Use o machado para congelar e causar dano.',
  loot: [LootItem(name: 'Fragmento de Bruma')],
  lore: 'Filho de Odin, amaldiçoado a não sentir dor.',
);

void main() {
  late _MockBossDetailsBloc bloc;

  setUpAll(() {
    registerFallbackValue(const Progress());
    registerFallbackValue(const BossDetailsStarted());
  });

  setUp(() {
    bloc = _MockBossDetailsBloc();
    when(() => bloc.state).thenReturn(BossDetailsState(boss: _boss));
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSubject() => MaterialApp(
        home: withSettings(
          BlocProvider<BossDetailsBloc>.value(
            value: bloc,
            child: const BossDetailsView(realmMapImage: null),
          ),
        ),
      );

  testWidgets('shows strategy text, weakness chip, and loot item', (tester) async {
    // Enlarge viewport to fit the long details sheet
    tester.view.physicalSize = const Size(1080, 3840);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // Strategy text
    expect(
      find.text('Use o machado para congelar e causar dano.'),
      findsOneWidget,
    );

    // Weakness chip label
    expect(find.text('Gelo'), findsOneWidget);

    // Loot item name
    expect(find.text('Fragmento de Bruma'), findsOneWidget);
  });
}
