import 'package:flutter/material.dart';

import '../logic/catalog_grouping.dart';
import '../logic/catalog_taxonomy.dart';
import '../logic/format.dart';
import '../models/phone.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final TextEditingController _search;
  String _categoryId = 'telefon';
  String? _brand;

  AppStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickDefaultBrand());
  }

  void _pickDefaultBrand() {
    if (_brand != null || store.brandIndex.isEmpty) return;
    final q = _search.text.trim().toLowerCase();
    final brands = filterBrandIndex(store.brandIndex, q);
    if (brands.isNotEmpty) {
      setState(() => _brand = brands.first.brand);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Ck.bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _categoryLabel(),
                prefixIcon: const Icon(Icons.search_rounded, color: Ck.mute),
                suffixIcon: IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/ara'),
                  icon: const Icon(Icons.tune_rounded, color: Ck.mute, size: 20),
                ),
              ),
            ),
          ),
          Expanded(child: _splitBody()),
        ],
      ),
    );
  }

  String _categoryLabel() {
    return catalogCategoryById(_categoryId).label;
  }

  Widget _splitBody() {
    final category = catalogCategoryById(_categoryId);
    if (category.status != CatalogCategoryStatus.active) {
      return Row(
        children: [
          _CategoryRail(
            categoryId: _categoryId,
            brand: _brand,
            brands: const [],
            onCategory: (id) => setState(() {
              _categoryId = id;
              _brand = null;
            }),
            onBrand: (_) {},
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${category.label} yakında.\n${category.description}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Ck.mute, height: 1.45),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (store.brandIndex.isEmpty) {
      return const Center(child: Text('Katalog yükleniyor…', style: TextStyle(color: Ck.mute)));
    }

    final brands = filterBrandIndex(store.brandIndex, _search.text);
    if (_brand != null && !brands.any((b) => b.brand == _brand)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _brand = brands.isEmpty ? null : brands.first.brand);
      });
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CategoryRail(
          categoryId: _categoryId,
          brand: _brand,
          brands: brands,
          onCategory: (id) => setState(() {
            _categoryId = id;
            _brand = null;
            _pickDefaultBrand();
          }),
          onBrand: (brand) => setState(() => _brand = brand),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: Ck.line),
        Expanded(
          child: _ProductPanel(
            store: store,
            brand: _brand,
            query: _search.text,
          ),
        ),
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.categoryId,
    required this.brand,
    required this.brands,
    required this.onCategory,
    required this.onBrand,
  });

  final String categoryId;
  final String? brand;
  final List<BrandGroup> brands;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onBrand;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: Ck.bg2,
      child: SizedBox(
        width: 118,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          children: [
            for (final cat in catalogCategories)
              _RailItem(
                label: cat.label,
                selected: cat.id == categoryId,
                onTap: () => onCategory(cat.id),
              ),
            if (categoryId == 'telefon' && brands.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 8, 6),
                child: Text(
                  'MARKA',
                  style: text.labelSmall?.copyWith(color: Ck.mute, letterSpacing: 0.6),
                ),
              ),
              for (final group in brands)
                _RailItem(
                  label: '${group.brand} Serisi',
                  selected: brand == group.brand,
                  dense: true,
                  onTap: () => onBrand(group.brand),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: selected ? Ck.ink : Colors.transparent, width: 3),
            ),
          ),
          padding: EdgeInsets.fromLTRB(dense ? 12 : 10, dense ? 10 : 12, 8, dense ? 10 : 12),
          child: Text(
            label,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: (dense ? text.bodySmall : text.titleSmall)?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Ck.ink : Ck.mute,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductPanel extends StatelessWidget {
  const _ProductPanel({
    required this.store,
    required this.brand,
    required this.query,
  });

  final AppStore store;
  final String? brand;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (brand == null) {
      return const Center(
        child: Text('Sol menüden marka seçin.', style: TextStyle(color: Ck.mute)),
      );
    }

    BrandGroup? group;
    for (final item in store.brandIndex) {
      if (item.brand == brand) {
        group = item;
        break;
      }
    }
    if (group == null) {
      return const Center(child: Text('Marka bulunamadı.', style: TextStyle(color: Ck.mute)));
    }

    final q = query.trim().toLowerCase();
    final entries = <_ProductEntry>[];
    for (final series in group.series) {
      for (final phone in series.models) {
        if (q.isNotEmpty &&
            !phone.name.toLowerCase().contains(q) &&
            !series.series.toLowerCase().contains(q) &&
            !phone.brand.toLowerCase().contains(q)) {
          continue;
        }
        entries.add(_ProductEntry(phone: phone, series: series.series));
      }
    }

    if (entries.isEmpty) {
      return const Center(child: Text('Eşleşen model yok.', style: TextStyle(color: Ck.mute)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$brand Serisi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Ck.mute),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16, color: Ck.line),
            itemBuilder: (context, i) => _ProductRow(store: store, entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

class _ProductEntry {
  const _ProductEntry({required this.phone, required this.series});
  final Phone phone;
  final String series;
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.store, required this.entry});
  final AppStore store;
  final _ProductEntry entry;

  @override
  Widget build(BuildContext context) {
    final phone = entry.phone;
    final text = Theme.of(context).textTheme;
    final technical = store.scores.technical(phone);
    final hasPrice = phone.priceTRY > 0;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/telefon', arguments: phone.id),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phone.name, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  if (phone.highlights.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Ck.mintDim,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        phone.highlights.first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall?.copyWith(color: Ck.mint, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    hasPrice ? formatPrice(phone.priceTRY) : 'Fiyat yakında',
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (!hasPrice)
                    Text(
                      'Teknik endeks ${technical.toStringAsFixed(0)}',
                      style: text.bodySmall,
                    )
                  else if (phone.year >= 2024)
                    Text(
                      "'den başlayan fiyatlarla",
                      style: text.bodySmall?.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PhoneVisual(phone: phone, height: 72),
          ],
        ),
      ),
    );
  }
}
