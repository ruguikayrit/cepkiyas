import '../models/phone.dart';

const ratingCategories = [
  ('overall', 'Genel'),
  ('camera', 'Kamera'),
  ('performance', 'Performans'),
  ('battery', 'Batarya'),
  ('display', 'Ekran'),
  ('design', 'Tasarım'),
];

class MergedScore {
  const MergedScore({
    required this.average,
    required this.count,
    required this.breakdown,
    this.mine,
  });

  final double average;
  final int count;
  final Map<String, double> breakdown;
  final UserVote? mine;
}

MergedScore mergedUserScore(Phone phone, UserVote? vote) {
  final extra = vote != null && vote.overall > 0 ? vote.overall : 0;
  final extraCount = extra > 0 ? 1 : 0;
  final count = phone.seedRatings.count + extraCount;
  final average = (phone.seedRatings.average * phone.seedRatings.count + extra) / count;
  return MergedScore(
    average: (average * 10).round() / 10,
    count: count,
    breakdown: {
      'camera': _blend(phone.seedRatings.camera, vote?.camera),
      'performance': _blend(phone.seedRatings.performance, vote?.performance),
      'battery': _blend(phone.seedRatings.battery, vote?.battery),
      'display': _blend(phone.seedRatings.display, vote?.display),
      'design': _blend(phone.seedRatings.design, vote?.design),
    },
    mine: vote,
  );
}

double _blend(double seed, int? mine) {
  if (mine == null || mine == 0) return seed;
  return ((seed * 12 + mine) / 13 * 10).round() / 10;
}
