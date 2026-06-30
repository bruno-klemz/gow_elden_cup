import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import 'bloc/album_bloc.dart';
import 'widgets/album_page_indicator.dart';
import 'widgets/blur_toggle_button.dart';
import 'widgets/realm_page.dart';

/// Pure UI for the album. Reads [AlbumBloc] from context.
///
/// Each realm is a page; the user flips horizontally between them.
///
/// NOTE(Task 7): Boss details navigation is a no-op tap until BossDetailsScreen
/// is implemented. When Task 7 lands, wire _openBoss to
/// BossDetailsScreen.push(context, boss) and add AlbumProgressRefreshed /
/// AlbumRevealRequested on return, matching the reference app's _openBoss.
class AlbumView extends StatefulWidget {
  const AlbumView({super.key});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  final _pageController = PageController();
  final _slotKeys = <String, GlobalKey>{};
  int _currentPage = 0;

  GlobalKey _slotKeyFor(String bossId) =>
      _slotKeys.putIfAbsent(bossId, () => GlobalKey());

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // TODO(Task 7): Replace with real BossDetailsScreen.push navigation.
  // On return, call AlbumProgressRefreshed and (if a boss was defeated)
  // AlbumRevealRequested. See reference album_view.dart _openBoss.
  void _openBoss(BuildContext context, boss) {
    // No-op until BossDetailsScreen exists (Task 7).
  }

  /// Flips to the realm of [bossId], then scrolls its slot into view so the
  /// reveal animation is always seen.
  Future<void> _goToRevealedSlot(AlbumState state, String bossId) async {
    final realmId = state.data?.bossById(bossId).realm;
    if (realmId == null) return;
    await _animateToRealm(state, realmId);
    if (mounted) _ensureSlotVisible(bossId);
  }

  /// Resolves the slot's context fresh (after any page change) and scrolls to
  /// it. No await before the context use, so it's always current.
  void _ensureSlotVisible(String bossId) {
    final ctx = _slotKeys[bossId]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      alignment: 0.3,
    );
  }

  Future<void> _animateToRealm(AlbumState state, String realmId) async {
    final pageIndex = state.realms.indexWhere((r) => r.id == realmId);
    if (pageIndex >= 0 && _pageController.hasClients) {
      await _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AlbumBloc, AlbumState>(
        listenWhen: (prev, curr) =>
            curr.justRevealedBossId != null &&
            curr.justRevealedBossId != prev.justRevealedBossId,
        listener: (context, state) {
          final id = state.justRevealedBossId;
          if (id != null) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _goToRevealedSlot(state, id));
          }
        },
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.gold));
          }
          final realms = state.realms;
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: realms.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final realm = realms[i];
                  return RealmPage(
                    realm: realm,
                    mainBosses: state.mainBossesIn(realm.id),
                    otherBosses: state.otherBossesIn(realm.id),
                    defeatedCount: state.defeatedIn(realm.id),
                    totalCount: state.countIn(realm.id),
                    isDefeated: state.isDefeated,
                    revealBossId: state.justRevealedBossId,
                    slotKeyFor: _slotKeyFor,
                    bottomInset: AlbumPageIndicator.reservedHeight,
                    onRevealDone: () =>
                        context.read<AlbumBloc>().add(const AlbumRevealConsumed()),
                    onBossTap: (boss) => _openBoss(context, boss),
                    onQuickDefeat: (boss) => context
                        .read<AlbumBloc>()
                        .add(AlbumBossQuickDefeated(boss.id)),
                  );
                },
              ),
              if (realms.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AlbumPageIndicator(
                      count: realms.length, currentIndex: _currentPage),
                ),
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: const BlurToggleButton(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
