part of 'favor_details_bloc.dart';

class FavorDetailsState extends Equatable {
  final Progress progress;

  const FavorDetailsState({this.progress = const Progress()});

  int completedCount(Favor favor) =>
      progress.completedStepCount(favor.id, favor.stepIds);

  bool isComplete(Favor favor) {
    final total = favor.stepIds.length;
    if (total == 0) return false;
    return completedCount(favor) == total;
  }

  /// Returns the localised seal text for the given favor.
  ///
  /// "Não iniciada" / "Em progresso X de N" / "Completa" — no nested ternary.
  String sealText(Favor favor) {
    final total = favor.stepIds.length;
    final done = completedCount(favor);
    if (done == 0) return 'Não iniciada';
    if (done == total) return 'Completa';
    return 'Em progresso $done de $total';
  }

  FavorDetailsState copyWith({Progress? progress}) {
    return FavorDetailsState(progress: progress ?? this.progress);
  }

  @override
  List<Object?> get props => [progress];
}
