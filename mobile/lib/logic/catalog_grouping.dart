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
