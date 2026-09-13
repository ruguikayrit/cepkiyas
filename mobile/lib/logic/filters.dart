import '../models/phone.dart';
import 'score.dart';

enum SortKey { smart, technical, user, priceAsc, priceDesc, newest, popular, name }

class CatalogFilters {
  CatalogFilters({
    this.query = '',
    List<String>? brands,
    List<int>? years,
    List<String>? os,
    this.minPrice = 0,
    required this.maxPrice,
    this.minRam = 0,
    this.minStorage = 0,
    this.only5g = false,
    this.foldable = false,
    this.sort = SortKey.smart,
  })  : brands = brands ?? [],
        years = years ?? [],
        os = os ?? [];

  String query;
  List<String> brands;
  List<int> years;
  List<String> os;
  int minPrice;
  int maxPrice;
  int minRam;
  int minStorage;
  bool only5g;
  bool foldable;
  SortKey sort;

  bool isActive(int priceMax) =>
      query.trim().isNotEmpty ||
      brands.isNotEmpty ||
      years.isNotEmpty ||
      os.isNotEmpty ||
      minPrice > 0 ||
      maxPrice < priceMax ||
      minRam > 0 ||
      minStorage > 0 ||
      only5g ||
      foldable;

  List<({String id, String label})> chips(int priceMax) {
    final items = <({String id, String label})>[];
    if (query.trim().isNotEmpty) items.add((id: 'q', label: '"${query.trim()}"'));
    for (final brand in brands) {
      items.add((id: 'brand-$brand', label: brand));
    }
    for (final year in years) {
      items.add((id: 'year-$year', label: '$year'));
    }
    for (final item in os) {
      items.add((id: 'os-$item', label: item));
    }
    if (minPrice > 0 || maxPrice < priceMax) {
      items.add((id: 'price', label: '$minPrice – $maxPrice ₺'));
    }
    if (minRam > 0) items.add((id: 'ram', label: '$minRam GB+ RAM'));
    if (minStorage > 0) items.add((id: 'storage', label: '$minStorage GB+'));
    if (only5g) items.add((id: '5g', label: '5G'));
    if (foldable) items.add((id: 'fold', label: 'Katlanır'));
    return items;
  }

  CatalogFilters withoutChip(String id, int priceMax) {
    final next = copy();
    if (id == 'q') next.query = '';
    if (id.startsWith('brand-')) next.brands.remove(id.substring(6));
    if (id.startsWith('year-')) {
      final year = int.tryParse(id.substring(5));
      if (year != null) next.years.remove(year);
    }
    if (id.startsWith('os-')) next.os.remove(id.substring(3));
    if (id == 'price') {
      next.minPrice = 0;
      next.maxPrice = priceMax;
    }
    if (id == 'ram') next.minRam = 0;
    if (id == 'storage') next.minStorage = 0;
    if (id == '5g') next.only5g = false;
    if (id == 'fold') next.foldable = false;
    return next;
  }

  CatalogFilters copy() => CatalogFilters(
        query: query,
        brands: [...brands],
        years: [...years],
        os: [...os],
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRam: minRam,
        minStorage: minStorage,
        only5g: only5g,
        foldable: foldable,
        sort: sort,
      );
}

const sortLabels = {
  SortKey.smart: 'Akıllı sıralama',
  SortKey.technical: 'Teknik puan',
  SortKey.user: 'Kullanıcı puanı',
  SortKey.priceAsc: 'En düşük fiyat',
  SortKey.priceDesc: 'En yüksek fiyat',
  SortKey.newest: 'Yeniden eskiye',
  SortKey.popular: 'Popülerlik',
  SortKey.name: 'Ada göre',
};

List<Phone> filterPhones(
  List<Phone> list,
  CatalogFilters filters,
  ScoreEngine scores,
  Map<String, double> userAverages,
) {
  final q = filters.query.trim().toLowerCase();
  final filtered = list.where((phone) {
    final hay = '${phone.fullName} ${phone.performance.chipset} ${phone.os}'.toLowerCase();
    if (q.isNotEmpty && !hay.contains(q)) return false;
    if (filters.brands.isNotEmpty && !filters.brands.contains(phone.brand)) return false;
    if (filters.years.isNotEmpty && !filters.years.contains(phone.year)) return false;
    if (filters.os.isNotEmpty && !filters.os.contains(phone.osFamily)) return false;
    if (phone.priceTRY > 0 && (phone.priceTRY < filters.minPrice || phone.priceTRY > filters.maxPrice)) {
      return false;
    }
    if (filters.minRam > 0 && phone.memory.ram > 0 && phone.memory.ram < filters.minRam) return false;
    if (filters.minStorage > 0 && phone.memory.storage > 0 && phone.memory.storage < filters.minStorage) {
      return false;
    }
    if (filters.only5g && !phone.connectivity.network5g) return false;
    if (filters.foldable && !phone.body.foldable) return false;
    return true;
  }).toList();

  filtered.sort((a, b) {
    switch (filters.sort) {
      case SortKey.technical:
        return scores.technical(b).compareTo(scores.technical(a));
      case SortKey.user:
        return (userAverages[b.id] ?? 0).compareTo(userAverages[a.id] ?? 0);
      case SortKey.priceAsc:
        final left = a.priceTRY == 0 ? 1 << 30 : a.priceTRY;
        final right = b.priceTRY == 0 ? 1 << 30 : b.priceTRY;
        return left.compareTo(right);
      case SortKey.priceDesc:
        return b.priceTRY.compareTo(a.priceTRY);
      case SortKey.newest:
        return b.releaseDate.compareTo(a.releaseDate);
      case SortKey.popular:
        return b.popularity.compareTo(a.popularity);
      case SortKey.name:
        return a.fullName.compareTo(b.fullName);
      case SortKey.smart:
        return scores
            .smart(b, userAverages[b.id] ?? b.seedRatings.average)
            .compareTo(scores.smart(a, userAverages[a.id] ?? a.seedRatings.average));
    }
  });
  return filtered;
}
