part of 'favor_album_bloc.dart';

sealed class FavorAlbumEvent extends Equatable {
  const FavorAlbumEvent();

  @override
  List<Object?> get props => [];
}

/// Loads favor content and persisted progress.
class FavorAlbumStarted extends FavorAlbumEvent {
  const FavorAlbumStarted();
}

/// Reloads progress (e.g. after returning from the favor details screen).
class FavorAlbumProgressRefreshed extends FavorAlbumEvent {
  const FavorAlbumProgressRefreshed();
}

/// Narrows the grid to a single realm. Pass `null` to show all realms.
class FavorAlbumRealmFilterChanged extends FavorAlbumEvent {
  final String? realmId;
  const FavorAlbumRealmFilterChanged(this.realmId);

  @override
  List<Object?> get props => [realmId];
}

/// Narrows the grid to favors with the given status. Pass `null` to show all.
class FavorAlbumStatusFilterChanged extends FavorAlbumEvent {
  final FavorStatus? status;
  const FavorAlbumStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}
