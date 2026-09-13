import 'package:flutter/material.dart';

import '../logic/catalog_grouping.dart';
import '../logic/catalog_window.dart';
import '../logic/catalog_taxonomy.dart';
import '../logic/format.dart';
import '../models/phone.dart';
import '../state/app_store.dart';
import '../theme.dart';

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
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              itemCount: catalogCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = catalogCategories[i];
                final selected = cat.id == _categoryId;
                return ChoiceChip(
                  label: Text(cat.label),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _categoryId = cat.id;
                    _brand = null;
                  }),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Ck.ink),
              decoration: InputDecoration(
                hintText: 'Marka veya model ara',
                hintStyle: const TextStyle(color: Ck.mute),
                filled: true,
                fillColor: Ck.panel,
                prefixIcon: const Icon(Icons.search, color: Ck.mute),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Ck.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Ck.line),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Son 10 yıl · ${CatalogWindow.label} aralığındaki marka ve modeller',
              style: const TextStyle(color: Ck.mute, fontSize: 12, height: 1.35),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    final category = catalogCategoryById(_categoryId);
    if (category.status != CatalogCategoryStatus.active) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '${category.label} grubu yakında.\n${category.description}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Ck.mute, height: 1.45),
          ),
        ),
      );
    }

    if (store.brandIndex.isEmpty) {
      return const Center(
        child: Text('Katalog henüz hazır değil.', style: TextStyle(color: Ck.mute)),
      );
    }

    if (_brand != null) {
      return _BrandModels(
        store: store,
        brand: _brand!,
        query: _search.text,
        onBack: () => setState(() => _brand = null),
      );
    }

    return _BrandList(
      index: filterBrandIndex(store.brandIndex, _search.text),
      onOpen: (brand) => setState(() => _brand = brand),
    );
  }
}

class _BrandList extends StatelessWidget {
  const _BrandList({required this.index, required this.onOpen});

  final List<BrandGroup> index;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (index.isEmpty) {
      return const Center(
        child: Text('Eşleşen marka yok.', style: TextStyle(color: Ck.mute)),
      );
    }

    final rows = <Object>[];
    String? lastLetter;
    for (final group in index) {
      final letter = brandIndexLetter(group.brand);
      if (letter != lastLetter) {
        rows.add(letter);
        lastLetter = letter;
      }
      rows.add(group);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: rows.length,
      itemBuilder: (context, i) {
        final row = rows[i];
        if (row is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Text(
              row,
              style: const TextStyle(color: Ck.mint, fontWeight: FontWeight.w700, letterSpacing: 0.8),
            ),
          );
        }
        final group = row as BrandGroup;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Ck.panel,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              title: Text(group.brand, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${group.count} model · ${group.series.length} seri', style: const TextStyle(color: Ck.mute)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Ck.mute),
              onTap: () => onOpen(group.brand),
            ),
          ),
        );
      },
    );
  }
}

class _BrandModels extends StatelessWidget {
  const _BrandModels({
    required this.store,
    required this.brand,
    required this.query,
    required this.onBack,
  });

  final AppStore store;
  final String brand;
  final String query;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    BrandGroup? group;
    for (final item in store.brandIndex) {
      if (item.brand == brand) {
        group = item;
        break;
      }
    }
    if (group == null) {
      return Center(child: TextButton(onPressed: onBack, child: const Text('Markalara dön')));
    }

    final q = query.trim().toLowerCase();
    final rows = <Object>[];
    for (final series in group.series) {
      final models = q.isEmpty
          ? series.models
          : series.models.where((p) => p.name.toLowerCase().contains(q) || series.series.toLowerCase().contains(q)).toList();
      if (models.isEmpty) continue;
      rows.add(series.series);
      rows.addAll(models);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Markalar'),
              ),
              Expanded(
                child: Text(
                  '$brand · ${group.count} model',
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Ck.mute, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final row = rows[i];
              if (row is String) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
                  child: Text(row, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                );
              }
              final phone = row as Phone;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Ck.panel,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    title: Text(phone.name, maxLines: 2),
                    subtitle: Text('${phone.year} · ${formatPrice(phone.priceTRY)}', style: const TextStyle(color: Ck.mute)),
                    onTap: () => Navigator.of(context).pushNamed('/telefon', arguments: phone.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
