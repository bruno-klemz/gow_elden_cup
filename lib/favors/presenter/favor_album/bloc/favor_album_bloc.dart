import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../boss/domain/entity/progress.dart';
import '../../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../../favors/domain/entity/favor.dart';
import '../../../../favors/domain/entity/favors_data.dart';
import '../../../../favors/domain/usecase/load_favors_usecase.dart';

part 'favor_album_event.dart';
part 'favor_album_state.dart';

/// Returns the completion status of [favor] based on [progress].
///
/// A favor with 0 steps is treated as [FavorStatus.pending] — it has
/// no measurable work completed, so it cannot be "done."
FavorStatus favorStatus(Favor favor, Progress progress) {
  final total = favor.stepIds.length;
  if (total == 0) return FavorStatus.pending;
  final done = progress.completedStepCount(favor.id, favor.stepIds);
  if (done == total) return FavorStatus.complete;
  if (done > 0) return FavorStatus.inProgress;
  return FavorStatus.pending;
}

class FavorAlbumBloc extends Bloc<FavorAlbumEvent, FavorAlbumState> {
  final LoadFavorsUsecase _loadFavors;
  final LoadProgressUsecase _loadProgress;

  FavorAlbumBloc({
    required LoadFavorsUsecase loadFavors,
    required LoadProgressUsecase loadProgress,
  })  : _loadFavors = loadFavors,
        _loadProgress = loadProgress,
        super(const FavorAlbumState()) {
    on<FavorAlbumStarted>(_onStarted);
    on<FavorAlbumProgressRefreshed>(_onProgressRefreshed);
    on<FavorAlbumRealmFilterChanged>(_onRealmFilterChanged);
    on<FavorAlbumStatusFilterChanged>(_onStatusFilterChanged);
  }

  Future<void> _onStarted(
      FavorAlbumStarted event, Emitter<FavorAlbumState> emit) async {
    emit(state.copyWith(status: FavorAlbumStatus.loading));
    final favorsData = await _loadFavors();
    final progress = await _loadProgress();
    emit(state.copyWith(
      status: FavorAlbumStatus.loaded,
      favorsData: favorsData,
      progress: progress,
    ));
  }

  Future<void> _onProgressRefreshed(
      FavorAlbumProgressRefreshed event, Emitter<FavorAlbumState> emit) async {
    final progress = await _loadProgress();
    emit(state.copyWith(progress: progress));
  }

  void _onRealmFilterChanged(
      FavorAlbumRealmFilterChanged event, Emitter<FavorAlbumState> emit) {
    emit(state.copyWith(
      realmFilter: event.realmId,
      clearRealmFilter: event.realmId == null,
    ));
  }

  void _onStatusFilterChanged(
      FavorAlbumStatusFilterChanged event, Emitter<FavorAlbumState> emit) {
    emit(state.copyWith(
      statusFilter: event.status,
      clearStatusFilter: event.status == null,
    ));
  }
}
