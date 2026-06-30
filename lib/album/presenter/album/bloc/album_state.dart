part of 'album_bloc.dart';

enum AlbumStatus { initial, loading, loaded }

class AlbumState extends Equatable {
  final AlbumStatus status;
  final AlbumData? data;
  final Progress progress;

  /// Id of a boss whose slot should play the reveal animation. Null once
  /// consumed.
  final String? justRevealedBossId;

  const AlbumState({
    this.status = AlbumStatus.initial,
    this.data,
    this.progress = const Progress(),
    this.justRevealedBossId,
  });

  bool get isLoaded => status == AlbumStatus.loaded && data != null;

  List<Realm> get realms => data?.realms ?? const [];
  int get totalBosses => data?.bosses.length ?? 0;
  int get totalDefeated => progress.defeated.length;

  List<Boss> bossesIn(String realmId) => data?.bossesIn(realmId) ?? const [];
  int countIn(String realmId) => bossesIn(realmId).length;
  int defeatedIn(String realmId) =>
      progress.defeatedCountIn(bossesIn(realmId).map((b) => b.id));

  /// Headline bosses of a realm, ordered by mainOrder (left to right).
  List<Boss> mainBossesIn(String realmId) =>
      bossesIn(realmId).where((b) => b.isMainBoss).toList()
        ..sort((a, b) => a.mainOrder.compareTo(b.mainOrder));

  /// Non-headline bosses of a realm, sorted alphabetically (case-insensitive).
  List<Boss> otherBossesIn(String realmId) =>
      bossesIn(realmId).where((b) => !b.isMainBoss).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  bool isDefeated(String id) => progress.isDefeated(id);

  AlbumState copyWith({
    AlbumStatus? status,
    AlbumData? data,
    Progress? progress,
    String? justRevealedBossId,
    bool clearReveal = false,
  }) {
    return AlbumState(
      status: status ?? this.status,
      data: data ?? this.data,
      progress: progress ?? this.progress,
      justRevealedBossId:
          clearReveal ? null : (justRevealedBossId ?? this.justRevealedBossId),
    );
  }

  @override
  List<Object?> get props => [status, data, progress, justRevealedBossId];
}
