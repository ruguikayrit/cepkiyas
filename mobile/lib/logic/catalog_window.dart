import '../models/phone.dart';

/// Katalog yalnızca son on yılın marka ve modellerini kapsar.
abstract final class CatalogWindow {
  static const minYear = 2016;
  static const maxYear = 2026;
  static const label = '2016–2026';

  static int normalizeYear(int year) {
    if (year >= 100 && year < 1000) return 2000 + year;
    return year;
  }

  static int? inferFromSlug(String slug) {
    final years = RegExp(r'(20(?:1[6-9]|2[0-6]))')
        .allMatches(slug)
        .map((m) => int.parse(m.group(1)!))
        .toList();
    if (years.isNotEmpty) return years.last;

    final s = slug.toLowerCase();
    const needles = <String, int>{
      'iphone-17': 2025,
      'iphone-16': 2024,
      'iphone-15': 2023,
      'iphone-14': 2022,
      'iphone-13': 2021,
      'iphone-12': 2020,
      'iphone-11': 2019,
      'iphone-xr': 2018,
      'iphone-xs': 2018,
      'iphone-x': 2017,
      'iphone-se-2022': 2022,
      'iphone-se-2020': 2020,
      'galaxy-s26': 2026,
      'galaxy-s25': 2025,
      'galaxy-s24': 2024,
      'galaxy-s23': 2023,
      'galaxy-s22': 2022,
      'galaxy-s21': 2021,
      'galaxy-s20': 2020,
      'galaxy-note-20': 2020,
      'galaxy-note-10': 2019,
      'pixel-9': 2024,
      'pixel-8': 2023,
      'pixel-7': 2022,
      'pixel-6': 2021,
      'redmi-note-14': 2024,
      'redmi-note-13': 2023,
    };
    for (final entry in needles.entries) {
      if (s.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static bool isLegacySlug(String slug) {
    final s = slug.toLowerCase();
    if (RegExp(r'iphone-[3-8](?![0-9])').hasMatch(s)) return true;
    if (RegExp(r'galaxy-s[1-9](?![0-9])').hasMatch(s)) return true;
    if (RegExp(r'galaxy-note-[1-9](?![0-9])').hasMatch(s)) return true;
    if (RegExp(r'pixel-[1-5](?![0-9])').hasMatch(s)) return true;
    return false;
  }

  static int effectiveYear(Phone phone) {
    final normalized = normalizeYear(phone.year);
    if (normalized >= minYear && normalized <= maxYear) return normalized;
    final inferred = inferFromSlug(phone.slug);
    if (inferred != null) return inferred;
    return normalized;
  }

  static bool includes(Phone phone) {
    final year = effectiveYear(phone);
    if (year < minYear || year > maxYear) return false;
    if (isLegacySlug(phone.slug) && !RegExp(r'20(?:1[6-9]|2[0-6])').hasMatch(phone.slug)) {
      return false;
    }
    return true;
  }

  static Phone withDisplayYear(Phone phone) {
    final year = effectiveYear(phone);
    if (year == phone.year) return phone;
    return phone.copyWith(year: year);
  }
}
