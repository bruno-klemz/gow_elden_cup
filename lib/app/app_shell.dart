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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        // No pill/chip highlight behind the selected icon.
        indicatorColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        destinations: const [
          NavigationDestination(
            icon: _OmegaIcon(),
            label: 'Chefes',
          ),
          NavigationDestination(
            icon: _FavorsIcon(),
            label: 'Favores',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Busca',
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
