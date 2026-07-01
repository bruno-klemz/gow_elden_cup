import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../album/domain/entity/boss.dart';
import '../../../service_locator.dart';
import '../../domain/usecase/load_progress_usecase.dart';
import '../../domain/usecase/set_map_revealed_usecase.dart';
import '../../domain/usecase/toggle_defeated_usecase.dart';
import 'bloc/boss_details_bloc.dart';
import 'boss_details_view.dart';

/// Composition root for the full-screen boss details.
class BossDetailsScreen extends StatelessWidget {
  const BossDetailsScreen({super.key, required this.boss, this.realmMapImage});

  final Boss boss;

  /// Realm-specific map image path (e.g. `images/map/midgard.webp`), or null.
  /// Resolved by the caller (album_view) from AlbumData before pushing.
  final String? realmMapImage;

  /// Pushes the boss details as a full-screen route. Returns the boss id if
  /// it was marked defeated here, or null if the user just went back.
  static Future<String?> push(
    BuildContext context,
    Boss boss, {
    String? realmMapImage,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            BossDetailsScreen(boss: boss, realmMapImage: realmMapImage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BossDetailsBloc(
        boss: boss,
        loadProgress: locator<LoadProgressUsecase>(),
        toggleDefeated: locator<ToggleDefeatedUsecase>(),
        setMapRevealed: locator<SetMapRevealedUsecase>(),
      )..add(const BossDetailsStarted()),
      child: BossDetailsView(realmMapImage: realmMapImage),
    );
  }
}
