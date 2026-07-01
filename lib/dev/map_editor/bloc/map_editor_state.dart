import 'package:equatable/equatable.dart';

import '../../../album/domain/entity/boss.dart';
import '../../../album/domain/entity/map_coord.dart';
import '../../../album/domain/entity/realm.dart';

class MapEditorState extends Equatable {
  final bool loading;
  final List<Realm> realms;
  final List<Boss> bosses;
  final String? selectedRealmId;
  final String? selectedBossId;
  final Map<String, MapCoord> coords;
  final String? exportedPath;

  const MapEditorState({
    this.loading = true,
    this.realms = const [],
    this.bosses = const [],
    this.selectedRealmId,
    this.selectedBossId,
    this.coords = const {},
    this.exportedPath,
  });

  List<Boss> get bossesForSelectedRealm => selectedRealmId == null
      ? const []
      : bosses.where((b) => b.realm == selectedRealmId).toList();

  MapEditorState copyWith({
    bool? loading,
    List<Realm>? realms,
    List<Boss>? bosses,
    String? selectedRealmId,
    String? selectedBossId,
    bool clearSelectedBoss = false,
    Map<String, MapCoord>? coords,
    String? exportedPath,
  }) => MapEditorState(
        loading: loading ?? this.loading,
        realms: realms ?? this.realms,
        bosses: bosses ?? this.bosses,
        selectedRealmId: selectedRealmId ?? this.selectedRealmId,
        selectedBossId: clearSelectedBoss ? null : (selectedBossId ?? this.selectedBossId),
        coords: coords ?? this.coords,
        exportedPath: exportedPath ?? this.exportedPath,
      );

  @override
  List<Object?> get props => [
        loading,
        realms,
        bosses,
        selectedRealmId,
        selectedBossId,
        coords,
        exportedPath,
      ];
}
