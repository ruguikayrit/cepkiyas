import 'package:flutter/material.dart';

import '../logic/format.dart';
import '../models/phone.dart';
import '../state/app_store.dart';
import '../theme.dart';

class PhoneVisual extends StatelessWidget {
  const PhoneVisual({super.key, required this.phone, this.height = 88});

  final Phone phone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final size = height;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.antiAlias,
      child: phone.image.isEmpty
          ? Center(
              child: Text(
                phone.brand,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            )
          : phone.image.startsWith('http')
              ? Image.network(
                  phone.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => Center(
                    child: Text(phone.brand, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ),
                )
              : Image.asset(
                  'assets${phone.image}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => Center(
                    child: Text(
                      phone.brand,
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ),
                ),
    );
  }
}

class ScorePill extends StatelessWidget {
  const ScorePill({super.key, required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Ck.panel2,
        border: Border.all(color: Ck.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatScore(value),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Ck.tone(value),
              letterSpacing: -0.4,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 9, color: Ck.mute, letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.value, required this.label, this.size = 72});

  final double value;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (value / 100).clamp(0, 1),
            strokeWidth: 4.5,
            backgroundColor: Ck.line,
            color: Ck.tone(value),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatScore(value),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.4),
              ),
              Text(label, style: const TextStyle(fontSize: 8, color: Ck.mute)),
            ],
          ),
        ],
      ),
    );
  }
}

class CompareChip extends StatelessWidget {
  const CompareChip({super.key, required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Ck.mintDim : Ck.panel,
          border: Border.all(color: selected ? Ck.mint : Ck.line),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          selected ? 'Seçildi' : 'Kıyasla',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Ck.mint : Ck.ink,
          ),
        ),
      ),
    );
  }
}

class PhoneTile extends StatelessWidget {
  const PhoneTile({super.key, required this.store, required this.phone, this.compact = false});

  final AppStore store;
  final Phone phone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final technical = store.scores.technical(phone);
    final user = store.scoreOf(phone);
    final index = store.scores.index(technical, user.average);
    if (compact) {
      return Material(
        color: Ck.panel,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).pushNamed('/telefon', arguments: phone.id),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Center(child: PhoneVisual(phone: phone, height: 92))),
                const SizedBox(height: 8),
                Text(phone.brand, style: const TextStyle(color: Ck.mute, fontSize: 11)),
                Text(
                  phone.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                Text(formatPrice(phone.priceTRY), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text('Endeks ${index.toStringAsFixed(1)}', style: const TextStyle(color: Ck.mute, fontSize: 11)),
                    ),
                    CompareChip(
                      selected: store.isCompared(phone.id),
                      onTap: () => store.toggleCompare(phone.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Material(
      color: Ck.panel,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed('/telefon', arguments: phone.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              PhoneVisual(phone: phone, height: 84),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phone.brand, style: const TextStyle(color: Ck.mute, fontSize: 12)),
                    Text(
                      phone.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.3),
                    ),
                    Text(
                      [
                        '${phone.year}',
                        if (phone.memory.ram > 0) '${phone.memory.ram} GB RAM',
                        if (phone.memory.storage > 0) '${phone.memory.storage} GB',
                        if (phone.battery.capacity != null)
                          formatCapacity(phone.battery.capacity, phone.battery.capacityNote),
                      ].join(' · '),
                      style: const TextStyle(color: Ck.mute, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ScorePill(value: technical, label: 'Teknik'),
                        const SizedBox(width: 6),
                        ScorePill(value: user.average * 10, label: 'Kullanıcı'),
                        const SizedBox(width: 6),
                        ScorePill(value: index, label: 'Endeks'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatPrice(phone.priceTRY), style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  CompareChip(
                    selected: store.isCompared(phone.id),
                    onTap: () => store.toggleCompare(phone.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneCard extends StatelessWidget {
  const PhoneCard({super.key, required this.store, required this.phone});

  final AppStore store;
  final Phone phone;

  @override
  Widget build(BuildContext context) {
    final technical = store.scores.technical(phone);
    final user = store.scoreOf(phone);
    return SizedBox(
      width: 168,
      child: Material(
        color: Ck.panel,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).pushNamed('/telefon', arguments: phone.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: PhoneVisual(phone: phone, height: 110)),
                const SizedBox(height: 10),
                Text(phone.brand, style: const TextStyle(color: Ck.mute, fontSize: 12)),
                Text(phone.name, style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3)),
                Text(phone.highlights.first, style: const TextStyle(color: Ck.mute, fontSize: 12), maxLines: 1),
                const Spacer(),
                Row(
                  children: [
                    ScorePill(value: technical, label: 'Teknik'),
                    const Spacer(),
                    Text('${formatScore(user.average)} / 10', style: const TextStyle(color: Ck.mute, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.4)),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
