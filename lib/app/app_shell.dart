import 'package:flutter/material.dart';
import '../album/presenter/album/album_screen.dart';
import '../album/presenter/search/search_screen.dart';
import '../favors/presenter/favor_album/favor_album_screen.dart';
import '../theme/app_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  static const _screens = [AlbumScreen(), FavorAlbumScreen(), SearchScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      // Native NavigationBar with a frost-blue indicator rail drawn ON THE BAR
      // ITSELF (top edge), sliding to sit above the active tab's column — the
      // marker belongs to the bar, not to the selected icon/label.
      bottomNavigationBar: Stack(
        children: [
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: AppColors.surface,
            // No filled pill behind the selected icon; the active tab is marked
            // by the rail on the bar's top edge instead.
            indicatorColor: Colors.transparent,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontFamily: AppText.displayFamily,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .8,
                color: selected ? AppColors.strong : AppColors.textMuted,
              );
            }),
            destinations: const [
              NavigationDestination(icon: _OmegaIcon(), label: 'Chefes'),
              NavigationDestination(icon: _FavorsIcon(), label: 'Favores'),
              NavigationDestination(
                icon: Icon(Icons.search, color: AppColors.textBody),
                label: 'Busca',
              ),
            ],
          ),
          // The rail: 1/3-width frost line pinned to the bar's top edge,
          // sliding to the active column. AnimatedAlign moves it across the
          // -1..1 horizontal axis (one step per tab) so it glides on change.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment(
                -1 + _index * (2 / (_screens.length - 1)),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / _screens.length,
                child: Container(height: 3, color: AppColors.strong),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The God of War Ragnarök Omega logo as the "Chefes" nav icon. Rendered in
/// full colour (it's a coloured emblem); falls back to a shield glyph if the
/// asset fails to load (e.g. in widget tests).
class _OmegaIcon extends StatelessWidget {
  const _OmegaIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/omega.png',
      width: 28,
      height: 28,
      errorBuilder: (context, error, stack) => const Icon(Icons.shield),
    );
  }
}

/// The realm-rune emblem as the "Favores" nav icon. Rendered in full colour
/// (not tinted) since it's a coloured emblem; falls back to a book glyph if the
/// asset fails to load (e.g. in widget tests).
class _FavorsIcon extends StatelessWidget {
  const _FavorsIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ui/favors_rune.png',
      width: 28,
      height: 28,
      errorBuilder: (context, error, stack) => const Icon(Icons.menu_book),
    );
  }
}
