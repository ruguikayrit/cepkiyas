import 'dart:convert';
import 'dart:io';

import 'package:cepkiyas_app/logic/image_resolve.dart';

void main() {
  final overlay = jsonDecode(File('assets/data/specs-overlay.json').readAsStringSync()) as Map;
  var n = 0;
  for (final v in overlay.values) {
    if (v is! Map) continue;
    final img = v['image']?.toString() ?? '';
    if (img.isEmpty) continue;
    n++;
    try {
      resolveProductImageUrl(img);
    } catch (e) {
      stdout.writeln('FAIL: $e\n  $img');
    }
  }
  stdout.writeln('tested $n');
}
