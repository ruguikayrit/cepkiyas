import 'package:flutter/material.dart';

import '../logic/catalog_grouping.dart';
import '../logic/filters.dart';
import '../logic/format.dart';
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
  var _view = _CatalogView.products;
  String? _brandFocus;

  AppStore get store => widget.store;

  static const _categories = [
    ('Telefon', true),
    ('Tablet', false),
    ('Bilgisayar', false),
    ('Akıllı saat', false),
  ];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: store.filters.query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = store.filtered;
    final chips = store.filters.chips(store.priceMax);
    final brandIndex = buildBrandIndex(store.phones);
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (label, active) = _categories[i];
              if (!active) {
                return Chip(
                  label: Text('$label · yakında'),
                  side: const BorderSide(color: Ck.line),
                  backgroundColor: Ck.panel,
                );
              }
              return FilterChip(
                label: Text('$label · ${store.phones.length}'),
                selected: true,
                onSelected: (_) {},
                showCheckmark: false,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SegmentedButton<_CatalogView>(
            segments: const [
              ButtonSegment(value: _CatalogView.products, label: Text('Ürünler')),
              ButtonSegment(value: _CatalogView.brands, label: Text('Markalar')),
            ],
            selected: {_view},
            onSelectionChanged: (value) => setState(() => _view = value.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (value) => store.setFilters(store.filters.copy()..query = value),
                  style: const TextStyle(color: Ck.ink),
                  decoration: InputDecoration(
                    hintText: 'Ürün, marka veya model ara',
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
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: store.filters.isActive(store.priceMax),
                label: Text('${chips.length}'),
                child: IconButton.filledTonal(
                  onPressed: () => _openFilters(context),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${list.length} ürün · ${sortLabels[store.filters.sort]}',
                  style: const TextStyle(color: Ck.mute),
                ),
              ),
              if (store.filters.isActive(store.priceMax))
                TextButton(onPressed: _clear, child: const Text('Temizle')),
            ],
          ),
        ),
        if (chips.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final chip = chips[i];
                return InputChip(
                  label: Text(chip.label),
                  onDeleted: () {
                    final next = store.filters.withoutChip(chip.id, store.priceMax);
                    store.setFilters(next);
                    if (chip.id == 'q') _search.clear();
                  },
                );
              },
            ),
          ),
        Expanded(
          child: _view == _CatalogView.brands
              ? _BrandDirectory(
                  index: brandIndex,
                  focus: _brandFocus,
                  onFocus: (brand) => setState(() => _brandFocus = brand),
                  store: store,
                )
              : list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Bu kriterlere uyan ürün yok.', style: TextStyle(color: Ck.mute)),
                          if (store.filters.isActive(store.priceMax))
                            TextButton(onPressed: _clear, child: const Text('Filtreleri temizle')),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) => PhoneTile(store: store, phone: list[i], compact: true),
                    ),
        ),
      ],
    );
  }

  void _clear() {
    _search.clear();
    store.resetFilters();
  }

  Future<void> _openFilters(BuildContext context) async {
    final draft = store.filters.copy();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Ck.bg2,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Filtreler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        ),
                        TextButton(
                          onPressed: () {
                            draft.query = '';
                            draft.brands.clear();
                            draft.years.clear();
                            draft.os.clear();
                            draft.minPrice = 0;
                            draft.maxPrice = store.priceMax;
                            draft.minRam = 0;
                            draft.minStorage = 0;
                            draft.only5g = false;
                            draft.foldable = false;
                            setModal(() {});
                          },
                          child: const Text('Temizle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SortKey>(
                      initialValue: draft.sort,
                      dropdownColor: Ck.panel,
                      decoration: const InputDecoration(labelText: 'Sırala'),
                      items: [
                        for (final key in SortKey.values)
                          DropdownMenuItem(value: key, child: Text(sortLabels[key]!)),
                      ],
                      onChanged: (value) => setModal(() => draft.sort = value ?? draft.sort),
                    ),
                    const SizedBox(height: 12),
                    Text('Marka (${store.brands.length})', style: const TextStyle(color: Ck.mute)),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 6,
                          children: [
                            for (final brand in store.brands)
                              FilterChip(
                                label: Text(brand),
                                selected: draft.brands.contains(brand),
                                onSelected: (on) => setModal(() {
                                  if (on) {
                                    draft.brands.add(brand);
                                  } else {
                                    draft.brands.remove(brand);
                                  }
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Yıl', style: TextStyle(color: Ck.mute)),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final year in store.years)
                          FilterChip(
                            label: Text('$year'),
                            selected: draft.years.contains(year),
                            onSelected: (on) => setModal(() {
                              if (on) {
                                draft.years.add(year);
                              } else {
                                draft.years.remove(year);
                              }
                            }),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final os in const ['iOS', 'Android', 'HarmonyOS'])
                          FilterChip(
                            label: Text(os),
                            selected: draft.os.contains(os),
                            onSelected: (on) => setModal(() {
                              if (on) {
                                draft.os.add(os);
                              } else {
                                draft.os.remove(os);
                              }
                            }),
                          ),
                      ],
                    ),
                    Text('Fiyat · ${formatPrice(draft.minPrice)} – ${formatPrice(draft.maxPrice)}'),
                    RangeSlider(
                      values: RangeValues(draft.minPrice.toDouble(), draft.maxPrice.toDouble()),
                      max: store.priceMax.toDouble(),
                      onChanged: (v) => setModal(() {
                        draft.minPrice = v.start.round();
                        draft.maxPrice = v.end.round();
                      }),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: draft.minRam,
                      dropdownColor: Ck.panel,
                      decoration: const InputDecoration(labelText: 'Min. RAM'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Tümü')),
                        DropdownMenuItem(value: 8, child: Text('8 GB+')),
                        DropdownMenuItem(value: 12, child: Text('12 GB+')),
                        DropdownMenuItem(value: 16, child: Text('16 GB+')),
                      ],
                      onChanged: (v) => setModal(() => draft.minRam = v ?? 0),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: draft.minStorage,
                      dropdownColor: Ck.panel,
                      decoration: const InputDecoration(labelText: 'Min. depolama'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Tümü')),
                        DropdownMenuItem(value: 128, child: Text('128 GB+')),
                        DropdownMenuItem(value: 256, child: Text('256 GB+')),
                        DropdownMenuItem(value: 512, child: Text('512 GB+')),
                      ],
                      onChanged: (v) => setModal(() => draft.minStorage = v ?? 0),
                    ),
                    SwitchListTile(
                      title: const Text('Yalnızca 5G'),
                      value: draft.only5g,
                      onChanged: (v) => setModal(() => draft.only5g = v),
                    ),
                    SwitchListTile(
                      title: const Text('Katlanır'),
                      value: draft.foldable,
                      onChanged: (v) => setModal(() => draft.foldable = v),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          store.setFilters(draft);
                          _search.text = draft.query;
                          Navigator.pop(context);
                        },
                        child: const Text('Ürünleri göster'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

enum _CatalogView { products, brands }

class _BrandDirectory extends StatelessWidget {
  const _BrandDirectory({
    required this.index,
    required this.focus,
    required this.onFocus,
    required this.store,
  });

  final List<BrandGroup> index;
  final String? focus;
  final ValueChanged<String?> onFocus;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    if (focus != null) {
      BrandGroup? group;
      for (final item in index) {
        if (item.brand == focus) {
          group = item;
          break;
        }
      }
      if (group == null) {
        return Center(child: TextButton(onPressed: () => onFocus(null), child: const Text('Markalar')));
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => onFocus(null), child: const Text('← Tüm markalar')),
          ),
          Text(group.brand, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          Text('${group.count} model', style: const TextStyle(color: Ck.mute)),
          const SizedBox(height: 12),
          for (final series in group.series) ...[
            Text(series.series, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            for (final phone in series.models)
              ListTile(
                dense: true,
                title: Text(phone.name),
                subtitle: Text('${phone.year} · ${formatPrice(phone.priceTRY)}'),
                onTap: () => Navigator.of(context).pushNamed('/telefon', arguments: phone.id),
              ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: index.length,
      itemBuilder: (_, i) {
        final group = index[i];
        return ListTile(
          title: Text(group.brand),
          subtitle: Text('${group.count} model · ${group.series.length} seri'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onFocus(group.brand),
        );
      },
    );
  }
}
