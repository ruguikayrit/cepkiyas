import 'package:flutter/material.dart';

import '../logic/format.dart';
import '../logic/product_media.dart';
import '../logic/ratings.dart';
import '../logic/specs.dart';
import '../models/phone.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../typography.dart';
import '../widgets/product_promo_gallery.dart';
import '../widgets/widgets.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.store, required this.phoneId});
  final AppStore store;
  final String phoneId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  UserVote? draft;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final phone = widget.store.byId(widget.phoneId);
        if (phone == null) {
          return const Scaffold(body: Center(child: Text('Model bulunamadı')));
        }
        final technical = widget.store.scores.technical(phone);
        final user = widget.store.scoreOf(phone);
        final index = widget.store.scores.index(technical, user.average);
        final cats = widget.store.scores.categories(phone);
        final view = draft ?? user.mine ?? const UserVote();

        return Scaffold(
          appBar: AppBar(
            title: Text(phone.name),
            actions: [
              IconButton(
                tooltip: widget.store.isFavorite(phone.id) ? 'Favorilerden çıkar' : 'Favorilere ekle',
                onPressed: () => widget.store.toggleFavorite(phone.id),
                icon: Icon(
                  widget.store.isFavorite(phone.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: widget.store.isFavorite(phone.id) ? Ck.mint : null,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              ProductPromoGallery(phone: phone),
              const SizedBox(height: 16),
              Text('${phone.brand} · ${phone.year}', style: Theme.of(context).textTheme.bodySmall),
              Text(phone.fullName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                phone.highlights.join(' · '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Ck.mute),
              ),
              if (phone.priceTRY > 0) ...[
                const SizedBox(height: 8),
                Text(formatPrice(phone.priceTRY), style: Theme.of(context).textTheme.titleLarge),
              ],
              const SizedBox(height: 12),
              CompareChip(
                selected: widget.store.isCompared(phone.id),
                onTap: () => widget.store.toggleCompare(phone.id),
              ),
              const SizedBox(height: 20),
              _SectionHeading('Tanıtım'),
              if (phone.colors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final color in phone.colors)
                      Chip(
                        avatar: CircleAvatar(backgroundColor: Color(color.value), radius: 8),
                        label: Text(color.name),
                        backgroundColor: Ck.panel,
                        side: const BorderSide(color: Ck.line),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              _PromoThumbs(phone: phone),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ScoreRing(value: technical, label: 'Teknik', size: 84),
                  ScoreRing(value: user.average * 10, label: 'Kullanıcı', size: 84),
                  ScoreRing(value: index, label: 'Endeks', size: 84),
                ],
              ),
              const SizedBox(height: 20),
              _SectionHeading('Öne çıkan özellikler'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Key('Ekran', '${phone.display.size}" ${phone.display.refreshRate} Hz'),
                  _Key('Bellek', '${phone.memory.ram} / ${phone.memory.storage} GB'),
                  _Key('Batarya', '${formatCapacity(phone.battery.capacity, phone.battery.capacityNote)} · ${phone.battery.wiredWatt} W'),
                  _Key('Yonga', phone.performance.chipset),
                  for (final entry in cats.entries) _Key('Teknik · ${entry.key}', formatScore(entry.value)),
                ],
              ),
              const SizedBox(height: 20),
              _SectionHeading('Topluluk puanı'),
              const SizedBox(height: 8),
              _RatingCard(
                user: user,
                view: view,
                onSet: (key, value) {
                  setState(() {
                    draft = switch (key) {
                      'overall' => view.copyWith(overall: value),
                      'camera' => view.copyWith(camera: value, overall: view.overall == 0 ? value : view.overall),
                      'performance' => view.copyWith(performance: value, overall: view.overall == 0 ? value : view.overall),
                      'battery' => view.copyWith(battery: value, overall: view.overall == 0 ? value : view.overall),
                      'display' => view.copyWith(display: value, overall: view.overall == 0 ? value : view.overall),
                      _ => view.copyWith(design: value, overall: view.overall == 0 ? value : view.overall),
                    };
                  });
                },
                onSave: () {
                  if (view.overall == 0) return;
                  widget.store.setVote(phone.id, view);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Oyun küresel ortalamaya eklendi')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _SectionHeading('Teknik özellikler'),
              const SizedBox(height: 8),
              for (final group in specGroups) _SpecBlock(phone: phone, group: group),
              _ChipBlock('Sensörler', phone.sensors),
              _ChipBlock('Kamera özellikleri', phone.camera.features),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: CkType.sectionLabel().copyWith(color: Ck.ink, letterSpacing: 0.4));
  }
}

class _PromoThumbs extends StatelessWidget {
  const _PromoThumbs({required this.phone});
  final Phone phone;

  @override
  Widget build(BuildContext context) {
    final images = promoImagesFor(phone);
    if (images.length <= 1) return const SizedBox.shrink();
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final url = images[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: url.startsWith('http')
                  ? Image.network(url, fit: BoxFit.cover)
                  : Image.asset('assets$url', fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.sizeOf(context).width - 40) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Ck.panel,
        border: Border.all(color: Ck.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Ck.mute, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.user,
    required this.view,
    required this.onSet,
    required this.onSave,
  });

  final MergedScore user;
  final UserVote view;
  final void Function(String key, int value) onSet;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Ck.panel,
        border: Border.all(color: Ck.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Küresel kullanıcı puanı', style: TextStyle(color: Ck.mute)),
          Text(formatScore(user.average), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.2)),
          Text('/ 10 · ${formatCount(user.count)} oy', style: const TextStyle(color: Ck.mute)),
          const SizedBox(height: 12),
          for (final entry in user.breakdown.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: 88, child: Text(ratingCategories.firstWhere((c) => c.$1 == entry.key).$2)),
                  SizedBox(width: 28, child: Text(formatScore(entry.value), style: const TextStyle(fontWeight: FontWeight.w700))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: entry.value / 10,
                        minHeight: 6,
                        color: Ck.mint,
                        backgroundColor: Ck.line,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Text('Puan ver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Text('Oyun cihazda saklanır ve küresel ortalamaya eklenir.', style: TextStyle(color: Ck.mute, fontSize: 13)),
          const SizedBox(height: 8),
          for (final category in ratingCategories)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.$2, style: const TextStyle(color: Ck.mute, fontSize: 12)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: [
                      for (var i = 1; i <= 10; i++)
                        GestureDetector(
                          onTap: () => onSet(category.$1, i),
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: view[category.$1] >= i ? Ck.mint : Ck.bg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: view[category.$1] >= i ? Ck.mint : Ck.line),
                            ),
                            child: Text(
                              '$i',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: view[category.$1] >= i ? Colors.white : Ck.ink,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: view.overall == 0 ? null : onSave,
              child: Text(user.mine != null ? 'Oyu güncelle' : 'Oyu kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecBlock extends StatelessWidget {
  const _SpecBlock({required this.phone, required this.group});
  final Phone phone;
  final SpecGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Ck.panel,
        border: Border.all(color: Ck.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.label, style: const TextStyle(color: Ck.mute, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final row in group.rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 120, child: Text(row.label, style: const TextStyle(color: Ck.mute))),
                  Expanded(child: Text(row.text(phone), style: const TextStyle(fontWeight: FontWeight.w500))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChipBlock extends StatelessWidget {
  const _ChipBlock(this.title, this.items);
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Ck.mute, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in items)
                Chip(
                  label: Text(item),
                  backgroundColor: Ck.panel,
                  side: const BorderSide(color: Ck.line),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
