import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'navigation/app_tab.dart';
import 'screens/account_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'state/app_store.dart';
import 'theme.dart';
import 'widgets/widgets.dart';

class CepKiyasApp extends StatelessWidget {
  const CepKiyasApp({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeknoKıyas',
      debugShowCheckedModeBanner: false,
      theme: Ck.theme(),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ListenableBuilder(
        listenable: store,
        builder: (_, _) => Shell(store: store),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/telefon') {
          return MaterialPageRoute(
            builder: (_) => DetailScreen(store: store, phoneId: settings.arguments as String),
          );
        }
        if (settings.name == '/ara') {
          return MaterialPageRoute(builder: (_) => SearchScreen(store: store));
        }
        return null;
      },
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(store: store),
      CatalogScreen(store: store),
      CompareScreen(store: store),
      FavoritesScreen(store: store),
      AccountScreen(store: store),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            _Logo(),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TeknoKıyas'),
                Text('Teknoloji kıyası', style: TextStyle(color: Ck.mute, fontSize: 11, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/ara'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: IndexedStack(index: store.tab.clamp(0, AppTab.count - 1), children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (store.compareIds.isNotEmpty && store.tab != AppTab.compare) _CompareBar(store: store),
          NavigationBar(
            backgroundColor: Ck.bg2,
            indicatorColor: Ck.mintDim,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 68,
            selectedIndex: store.tab.clamp(0, AppTab.count - 1),
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
                label: 'Ürünler',
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
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Ck.mint, borderRadius: BorderRadius.circular(8)),
      child: const Text('TK', style: TextStyle(color: Color(0xFF08110C), fontWeight: FontWeight.w800, fontSize: 11)),
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
