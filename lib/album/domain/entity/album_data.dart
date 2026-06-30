import 'package:equatable/equatable.dart';

import 'boss.dart';
import 'realm.dart';

class AlbumData extends Equatable {
  final List<Realm> realms;
  final List<Boss> bosses;
  const AlbumData({required this.realms, required this.bosses});

  @override
  List<Object?> get props => [realms, bosses];

  List<Boss> bossesIn(String realmId) =>
      bosses.where((b) => b.realm == realmId).toList();

  Boss bossById(String id) => bosses.firstWhere((b) => b.id == id);
}
