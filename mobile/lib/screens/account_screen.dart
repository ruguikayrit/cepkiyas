import 'package:flutter/material.dart';

import '../state/app_store.dart';
import '../theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final voted = store.votes.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Ck.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Ck.line),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Ck.mint, borderRadius: BorderRadius.circular(14)),
                child: const Text('TK', style: TextStyle(color: Color(0xFF08110C), fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TeknoKıyas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Teknoloji kıyası', style: TextStyle(color: Ck.mute, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _StatTile(label: 'Katalogdaki modeller', value: '${store.phones.length}'),
        _StatTile(label: 'Verdiğiniz oylar', value: '$voted'),
        _StatTile(label: 'Kıyas sepeti', value: '${store.compareIds.length} / ${AppStore.maxCompare}'),
        _StatTile(label: 'Favoriler', value: '${store.favoriteIds.length}'),
        const SizedBox(height: 20),
        const Text(
          'Hesap ve bulut senkronu yakında. Şimdilik oylar, kıyas ve favoriler bu cihazda tutulur.',
          style: TextStyle(color: Ck.mute, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Ck.panel,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}
