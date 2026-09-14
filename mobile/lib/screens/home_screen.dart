import 'package:flutter/material.dart';

import '../navigation/app_tab.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

const duels = [
  ['iphone-16-pro-max', 'galaxy-s25-ultra'],
  ['pixel-9-pro-xl', 'xiaomi-15-ultra'],
  ['oneplus-13', 'vivo-x200-pro'],
  ['poco-f7-ultra', 'redmi-note-14-pro-plus'],
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final featured = store.phones.where((phone) => phone.image.isNotEmpty).toList()
      ..sort((a, b) => store.scores.technical(b).compareTo(store.scores.technical(a)));
    final top = featured.take(4).toList();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SectionTitle('Teknik skoru en yüksekler')),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 248,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: top.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => PhoneCard(store: store, phone: top[i]),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SectionTitle('Hazır düellolar')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: duels.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final left = store.byId(duels[i][0]);
              final right = store.byId(duels[i][1]);
              if (left == null || right == null) return const SizedBox.shrink();
              return Material(
                color: Ck.panel,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await store.replaceCompare([left.id, right.id]);
                    store.goTab(AppTab.compare);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(child: _DuelSide(brand: left.brand, name: left.name)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('vs', style: TextStyle(color: Ck.mute, fontWeight: FontWeight.w700)),
                        ),
                        Expanded(child: _DuelSide(brand: right.brand, name: right.name, alignEnd: true)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final brand in store.brands)
                  ActionChip(
                    label: Text(brand),
                    backgroundColor: Ck.panel,
                    side: const BorderSide(color: Ck.line),
                    onPressed: () {
                      store.setFilters(store.filters.copy()..brands = [brand]);
                      store.goTab(AppTab.products);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DuelSide extends StatelessWidget {
  const _DuelSide({required this.brand, required this.name, this.alignEnd = false});
  final String brand;
  final String name;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(brand, style: const TextStyle(color: Ck.mute, fontSize: 12)),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
