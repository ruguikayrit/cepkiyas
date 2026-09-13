import 'package:flutter/material.dart';

import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final items = store.favorites;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border_rounded, size: 48, color: Ck.mute.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              const Text('Henüz favori yok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                'Ürün detayında veya listede kalp ile kaydedebilirsiniz. Favoriler cihazınızda saklanır.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Ck.mute, height: 1.45, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => PhoneTile(store: store, phone: items[i]),
    );
  }
}
