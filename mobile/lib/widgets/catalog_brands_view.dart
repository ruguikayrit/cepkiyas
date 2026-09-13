import 'package:flutter/material.dart';

import '../logic/catalog_grouping.dart';
import '../logic/format.dart';
import '../state/app_store.dart';
import '../theme.dart';
import 'widgets.dart';

/// Marka → seri → model ağacı; A–Z bölüm başlıkları.
class CatalogBrandsView extends StatelessWidget {
  const CatalogBrandsView({
    super.key,
    required this.store,
    required this.index,
    required this.focusBrand,
    required this.onFocusBrand,
    required this.query,
  });

  final AppStore store;
  final List<BrandGroup> index;
  final String? focusBrand;
  final ValueChanged<String?> onFocusBrand;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (focusBrand != null) {
      return _BrandSeriesPage(
        store: store,
        index: index,
        brand: focusBrand!,
        onBack: () => onFocusBrand(null),
      );
    }

    final filtered = filterBrandIndex(index, query);
    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aramanızla eşleşen marka veya model yok.', style: TextStyle(color: Ck.mute)),
        ),
      );
    }

    final sections = buildBrandSections(filtered);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              query.trim().isEmpty
                  ? '${filtered.length} marka · seri başlıkları altında modeller'
                  : '${filtered.length} eşleşen marka',
              style: const TextStyle(color: Ck.mute, fontSize: 13),
            ),
          ),
        ),
        for (final section in sections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                section.$1,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Ck.mint,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final group = section.$2[i];
                return _BrandRow(group: group, onTap: () => onFocusBrand(group.brand));
              },
              childCount: section.$2.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.group, required this.onTap});

  final BrandGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topSeries = group.series.take(2).map((s) => s.series).join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Ck.panel,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Ck.panel2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Ck.line),
                  ),
                  child: Text(
                    group.brand.length >= 2 ? group.brand.substring(0, 2).toUpperCase() : group.brand,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.brand, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        '${group.count} model · ${group.series.length} seri',
                        style: const TextStyle(color: Ck.mute, fontSize: 12),
                      ),
                      if (topSeries.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          topSeries,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Ck.mute, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Ck.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandSeriesPage extends StatelessWidget {
  const _BrandSeriesPage({
    required this.store,
    required this.index,
    required this.brand,
    required this.onBack,
  });

  final AppStore store;
  final List<BrandGroup> index;
  final String brand;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    BrandGroup? group;
    for (final item in index) {
      if (item.brand == brand) {
        group = item;
        break;
      }
    }
    if (group == null) {
      return Center(child: TextButton(onPressed: onBack, child: const Text('Markalar')));
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Tüm markalar'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(brand, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
                      Text(
                        '${group.count} model · ${group.series.length} seri grubu',
                        style: const TextStyle(color: Ck.mute),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        for (final series in group.series)
          SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          series.series,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                        ),
                      ),
                      Text('${series.count}', style: const TextStyle(color: Ck.mute, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final phone = series.models[i];
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
                                PhoneVisual(phone: phone, height: 52),
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
                  },
                  childCount: series.models.length,
                ),
              ),
            ],
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
