import 'package:flutter/material.dart';

import 'navigation/app_tab.dart';
import 'screens/account_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'state/app_store.dart';
import 'theme.dart';
import 'typography.dart';
import 'widgets/brand_lockup.dart';
import 'widgets/brand_tagline.dart';
import 'widgets/widgets.dart';

class Shell extends StatefulWidget {
  const Shell({super.key, required this.store});
  final AppStore store;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late final List<Widget> _tabs;

  AppStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    store.addListener(_onStore);
    _tabs = [
      HomeScreen(store: store),
      CatalogScreen(store: store),
      CompareScreen(store: store),
      FavoritesScreen(store: store),
      AccountScreen(store: store),
    ];
  }

  @override
  void dispose() {
    store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final tab = store.tab.clamp(0, AppTab.count - 1);

    return Scaffold(
      backgroundColor: Ck.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 88,
        title: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLockup(height: 28),
                  const SizedBox(height: 4),
                  BrandTagline(
                    align: TextAlign.center,
                    color: Ck.mute.withValues(alpha: 0.9),
                    compact: true,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/ara'),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ColoredBox(
        color: Ck.bg,
        child: _tabs[tab],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (store.compareIds.isNotEmpty && tab != AppTab.compare) _CompareBar(store: store),
          Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Ck.navBg,
                indicatorColor: Ck.navIndicator,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  return IconThemeData(
                    color: states.contains(WidgetState.selected) ? Ck.navActive : Ck.navMute,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  return CkType.navLabel(selected: states.contains(WidgetState.selected));
                }),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Ck.navBg,
              indicatorColor: Ck.navIndicator,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: tab,
              onDestinationSelected: store.goTab,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Anasayfa',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.category_outlined),
                  selectedIcon: Icon(Icons.category_rounded),
                  label: 'Kategori',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: store.compareIds.isNotEmpty,
                    label: Text('${store.compareIds.length}'),
                    child: const Icon(Icons.compare_arrows_outlined),
                  ),
                  selectedIcon: const Icon(Icons.compare_arrows_rounded),
                  label: 'Kıyas',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: store.favoriteIds.isNotEmpty,
                    label: Text('${store.favoriteIds.length}'),
                    child: const Icon(Icons.favorite_border_rounded),
                  ),
                  selectedIcon: const Icon(Icons.favorite_rounded),
                  label: 'Favoriler',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Hesabım',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareBar extends StatelessWidget {
  const _CompareBar({required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Ck.bg2,
        border: Border(top: BorderSide(color: Ck.line)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final phone in store.compared)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        children: [
                          PhoneVisual(phone: phone, height: 36),
                          const SizedBox(width: 6),
                          Text(phone.name, style: const TextStyle(fontSize: 12)),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => store.toggleCompare(phone.id),
                            icon: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          TextButton(onPressed: store.clearCompare, child: const Text('Temizle')),
          FilledButton(
            onPressed: store.compareIds.length < 2 ? null : () => store.goTab(AppTab.compare),
            child: Text(store.compareIds.length < 2 ? 'Kıyasla' : 'Kıyasla (${store.compareIds.length})'),
          ),
        ],
      ),
    );
  }
}
