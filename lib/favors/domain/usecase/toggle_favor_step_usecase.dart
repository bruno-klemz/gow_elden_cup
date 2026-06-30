import '../../../boss/domain/entity/progress.dart';
import '../../../boss/domain/repository/progress_repository.dart';

abstract class ToggleFavorStepUsecase {
  Future<Progress> call(Progress current, String favorId, String stepId);
}

class ToggleFavorStepUsecaseImpl implements ToggleFavorStepUsecase {
  final ProgressRepository repository;

  ToggleFavorStepUsecaseImpl({required this.repository});

  /// Reloads fresh progress from the repository before mutating so that a
  /// stale in-memory [current] snapshot from a sibling bloc can never clobber
  /// keys written by another feature.
  @override
  Future<Progress> call(Progress current, String favorId, String stepId) async {
    final fresh = await repository.load();
    final next = fresh.toggleStep(favorId, stepId);
    await repository.save(next);
    return next;
  }
}
