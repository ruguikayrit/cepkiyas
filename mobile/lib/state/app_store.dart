import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/filters.dart';
import '../logic/hydrate.dart';
import '../logic/ratings.dart';
import '../logic/score.dart';
import '../models/phone.dart';

class AppStore extends ChangeNotifier {
  static const _compareKey = 'cepkiyas.compare.v1';
  static const _votesKey = 'cepkiyas.votes.v1';
  static const maxCompare = 4;

  List<Phone> phones = [];
  List<String> compareIds = [];
  Map<String, UserVote> votes = {};
  late ScoreEngine scores;
  late CatalogFilters filters;
  int tab = 0;

  Future<void> load() async {
    final officialRaw = await rootBundle.loadString('assets/data/phones.json');
    final listingRaw = await rootBundle.loadString('assets/data/catalog.json');
    Map<String, dynamic> overlay = {};
    try {
      overlay = jsonDecode(await rootBundle.loadString('assets/data/specs-overlay.json')) as Map<String, dynamic>;
    } catch (_) {}
    final official = (jsonDecode(officialRaw) as List)
        .map((e) => Phone.fromJson(e as Map<String, dynamic>))
        .toList();
    final officialIds = official.map((phone) => phone.id).toSet();
    final listing = (jsonDecode(listingRaw) as List)
        .map((e) => CatalogRow.fromJson(e as Map<String, dynamic>))
        .where((row) => row.officialId == null || !officialIds.contains(row.officialId))
        .map((row) => hydrateListing(row, overlay[row.id] as Map<String, dynamic>?));
    phones = [...official, ...listing];
    scores = ScoreEngine(phones);
    final maxPrice = phones.fold<int>(200000, (max, phone) => phone.priceTRY > max ? phone.priceTRY : max);
    filters = CatalogFilters(maxPrice: maxPrice);

    final prefs = await SharedPreferences.getInstance();
    compareIds = prefs.getStringList(_compareKey) ?? [];
    final votesRaw = prefs.getString(_votesKey);
    if (votesRaw != null) {
      final map = jsonDecode(votesRaw) as Map<String, dynamic>;
      votes = map.map((k, v) => MapEntry(k, UserVote.fromJson(v as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  Phone? byId(String id) {
    for (final phone in phones) {
      if (phone.id == id) return phone;
    }
    return null;
  }

  List<Phone> get compared => [
        for (final id in compareIds)
          if (byId(id) != null) byId(id)!,
      ];

  bool isCompared(String id) => compareIds.contains(id);

  Future<void> toggleCompare(String id) async {
    if (compareIds.contains(id)) {
      compareIds = compareIds.where((item) => item != id).toList();
    } else if (compareIds.length >= maxCompare) {
      compareIds = [...compareIds.skip(1), id];
    } else {
      compareIds = [...compareIds, id];
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_compareKey, compareIds);
  }

  Future<void> replaceCompare(List<String> ids) async {
    compareIds = ids.take(maxCompare).toList();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_compareKey, compareIds);
  }

  Future<void> clearCompare() async {
    compareIds = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_compareKey);
  }

  MergedScore scoreOf(Phone phone) => mergedUserScore(phone, votes[phone.id]);

  Map<String, double> get averages => {
        for (final phone in phones) phone.id: scoreOf(phone).average,
      };

  Future<void> setVote(String id, UserVote vote) async {
    votes = {...votes, id: vote};
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _votesKey,
      jsonEncode(votes.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  void setFilters(CatalogFilters next) {
    filters = next;
    notifyListeners();
  }

  void goTab(int index) {
    tab = index;
    notifyListeners();
  }

  List<Phone> get filtered => filterPhones(phones, filters, scores, averages);

  List<String> get brands => {...phones.map((p) => p.brand)}.toList()..sort();

  List<int> get years => {...phones.map((p) => p.year)}.toList()..sort((a, b) => b.compareTo(a));

  int get priceMax => phones.fold<int>(200000, (max, phone) => phone.priceTRY > max ? phone.priceTRY : max);

  List<Phone> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return phones.take(8).toList();
    return phones
        .where((p) => '${p.fullName} ${p.performance.chipset} ${p.os}'.toLowerCase().contains(q))
        .take(12)
        .toList();
  }
}
