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

void main() {
  testWidgets('renders realm names and bosses for selected realm', (t) async {
    final bloc = _MockBloc();
    final state = MapEditorState(
      loading: false,
      realms: const [Realm(id: 'midgard', name: 'Midgard', order: 1)],
      bosses: [_boss('gulltoppr')],
      selectedRealmId: 'midgard',
    );
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
}
