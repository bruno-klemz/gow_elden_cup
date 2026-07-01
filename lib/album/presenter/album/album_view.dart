import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../boss/presenter/boss_details/boss_details_screen.dart';
import '../../../theme/app_theme.dart';
import '../../domain/entity/boss.dart';
import 'bloc/album_bloc.dart';
import 'widgets/album_page_indicator.dart';
import 'widgets/blur_toggle_button.dart';
import 'widgets/realm_page.dart';
import 'widgets/sticker_reveal_overlay.dart';

/// Pure UI for the album. Reads [AlbumBloc] from context.
///
/// Each realm is a page; the user flips horizontally between them.
class AlbumView extends StatefulWidget {
  const AlbumView({super.key});

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  final _pageController = PageController();
  final _slotKeys = <String, GlobalKey>{};
  final _stackKey = GlobalKey();
  int _currentPage = 0;

  /// The boss currently playing the peel-and-stick reveal, and where its slot
  /// sits in the Stack's coordinate space. Both null when idle.
  Boss? _revealBoss;
  Rect? _revealRect;

  GlobalKey _slotKeyFor(String bossId) =>
      _slotKeys.putIfAbsent(bossId, () => GlobalKey());

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openBoss(BuildContext context, Boss boss) async {
    final state = context.read<AlbumBloc>().state;
    final realm = state.data?.realms
        .where((r) => r.id == boss.realm)
        .firstOrNull;
    final defeatedId = await BossDetailsScreen.push(
      context,
      boss,
      realmMapImage: realm?.mapImage,
    );
    if (!context.mounted) return;
    final bloc = context.read<AlbumBloc>();
    bloc.add(const AlbumProgressRefreshed());
    if (defeatedId != null) {
      bloc.add(AlbumRevealRequested(defeatedId));
    }
  }

  /// Flips to the realm of [bossId], scrolls its slot into view, then plays the
  /// peel-and-stick reveal overlay over it.
  Future<void> _goToRevealedSlot(AlbumState state, String bossId) async {
    final boss = state.data?.bossById(bossId);
    if (boss == null) return;
    await _animateToRealm(state, boss.realm);
    if (!mounted) return;
    await _ensureSlotVisible(bossId);
    if (!mounted) return;
    _startReveal(boss, bossId);
  }

  /// Resolves the slot's context fresh (after any page change) and scrolls to
  /// it. No await before the context use, so it's always current.
  Future<void> _ensureSlotVisible(String bossId) async {
    final ctx = _slotKeys[bossId]?.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      alignment: 0.3,
    );
  }

  /// Computes the slot's rect in the Stack's coordinate space and shows the
  /// reveal overlay. Clears the bloc's reveal flag when the animation finishes.
  void _startReveal(Boss boss, String bossId) {
    final slotCtx = _slotKeys[bossId]?.currentContext;
    final stackCtx = _stackKey.currentContext;
    if (slotCtx == null || stackCtx == null) return;

    final slotBox = slotCtx.findRenderObject() as RenderBox?;
    final stackBox = stackCtx.findRenderObject() as RenderBox?;
    if (slotBox == null || stackBox == null) return;

    final topLeft = slotBox.localToGlobal(Offset.zero, ancestor: stackBox);
    setState(() {
      _revealBoss = boss;
      _revealRect = topLeft & slotBox.size;
    });
  }

  void _endReveal() {
    if (!mounted) return;
    setState(() {
      _revealBoss = null;
      _revealRect = null;
    });
    context.read<AlbumBloc>().add(const AlbumRevealConsumed());
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
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _goToRevealedSlot(state, id),
            );
          }
        },
        builder: (context, state) {
          if (!state.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.frost),
            );
          }
          final realms = state.realms;
          return Stack(
            key: _stackKey,
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
                    // While the overlay is playing, the slot keeps its pending
                    // (blurred) look — the sticker only "sticks" at the end.
                    revealingBossId: state.justRevealedBossId,
                    slotKeyFor: _slotKeyFor,
                    bottomInset: AlbumPageIndicator.reservedHeight,
                    onBossTap: (boss) => _openBoss(context, boss),
                    onQuickDefeat: (boss) => context.read<AlbumBloc>().add(
                      AlbumBossQuickDefeated(boss.id),
                    ),
                  );
                },
              ),
              if (realms.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AlbumPageIndicator(
                    count: realms.length,
                    currentIndex: _currentPage,
                  ),
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
              if (_revealBoss != null && _revealRect != null)
                Positioned.fill(
                  child: StickerRevealOverlay(
                    // key by boss id so a new reveal restarts the controller
                    key: ValueKey(_revealBoss!.id),
                    boss: _revealBoss!,
                    slotRect: _revealRect!,
                    onDone: _endReveal,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
