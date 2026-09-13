class PhoneColor {
  const PhoneColor({required this.name, required this.hex});
  final String name;
  final String hex;

  factory PhoneColor.fromJson(Map<String, dynamic> json) => PhoneColor(
        name: json['name'] as String,
        hex: json['hex'] as String,
      );

  int get value => int.parse('FF${hex.replaceFirst('#', '')}', radix: 16);
}

class SeedRatings {
  const SeedRatings({
    required this.average,
    required this.count,
    required this.camera,
    required this.performance,
    required this.battery,
    required this.display,
    required this.design,
  });

  final double average;
  final int count;
  final double camera;
  final double performance;
  final double battery;
  final double display;
  final double design;

  factory SeedRatings.fromJson(Map<String, dynamic> json) => SeedRatings(
        average: (json['average'] as num).toDouble(),
        count: json['count'] as int,
        camera: (json['camera'] as num).toDouble(),
        performance: (json['performance'] as num).toDouble(),
        battery: (json['battery'] as num).toDouble(),
        display: (json['display'] as num).toDouble(),
        design: (json['design'] as num).toDouble(),
      );
}

class CameraLens {
  const CameraLens({
    required this.name,
    required this.mp,
    required this.aperture,
    this.ois = false,
  });

  final String name;
  final double mp;
  final String aperture;
  final bool ois;

  factory CameraLens.fromJson(Map<String, dynamic> json) => CameraLens(
        name: json['name'] as String,
        mp: (json['mp'] as num).toDouble(),
        aperture: json['aperture'] as String,
        ois: json['ois'] as bool? ?? false,
      );
}

class Phone {
  const Phone({
    required this.id,
    required this.slug,
    required this.brand,
    required this.name,
    required this.fullName,
    required this.year,
    required this.releaseDate,
    required this.priceTRY,
    required this.popularity,
    required this.os,
    required this.osFamily,
    required this.colors,
    required this.accent,
    required this.highlights,
    required this.image,
    required this.sourceUrl,
    required this.seedRatings,
    required this.display,
    required this.body,
    required this.performance,
    required this.memory,
    required this.camera,
    required this.battery,
    required this.connectivity,
    required this.audio,
    required this.features,
    required this.sensors,
    required this.benchmarks,
  });

  final String id;
  final String slug;
  final String brand;
  final String name;
  final String fullName;
  final int year;
  final DateTime releaseDate;
  final int priceTRY;
  final int popularity;
  final String os;
  final String osFamily;
  final List<PhoneColor> colors;
  final String accent;
  final List<String> highlights;
  final String image;
  final String sourceUrl;
  final SeedRatings seedRatings;
  final DisplaySpec display;
  final BodySpec body;
  final PerfSpec performance;
  final MemorySpec memory;
  final CameraSpec camera;
  final BatterySpec battery;
  final ConnectSpec connectivity;
  final AudioSpec audio;
  final FeatureSpec features;
  final List<String> sensors;
  final BenchSpec benchmarks;

  int get accentValue =>
      int.parse('FF${accent.replaceFirst('#', '')}', radix: 16);

  factory Phone.fromJson(Map<String, dynamic> json) => Phone(
        id: json['id'] as String,
        slug: json['slug'] as String,
        brand: json['brand'] as String,
        name: json['name'] as String,
        fullName: json['fullName'] as String,
        year: json['year'] as int,
        releaseDate: DateTime.parse(json['releaseDate'] as String),
        priceTRY: json['priceTRY'] as int,
        popularity: json['popularity'] as int,
        os: json['os'] as String,
        osFamily: json['osFamily'] as String,
        colors: (json['colors'] as List)
            .map((e) => PhoneColor.fromJson(e as Map<String, dynamic>))
            .toList(),
        accent: json['accent'] as String,
        highlights: (json['highlights'] as List).cast<String>(),
        image: json['image'] as String,
        sourceUrl: json['sourceUrl'] as String,
        seedRatings:
            SeedRatings.fromJson(json['seedRatings'] as Map<String, dynamic>),
        display: DisplaySpec.fromJson(json['display'] as Map<String, dynamic>),
        body: BodySpec.fromJson(json['body'] as Map<String, dynamic>),
        performance: PerfSpec.fromJson(json['performance'] as Map<String, dynamic>),
        memory: MemorySpec.fromJson(json['memory'] as Map<String, dynamic>),
        camera: CameraSpec.fromJson(json['camera'] as Map<String, dynamic>),
        battery: BatterySpec.fromJson(json['battery'] as Map<String, dynamic>),
        connectivity:
            ConnectSpec.fromJson(json['connectivity'] as Map<String, dynamic>),
        audio: AudioSpec.fromJson(json['audio'] as Map<String, dynamic>),
        features: FeatureSpec.fromJson(json['features'] as Map<String, dynamic>),
        sensors: (json['sensors'] as List).cast<String>(),
        benchmarks: BenchSpec.fromJson(json['benchmarks'] as Map<String, dynamic>),
      );
}

class DisplaySpec {
  const DisplaySpec({
    required this.size,
    required this.type,
    required this.resolution,
    required this.refreshRate,
    required this.brightness,
    required this.protection,
    required this.ppi,
    required this.ratio,
    required this.hdr,
    required this.alwaysOn,
  });

  final double size;
  final String type;
  final String resolution;
  final int refreshRate;
  final int brightness;
  final String protection;
  final int ppi;
  final String ratio;
  final bool hdr;
  final bool alwaysOn;

  factory DisplaySpec.fromJson(Map<String, dynamic> json) => DisplaySpec(
        size: (json['size'] as num).toDouble(),
        type: json['type'] as String,
        resolution: json['resolution'] as String,
        refreshRate: json['refreshRate'] as int,
        brightness: json['brightness'] as int,
        protection: json['protection'] as String,
        ppi: json['ppi'] as int,
        ratio: json['ratio'] as String,
        hdr: json['hdr'] as bool,
        alwaysOn: json['alwaysOn'] as bool,
      );
}

class BodySpec {
  const BodySpec({
    required this.height,
    required this.width,
    required this.thickness,
    required this.weight,
    required this.material,
    required this.ipRating,
    required this.foldable,
  });

  final double height;
  final double width;
  final double thickness;
  final int weight;
  final String material;
  final String ipRating;
  final bool foldable;

  factory BodySpec.fromJson(Map<String, dynamic> json) => BodySpec(
        height: (json['height'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        thickness: (json['thickness'] as num).toDouble(),
        weight: json['weight'] as int,
        material: json['material'] as String,
        ipRating: json['ipRating'] as String,
        foldable: json['foldable'] as bool,
      );
}

class PerfSpec {
  const PerfSpec({
    required this.chipset,
    required this.cpu,
    required this.gpu,
    required this.processNm,
    required this.cores,
  });

  final String chipset;
  final String cpu;
  final String gpu;
  final int processNm;
  final int cores;

  factory PerfSpec.fromJson(Map<String, dynamic> json) => PerfSpec(
        chipset: json['chipset'] as String,
        cpu: json['cpu'] as String,
        gpu: json['gpu'] as String,
        processNm: json['processNm'] as int,
        cores: json['cores'] as int,
      );
}

class MemorySpec {
  const MemorySpec({
    required this.ram,
    required this.storage,
    required this.expandable,
  });

  final int ram;
  final int storage;
  final bool expandable;

  factory MemorySpec.fromJson(Map<String, dynamic> json) => MemorySpec(
        ram: json['ram'] as int,
        storage: json['storage'] as int,
        expandable: json['expandable'] as bool,
      );
}

class CameraSpec {
  const CameraSpec({
    required this.rear,
    required this.front,
    required this.features,
    required this.dxomark,
    required this.video,
  });

  final List<CameraLens> rear;
  final CameraLens front;
  final List<String> features;
  final int? dxomark;
  final String video;

  factory CameraSpec.fromJson(Map<String, dynamic> json) => CameraSpec(
        rear: (json['rear'] as List)
            .map((e) => CameraLens.fromJson(e as Map<String, dynamic>))
            .toList(),
        front: CameraLens.fromJson(json['front'] as Map<String, dynamic>),
        features: (json['features'] as List).cast<String>(),
        dxomark: json['dxomark'] as int?,
        video: json['video'] as String,
      );
}

class BatterySpec {
  const BatterySpec({
    required this.capacity,
    this.capacityNote,
    required this.wiredWatt,
    required this.wirelessWatt,
    required this.reverse,
    required this.estimatedHours,
    this.hoursNote,
  });

  final int? capacity;
  final String? capacityNote;
  final int wiredWatt;
  final int wirelessWatt;
  final bool reverse;
  final int estimatedHours;
  final String? hoursNote;

  factory BatterySpec.fromJson(Map<String, dynamic> json) => BatterySpec(
        capacity: json['capacity'] as int?,
        capacityNote: json['capacityNote'] as String?,
        wiredWatt: json['wiredWatt'] as int,
        wirelessWatt: json['wirelessWatt'] as int,
        reverse: json['reverse'] as bool,
        estimatedHours: json['estimatedHours'] as int,
        hoursNote: json['hoursNote'] as String?,
      );
}

class ConnectSpec {
  const ConnectSpec({
    required this.network5g,
    required this.wifi,
    required this.bluetooth,
    required this.nfc,
    required this.usb,
    required this.sim,
    required this.esim,
    required this.infrared,
  });

  final bool network5g;
  final String wifi;
  final String bluetooth;
  final bool nfc;
  final String usb;
  final String sim;
  final bool esim;
  final bool infrared;

  factory ConnectSpec.fromJson(Map<String, dynamic> json) => ConnectSpec(
        network5g: json['network5g'] as bool,
        wifi: json['wifi'] as String,
        bluetooth: json['bluetooth'] as String,
        nfc: json['nfc'] as bool,
        usb: json['usb'] as String,
        sim: json['sim'] as String,
        esim: json['esim'] as bool,
        infrared: json['infrared'] as bool,
      );
}

class AudioSpec {
  const AudioSpec({
    required this.speakers,
    required this.jack,
    required this.dolby,
  });

  final String speakers;
  final bool jack;
  final bool dolby;

  factory AudioSpec.fromJson(Map<String, dynamic> json) => AudioSpec(
        speakers: json['speakers'] as String,
        jack: json['jack'] as bool,
        dolby: json['dolby'] as bool,
      );
}

class FeatureSpec {
  const FeatureSpec({
    required this.fingerprint,
    required this.faceUnlock,
    required this.stylus,
  });

  final String fingerprint;
  final bool faceUnlock;
  final bool stylus;

  factory FeatureSpec.fromJson(Map<String, dynamic> json) => FeatureSpec(
        fingerprint: json['fingerprint'] as String,
        faceUnlock: json['faceUnlock'] as bool,
        stylus: json['stylus'] as bool,
      );
}

class BenchSpec {
  const BenchSpec({
    required this.antutu,
    required this.geekbenchSingle,
    required this.geekbenchMulti,
  });

  final int antutu;
  final int geekbenchSingle;
  final int geekbenchMulti;

  factory BenchSpec.fromJson(Map<String, dynamic> json) => BenchSpec(
        antutu: json['antutu'] as int,
        geekbenchSingle: json['geekbenchSingle'] as int,
        geekbenchMulti: json['geekbenchMulti'] as int,
      );
}

class UserVote {
  const UserVote({
    this.overall = 0,
    this.camera = 0,
    this.performance = 0,
    this.battery = 0,
    this.display = 0,
    this.design = 0,
  });

  final int overall;
  final int camera;
  final int performance;
  final int battery;
  final int display;
  final int design;

  UserVote copyWith({
    int? overall,
    int? camera,
    int? performance,
    int? battery,
    int? display,
    int? design,
  }) =>
      UserVote(
        overall: overall ?? this.overall,
        camera: camera ?? this.camera,
        performance: performance ?? this.performance,
        battery: battery ?? this.battery,
        display: display ?? this.display,
        design: design ?? this.design,
      );

  Map<String, int> toJson() => {
        'overall': overall,
        'camera': camera,
        'performance': performance,
        'battery': battery,
        'display': display,
        'design': design,
      };

  factory UserVote.fromJson(Map<String, dynamic> json) => UserVote(
        overall: json['overall'] as int? ?? 0,
        camera: json['camera'] as int? ?? 0,
        performance: json['performance'] as int? ?? 0,
        battery: json['battery'] as int? ?? 0,
        display: json['display'] as int? ?? 0,
        design: json['design'] as int? ?? 0,
      );

  int operator [](String key) => switch (key) {
        'overall' => overall,
        'camera' => camera,
        'performance' => performance,
        'battery' => battery,
        'display' => display,
        'design' => design,
        _ => 0,
      };
}
