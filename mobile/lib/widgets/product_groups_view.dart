import 'package:flutter/material.dart';

import '../logic/catalog_grouping.dart';
import '../logic/catalog_taxonomy.dart';
import '../logic/format.dart';
import '../models/phone.dart';
import '../state/app_store.dart';
import '../theme.dart';
import 'widgets.dart';

/// Ürün grubu → marka (alt başlık) → seri (alt başlık) → modeller.
/// Tek seferde binlerce sliver oluşturmaz; ListView.builder ile lazy yükler.
class ProductGroupsView extends StatefulWidget {
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
  State<ProductGroupsView> createState() => _ProductGroupsViewState();
}

class _ProductGroupsViewState extends State<ProductGroupsView> {
  List<_CatalogEntry>? _cache;
  String _cacheQuery = '';
  String? _cacheCategory;
  int _cachePhoneCount = 0;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _scheduleRebuild();
  }

  @override
  void didUpdateWidget(ProductGroupsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query ||
        widget.onlyCategoryId != oldWidget.onlyCategoryId ||
        widget.store.phones.length != oldWidget.store.phones.length) {
      _scheduleRebuild();
    }
  }

  void _scheduleRebuild() {
    setState(() => _loading = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final phoneCount = widget.store.phones.length;
      final entries = _buildEntries();
      setState(() {
        _cache = entries;
        _cacheQuery = widget.query;
        _cacheCategory = widget.onlyCategoryId;
        _cachePhoneCount = phoneCount;
        _loading = false;
      });
    });
  }

  bool get _cacheValid =>
      _cache != null &&
      _cacheQuery == widget.query &&
      _cacheCategory == widget.onlyCategoryId &&
      _cachePhoneCount == widget.store.phones.length;

  List<_CatalogEntry> _buildEntries() {
    final visible = widget.onlyCategoryId == null
        ? widget.categories
        : widget.categories.where((c) => c.id == widget.onlyCategoryId).toList();

    final out = <_CatalogEntry>[];
    for (final category in visible) {
      out.add(_CatalogEntry.group(category));
      if (category.status != CatalogCategoryStatus.active) {
        out.add(_CatalogEntry.soon(category.description));
        continue;
      }
      final index = filterBrandIndex(buildBrandIndex(widget.store.phones), widget.query);
      if (index.isEmpty) {
        out.add(_CatalogEntry.emptySearch);
        continue;
      }
      for (final brand in index) {
        out.add(_CatalogEntry.brand(brand.brand, brand.count));
        for (final series in brand.series) {
          out.add(_CatalogEntry.series(series.series));
          for (final phone in series.models) {
            out.add(_CatalogEntry.model(phone));
          }
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || !_cacheValid) {
      return const Center(child: CircularProgressIndicator(color: Ck.mint, strokeWidth: 2));
    }
    final entries = _cache!;
    if (entries.length == 1 && entries.first.kind == _EntryKind.emptySearch) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Aramanızla eşleşen marka veya model yok.', style: TextStyle(color: Ck.mute)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: entries.length,
      itemBuilder: (context, index) => _CatalogEntryTile(entry: entries[index], store: widget.store),
    );
  }
}

enum _EntryKind { group, soon, brand, series, model, emptySearch }

class _CatalogEntry {
  const _CatalogEntry._(this.kind, {this.category, this.text, this.brand, this.count, this.phone});

  factory _CatalogEntry.group(CatalogCategory category) => _CatalogEntry._(_EntryKind.group, category: category);
  factory _CatalogEntry.soon(String text) => _CatalogEntry._(_EntryKind.soon, text: text);
  factory _CatalogEntry.brand(String brand, int count) => _CatalogEntry._(_EntryKind.brand, brand: brand, count: count);
  factory _CatalogEntry.series(String text) => _CatalogEntry._(_EntryKind.series, text: text);
  factory _CatalogEntry.model(Phone phone) => _CatalogEntry._(_EntryKind.model, phone: phone);
  static const emptySearch = _CatalogEntry._(_EntryKind.emptySearch);

  final _EntryKind kind;
  final CatalogCategory? category;
  final String? text;
  final String? brand;
  final int? count;
  final Phone? phone;
}

class _CatalogEntryTile extends StatelessWidget {
  const _CatalogEntryTile({required this.entry, required this.store});

  final _CatalogEntry entry;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    switch (entry.kind) {
      case _EntryKind.group:
        return _ProductGroupHeader(category: entry.category!);
      case _EntryKind.soon:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Text(
            '${entry.text}\nBu gruptaki marka ve modeller yakında eklenecek.',
            style: const TextStyle(color: Ck.mute, height: 1.45, fontSize: 13),
          ),
        );
      case _EntryKind.brand:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.brand!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.4),
                ),
              ),
              Text(
                '${entry.count} model',
                style: const TextStyle(color: Ck.mute, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      case _EntryKind.series:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            entry.text!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Ck.mute,
              letterSpacing: -0.2,
            ),
          ),
        );
      case _EntryKind.model:
        return _ModelRow(store: store, phone: entry.phone!);
      case _EntryKind.emptySearch:
        return const SizedBox.shrink();
    }
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
