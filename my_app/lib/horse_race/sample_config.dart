import 'track_component.dart';

class Frame {
  final int number;
  const Frame(this.number);
}

class HorseSpec {
  final String id;
  final String name;
  final Frame frame;

  /// 内外の好み（-1.0..+1.0）
  final double laneBias;

  const HorseSpec({
    required this.id,
    required this.name,
    required this.frame,
    this.laneBias = 0.0,
  });
}

class RaceConfig {
  final RaceCourse course;
  final List<HorseSpec> horses;

  const RaceConfig({
    required this.course,
    required this.horses,
  });
}

/// サンプル（まず動かすための最小）
class SampleConfigs {
  static RaceConfig tokyo6Horses() {
    final course = RaceCourse(
      id: 'tokyo',
      name: 'Tokyo',
      segments: const [
        const RaceSegment(id: 'start', name: 'Start', timeEnd: 0.15, tighten: 2.0),
        const RaceSegment(id: 'back', name: 'Back', timeEnd: 0.50, tighten: 3.0),
        const RaceSegment(id: 'curve', name: 'Curve', timeEnd: 0.75, tighten: 4.0),
        const RaceSegment(id: 'home', name: 'Home', timeEnd: 1.00, tighten: 2.5),
      ],
    );

    final horses = const [
      HorseSpec(id: 'h1', name: 'Horse 1', frame: Frame(1), laneBias: -0.3),
      HorseSpec(id: 'h2', name: 'Horse 2', frame: Frame(2), laneBias: -0.1),
      HorseSpec(id: 'h3', name: 'Horse 3', frame: Frame(3), laneBias: 0.0),
      HorseSpec(id: 'h4', name: 'Horse 4', frame: Frame(4), laneBias: 0.1),
      HorseSpec(id: 'h5', name: 'Horse 5', frame: Frame(5), laneBias: 0.2),
      HorseSpec(id: 'h6', name: 'Horse 6', frame: Frame(6), laneBias: 0.35),
    ];

    return RaceConfig(course: course, horses: horses);
  }
}
