import 'package:get_it/get_it.dart';
import 'album/data/repository/boss_repository_impl.dart';
import 'album/domain/repository/boss_repository.dart';
import 'album/domain/usecase/load_album_usecase.dart';
import 'boss/data/repository/progress_repository_impl.dart';
import 'boss/domain/repository/progress_repository.dart';
import 'boss/domain/usecase/load_progress_usecase.dart';
import 'boss/domain/usecase/set_map_revealed_usecase.dart';
import 'boss/domain/usecase/toggle_defeated_usecase.dart';
import 'favors/data/repository/favors_repository_impl.dart';
import 'favors/domain/repository/favors_repository.dart';
import 'favors/domain/usecase/load_favors_usecase.dart';
import 'favors/domain/usecase/toggle_favor_step_usecase.dart';
import 'settings/data/repository/settings_repository_impl.dart';
import 'settings/domain/repository/settings_repository.dart';
import 'settings/domain/usecase/load_settings_usecase.dart';
import 'settings/domain/usecase/set_blur_pending_usecase.dart';

final locator = GetIt.instance;

/// Registers repositories and use cases. BLoCs are never registered here —
/// they are created at the composition root (the *Screen widgets).
void setupLocator() {
  // Repositories (singletons — stateless data access)
  locator.registerLazySingleton<BossRepository>(() => BossRepositoryImpl());
  locator.registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl());
  locator.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl());

  // Use cases (factories)
  locator.registerFactory<LoadAlbumUsecase>(
      () => LoadAlbumUsecaseImpl(repository: locator<BossRepository>()));
  locator.registerFactory<LoadProgressUsecase>(
      () => LoadProgressUsecaseImpl(repository: locator<ProgressRepository>()));
  locator.registerFactory<ToggleDefeatedUsecase>(() =>
      ToggleDefeatedUsecaseImpl(repository: locator<ProgressRepository>()));
  locator.registerFactory<SetMapRevealedUsecase>(() =>
      SetMapRevealedUsecaseImpl(repository: locator<ProgressRepository>()));
  locator.registerFactory<LoadSettingsUsecase>(
      () => LoadSettingsUsecaseImpl(repository: locator<SettingsRepository>()));
  locator.registerFactory<SetBlurPendingUsecase>(() =>
      SetBlurPendingUsecaseImpl(repository: locator<SettingsRepository>()));

  // Favors
  locator.registerLazySingleton<FavorsRepository>(() => FavorsRepositoryImpl());
  locator.registerFactory<LoadFavorsUsecase>(
      () => LoadFavorsUsecaseImpl(repository: locator<FavorsRepository>()));
  locator.registerFactory<ToggleFavorStepUsecase>(() =>
      ToggleFavorStepUsecaseImpl(repository: locator<ProgressRepository>()));
}
