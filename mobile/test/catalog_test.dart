import 'dart:convert';
import 'dart:io';

import 'package:cepkiyas_app/logic/catalog_window.dart';
import 'package:cepkiyas_app/logic/hydrate.dart';
import 'package:cepkiyas_app/logic/score.dart';
import 'package:cepkiyas_app/logic/specs.dart';
import 'package:cepkiyas_app/models/phone.dart';
import 'package:flutter_test/flutter_test.dart';

List<Phone> loadCatalog() {
  final official = (jsonDecode(File('assets/data/phones.json').readAsStringSync()) as List)
      .map((e) => Phone.fromJson(e as Map<String, dynamic>))
      .toList();
  final officialIds = official.map((phone) => phone.id).toSet();
  final listing = (jsonDecode(File('assets/data/catalog.json').readAsStringSync()) as List)
      .map((e) => CatalogRow.fromJson(e as Map<String, dynamic>))
      .where((row) => row.officialId == null || !officialIds.contains(row.officialId))
      .map(hydrateListing);
  return [...official, ...listing]
      .where(CatalogWindow.includes)
      .map(CatalogWindow.withDisplayYear)
      .toList();
}

void main() {
  test('Epey envanteri ve resmi modeller birlikte yüklenir', () {
    final phones = loadCatalog();
    expect(phones.length, greaterThan(4000));
    expect(phones.where((phone) => phone.image.isNotEmpty).length, 20);

    final engine = ScoreEngine(phones);
    for (final phone in phones.where((item) => item.image.isNotEmpty)) {
      final score = engine.technical(phone);
      expect(score, greaterThan(0));
      expect(score, lessThanOrEqualTo(100));
    }
  });

  test('kıyas satırında düşük fiyat kazanır', () {
    final phones = loadCatalog().where((phone) => phone.image.isNotEmpty).toList();
    final pair = [phones.first, phones.last];
    final priceRow = specGroups.first.rows.firstWhere((row) => row.id == 'price');
    final winners = winnersFor(pair, priceRow);
    final cheaper = pair[0].priceTRY <= pair[1].priceTRY ? pair[0].id : pair[1].id;
    expect(winners, contains(cheaper));
  });
}
