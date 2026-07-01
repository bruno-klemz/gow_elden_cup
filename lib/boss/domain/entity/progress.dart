import 'package:equatable/equatable.dart';

class Progress extends Equatable {
  final Set<String> defeated;
  final Set<String> revealedMap;
  final Set<String> completedFavorSteps;

  const Progress({
    this.defeated = const {},
    this.revealedMap = const {},
    this.completedFavorSteps = const {},
  });

  bool isDefeated(String id) => defeated.contains(id);
  bool isMapRevealed(String id) =>
      revealedMap.contains(id) || defeated.contains(id);

  Progress toggleDefeated(String id) {
    final next = Set<String>.from(defeated);
    next.contains(id) ? next.remove(id) : next.add(id);
    return _copy(defeated: next);
  }

  Progress revealMap(String id) => _copy(revealedMap: {...revealedMap, id});
  Progress hideMap(String id) =>
      _copy(revealedMap: {...revealedMap}..remove(id));
  int defeatedCountIn(Iterable<String> bossIds) =>
      bossIds.where(defeated.contains).length;

  String _key(String favorId, String stepId) => '$favorId:$stepId';
  bool isStepDone(String favorId, String stepId) =>
      completedFavorSteps.contains(_key(favorId, stepId));

  Progress toggleStep(String favorId, String stepId) {
    final k = _key(favorId, stepId);
    final next = Set<String>.from(completedFavorSteps);
    next.contains(k) ? next.remove(k) : next.add(k);
    return _copy(completedFavorSteps: next);
  }

  int completedStepCount(String favorId, Iterable<String> stepIds) =>
      stepIds.where((s) => isStepDone(favorId, s)).length;

  Progress _copy({
    Set<String>? defeated,
    Set<String>? revealedMap,
    Set<String>? completedFavorSteps,
  }) => Progress(
    defeated: defeated ?? this.defeated,
    revealedMap: revealedMap ?? this.revealedMap,
    completedFavorSteps: completedFavorSteps ?? this.completedFavorSteps,
  );

  @override
  List<Object?> get props => [defeated, revealedMap, completedFavorSteps];
}
