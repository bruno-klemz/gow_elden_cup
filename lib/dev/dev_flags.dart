/// Dev-only compile-time flags. Enable with e.g.
/// `flutter run --dart-define=MAP_EDITOR=true`.
///
/// Defaults to false so no dev surface ships in release builds.
const bool kMapEditor = bool.fromEnvironment('MAP_EDITOR');
