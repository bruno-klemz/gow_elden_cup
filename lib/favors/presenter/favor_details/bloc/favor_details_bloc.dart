import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../boss/domain/entity/progress.dart';
import '../../../../boss/domain/usecase/load_progress_usecase.dart';
import '../../../../favors/domain/entity/favor.dart';
import '../../../../favors/domain/usecase/toggle_favor_step_usecase.dart';

part 'favor_details_event.dart';
part 'favor_details_state.dart';

class FavorDetailsBloc extends Bloc<FavorDetailsEvent, FavorDetailsState> {
  final Favor _favor;
  final LoadProgressUsecase _loadProgress;
  final ToggleFavorStepUsecase _toggleStep;

  FavorDetailsBloc({
    required Favor favor,
    required LoadProgressUsecase loadProgress,
    required ToggleFavorStepUsecase toggleStep,
  })  : _favor = favor,
        _loadProgress = loadProgress,
        _toggleStep = toggleStep,
        super(const FavorDetailsState()) {
    on<FavorDetailsStarted>(_onStarted);
    on<FavorStepToggled>(_onToggled);
  }

  Future<void> _onStarted(
      FavorDetailsStarted e, Emitter<FavorDetailsState> emit) async {
    emit(state.copyWith(progress: await _loadProgress()));
  }

  Future<void> _onToggled(
      FavorStepToggled e, Emitter<FavorDetailsState> emit) async {
    final next = await _toggleStep(state.progress, _favor.id, e.stepId);
    emit(state.copyWith(progress: next));
  }
}
