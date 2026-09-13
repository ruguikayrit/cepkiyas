import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final list = store.filtered;
    return Column(
      children: [
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
                    hintText: 'Model, yonga, sistem…',
                    hintStyle: const TextStyle(color: Ck.mute),
                    filled: true,
                    fillColor: Ck.panel,
                    prefixIcon: const Icon(Icons.search, color: Ck.mute),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Ck.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Ck.line),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () => _openFilters(context),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${list.length} model · ${sortLabels[store.filters.sort]}', style: const TextStyle(color: Ck.mute)),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => PhoneTile(store: store, phone: list[i]),
          ),
        ),
      ],
    );
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
                    const Text('Filtreler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
                    Text('Fiyat · ${formatPrice(draft.maxPrice)}'),
                    Slider(
                      value: draft.maxPrice.toDouble(),
                      max: store.priceMax.toDouble(),
                      onChanged: (v) => setModal(() => draft.maxPrice = v.round()),
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
                          Navigator.pop(context);
                        },
                        child: const Text('Uygula'),
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
