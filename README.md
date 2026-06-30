# gow_elden_cup

A Flutter sticker-album app, built as a sibling of [`elden_world_cup`](https://github.com/bruno-klemz/elden_world_cup)
(the Elden Ring boss album). Same essence — an **offline, single-codebase
album** that ships as both a mobile app and a web site on GitHub Pages — but for
a **different game**, so the dataset and assets are this project's own.

This README is the replication guide: it captures everything a sibling project
needs to reproduce the same logic. The game-specific data model is intentionally
left generic — fill it in with the new game's entities.

---

## What this app is

- An **offline** album: all content (entries + images) ships inside the app, no
  backend, no network. State (what the user has "collected"/completed) lives in
  `shared_preferences`.
- One **Flutter codebase** → **mobile** (Android/iOS) **and web** (GitHub Pages).
- On web, the UI is constrained to a **phone-width frame** so it keeps its mobile
  proportions instead of stretching across the browser.

## Tech stack

Mirror these in `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^9.0.0      # state management
  get_it: ^8.0.0            # service locator / DI
  equatable: ^2.0.5         # value equality for entities
  shared_preferences: ^2.3.0 # persisted user progress

dev_dependencies:
  flutter_lints: ^6.0.0
  bloc_test: ^10.0.0
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  assets:
    - assets/<data>.json      # the dataset (see Data model)
    - assets/images/          # art + any sub-folders
```

`publish_to: 'none'` — this is an app, not a pub package.

---

## Architecture — feature-based Clean Architecture

Adapted from the team's production app (`jus-pra-voce-app`), scaled down for a
small, single-module, offline app. Each feature is
`lib/<feature>/{data,domain,presenter}`:

- **`domain/`** — pure Dart, no Flutter deps.
  - `entity/` — immutable entities, using `Equatable`.
  - `repository/` — repository **interfaces** (contracts only).
  - `usecase/` — one class per operation (`abstract XUsecase` + `XUsecaseImpl`),
    depends on repository interfaces.
- **`data/`** — `repository/` holds the concrete `*Impl`. This is the **only**
  place that imports an external dep (`shared_preferences`, `rootBundle`, …).
- **`presenter/<screen>/`**:
  - `bloc/` — `*_bloc.dart` + `part` event/state files.
  - `*_screen.dart` — the **wire**: `BlocProvider` + `locator` lookups (the
    composition root for that screen).
  - `*_view.dart` — pure UI consuming the bloc via `BlocBuilder`/`BlocConsumer`.
  - `widgets/` — leaf widgets.

### Composition root (`lib/service_locator.dart`)

`get_it` registers **repositories as lazy singletons** and **use cases as
factories**. **BLoCs are never registered** — they are created in the `*_screen`
wire, with use cases injected via the constructor.

```dart
final locator = GetIt.instance;

void setupLocator() {
  // Repositories — singletons (stateless data access)
  locator.registerLazySingleton<AlbumRepository>(() => AlbumRepositoryImpl());
  locator.registerLazySingleton<ProgressRepository>(() => ProgressRepositoryImpl());

  // Use cases — factories
  locator.registerFactory<LoadAlbumUsecase>(
      () => LoadAlbumUsecaseImpl(repository: locator<AlbumRepository>()));
  // …
}
```

`main()` calls `setupLocator()` before `runApp`. A top-level `SettingsBloc` (or
similar global state) is provided **above `MaterialApp`** so it sits above the
Navigator and is shared across all routes.

### Rules of thumb (full fidelity to the team's pattern)

- `flutter_bloc` for state; business logic in BLoCs with constructor-injected use cases.
- Repository **interface in `domain/`** + impl in `data/` (dependency inversion).
- One use case per operation.
- **Adapter rule:** external deps live only in their repository impl.

### Deliberately skipped (monorepo overhead)

- Melos / workspace packages.
- GraphQL — this app is fully offline.

---

## Coding standards

- **File-level constants use a `k` prefix**: `const kSlotAspectRatio = 3 / 4;`.
- **File name matches the primary class** (snake_case file, PascalCase class).
- **~200-line file limit.** Split widgets into their own files under `widgets/`.
  Avoid private `_Widget` classes embedded in another file — give them a file.
- **A widget either takes all data via props OR reads state via a BLoC** — never
  mix. Leaf widgets are prop-driven; `*_view.dart` reads the bloc.
- **No nested ternaries** — extract to a variable or `if`/`else`.
- **Cache repeated getters** as locals at the top of `build()`.
- **Check `mounted`** before `setState` from async callbacks.
- **Asset paths via constants**, not scattered string literals.
- **`spacing:` on `Column`/`Row`** instead of `SizedBox` separators where practical.

## Theming

A static `AppColors` + `AppText` in `lib/theme/app_theme.dart` (no
`ThemeExtension` needed at this scale). Use **semantic color names** so a palette
swap is global. Treat typography as a contract: define styles once in `AppText`;
at call sites only `.copyWith(color:)` / `fontWeight` — never redefine
fontSize/height. As the UI grows, add `AppSpacing`/`AppRadius` constant classes
so spacing/radius are tokens, not magic numbers.

---

## Data model (game-specific — adapt this)

> This is the part that differs from `elden_world_cup`. The structure below is
> the **shape**; replace the fields with the new game's entities.

- The whole dataset is a single JSON file in `assets/` (e.g. `assets/entries.json`),
  loaded once via `rootBundle` inside the data-layer repository impl.
- Each entry maps to an immutable `Equatable` entity with a `fromJson` factory.
- Reference images by a **relative path string** stored in the entity (e.g.
  `"art": "images/foo.png"`), resolved against `assets/`.

Example entity shape (rename/replace fields for the new game):

```jsonc
{
  "id": "unique_slug",
  "name": "Display Name",
  "category": "some_grouping_id",   // e.g. region / world / chapter
  "art": "images/unique_slug.png",
  "attributes": { /* game-specific stats */ },
  "lore": "Flavor text."
}
```

**Asset discipline (non-negotiable):** every `Image.asset` MUST have an
`errorBuilder` fallback so a missing asset renders a placeholder instead of
crashing. Track missing assets as gaps to fill — never block on them.

---

## Web frame (`MobileFrame`)

On web, wrap the app in a centered phone-width column; on native, return the
child untouched. Inject the `isWeb` flag so both paths are testable.

```dart
class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child, this.isWeb = kIsWeb});
  final Widget child;
  final bool isWeb;
  static const double maxWidth = 430; // iPhone Pro Max class

  @override
  Widget build(BuildContext context) {
    if (!isWeb) return child;
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
```

Hook it in via `MaterialApp.builder`:

```dart
builder: (context, child) => MobileFrame(child: child!),
```

---

## Web deploy (GitHub Pages via GitHub Actions)

Push to `master` → GitHub Actions builds the web bundle and publishes to Pages
(~2 min). Site URL: `https://bruno-klemz.github.io/gow_elden_cup/`.

**One-time setup:** Repo → Settings → Pages → **Source: GitHub Actions**.

Add `.github/workflows/deploy-web.yml`. This project lives at the **repo root**
(the Flutter project was created directly in the repo), so there is **no
`working-directory`** — unlike `elden_world_cup`, where the project sits in a
subfolder. The two things that MUST match this repo:

1. `flutter-version` matches the local SDK (currently **3.38.3**).
2. `--base-href /gow_elden_cup/` matches the repo name (it's a project page,
   served under a sub-path).

```yaml
name: Deploy web to GitHub Pages

on:
  push:
    branches: [master]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: 3.38.3
      - run: flutter pub get
      - run: flutter build web --release --base-href /gow_elden_cup/
      - uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

---

## Testing

- **Tests mirror source structure**: `test/<path>/<name>_test.dart`.
- **Arrange / Act / Assert.**
- **Widget tests**: pump, find via `find.*`, assert. For long scrollable sheets,
  enlarge `tester.view.physicalSize` and reset it in `addTearDown`.
- BLoC tests with `bloc_test`; mock use cases / repositories with `mocktail`.
- **Golden tests** (`alchemist`) are worth adding once the visuals stabilize —
  this is a UI-heavy app.

---

## Running locally

```bash
flutter pub get
flutter run -d chrome   # web
flutter run             # mobile (device/emulator)
flutter analyze
flutter test
```

---

## Status — v1 implemented end-to-end

- **25 tests passing** (`flutter test`), **`flutter analyze` clean** (no issues).
- **Web build:** `flutter build web --release --base-href /gow_elden_cup/` succeeds.
- **APK build:** `flutter build apk --debug` succeeds.
- All 15 plan tasks complete.

### What is implemented

- **Offline album** with two content tabs (**Chefes** and **Favores**) plus a **Busca** (search) tab across both datasets — no network, no backend.
- **65 bosses** grouped across 9 realms (Nine Realms + Realm Between + beyond), each with:
  - Type badge (standard / mini-boss / story / optional).
  - Combat tab: weaknesses, immunities, strategy.
  - Per-realm map (placeholder image; real map coords to be set via the dev coord picker).
  - Loot and lore sections.
- **47 favors** (side quests) with a book/diary detail screen featuring:
  - Per-step checkboxes — progress persisted via `shared_preferences`.
  - Realm and status filters (all / in-progress / completed).
- **Progress persistence:** album completion state (boss collected + favor steps) survives app restarts via `shared_preferences`.
- **Web phone-frame (`MobileFrame`):** on web the UI is constrained to a 430 px phone-width column so the layout keeps its mobile proportions in the browser.
- **GitHub Pages deploy** via the `.github/workflows/deploy-web.yml` workflow (push to `master` → ~2 min build → live at the site URL below).

### Placeholders in use

- **Boss art:** every boss renders `assets/images/placeholder.webp`. Drop the real portrait in `assets/images/` and update `art` in `assets/gow_bosses.json`. Every `Image.asset` has an `errorBuilder` fallback — a missing file never crashes the app.
- **Per-realm maps:** all nine realms share a single `assets/images/placeholder.webp`. Replace per realm by adding the image and updating `Realm.mapImage`.
- **Map coordinates:** every boss has `"mapCoord": {"x": 0, "y": 0}`. Set real values using the dev coord picker (`lib/dev/coord_picker_screen.dart` — swap it in as `home` in `main.dart` temporarily, tap the map, copy the printed snippet).
- **Loot icons:** no per-item icons provided; loot renders text only.

### Content to review (`needsReview: true`)

9 bosses and 3 favors are flagged `needsReview: true` in the JSON datasets. Their lore,
loot names, and weaknesses/immunities were paraphrased from PowerPyx/Game8 guides and
should be verified for accuracy before publishing. Real map coordinates also need to be
set for all entries via the dev coord picker.

### Site URL

`https://bruno-klemz.github.io/gow_elden_cup/`

**One-time manual setup required:** Repo → Settings → Pages → Source: **GitHub Actions**.
After that, every push to `master` (or a manual `workflow_dispatch`) triggers the deploy.
