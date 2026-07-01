import '../entity/progress.dart';
import '../repository/progress_repository.dart';

/// Reveals or hides a boss's map on the given progress, persists, and returns
/// the updated progress.
abstract class SetMapRevealedUsecase {
  Future<Progress> call(
    Progress current,
    String bossId, {
    required bool revealed,
  });
}

class SetMapRevealedUsecaseImpl implements SetMapRevealedUsecase {
  final ProgressRepository _repository;

  SetMapRevealedUsecaseImpl({required ProgressRepository repository})
    : _repository = repository;

  /// Reloads fresh progress from the repository before mutating so that a
  /// stale in-memory [current] snapshot from a sibling bloc can never clobber
  /// keys written by another feature.
  @override
  Future<Progress> call(
    Progress current,
    String bossId, {
    required bool revealed,
  }) async {
    final fresh = await _repository.load();
    final next = revealed ? fresh.revealMap(bossId) : fresh.hideMap(bossId);
    await _repository.save(next);
    return next;
  }
}
