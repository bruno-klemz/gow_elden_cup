import 'boss.dart';
import 'realm.dart';

class AlbumData {
  final List<Realm> realms;
  final List<Boss> bosses;
  const AlbumData({required this.realms, required this.bosses});

  List<Boss> bossesIn(String realmId) =>
      bosses.where((b) => b.realm == realmId).toList();

  Boss bossById(String id) => bosses.firstWhere((b) => b.id == id);
}
