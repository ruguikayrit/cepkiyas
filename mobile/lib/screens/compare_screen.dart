import 'package:flutter/material.dart';

import '../logic/format.dart';
import '../logic/specs.dart';
import '../models/phone.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  bool diffOnly = false;
  String query = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final selected = widget.store.compared;
        final suggestions = widget.store.phones
            .where((p) => !widget.store.isCompared(p.id))
            .where((p) => query.isEmpty || p.fullName.toLowerCase().contains(query.toLowerCase()))
            .take(8)
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const Text('Yan yana kıyas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
            const SizedBox(height: 4),
            const Text(
              'En fazla 4 model. Yeşil hücre o satırdaki daha iyi değeri gösterir.',
              style: TextStyle(color: Ck.mute),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Kıyasa model ekle…',
                filled: true,
                fillColor: Ck.panel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Ck.line)),
              ),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (phone) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: PhoneVisual(phone: phone, height: 48),
                title: Text(phone.name),
                subtitle: Text(phone.brand),
                trailing: const Icon(Icons.add, color: Ck.mint),
                onTap: () => widget.store.toggleCompare(phone.id),
              ),
            ),
            if (selected.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text('Kıyas için en az iki telefon seçin.', textAlign: TextAlign.center, style: TextStyle(color: Ck.mute)),
              )
            else ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sadece farklar'),
                value: diffOnly,
                onChanged: (value) => setState(() => diffOnly = value),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final phone in selected)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () => widget.store.toggleCompare(phone.id),
                                  icon: const Icon(Icons.close, size: 18),
                                ),
                              ),
                              PhoneVisual(phone: phone, height: 96),
                              Text(phone.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(formatPrice(phone.priceTRY), style: const TextStyle(color: Ck.mute, fontSize: 12)),
                              const SizedBox(height: 8),
                              ScoreRing(value: widget.store.scores.technical(phone), label: 'Teknik', size: 64),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (selected.length >= 2)
                for (final group in specGroups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 18, 0, 8),
                    child: Text(group.label.toUpperCase(), style: const TextStyle(color: Ck.mute, fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w700)),
                  ),
                  for (final row in group.rows)
                    if (!diffOnly || rowHasDifference(selected, row))
                      _CompareRow(phones: selected, row: row),
                ],
            ],
          ],
        );
      },
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.phones, required this.row});
  final List<Phone> phones;
  final SpecRow row;

  @override
  Widget build(BuildContext context) {
    final list = phones;
    final winners = winnersFor(list, row);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Ck.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Ck.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.label, style: const TextStyle(color: Ck.mute, fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final phone in list)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: winners.contains(phone.id) ? Ck.mintDim : Ck.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      row.text(phone),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: winners.contains(phone.id) ? FontWeight.w700 : FontWeight.w500,
                        color: winners.contains(phone.id) ? Ck.mint : Ck.ink,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
