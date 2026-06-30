import 'package:flutter/material.dart';
import '../../../domain/entity/favor.dart';
import '../bloc/favor_album_bloc.dart';
import 'realm_section.dart';

/// Scrollable list of [RealmSection]s, grouping [favors] by realm while
/// preserving encounter order.
class FavorList extends StatelessWidget {
  const FavorList({
    super.key,
    required this.favors,
    required this.state,
    required this.onFavorTap,
  });

  final List<Favor> favors;
  final FavorAlbumState state;
  final ValueChanged<Favor> onFavorTap;

  @override
  Widget build(BuildContext context) {
    // Group favors by realm while preserving encounter order.
    final realmIds = <String>[];
    final byRealm = <String, List<Favor>>{};
    for (final favor in favors) {
      if (!byRealm.containsKey(favor.realm)) {
        realmIds.add(favor.realm);
        byRealm[favor.realm] = [];
      }
      byRealm[favor.realm]!.add(favor);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      itemCount: realmIds.length,
      itemBuilder: (context, index) {
        final realmId = realmIds[index];
        final realmFavors = byRealm[realmId]!;
        return RealmSection(
          realmId: realmId,
          favors: realmFavors,
          state: state,
          onFavorTap: onFavorTap,
        );
      },
    );
  }
}
