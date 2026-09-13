import 'package:intl/intl.dart';

final _price = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
final _num = NumberFormat.decimalPattern('tr_TR');
final _score = NumberFormat('0.0', 'tr_TR');

String formatPrice(int value) => value == 0 ? 'Fiyat yok' : _price.format(value);
String formatNumber(num value) => _num.format(value);
String formatScore(num value) => _score.format(value);

String formatCount(int value) {
  if (value >= 1000) {
    return '${_score.format(value / 1000)} B';
  }
  return _num.format(value);
}

String boolLabel(bool value) => value ? 'Var' : 'Yok';

String formatCapacity(int? capacity, [String? note]) {
  if (capacity == null) return note ?? 'Üretici belirtmedi';
  return '${formatNumber(capacity)} mAh';
}

String formatHours(int hours, [String? note]) {
  if (hours == 0) return note ?? 'Belirtilmedi';
  return note == null ? '$hours saat' : '$hours saat · $note';
}
