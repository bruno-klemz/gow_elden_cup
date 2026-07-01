import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gow_elden_cup/album/domain/entity/boss.dart';
import 'package:gow_elden_cup/album/domain/entity/map_coord.dart';
import 'package:gow_elden_cup/album/domain/entity/realm.dart';
import 'package:gow_elden_cup/dev/map_editor/bloc/map_editor_bloc.dart';
import 'package:gow_elden_cup/dev/map_editor/bloc/map_editor_state.dart';
import 'package:gow_elden_cup/dev/map_editor/map_editor_view.dart';
import 'package:mocktail/mocktail.dart';

class _MockBloc extends MockBloc<MapEditorEvent, MapEditorState>
    implements MapEditorBloc {}

Boss _boss(String id) => Boss(
      id: id,
      name: id,
      realm: 'midgard',
      art: '',
      locationName: '',
      mapCoord: const MapCoord(0, 0),
      lore: '',
    );

MapEditorState _loadedState({String? selectedBossId}) => MapEditorState(
      loading: false,
      realms: const [
        Realm(id: 'midgard', name: 'Midgard', order: 1, mapImage: 'images/map/midgard.webp'),
      ],
      bosses: [_boss('gulltoppr')],
      selectedRealmId: 'midgard',
      selectedBossId: selectedBossId,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(CoordPlaced(0, 0));
  });

  testWidgets('renders realm names and bosses for selected realm', (t) async {
    final bloc = _MockBloc();
    final state = _loadedState();
    whenListen(bloc, Stream<MapEditorState>.empty(), initialState: state);

    await t.pumpWidget(
      MaterialApp(
        home: BlocProvider<MapEditorBloc>.value(
          value: bloc,
          child: const MapEditorView(),
        ),
      ),
    );

    expect(find.text('Midgard'), findsWidgets);
    expect(find.text('gulltoppr'), findsOneWidget);
  });

  testWidgets('tapping the map canvas emits CoordPlaced with x,y in [0,1]',
      (t) async {
    final bloc = _MockBloc();
    final state = _loadedState(selectedBossId: 'gulltoppr');
    whenListen(bloc, Stream<MapEditorState>.empty(), initialState: state);

    // Give the test surface a fixed size so tap coordinates are deterministic.
    t.view.physicalSize = const Size(800, 600);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);

    await t.pumpWidget(
      MaterialApp(
        home: BlocProvider<MapEditorBloc>.value(
          value: bloc,
          child: const MapEditorView(),
        ),
      ),
    );

    // The map canvas is the GestureDetector wrapping the Stack in _MapCanvas.
    // It is the outermost GestureDetector in the Expanded area — find via
    // ancestor of the Positioned.fill Image (identified by the Stack inside
    // the LayoutBuilder). Tap at center of the GestureDetector.
    final mapGesture = find.descendant(
      of: find.byType(Expanded).last,
      matching: find.byType(GestureDetector),
    );

    await t.tapAt(t.getCenter(mapGesture.first));
    await t.pump();

    // Verify a CoordPlaced event was added with x and y clamped to [0..1].
    verify(
      () => bloc.add(
        any(
          that: isA<CoordPlaced>()
              .having((e) => e.x, 'x', inInclusiveRange(0.0, 1.0))
              .having((e) => e.y, 'y', inInclusiveRange(0.0, 1.0)),
        ),
      ),
    ).called(1);
  });
}
