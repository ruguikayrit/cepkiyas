import '../models/phone.dart';

class SeriesGroup {
  SeriesGroup({required this.series, required this.models});
  final String series;
  final List<Phone> models;
  int get count => models.length;
}

class BrandGroup {
  BrandGroup({required this.brand, required this.series});
  final String brand;
  final List<SeriesGroup> series;
  int get count => series.fold(0, (sum, item) => sum + item.count);
}

String normalizeModelName(String name) {
  return name
      .replaceAll(RegExp(r'\s+\d+\s*(gb|tb)$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+(5g|4g|lte|wifi|wi-fi)$', caseSensitive: false), '')
      .trim();
}

String seriesGroupKey(String name) {
  var base = normalizeModelName(name);
  final patterns = [
    RegExp(r'\s+Pro Max$', caseSensitive: false),
    RegExp(r'\s+Pro Plus$', caseSensitive: false),
    RegExp(r'\s+Ultra$', caseSensitive: false),
    RegExp(r'\s+Pro$', caseSensitive: false),
    RegExp(r'\s+Plus$', caseSensitive: false),
    RegExp(r'\s+FE$', caseSensitive: false),
    RegExp(r'\s+Edge$', caseSensitive: false),
    RegExp(r'\s+Lite$', caseSensitive: false),
    RegExp(r'\s+Max$', caseSensitive: false),
    RegExp(r'\s+Mini$', caseSensitive: false),
    RegExp(r'\s+SE$', caseSensitive: false),
    RegExp(r'\s+e$', caseSensitive: false),
  ];
  for (final pattern in patterns) {
    if (pattern.hasMatch(base)) {
      base = base.replaceFirst(pattern, '').trim();
      break;
    }
  }
  return base.isEmpty ? normalizeModelName(name) : base;
}

String brandIndexLetter(String brand) {
  if (brand.isEmpty) return '#';
  final first = brand[0].toUpperCase();
  final code = first.codeUnitAt(0);
  if (code >= 65 && code <= 90) return first;
  if (first == 'İ') return 'I';
  if (first == 'Ş') return 'S';
  if (first == 'Ç') return 'C';
  if (first == 'Ö') return 'O';
  if (first == 'Ü') return 'U';
  if (first == 'Ğ') return 'G';
  return '#';
}

/// A–Z bölüm başlıkları altında marka listesi (Epey marka dizini mantığı).
List<(String letter, List<BrandGroup> brands)> buildBrandSections(List<BrandGroup> index) {
  final map = <String, List<BrandGroup>>{};
  for (final group in index) {
    final letter = brandIndexLetter(group.brand);
    map.putIfAbsent(letter, () => []).add(group);
  }
  final letters = map.keys.toList()
    ..sort((a, b) {
      if (a == '#') return 1;
      if (b == '#') return -1;
      return a.compareTo(b);
    });
  return [for (final letter in letters) (letter, map[letter]!)];
}

List<BrandGroup> filterBrandIndex(List<BrandGroup> index, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return index;
  final out = <BrandGroup>[];
  for (final group in index) {
    if (group.brand.toLowerCase().contains(q)) {
      out.add(group);
      continue;
    }
    final seriesHits = <SeriesGroup>[];
    for (final series in group.series) {
      final models = series.models.where((p) {
        return p.name.toLowerCase().contains(q) || series.series.toLowerCase().contains(q);
      }).toList();
      if (models.isNotEmpty) {
        seriesHits.add(SeriesGroup(series: series.series, models: models));
      }
    }
    if (seriesHits.isNotEmpty) {
      out.add(BrandGroup(brand: group.brand, series: seriesHits));
    }
  }
  return out;
}

List<BrandGroup> buildBrandIndex(List<Phone> list) {
  final byBrand = <String, Map<String, List<Phone>>>{};
  for (final phone in list) {
    byBrand.putIfAbsent(phone.brand, () => {});
    final key = seriesGroupKey(phone.name);
    byBrand[phone.brand]!.putIfAbsent(key, () => []).add(phone);
  }

  final brands = byBrand.keys.toList()..sort((a, b) => a.compareTo(b));
  return [
    for (final brand in brands)
      BrandGroup(
        brand: brand,
        series: () {
          final seriesList = [
            for (final entry in byBrand[brand]!.entries)
              SeriesGroup(
                series: entry.key,
                models: (entry.value.toList()
                  ..sort((a, b) {
                    final year = b.year.compareTo(a.year);
                    if (year != 0) return year;
                    return a.name.compareTo(b.name);
                  })),
              ),
          ];
          seriesList.sort((a, b) {
            final year = b.models.first.year.compareTo(a.models.first.year);
            if (year != 0) return year;
            return a.series.compareTo(b.series);
          });
          return seriesList;
        }(),
      ),
  ];
}
