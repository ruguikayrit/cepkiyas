import 'package:flutter/material.dart';

import '../logic/catalog_grouping.dart';
import '../logic/catalog_taxonomy.dart';
import '../logic/filters.dart';
import '../logic/format.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/catalog_brands_view.dart';
import '../widgets/widgets.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final TextEditingController _search;
  var _view = _CatalogBrowseMode.brands;
  String _categoryId = 'telefon';
  String? _brandFocus;

  AppStore get store => widget.store;

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

  CatalogCategory get _category => catalogCategoryById(_categoryId);

  bool get _categoryActive => _category.status == CatalogCategoryStatus.active;

  @override
  Widget build(BuildContext context) {
    final categories = [
      for (final item in catalogCategories)
        item.id == 'telefon' ? CatalogCategory(id: item.id, label: item.label, description: item.description, icon: item.icon, status: item.status, count: store.phones.length) : item,
    ];

    if (!_categoryActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryStrip(
            categories: categories,
            selectedId: _categoryId,
            onSelect: _selectCategory,
          ),
          Expanded(child: _CategorySoonBody(category: _category)),
        ],
      );
    }

    final list = store.filtered;
    final chips = store.filters.chips(store.priceMax);
    final brandIndex = buildBrandIndex(store.phones);
    final searchForBrands = _view == _CatalogBrowseMode.brands ? _search.text : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CategoryStrip(
          categories: categories,
          selectedId: _categoryId,
          onSelect: _selectCategory,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(
            _category.description,
            style: const TextStyle(color: Ck.mute, fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SegmentedButton<_CatalogBrowseMode>(
            segments: const [
              ButtonSegment(value: _CatalogBrowseMode.brands, label: Text('Markalar & seriler')),
              ButtonSegment(value: _CatalogBrowseMode.products, label: Text('Tüm ürünler')),
            ],
            selected: {_view},
            onSelectionChanged: (value) => setState(() {
              _view = value.first;
              if (_view == _CatalogBrowseMode.products) {
                _brandFocus = null;
                store.setFilters(store.filters.copy()..query = _search.text);
              }
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (value) {
                    if (_view == _CatalogBrowseMode.products) {
                      store.setFilters(store.filters.copy()..query = value);
                    } else {
                      setState(() {});
                    }
                  },
                  style: const TextStyle(color: Ck.ink),
                  decoration: InputDecoration(
                    hintText: _view == _CatalogBrowseMode.brands ? 'Marka veya model ara' : 'Ürün, marka veya model ara',
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
              if (_view == _CatalogBrowseMode.products) ...[
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
            ],
          ),
        ),
        if (_view == _CatalogBrowseMode.products) ...[
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
        ],
        Expanded(
          child: _view == _CatalogBrowseMode.brands
              ? CatalogBrandsView(
                  store: store,
                  index: brandIndex,
                  focusBrand: _brandFocus,
                  onFocusBrand: (brand) => setState(() => _brandFocus = brand),
                  query: searchForBrands,
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

  void _selectCategory(String id) {
    setState(() {
      _categoryId = id;
      _brandFocus = null;
    });
  }

  void _clear() {
    _search.clear();
    store.resetFilters();
    setState(() {});
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

enum _CatalogBrowseMode { brands, products }

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CatalogCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final selected = cat.id == selectedId;
          final active = cat.status == CatalogCategoryStatus.active;
          return SizedBox(
            width: 108,
            child: Material(
              color: selected ? Ck.mintDim : Ck.panel,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(cat.id),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? Ck.mint : Ck.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(cat.icon, size: 22, color: active ? (selected ? Ck.mint : Ck.ink) : Ck.mute),
                      const Spacer(),
                      Text(
                        cat.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: active ? Ck.ink : Ck.mute,
                        ),
                      ),
                      Text(
                        active && cat.count != null ? '${cat.count}' : 'Yakında',
                        style: TextStyle(fontSize: 11, color: active ? Ck.mute : Ck.mute.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategorySoonBody extends StatelessWidget {
  const _CategorySoonBody({required this.category});

  final CatalogCategory category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 48, color: Ck.mute),
            const SizedBox(height: 16),
            Text(category.label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              category.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Ck.mute, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu ürün grubu katalogda hazırlanıyor. Şimdilik Telefon bölümünde tüm modelleri inceleyebilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Ck.mute, fontSize: 13, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
