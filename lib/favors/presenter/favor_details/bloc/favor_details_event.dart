part of 'favor_details_bloc.dart';

sealed class FavorDetailsEvent extends Equatable {
  const FavorDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the current progress for this favor.
class FavorDetailsStarted extends FavorDetailsEvent {
  const FavorDetailsStarted();
}

/// Toggles the completion state of a single favor step.
class FavorStepToggled extends FavorDetailsEvent {
  final String stepId;
  const FavorStepToggled(this.stepId);

  @override
  List<Object?> get props => [stepId];
}
