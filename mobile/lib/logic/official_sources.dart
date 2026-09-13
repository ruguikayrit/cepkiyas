/// Marka resmi teknik sayfa kökleri (özellik kaynağı bağlantısı).
String officialBrandSpecsUrl(String brand, {String? slug}) {
  final b = brand.toLowerCase();
  final s = (slug ?? '').toLowerCase();

  if (b == 'apple' || s.contains('iphone')) {
    if (s.contains('iphone-17') || s.contains('iphone-16')) return 'https://www.apple.com/iphone/';
    return 'https://www.apple.com/iphone/specs/';
  }
  if (b == 'samsung' || s.contains('galaxy')) {
    return 'https://www.samsung.com/us/smartphones/all-smartphones/';
  }
  if (b == 'google' || s.contains('pixel')) {
    return 'https://store.google.com/product/pixel_phone_specs';
  }
  if (b == 'xiaomi' || b == 'poco' || s.contains('redmi')) {
    return 'https://www.mi.com/global/product/';
  }
  if (b == 'oneplus') return 'https://www.oneplus.com/global/phones';
  if (b == 'honor') return 'https://www.honor.com/global/phones/';
  if (b == 'oppo') return 'https://www.oppo.com/en/smartphones/';
  if (b == 'vivo') return 'https://www.vivo.com/en/products';
  if (b == 'realme') return 'https://www.realme.com/global/phones';
  if (b == 'motorola') return 'https://www.motorola.com/us/en/smartphones';
  if (b == 'nothing') return 'https://nothing.tech/phone';
  if (b == 'huawei') return 'https://consumer.huawei.com/en/phones/';
  return '';
}

String preferOfficialSourceUrl({
  required String brand,
  required String slug,
  required String current,
}) {
  final official = officialBrandSpecsUrl(brand, slug: slug);
  if (official.isEmpty) return current;
  if (current.contains('epey.com')) return official;
  if (current.isEmpty) return official;
  return current;
}
