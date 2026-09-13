import 'package:flutter/material.dart';

import '../logic/format.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.store.search(query);
    final brands = widget.store.matchingBrands(query);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => query = value),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _openCatalog(),
          style: const TextStyle(color: Ck.ink),
          decoration: const InputDecoration(
            hintText: 'Ürün, marka veya model ara',
            hintStyle: TextStyle(color: Ck.mute),
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView(
        children: [
          if (brands.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final brand in brands)
                    ActionChip(
                      label: Text(brand),
                      onPressed: () {
                        widget.store.setFilters(widget.store.filters.copy()..brands = [brand]..query = '');
                        widget.store.goTab(1);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
          for (final phone in results)
            ListTile(
              leading: PhoneVisual(phone: phone, height: 52),
              title: Text(phone.fullName),
              subtitle: Text('${phone.brand} · ${formatPrice(phone.priceTRY)}'),
              trailing: Text(
                formatScore(widget.store.scores.technical(phone)),
                style: const TextStyle(color: Ck.mint, fontWeight: FontWeight.w700),
              ),
              onTap: () => Navigator.of(context).pushReplacementNamed('/telefon', arguments: phone.id),
            ),
          if (query.trim().isNotEmpty)
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text('Katalogda tüm sonuçları gör (${widget.store.searchCount(query)})'),
              onTap: _openCatalog,
            ),
        ],
      ),
    );
  }

  void _openCatalog() {
    widget.store.setFilters(widget.store.filters.copy()..query = query);
    widget.store.goTab(1);
    Navigator.pop(context);
  }
}
