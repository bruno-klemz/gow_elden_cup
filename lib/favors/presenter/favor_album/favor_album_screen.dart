import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../favors/domain/usecase/load_favors_usecase.dart';
import '../../../service_locator.dart';
import 'bloc/favor_album_bloc.dart';
import 'favor_album_view.dart';

/// Composition root for the favor album: creates [FavorAlbumBloc] from the
/// service locator and starts the data load.
class FavorAlbumScreen extends StatelessWidget {
  const FavorAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FavorAlbumBloc(
        loadFavors: locator<LoadFavorsUsecase>(),
        loadProgress: locator<LoadProgressUsecase>(),
      )..add(const FavorAlbumStarted()),
      child: const FavorAlbumView(),
    );
  }
}
