import '../models/phone.dart';
import 'image_resolve.dart';

List<String> promoImagesFor(Phone phone) {
  if (phone.promoImages.isNotEmpty) return resolvePromoUrls(phone.promoImages);
  if (phone.image.isNotEmpty) {
    final u = resolveProductImageUrl(phone.image);
    if (u.isNotEmpty) return [u];
  }
  return const [];
}

String? promoHeroImage(Phone phone) {
  final images = promoImagesFor(phone);
  return images.isEmpty ? null : images.first;
}

List<String> buildPromoImagesFromExtra(Map<String, dynamic>? extra) {
  if (extra == null) return const [];
  final raw = extra['promoImages'];
  if (raw is List) {
    return raw.map((e) => e.toString()).where((u) => u.isNotEmpty).toList();
  }
  final image = extra['image'] as String?;
  if (image == null || image.isEmpty) return const [];
  final primary = resolveProductImageUrl(image);
  if (primary.isEmpty) return const [];
  final urls = <String>[primary];
  if (primary.contains('width=')) {
    final wide = primary.replaceFirst(RegExp(r'width=\d+'), 'width=960');
    urls.add(wide);
  }
  return resolvePromoUrls(urls);
}
