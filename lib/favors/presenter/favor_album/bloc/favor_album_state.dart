part of 'favor_album_bloc.dart';

enum FavorAlbumStatus { initial, loading, loaded }

enum FavorStatus { pending, inProgress, complete }

class FavorAlbumState extends Equatable {
  final FavorAlbumStatus status;
  final FavorsData? favorsData;
  final Progress progress;
  final String? realmFilter;
  final FavorStatus? statusFilter;

  const FavorAlbumState({
    this.status = FavorAlbumStatus.initial,
    this.favorsData,
    this.progress = const Progress(),
    this.realmFilter,
    this.statusFilter,
  });

  bool get isLoaded => status == FavorAlbumStatus.loaded && favorsData != null;

  /// Distinct realm ids present in the loaded favors, in encounter order.
  List<String> get realmIds {
    final data = favorsData;
    if (data == null) return const [];
    final seen = <String>{};
    return data.favors.map((f) => f.realm).where(seen.add).toList();
  }

  /// Favors after applying both filters.
  List<Favor> get filteredFavors {
    final data = favorsData;
    if (data == null) return const [];

    var favors = data.favors;

    final realm = realmFilter;
    if (realm != null) {
      favors = favors.where((f) => f.realm == realm).toList();
    }

    final status = statusFilter;
    if (status != null) {
      favors = favors.where((f) => favorStatus(f, progress) == status).toList();
    }

    return favors;
  }

  FavorAlbumState copyWith({
    FavorAlbumStatus? status,
    FavorsData? favorsData,
    Progress? progress,
    String? realmFilter,
    FavorStatus? statusFilter,
    bool clearRealmFilter = false,
    bool clearStatusFilter = false,
  }) {
    return FavorAlbumState(
      status: status ?? this.status,
      favorsData: favorsData ?? this.favorsData,
      progress: progress ?? this.progress,
      realmFilter: clearRealmFilter ? null : (realmFilter ?? this.realmFilter),
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
    );
  }

  @override
  List<Object?> get props => [
    status,
    favorsData,
    progress,
    realmFilter,
    statusFilter,
  ];
}
