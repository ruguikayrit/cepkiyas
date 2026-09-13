import '../models/phone.dart';

List<String> promoImagesFor(Phone phone) {
  if (phone.promoImages.isNotEmpty) return phone.promoImages;
  if (phone.image.isNotEmpty) return [phone.image];
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
  final urls = <String>[image];
  if (image.contains('width=')) {
    urls.add(image.replaceFirst(RegExp(r'width=\d+'), 'width=960'));
  }
  return urls.toSet().toList();
}
