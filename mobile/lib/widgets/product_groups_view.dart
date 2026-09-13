import 'package:flutter/material.dart';

import '../logic/catalog_grouping.dart';
import '../logic/catalog_taxonomy.dart';
import '../logic/format.dart';
import '../models/phone.dart';
import '../state/app_store.dart';
import '../theme.dart';
import 'widgets.dart';

/// Ürün grubu → marka (alt başlık) → seri (alt başlık) → modeller.
class ProductGroupsView extends StatelessWidget {
  const ProductGroupsView({
    super.key,
    required this.store,
    required this.categories,
    required this.onlyCategoryId,
    required this.query,
  });

  final AppStore store;
  final List<CatalogCategory> categories;
  final String? onlyCategoryId;
  final String query;

  @override
  Widget build(BuildContext context) {
    final visible = onlyCategoryId == null
        ? categories
        : categories.where((c) => c.id == onlyCategoryId).toList();

    return CustomScrollView(
      slivers: [
        for (final category in visible) ..._groupSlivers(context, category),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  List<Widget> _groupSlivers(BuildContext context, CatalogCategory category) {
    final active = category.status == CatalogCategoryStatus.active;
    return [
      SliverToBoxAdapter(child: _ProductGroupHeader(category: category)),
      if (!active)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Text(
              '${category.description}\nBu gruptaki marka ve modeller yakında eklenecek.',
              style: const TextStyle(color: Ck.mute, height: 1.45, fontSize: 13),
            ),
          ),
        )
      else ..._phoneGroupContent(context),
    ];
  }

  List<Widget> _phoneGroupContent(BuildContext context) {
    final index = filterBrandIndex(buildBrandIndex(store.phones), query);
    if (index.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Text('Aramanızla eşleşen marka veya model yok.', style: TextStyle(color: Ck.mute)),
          ),
        ),
      ];
    }

    final out = <Widget>[];
    for (final brand in index) {
      out.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    brand.brand,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4),
                  ),
                ),
                Text(
                  '${brand.count} model',
                  style: const TextStyle(color: Ck.mute, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );

      for (final series in brand.series) {
        out.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                series.series,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Ck.mute,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        );
        out.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ModelRow(store: store, phone: series.models[i]),
              childCount: series.models.length,
            ),
          ),
        );
      }
    }
    return out;
  }
}

class _ProductGroupHeader extends StatelessWidget {
  const _ProductGroupHeader({required this.category});

  final CatalogCategory category;

  @override
  Widget build(BuildContext context) {
    final active = category.status == CatalogCategoryStatus.active;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? Ck.mintDim : Ck.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? Ck.mint.withValues(alpha: 0.5) : Ck.line),
            ),
            child: Icon(category.icon, color: active ? Ck.mint : Ck.mute, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.6),
                ),
                const SizedBox(height: 2),
                Text(
                  active && category.count != null
                      ? '${category.count} model · ${category.description}'
                      : 'Yakında · ${category.description}',
                  style: const TextStyle(color: Ck.mute, fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({required this.store, required this.phone});

  final AppStore store;
  final Phone phone;

  @override
  Widget build(BuildContext context) {
    final technical = store.scores.technical(phone);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Ck.panel,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).pushNamed('/telefon', arguments: phone.id),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                PhoneVisual(phone: phone, height: 48),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phone.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${phone.year} · ${formatPrice(phone.priceTRY)}',
                        style: const TextStyle(color: Ck.mute, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ScorePill(value: technical, label: 'Teknik'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
