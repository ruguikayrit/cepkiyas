import '../models/phone.dart';

class CatalogRow {
  const CatalogRow({
    required this.id,
    required this.slug,
    required this.brand,
    required this.name,
    required this.fullName,
    required this.year,
    required this.priceTRY,
    required this.popularity,
    required this.os,
    required this.osFamily,
    required this.accent,
    required this.sourceUrl,
    this.officialId,
    required this.ram,
    required this.storage,
    required this.foldable,
    required this.network5g,
  });

  final String id;
  final String slug;
  final String brand;
  final String name;
  final String fullName;
  final int year;
  final int priceTRY;
  final int popularity;
  final String os;
  final String osFamily;
  final String accent;
  final String sourceUrl;
  final String? officialId;
  final int ram;
  final int storage;
  final bool foldable;
  final bool network5g;

  factory CatalogRow.fromJson(Map<String, dynamic> json) => CatalogRow(
        id: json['id'] as String,
        slug: json['slug'] as String,
        brand: json['brand'] as String,
        name: json['name'] as String,
        fullName: json['fullName'] as String,
        year: json['year'] as int,
        priceTRY: json['priceTRY'] as int,
        popularity: json['popularity'] as int,
        os: json['os'] as String,
        osFamily: json['osFamily'] as String,
        accent: json['accent'] as String,
        sourceUrl: json['sourceUrl'] as String,
        officialId: json['officialId'] as String?,
        ram: json['ram'] as int,
        storage: json['storage'] as int,
        foldable: json['foldable'] as bool,
        network5g: json['network5g'] as bool,
      );
}

Phone hydrateListing(CatalogRow row, [Map<String, dynamic>? extra]) {
  extra ??= const {};
  final ram = (extra['ram'] as num?)?.toInt() ?? row.ram;
  final storage = (extra['storage'] as num?)?.toInt() ?? row.storage;
  final chipset = extra['chipset'] as String?;
  final displaySize = (extra['displaySize'] as num?)?.toDouble() ?? 0;
  final capacity = (extra['capacity'] as num?)?.toInt();
  final highlights = [
    if (chipset != null && chipset.isNotEmpty) chipset,
    if (displaySize > 0) '${displaySize}"',
    if (capacity != null) '$capacity mAh',
  ];
  return Phone(
    id: row.id,
    slug: row.slug,
    brand: row.brand,
    name: row.name,
    fullName: row.fullName,
    year: row.year,
    releaseDate: DateTime(row.year),
    priceTRY: row.priceTRY,
    popularity: row.popularity,
    os: extra['os'] as String? ?? row.os,
    osFamily: row.osFamily,
    colors: [PhoneColor(name: 'Varsayılan', hex: row.accent)],
    accent: row.accent,
    highlights: highlights.isEmpty ? [row.brand, '${row.year}'] : highlights,
    image: extra['image'] as String? ?? '',
    sourceUrl: extra['sourceUrl'] as String? ?? row.sourceUrl,
    seedRatings: const SeedRatings(
      average: 7,
      count: 0,
      camera: 7,
      performance: 7,
      battery: 7,
      display: 7,
      design: 7,
    ),
    display: DisplaySpec(
      size: displaySize,
      type: extra['displayType'] as String? ?? 'Belirtilmedi',
      resolution: 'Belirtilmedi',
      refreshRate: (extra['refreshRate'] as num?)?.toInt() ?? 0,
      brightness: (extra['brightness'] as num?)?.toInt() ?? 0,
      protection: 'Belirtilmedi',
      ppi: 0,
      ratio: 'Belirtilmedi',
      hdr: ((extra['refreshRate'] as num?)?.toInt() ?? 0) >= 90,
      alwaysOn: false,
    ),
    body: BodySpec(
      height: (extra['height'] as num?)?.toDouble() ?? 0,
      width: (extra['width'] as num?)?.toDouble() ?? 0,
      thickness: (extra['thickness'] as num?)?.toDouble() ?? 0,
      weight: (extra['weight'] as num?)?.toInt() ?? 0,
      material: 'Belirtilmedi',
      ipRating: extra['ipRating'] as String? ?? 'Belirtilmedi',
      foldable: row.foldable,
    ),
    performance: PerfSpec(
      chipset: chipset ?? 'Belirtilmedi',
      cpu: 'Belirtilmedi',
      gpu: 'Belirtilmedi',
      processNm: 0,
      cores: 0,
    ),
    memory: MemorySpec(ram: ram, storage: storage, expandable: false),
    camera: CameraSpec(
      rear: [CameraLens(name: 'Ana', mp: (extra['mainMp'] as num?)?.toDouble() ?? 0, aperture: '—')],
      front: const CameraLens(name: 'Ön', mp: 0, aperture: '—'),
      features: const [],
      dxomark: null,
      video: 'Belirtilmedi',
    ),
    battery: BatterySpec(
      capacity: capacity,
      capacityNote: capacity == null ? 'Çapraz kaynakta mAh yok' : null,
      wiredWatt: (extra['wiredWatt'] as num?)?.toInt() ?? 0,
      wirelessWatt: 0,
      reverse: false,
      estimatedHours: 0,
    ),
    connectivity: ConnectSpec(
      network5g: extra['network5g'] as bool? ?? row.network5g,
      wifi: 'Belirtilmedi',
      bluetooth: 'Belirtilmedi',
      nfc: false,
      usb: 'Belirtilmedi',
      sim: 'Belirtilmedi',
      esim: row.brand == 'Apple',
      infrared: false,
    ),
    audio: const AudioSpec(speakers: 'Belirtilmedi', jack: false, dolby: false),
    features: const FeatureSpec(fingerprint: 'Belirtilmedi', faceUnlock: false, stylus: false),
    sensors: const [],
    benchmarks: const BenchSpec(antutu: 0, geekbenchSingle: 0, geekbenchMulti: 0),
  );
}
