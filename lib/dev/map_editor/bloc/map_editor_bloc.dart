import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../album/domain/entity/map_coord.dart';
import '../../../album/domain/usecase/load_album_usecase.dart';
import '../coord_exporter.dart';
import 'map_editor_state.dart';

abstract class MapEditorEvent {}

class MapEditorStarted extends MapEditorEvent {}

class RealmSelected extends MapEditorEvent {
  final String realmId;
  RealmSelected(this.realmId);
}

class BossSelected extends MapEditorEvent {
  final String bossId;
  BossSelected(this.bossId);
}

class CoordPlaced extends MapEditorEvent {
  final double x;
  final double y;
  CoordPlaced(this.x, this.y);
}

class CoordsExported extends MapEditorEvent {}

typedef ExportFn = Future<String> Function(Map<String, MapCoord> coords);

class MapEditorBloc extends Bloc<MapEditorEvent, MapEditorState> {
  final LoadAlbumUsecase _loadAlbum;
  final ExportFn _export;

  MapEditorBloc(this._loadAlbum, {ExportFn? export})
      : _export = export ?? exportCoords,
        super(const MapEditorState()) {
    on<MapEditorStarted>(_onStarted);
    on<RealmSelected>(
      (e, emit) => emit(state.copyWith(selectedRealmId: e.realmId)),
    );
    on<BossSelected>(
      (e, emit) => emit(state.copyWith(selectedBossId: e.bossId)),
    );
    on<CoordPlaced>(_onPlaced);
    on<CoordsExported>(_onExported);
  }

  Future<void> _onStarted(
    MapEditorStarted event,
    Emitter<MapEditorState> emit,
  ) async {
    final data = await _loadAlbum();
    // Seed coords from existing JSON values so unedited bosses keep their coord.
    final seeded = <String, MapCoord>{
      for (final b in data.bosses) b.id: b.mapCoord,
    };
    emit(state.copyWith(
      loading: false,
      realms: data.realms,
      bosses: data.bosses,
      coords: seeded,
    ));
  }

  void _onPlaced(CoordPlaced event, Emitter<MapEditorState> emit) {
    final id = state.selectedBossId;
    if (id == null) return;
    final next = Map<String, MapCoord>.from(state.coords);
    next[id] = MapCoord(event.x, event.y);
    emit(state.copyWith(coords: next));
  }

  Future<void> _onExported(
    CoordsExported event,
    Emitter<MapEditorState> emit,
  ) async {
    final path = await _export(state.coords);
    // ignore: avoid_print
    print('map_coords.json => $path\n${encodeCoords(state.coords)}');
    emit(state.copyWith(exportedPath: path));
  }
}
