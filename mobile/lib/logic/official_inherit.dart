import '../models/phone.dart';
import 'catalog_grouping.dart';
import 'image_resolve.dart';
import 'official_sources.dart';

/// Katalog kaydını, aynı serideki resmi modele (phones.json) bağlar.
Phone applyOfficialInheritance(Phone phone, Map<String, Phone> officialsById) {
  if (officialsById.containsKey(phone.id)) return phone;

  final template = _findTemplate(phone, officialsById);
  if (template == null) return _applySourceAndImages(phone);

  final merged = _mergeFromTemplate(phone, template);
  return _applySourceAndImages(merged);
}

Phone _applySourceAndImages(Phone phone) {
  final image = resolveProductImageUrl(phone.image);
  final promos = resolvePromoUrls(phone.promoImages);
  final images = promos.isNotEmpty
      ? promos
      : (image.isNotEmpty ? [image] : phone.promoImages);
  return phone.copyWith(
    image: images.isNotEmpty ? images.first : image,
    promoImages: images,
    sourceUrl: preferOfficialSourceUrl(brand: phone.brand, slug: phone.slug, current: phone.sourceUrl),
  );
}

Phone? _findTemplate(Phone phone, Map<String, Phone> officials) {
  final slug = phone.slug.toLowerCase();
  for (final entry in _slugToOfficial.entries) {
    if (slug.contains(entry.key)) {
      final t = officials[entry.value];
      if (t != null) return t;
    }
  }

  final series = seriesGroupKey(phone.name).toLowerCase();
  Phone? best;
  var bestScore = 0;
  for (final official in officials.values) {
    if (official.brand != phone.brand) continue;
    final oSeries = seriesGroupKey(official.name).toLowerCase();
    var score = 0;
    if (oSeries == series) score += 10;
    if (official.year == phone.year) score += 5;
    if ((official.year - phone.year).abs() <= 1) score += 2;
    if (score > bestScore) {
      bestScore = score;
      best = official;
    }
  }
  return bestScore >= 7 ? best : null;
}

Phone _mergeFromTemplate(Phone listing, Phone template) {
  final storage = listing.memory.storage > 0 ? listing.memory.storage : template.memory.storage;
  final ram = listing.memory.ram > 0 ? listing.memory.ram : template.memory.ram;

  return Phone(
    id: listing.id,
    slug: listing.slug,
    brand: listing.brand,
    name: listing.name,
    fullName: listing.fullName,
    year: listing.year,
    releaseDate: listing.releaseDate,
    priceTRY: listing.priceTRY > 0 ? listing.priceTRY : template.priceTRY,
    popularity: listing.popularity,
    os: template.os,
    osFamily: template.osFamily,
    colors: template.colors,
    accent: template.accent,
    highlights: template.highlights,
    image: listing.image.isNotEmpty ? listing.image : template.image,
    promoImages: listing.promoImages.isNotEmpty ? listing.promoImages : template.promoImages,
    sourceUrl: template.sourceUrl,
    seedRatings: template.seedRatings,
    display: template.display,
    body: template.body,
    performance: template.performance,
    memory: MemorySpec(ram: ram, storage: storage, expandable: template.memory.expandable),
    camera: template.camera,
    battery: template.battery,
    connectivity: template.connectivity,
    audio: template.audio,
    features: template.features,
    sensors: template.sensors,
    benchmarks: template.benchmarks,
  );
}

const _slugToOfficial = {
  'iphone-16-pro-max': 'iphone-16-pro-max',
  'iphone-16-pro': 'iphone-16-pro',
  'iphone-16': 'iphone-16',
  'galaxy-s25-ultra': 'galaxy-s25-ultra',
  'galaxy-s25': 'galaxy-s25',
  'galaxy-z-fold6': 'galaxy-z-fold6',
  'galaxy-a56': 'galaxy-a56',
  'pixel-9-pro-xl': 'pixel-9-pro-xl',
  'pixel-9': 'pixel-9',
  'xiaomi-15-ultra': 'xiaomi-15-ultra',
  'xiaomi-15': 'xiaomi-15',
  'redmi-note-14-pro-plus': 'redmi-note-14-pro-plus',
  'oneplus-13': 'oneplus-13',
  'nothing-phone-3': 'nothing-phone-3',
  'honor-magic7-pro': 'honor-magic7-pro',
  'oppo-find-x8-pro': 'oppo-find-x8-pro',
  'vivo-x200-pro': 'vivo-x200-pro',
  'poco-f7-ultra': 'poco-f7-ultra',
  'huawei-pura-70-ultra': 'huawei-pura-70-ultra',
  'realme-gt-7-pro': 'realme-gt-7-pro',
  'apple-iphone-16-pro-max': 'iphone-16-pro-max',
  'apple-iphone-16-pro': 'iphone-16-pro',
  'apple-iphone-16': 'iphone-16',
  'apple-iphone-17': 'iphone-16',
  'apple-iphone-17-pro': 'iphone-16-pro',
  'apple-iphone-17-pro-max': 'iphone-16-pro-max',
};
