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
