import '../models/phone.dart';

class _Range {
  const _Range(this.min, this.max);
  final double min;
  final double max;
}

class ScoreEngine {
  ScoreEngine(this.phones) : _catalog = _Catalog.from(phones);

  final List<Phone> phones;
  final _Catalog _catalog;

  double technical(Phone phone) {
    final performance = _norm(phone.benchmarks.antutu.toDouble(), _catalog.antutu) * 0.65 +
        _norm(phone.benchmarks.geekbenchMulti.toDouble(), _catalog.geek) * 0.35;
    final camera = _norm(_cameraRaw(phone), _catalog.camera);
    final display = _norm(_displayRaw(phone), _catalog.display);
    final battery = _norm(_batteryRaw(phone), _catalog.battery);
    final memory = _norm(_memoryRaw(phone), _catalog.memory);
    final body = _norm(_bodyRaw(phone), _catalog.body);
    final extras = _featureRaw(phone);
    final total = performance * 0.22 +
        camera * 0.18 +
        display * 0.14 +
        battery * 0.16 +
        memory * 0.1 +
        body * 0.08 +
        extras * 0.12;
    return _round1(total);
  }

  Map<String, double> categories(Phone phone) => {
        'performans': _round1(_norm(phone.benchmarks.antutu.toDouble(), _catalog.antutu)),
        'kamera': _round1(_norm(_cameraRaw(phone), _catalog.camera)),
        'ekran': _round1(_norm(_displayRaw(phone), _catalog.display)),
        'batarya': _round1(_norm(_batteryRaw(phone), _catalog.battery)),
        'bellek': _round1(_norm(_memoryRaw(phone), _catalog.memory)),
      };

  double recency(Phone phone) {
    final age = DateTime.now().difference(phone.releaseDate).inDays.toDouble();
    return _clamp(100 - age / 8);
  }

  double smart(Phone phone, double userAverage) =>
      phone.popularity * 0.38 +
      technical(phone) * 0.32 +
      userAverage * 10 * 0.18 +
      recency(phone) * 0.12;

  double index(double technicalScore, double userAverage) =>
      _round1(technicalScore * 0.55 + userAverage * 10 * 0.45);
}

class _Catalog {
  _Catalog({
    required this.antutu,
    required this.geek,
    required this.camera,
    required this.display,
    required this.battery,
    required this.memory,
    required this.body,
  });

  final _Range antutu;
  final _Range geek;
  final _Range camera;
  final _Range display;
  final _Range battery;
  final _Range memory;
  final _Range body;

  factory _Catalog.from(List<Phone> phones) {
    final scored = phones.where((phone) => phone.image.isNotEmpty).toList();
    final base = scored.isNotEmpty ? scored : phones;
    return _Catalog(
      antutu: _range(base.map((p) => p.benchmarks.antutu.toDouble())),
      geek: _range(base.map((p) => p.benchmarks.geekbenchMulti.toDouble())),
      camera: _range(base.map(_cameraRaw)),
      display: _range(base.map(_displayRaw)),
      battery: _range(base.map(_batteryRaw)),
      memory: _range(base.map(_memoryRaw)),
      body: _range(base.map(_bodyRaw)),
    );
  }
}

double _cameraRaw(Phone p) {
  final rear = p.camera.rear.fold<double>(0, (s, l) => s + l.mp);
  final dxo = p.camera.dxomark ?? (rear > 0 ? 118 : 0);
  return dxo * 2 + rear;
}

double _displayRaw(Phone p) =>
    p.display.size * 8 + p.display.refreshRate * 0.25 + p.display.brightness / 80 + p.display.ppi / 12;

double _batteryRaw(Phone p) {
  final capacity = p.battery.capacity ?? p.battery.estimatedHours * 155;
  return capacity + p.battery.wiredWatt * 8 + p.battery.estimatedHours * 40;
}

double _memoryRaw(Phone p) => p.memory.ram * 18 + p.memory.storage * 0.08;

double _bodyRaw(Phone p) {
  final weight = p.body.weight == 0 ? 200 : p.body.weight;
  final thickness = p.body.thickness == 0 ? 8.2 : p.body.thickness;
  return _ipRank(p.body.ipRating) * 2 + (280 - weight) + (12 - thickness) * 8;
}

double _featureRaw(Phone p) {
  var score = 40.0;
  if (p.connectivity.network5g) score += 10;
  if (p.connectivity.nfc) score += 6;
  if (p.connectivity.esim) score += 5;
  if (p.battery.wirelessWatt > 0) score += 8;
  if (p.battery.reverse) score += 4;
  if (p.audio.dolby) score += 4;
  if (p.features.stylus) score += 6;
  if (p.features.faceUnlock) score += 4;
  if (p.display.alwaysOn) score += 4;
  if (p.display.hdr) score += 4;
  if (p.connectivity.wifi.contains('7')) score += 5;
  return _clamp(score);
}

int _ipRank(String rating) {
  final match = RegExp(r'IP(\d)(\d)', caseSensitive: false).firstMatch(rating);
  if (match == null) return 0;
  return int.parse(match.group(1)!) * 10 + int.parse(match.group(2)!);
}

_Range _range(Iterable<double> values) {
  final list = values.toList();
  return _Range(list.reduce((a, b) => a < b ? a : b), list.reduce((a, b) => a > b ? a : b));
}

double _norm(double value, _Range range) {
  if (range.max == range.min) return 70;
  return _clamp(((value - range.min) / (range.max - range.min)) * 100);
}

double _clamp(double value) => value.clamp(0, 100);

double _round1(double value) => (value * 10).round() / 10;
