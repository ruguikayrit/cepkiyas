import '../models/phone.dart';
import 'format.dart';

enum CompareDirection { higher, lower, boolean, ip, none }

class SpecRow {
  const SpecRow({
    required this.id,
    required this.label,
    required this.direction,
    required this.text,
    this.numeric,
  });

  final String id;
  final String label;
  final CompareDirection direction;
  final String Function(Phone) text;
  final double Function(Phone)? numeric;
}

class SpecGroup {
  const SpecGroup(this.id, this.label, this.rows);
  final String id;
  final String label;
  final List<SpecRow> rows;
}

String _mp(double value) => value == value.roundToDouble() ? '${value.toInt()}' : '$value';

double _ipNumeric(String rating) {
  final match = RegExp(r'IP(\d)(\d)', caseSensitive: false).firstMatch(rating);
  if (match == null) return 0;
  return double.parse(match.group(1)!) * 10 + double.parse(match.group(2)!);
}

final specGroups = <SpecGroup>[
  SpecGroup('summary', 'Özet', [
    SpecRow(id: 'os', label: 'İşletim sistemi', direction: CompareDirection.none, text: (p) => p.os),
    SpecRow(id: 'year', label: 'Çıkış yılı', direction: CompareDirection.higher, text: (p) => '${p.year}', numeric: (p) => p.year.toDouble()),
    SpecRow(id: 'price', label: 'Liste fiyatı', direction: CompareDirection.lower, text: (p) => formatPrice(p.priceTRY), numeric: (p) => p.priceTRY == 0 ? 1e12 : p.priceTRY.toDouble()),
  ]),
  SpecGroup('display', 'Ekran', [
    SpecRow(id: 'size', label: 'Boyut', direction: CompareDirection.higher, text: (p) => '${p.display.size} inç', numeric: (p) => p.display.size),
    SpecRow(id: 'type', label: 'Teknoloji', direction: CompareDirection.none, text: (p) => p.display.type),
    SpecRow(id: 'res', label: 'Çözünürlük', direction: CompareDirection.none, text: (p) => p.display.resolution),
    SpecRow(id: 'hz', label: 'Yenileme hızı', direction: CompareDirection.higher, text: (p) => '${p.display.refreshRate} Hz', numeric: (p) => p.display.refreshRate.toDouble()),
    SpecRow(id: 'nit', label: 'Tepe parlaklık', direction: CompareDirection.higher, text: (p) => '${formatNumber(p.display.brightness)} nit', numeric: (p) => p.display.brightness.toDouble()),
    SpecRow(id: 'ppi', label: 'Piksel yoğunluğu', direction: CompareDirection.higher, text: (p) => '${p.display.ppi} ppi', numeric: (p) => p.display.ppi.toDouble()),
    SpecRow(id: 'glass', label: 'Koruma', direction: CompareDirection.none, text: (p) => p.display.protection),
    SpecRow(id: 'hdr', label: 'HDR', direction: CompareDirection.boolean, text: (p) => boolLabel(p.display.hdr), numeric: (p) => p.display.hdr ? 1 : 0),
    SpecRow(id: 'aod', label: 'Always-on', direction: CompareDirection.boolean, text: (p) => boolLabel(p.display.alwaysOn), numeric: (p) => p.display.alwaysOn ? 1 : 0),
  ]),
  SpecGroup('body', 'Gövde', [
    SpecRow(id: 'dims', label: 'Ölçüler', direction: CompareDirection.none, text: (p) => '${p.body.height} × ${p.body.width} × ${p.body.thickness} mm'),
    SpecRow(id: 'thick', label: 'Kalınlık', direction: CompareDirection.lower, text: (p) => '${p.body.thickness} mm', numeric: (p) => p.body.thickness),
    SpecRow(id: 'weight', label: 'Ağırlık', direction: CompareDirection.lower, text: (p) => '${p.body.weight} g', numeric: (p) => p.body.weight.toDouble()),
    SpecRow(id: 'material', label: 'Malzeme', direction: CompareDirection.none, text: (p) => p.body.material),
    SpecRow(id: 'ip', label: 'Dayanıklılık', direction: CompareDirection.ip, text: (p) => p.body.ipRating, numeric: (p) => _ipNumeric(p.body.ipRating)),
    SpecRow(id: 'fold', label: 'Katlanır', direction: CompareDirection.none, text: (p) => boolLabel(p.body.foldable)),
  ]),
  SpecGroup('performance', 'Performans', [
    SpecRow(id: 'chip', label: 'Yonga seti', direction: CompareDirection.none, text: (p) => p.performance.chipset),
    SpecRow(id: 'cpu', label: 'İşlemci', direction: CompareDirection.none, text: (p) => p.performance.cpu),
    SpecRow(id: 'gpu', label: 'GPU', direction: CompareDirection.none, text: (p) => p.performance.gpu),
    SpecRow(id: 'nm', label: 'Üretim', direction: CompareDirection.lower, text: (p) => '${p.performance.processNm} nm', numeric: (p) => p.performance.processNm.toDouble()),
    SpecRow(id: 'antutu', label: 'AnTuTu', direction: CompareDirection.higher, text: (p) => formatNumber(p.benchmarks.antutu), numeric: (p) => p.benchmarks.antutu.toDouble()),
    SpecRow(id: 'gb1', label: 'Geekbench tek', direction: CompareDirection.higher, text: (p) => formatNumber(p.benchmarks.geekbenchSingle), numeric: (p) => p.benchmarks.geekbenchSingle.toDouble()),
    SpecRow(id: 'gb2', label: 'Geekbench çoklu', direction: CompareDirection.higher, text: (p) => formatNumber(p.benchmarks.geekbenchMulti), numeric: (p) => p.benchmarks.geekbenchMulti.toDouble()),
  ]),
  SpecGroup('memory', 'Bellek', [
    SpecRow(id: 'ram', label: 'RAM', direction: CompareDirection.higher, text: (p) => '${p.memory.ram} GB', numeric: (p) => p.memory.ram.toDouble()),
    SpecRow(id: 'storage', label: 'Depolama', direction: CompareDirection.higher, text: (p) => '${p.memory.storage} GB', numeric: (p) => p.memory.storage.toDouble()),
    SpecRow(id: 'sd', label: 'MicroSD', direction: CompareDirection.boolean, text: (p) => boolLabel(p.memory.expandable), numeric: (p) => p.memory.expandable ? 1 : 0),
  ]),
  SpecGroup('camera', 'Kamera', [
    SpecRow(id: 'main', label: 'Ana kamera', direction: CompareDirection.higher, text: (p) => '${_mp(p.camera.rear.first.mp)} MP ${p.camera.rear.first.aperture}', numeric: (p) => p.camera.rear.first.mp),
    SpecRow(id: 'lenses', label: 'Arka kurulum', direction: CompareDirection.higher, text: (p) => p.camera.rear.map((l) => '${l.name} ${_mp(l.mp)} MP').join(' · '), numeric: (p) => p.camera.rear.length.toDouble()),
    SpecRow(id: 'front', label: 'Ön kamera', direction: CompareDirection.higher, text: (p) => '${_mp(p.camera.front.mp)} MP', numeric: (p) => p.camera.front.mp),
    SpecRow(id: 'video', label: 'Video', direction: CompareDirection.none, text: (p) => p.camera.video),
    SpecRow(id: 'dxo', label: 'DxOMark', direction: CompareDirection.higher, text: (p) => p.camera.dxomark?.toString() ?? '—', numeric: (p) => (p.camera.dxomark ?? 0).toDouble()),
  ]),
  SpecGroup('battery', 'Batarya', [
    SpecRow(id: 'cap', label: 'Kapasite', direction: CompareDirection.higher, text: (p) => formatCapacity(p.battery.capacity, p.battery.capacityNote), numeric: (p) => (p.battery.capacity ?? 0).toDouble()),
    SpecRow(id: 'wired', label: 'Kablolu şarj', direction: CompareDirection.higher, text: (p) => '${p.battery.wiredWatt} W', numeric: (p) => p.battery.wiredWatt.toDouble()),
    SpecRow(id: 'wireless', label: 'Kablosuz şarj', direction: CompareDirection.higher, text: (p) => p.battery.wirelessWatt == 0 ? 'Yok' : '${p.battery.wirelessWatt} W', numeric: (p) => p.battery.wirelessWatt.toDouble()),
    SpecRow(id: 'reverse', label: 'Ters şarj', direction: CompareDirection.boolean, text: (p) => boolLabel(p.battery.reverse), numeric: (p) => p.battery.reverse ? 1 : 0),
    SpecRow(id: 'hours', label: 'Kullanım süresi', direction: CompareDirection.higher, text: (p) => formatHours(p.battery.estimatedHours, p.battery.hoursNote), numeric: (p) => p.battery.estimatedHours.toDouble()),
  ]),
  SpecGroup('connect', 'Bağlantı', [
    SpecRow(id: '5g', label: '5G', direction: CompareDirection.boolean, text: (p) => boolLabel(p.connectivity.network5g), numeric: (p) => p.connectivity.network5g ? 1 : 0),
    SpecRow(id: 'wifi', label: 'Wi-Fi', direction: CompareDirection.none, text: (p) => p.connectivity.wifi),
    SpecRow(id: 'bt', label: 'Bluetooth', direction: CompareDirection.none, text: (p) => p.connectivity.bluetooth),
    SpecRow(id: 'nfc', label: 'NFC', direction: CompareDirection.boolean, text: (p) => boolLabel(p.connectivity.nfc), numeric: (p) => p.connectivity.nfc ? 1 : 0),
    SpecRow(id: 'usb', label: 'USB', direction: CompareDirection.none, text: (p) => p.connectivity.usb),
    SpecRow(id: 'sim', label: 'SIM', direction: CompareDirection.none, text: (p) => p.connectivity.sim),
    SpecRow(id: 'esim', label: 'eSIM', direction: CompareDirection.boolean, text: (p) => boolLabel(p.connectivity.esim), numeric: (p) => p.connectivity.esim ? 1 : 0),
  ]),
  SpecGroup('other', 'Diğer', [
    SpecRow(id: 'speakers', label: 'Hoparlör', direction: CompareDirection.none, text: (p) => p.audio.speakers),
    SpecRow(id: 'jack', label: '3.5 mm jack', direction: CompareDirection.boolean, text: (p) => boolLabel(p.audio.jack), numeric: (p) => p.audio.jack ? 1 : 0),
    SpecRow(id: 'fp', label: 'Parmak izi', direction: CompareDirection.none, text: (p) => p.features.fingerprint),
    SpecRow(id: 'face', label: 'Yüz tanıma', direction: CompareDirection.boolean, text: (p) => boolLabel(p.features.faceUnlock), numeric: (p) => p.features.faceUnlock ? 1 : 0),
    SpecRow(id: 'pen', label: 'Kalem', direction: CompareDirection.boolean, text: (p) => boolLabel(p.features.stylus), numeric: (p) => p.features.stylus ? 1 : 0),
  ]),
];

List<String> winnersFor(List<Phone> phones, SpecRow row) {
  if (row.direction == CompareDirection.none || phones.length < 2 || row.numeric == null) {
    return const [];
  }
  final values = phones.map(row.numeric!).toList();
  if (values.every((v) => v == values.first)) return const [];
  final target = row.direction == CompareDirection.lower
      ? values.reduce((a, b) => a < b ? a : b)
      : values.reduce((a, b) => a > b ? a : b);
  return [
    for (var i = 0; i < phones.length; i++)
      if (values[i] == target) phones[i].id,
  ];
}

bool rowHasDifference(List<Phone> phones, SpecRow row) {
  return phones.map(row.text).toSet().length > 1;
}
