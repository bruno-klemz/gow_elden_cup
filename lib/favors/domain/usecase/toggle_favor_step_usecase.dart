import '../../../boss/domain/entity/progress.dart';
import '../../../boss/domain/repository/progress_repository.dart';

abstract class ToggleFavorStepUsecase {
  Future<Progress> call(Progress current, String favorId, String stepId);
}

class ToggleFavorStepUsecaseImpl implements ToggleFavorStepUsecase {
  final ProgressRepository repository;

  ToggleFavorStepUsecaseImpl({required this.repository});

  @override
  Future<Progress> call(Progress current, String favorId, String stepId) async {
    final next = current.toggleStep(favorId, stepId);
    await repository.save(next);
    return next;
  }
}
