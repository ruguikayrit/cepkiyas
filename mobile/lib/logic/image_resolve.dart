/// Ürün görselleri — SVG eler; Commons URL'lerini bozmadan normalize eder.
String resolveProductImageUrl(String url) {
  if (url.isEmpty) return '';
  try {
    final lower = url.toLowerCase();
    if (lower.contains('.svg')) return '';

    if (url.contains('Special:FilePath')) {
      const marker = 'Special:FilePath/';
      final start = url.indexOf(marker);
      if (start < 0) return _https(url);

      var tail = url.substring(start + marker.length);
      var width = '960';
      final q = tail.indexOf('?');
      if (q >= 0) {
        final query = tail.substring(q + 1);
        tail = tail.substring(0, q);
        final match = RegExp(r'width=(\d+)').firstMatch(query);
        if (match != null) width = match.group(1)!;
      }
      if (tail.isEmpty) return '';
      // Dosya adını yeniden encode etme — overlay'deki haliyle kullan (Uri.parse patlamasın).
      return 'https://commons.wikimedia.org/wiki/Special:FilePath/$tail?width=$width';
    }

    return _https(url);
  } catch (_) {
    return '';
  }
}

String _https(String url) => url.replaceFirst(RegExp(r'^http://'), 'https://');

List<String> resolvePromoUrls(List<String> urls) {
  return urls.map(resolveProductImageUrl).where((u) => u.isNotEmpty).toSet().toList();
}
