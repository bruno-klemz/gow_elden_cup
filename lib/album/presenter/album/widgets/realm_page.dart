import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/realm_theme.dart';
import '../../../domain/entity/boss.dart';
import '../../../domain/entity/realm.dart';
import 'sticker_slot.dart';

/// A single self-contained album page for one realm: a collapsing header
/// (realm name + progress) over scrollable sections — headline ("main") bosses
/// in a larger 2-column grid up top, then the remaining bosses in a 3-column
/// grid, each under its own divider.
class RealmPage extends StatelessWidget {
  const RealmPage({
    super.key,
    required this.realm,
    required this.mainBosses,
    required this.otherBosses,
    required this.defeatedCount,
    required this.totalCount,
    required this.isDefeated,
    required this.onBossTap,
    required this.onQuickDefeat,
    this.revealingBossId,
    this.slotKeyFor,
    this.bottomInset = 0,
  });

  final Realm realm;
  final List<Boss> mainBosses;
  final List<Boss> otherBosses;
  final int defeatedCount;
  final int totalCount;
  final bool Function(String bossId) isDefeated;
  final void Function(Boss) onBossTap;
  final void Function(Boss) onQuickDefeat;

  /// Boss whose slot is currently mid-reveal. That slot keeps its pending look
  /// (the full-screen overlay owns the animation and "sticks" it at the end).
  final String? revealingBossId;
  final GlobalKey Function(String bossId)? slotKeyFor;

  /// Extra bottom padding so the last row clears the floating page indicator.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final pct = totalCount == 0 ? 0.0 : defeatedCount / totalCount;
    final hasMain = mainBosses.isNotEmpty;
    // This page's characteristic colour, from the realm's identity.
    final accent = RealmTheme.of(realm.id).accent;
    return CustomScrollView(
      slivers: [
        _header(context, pct, accent),
        if (hasMain) ...[
          _sectionLabel(
            '★ Chefes principais',
            highlighted: true,
            accent: accent,
          ),
          _grid(mainBosses, crossAxisCount: 2, accent: accent),
        ],
        _sectionLabel(
          hasMain ? 'Demais chefes' : 'Chefes',
          highlighted: false,
          accent: accent,
        ),
        _grid(
          otherBosses,
          crossAxisCount: 3,
          accent: accent,
          bottomInset: 16 + bottomInset,
        ),
      ],
    );
  }

  Widget _header(BuildContext context, double pct, Color accent) =>
      SliverAppBar(
        expandedHeight: 132,
        pinned: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            final top = constraints.biggest.height;
            final collapsed =
                top <= kToolbarHeight + MediaQuery.of(context).padding.top + 8;
            return FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 14,
              ),
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: collapsed ? 1 : 0,
                child: Text(
                  '${realm.name}  ·  $defeatedCount/$totalCount',
                  style: AppText.regionLabel,
                ),
              ),
              background: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 18,
                  16,
                  14,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      realm.name,
                      style: TextStyle(
                        color: accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$defeatedCount de $totalCount derrotados',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 11),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _sectionLabel(
    String text, {
    required bool highlighted,
    required Color accent,
  }) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: highlighted ? accent : const Color(0xFF6B5D44),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    highlighted ? accent : AppColors.border,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _grid(
    List<Boss> bosses, {
    required int crossAxisCount,
    required Color accent,
    double bottomInset = 0,
  }) => SliverPadding(
    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 4,
      ),
      delegate: SliverChildBuilderDelegate((context, i) {
        final boss = bosses[i];
        return StickerSlot(
          key: slotKeyFor?.call(boss.id),
          boss: boss,
          defeated: isDefeated(boss.id),
          accent: accent,
          isMain: boss.isMainBoss,
          revealing: boss.id == revealingBossId,
          onTap: () => onBossTap(boss),
          onQuickDefeat: () => onQuickDefeat(boss),
        );
      }, childCount: bosses.length),
    ),
  );
}
