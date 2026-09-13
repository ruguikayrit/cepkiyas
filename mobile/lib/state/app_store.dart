import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/catalog_grouping.dart';
import '../logic/catalog_window.dart';
import '../logic/official_inherit.dart';
import '../logic/filters.dart';
import '../logic/hydrate.dart';
import '../logic/ratings.dart';
import '../logic/score.dart';
import '../models/phone.dart';
import '../models/user_account.dart';

class AppStore extends ChangeNotifier {
  static const _compareKey = 'cepkiyas.compare.v1';
  static const _favoritesKey = 'cepkiyas.favorites.v1';
  static const _votesKey = 'cepkiyas.votes.v1';
  static const _sessionKey = 'cepkiyas.session.v1';
  static const _usersKey = 'cepkiyas.users.v1';
  static const maxCompare = 4;

  List<Phone> phones = [];
  List<BrandGroup> brandIndex = [];
  List<String> compareIds = [];
  List<String> favoriteIds = [];
  Map<String, UserVote> votes = {};
  UserAccount? session;
  Map<String, Map<String, dynamic>> _users = {};
  late ScoreEngine scores;
  late CatalogFilters filters;
  int tab = 0;

  bool get isSignedIn => session != null;

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
    final officialsById = {for (final p in official) p.id: p};
    final officialIds = officialsById.keys.toSet();
    final listing = (jsonDecode(listingRaw) as List)
        .map((e) => CatalogRow.fromJson(e as Map<String, dynamic>))
        .where((row) => row.officialId == null || !officialIds.contains(row.officialId))
        .map((row) => hydrateListing(row, overlay[row.id] as Map<String, dynamic>?));
    phones = [...official, ...listing]
        .map((p) {
          try {
            return applyOfficialInheritance(p, officialsById);
          } catch (_) {
            return p;
          }
        })
        .where(CatalogWindow.includes)
        .map(CatalogWindow.withDisplayYear)
        .toList();
    brandIndex = buildBrandIndex(phones);
    scores = ScoreEngine(phones);
    final maxPrice = phones.fold<int>(200000, (max, phone) => phone.priceTRY > max ? phone.priceTRY : max);
    filters = CatalogFilters(maxPrice: maxPrice);

    final prefs = await SharedPreferences.getInstance();
    compareIds = prefs.getStringList(_compareKey) ?? [];
    favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    final votesRaw = prefs.getString(_votesKey);
    if (votesRaw != null) {
      final map = jsonDecode(votesRaw) as Map<String, dynamic>;
      votes = map.map((k, v) => MapEntry(k, UserVote.fromJson(v as Map<String, dynamic>)));
    }
    final usersRaw = prefs.getString(_usersKey);
    if (usersRaw != null) {
      final map = jsonDecode(usersRaw) as Map<String, dynamic>;
      _users = map.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
    }
    final sessionEmail = prefs.getString(_sessionKey);
    if (sessionEmail != null && _users.containsKey(sessionEmail)) {
      final profile = _users[sessionEmail]!;
      session = UserAccount(
        email: sessionEmail,
        name: profile['name'] as String? ?? '',
        phone: profile['phone'] as String? ?? '',
      );
    }
    notifyListeners();
  }

  String _normEmail(String email) => email.trim().toLowerCase();

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirm,
  }) async {
    final mail = _normEmail(email);
    if (name.trim().length < 2) return 'Ad soyad girin.';
    if (!mail.contains('@') || !mail.contains('.')) return 'Geçerli bir e-posta girin.';
    if (password.length < 6) return 'Şifre en az 6 karakter olmalı.';
    if (password != confirm) return 'Şifreler eşleşmiyor.';
    if (_users.containsKey(mail)) return 'Bu e-posta ile kayıt zaten var.';
    _users = {
      ..._users,
      mail: {
        'name': name.trim(),
        'phone': phone.trim(),
        'password': password,
      },
    };
    session = UserAccount(email: mail, name: name.trim(), phone: phone.trim());
    await _persistAuth();
    notifyListeners();
    return null;
  }

  Future<String?> signIn({required String email, required String password}) async {
    final mail = _normEmail(email);
    final user = _users[mail];
    if (user == null) return 'E-posta veya şifre hatalı.';
    if (user['password'] != password) return 'E-posta veya şifre hatalı.';
    session = UserAccount(
      email: mail,
      name: user['name'] as String? ?? '',
      phone: user['phone'] as String? ?? '',
    );
    await _persistAuth();
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  Future<String?> changePassword({
    required String current,
    required String next,
    required String confirm,
  }) async {
    final mail = session?.email;
    if (mail == null) return 'Oturum açık değil.';
    final user = _users[mail];
    if (user == null || user['password'] != current) return 'Mevcut şifre hatalı.';
    if (next.length < 6) return 'Yeni şifre en az 6 karakter olmalı.';
    if (next != confirm) return 'Yeni şifreler eşleşmiyor.';
    _users = {
      ..._users,
      mail: {...user, 'password': next},
    };
    await _persistAuth();
    notifyListeners();
    return null;
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final mail = session?.email;
    if (mail == null) return;
    final user = _users[mail];
    if (user == null) return;
    _users = {
      ..._users,
      mail: {...user, 'name': name.trim(), 'phone': phone.trim()},
    };
    session = session!.copyWith(name: name.trim(), phone: phone.trim());
    await _persistAuth();
    notifyListeners();
  }

  Future<void> _persistAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(_users));
    if (session != null) {
      await prefs.setString(_sessionKey, session!.email);
    }
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

  bool isFavorite(String id) => favoriteIds.contains(id);

  List<Phone> get favorites => [
        for (final id in favoriteIds)
          if (byId(id) != null) byId(id)!,
      ];

  Future<void> toggleFavorite(String id) async {
    if (favoriteIds.contains(id)) {
      favoriteIds = favoriteIds.where((item) => item != id).toList();
    } else {
      favoriteIds = [...favoriteIds, id];
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

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

  void resetFilters() {
    filters = CatalogFilters(maxPrice: priceMax);
    notifyListeners();
  }

  List<String> matchingBrands(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return brands.where((brand) => brand.toLowerCase().contains(q)).take(6).toList();
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
        .where((p) => '${p.fullName} ${p.brand} ${p.performance.chipset} ${p.os}'.toLowerCase().contains(q))
        .take(12)
        .toList();
  }

  int searchCount(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return phones.length;
    return phones
        .where((p) => '${p.fullName} ${p.brand} ${p.performance.chipset} ${p.os}'.toLowerCase().contains(q))
        .length;
  }
}
