/// Ürün görselleri — SVG ve kırık Commons URL'lerini eler / düzeltir.
String resolveProductImageUrl(String url) {
  if (url.isEmpty) return '';
  final lower = url.toLowerCase();
  if (lower.contains('.svg')) return '';

  if (url.contains('Special:FilePath')) {
    final uri = Uri.parse(url);
    final file = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    if (file.isEmpty) return '';
    final width = uri.queryParameters['width'] ?? '960';
    return 'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(Uri.decodeComponent(file))}?width=$width';
  }

  return url.replaceFirst('http://', 'https://');
}

List<String> resolvePromoUrls(List<String> urls) {
  return urls.map(resolveProductImageUrl).where((u) => u.isNotEmpty).toSet().toList();
}
