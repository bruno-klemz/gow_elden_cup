import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gow_elden_cup/boss/domain/entity/progress.dart';
import 'package:gow_elden_cup/boss/domain/usecase/load_progress_usecase.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor.dart';
import 'package:gow_elden_cup/favors/domain/entity/favor_step.dart';
import 'package:gow_elden_cup/favors/domain/entity/favors_data.dart';
import 'package:gow_elden_cup/favors/domain/usecase/load_favors_usecase.dart';
import 'package:gow_elden_cup/favors/presenter/favor_album/bloc/favor_album_bloc.dart';

class _MockLoadFavors extends Mock implements LoadFavorsUsecase {}

class _MockLoadProgress extends Mock implements LoadProgressUsecase {}

// ── fixture data ──────────────────────────────────────────────────────────────

const _step1 = FavorStep(id: 's1', title: 'Step 1', detail: 'd1');
const _step2 = FavorStep(id: 's2', title: 'Step 2', detail: 'd2');
const _step3 = FavorStep(id: 's3', title: 'Step 3', detail: 'd3');

/// Midgard favor — 2 steps; completed when both done.
const _favorMidgardComplete = Favor(
  id: 'fav-mid-complete',
  name: 'The Last Remnants of Asgard',
  realm: 'midgard',
  summary: 's',
  lore: 'l',
  steps: [_step1, _step2],
);

/// Midgard favor — 2 steps; 1 done → inProgress.
const _favorMidgardInProgress = Favor(
  id: 'fav-mid-progress',
  name: 'In Plain Sight',
  realm: 'midgard',
  summary: 's',
  lore: 'l',
  steps: [_step1, _step2],
);

/// Svartalfheim favor — 0 steps → pending (0-step rule).
const _favorSvartalfPending = Favor(
  id: 'fav-svart-pending',
  name: 'Weight of Chains',
  realm: 'svartalfheim',
  summary: 's',
  lore: 'l',
  steps: [],
);

/// Svartalfheim favor — 3 steps; 0 done → pending.
const _favorSvartalfPending2 = Favor(
  id: 'fav-svart-pending2',
  name: 'Imprisoned Minds',
  realm: 'svartalfheim',
  summary: 's',
  lore: 'l',
  steps: [_step1, _step2, _step3],
);

const _allFavors = FavorsData(favors: [
  _favorMidgardComplete,
  _favorMidgardInProgress,
  _favorSvartalfPending,
  _favorSvartalfPending2,
]);

/// Progress: fav-mid-complete has both steps done; fav-mid-progress has 1 done.
final _progressWithSomeComplete = Progress(
  completedFavorSteps: {
    'fav-mid-complete:s1',
    'fav-mid-complete:s2',
    'fav-mid-progress:s1',
  },
);

// ── tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _MockLoadFavors loadFavors;
  late _MockLoadProgress loadProgress;

  setUp(() {
    loadFavors = _MockLoadFavors();
    loadProgress = _MockLoadProgress();
  });

  FavorAlbumBloc build() => FavorAlbumBloc(
        loadFavors: loadFavors,
        loadProgress: loadProgress,
      );

  group('FavorAlbumStarted', () {
    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'loads favors and progress, transitions to loaded',
      setUp: () {
        when(() => loadFavors()).thenAnswer((_) async => _allFavors);
        when(() => loadProgress())
            .thenAnswer((_) async => _progressWithSomeComplete);
      },
      build: build,
      act: (bloc) => bloc.add(const FavorAlbumStarted()),
      expect: () => [
        isA<FavorAlbumState>()
            .having((s) => s.status, 'loading', FavorAlbumStatus.loading),
        isA<FavorAlbumState>()
            .having((s) => s.status, 'loaded', FavorAlbumStatus.loaded)
            .having((s) => s.favorsData, 'favorsData', isNotNull)
            .having((s) => s.favorsData!.favors.length, 'favorCount', 4)
            .having((s) => s.progress.completedFavorSteps.length,
                'stepsCompleted', 3),
      ],
    );
  });

  group('FavorAlbumProgressRefreshed', () {
    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'reloads only progress, data unchanged',
      setUp: () {
        when(() => loadFavors()).thenAnswer((_) async => _allFavors);
        when(() => loadProgress()).thenAnswer((_) async => const Progress());
      },
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: const Progress(),
      ),
      act: (bloc) {
        when(() => loadProgress())
            .thenAnswer((_) async => _progressWithSomeComplete);
        bloc.add(const FavorAlbumProgressRefreshed());
      },
      expect: () => [
        isA<FavorAlbumState>()
            .having((s) => s.progress.completedFavorSteps.length,
                'stepsCompleted', 3)
            .having((s) => s.favorsData, 'dataUnchanged', _allFavors),
      ],
    );
  });

  group('FavorAlbumStatusFilterChanged', () {
    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'filtering by complete yields ONLY fully completed favors',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumStatusFilterChanged(FavorStatus.complete)),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.map((f) => f.id).toList(),
          'filteredIds',
          ['fav-mid-complete'],
        ),
      ],
    );

    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'filtering by inProgress yields ONLY partially completed favors',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumStatusFilterChanged(FavorStatus.inProgress)),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.map((f) => f.id).toList(),
          'filteredIds',
          ['fav-mid-progress'],
        ),
      ],
    );

    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'filtering by pending yields pending favors (including 0-step)',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumStatusFilterChanged(FavorStatus.pending)),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.map((f) => f.id).toSet(),
          'filteredIds',
          {'fav-svart-pending', 'fav-svart-pending2'},
        ),
      ],
    );

    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'clearing status filter (null) returns all favors',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
        statusFilter: FavorStatus.complete,
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumStatusFilterChanged(null)),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.length,
          'allFavors',
          4,
        ),
      ],
    );
  });

  group('FavorAlbumRealmFilterChanged', () {
    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'filtering by midgard yields only midgard favors by name',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumRealmFilterChanged('midgard')),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.map((f) => f.name).toSet(),
          'midgardFavorNames',
          {'The Last Remnants of Asgard', 'In Plain Sight'},
        ),
      ],
    );

    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'filtering by svartalfheim yields only svartalfheim favors by id',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumRealmFilterChanged('svartalfheim')),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.map((f) => f.id).toSet(),
          'svartalfIds',
          {'fav-svart-pending', 'fav-svart-pending2'},
        ),
      ],
    );

    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'realm + status filters combine: midgard complete yields exactly one favor',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
        realmFilter: 'midgard',
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumStatusFilterChanged(FavorStatus.complete)),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.map((f) => f.id).toList(),
          'combinedFilter',
          ['fav-mid-complete'],
        ),
      ],
    );

    blocTest<FavorAlbumBloc, FavorAlbumState>(
      'clearing realm filter (null) returns all realms for current status',
      build: build,
      seed: () => FavorAlbumState(
        status: FavorAlbumStatus.loaded,
        favorsData: _allFavors,
        progress: _progressWithSomeComplete,
        realmFilter: 'midgard',
      ),
      act: (bloc) =>
          bloc.add(const FavorAlbumRealmFilterChanged(null)),
      expect: () => [
        isA<FavorAlbumState>().having(
          (s) => s.filteredFavors.length,
          'allRealms',
          4,
        ),
      ],
    );
  });

  group('favorStatus helper', () {
    test('0-step favor is pending', () {
      final status = favorStatus(_favorSvartalfPending, const Progress());
      expect(status, FavorStatus.pending);
    });

    test('favor with all steps done is complete', () {
      final status = favorStatus(
        _favorMidgardComplete,
        _progressWithSomeComplete,
      );
      expect(status, FavorStatus.complete);
    });

    test('favor with some steps done is inProgress', () {
      final status = favorStatus(
        _favorMidgardInProgress,
        _progressWithSomeComplete,
      );
      expect(status, FavorStatus.inProgress);
    });

    test('favor with no steps done is pending', () {
      final status = favorStatus(_favorSvartalfPending2, const Progress());
      expect(status, FavorStatus.pending);
    });
  });
}
