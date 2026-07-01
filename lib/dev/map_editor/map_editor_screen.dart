import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../album/domain/usecase/load_album_usecase.dart';
import '../../service_locator.dart';
import 'bloc/map_editor_bloc.dart';
import 'map_editor_view.dart';

class MapEditorScreen extends StatelessWidget {
  const MapEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MapEditorBloc(locator<LoadAlbumUsecase>())..add(MapEditorStarted()),
      child: const MapEditorView(),
    );
  }
}
