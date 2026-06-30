import '../entity/progress.dart';
import '../repository/progress_repository.dart';

/// Toggles a boss's defeated state on the given progress, persists, and returns
/// the updated progress.
abstract class ToggleDefeatedUsecase {
  Future<Progress> call(Progress current, String bossId);
}

class ToggleDefeatedUsecaseImpl implements ToggleDefeatedUsecase {
  final ProgressRepository _repository;

  ToggleDefeatedUsecaseImpl({required ProgressRepository repository})
      : _repository = repository;

  /// Reloads fresh progress from the repository before mutating so that a
  /// stale in-memory [current] snapshot from a sibling bloc can never clobber
  /// keys written by another feature.
  @override
  Future<Progress> call(Progress current, String bossId) async {
    final fresh = await _repository.load();
    final next = fresh.toggleDefeated(bossId);
    await _repository.save(next);
    return next;
  }
}
