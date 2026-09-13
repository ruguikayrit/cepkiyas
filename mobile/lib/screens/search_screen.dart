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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (value) => setState(() => query = value),
          style: const TextStyle(color: Ck.ink),
          decoration: const InputDecoration(
            hintText: 'iPhone, S25 Ultra, Snapdragon…',
            hintStyle: TextStyle(color: Ck.mute),
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (_, i) {
          final phone = results[i];
          return ListTile(
            leading: PhoneVisual(phone: phone, height: 52),
            title: Text(phone.fullName),
            subtitle: Text('${phone.performance.chipset} · ${formatPrice(phone.priceTRY)}'),
            trailing: Text(
              formatScore(widget.store.scores.technical(phone)),
              style: const TextStyle(color: Ck.mint, fontWeight: FontWeight.w700),
            ),
            onTap: () => Navigator.of(context).pushReplacementNamed('/telefon', arguments: phone.id),
          );
        },
      ),
    );
  }
}
