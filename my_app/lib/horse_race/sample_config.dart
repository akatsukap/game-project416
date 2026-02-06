import 'dart:math' as math;
import 'package:flame/components.dart';

import 'frame_color.dart';
import 'models.dart';
import 'track_component.dart';

class SampleConfigs {
  /// 競馬場データ（将来ここに25場を増やす）
  static RaceCourse courseOf(TrackId id) {
    switch (id) {
      case TrackId.tokyo:
        return RaceCourse(
          id: 'tokyo',
          name: 'Tokyo',
          ovalScale: Vector2(1.6, 1.0),
          segments: const [
            RaceSegment(id: 'start', name: 'Start', timeEnd: 0.15, tighten: 2.0),
            RaceSegment(id: 'back', name: 'Back', timeEnd: 0.50, tighten: 3.0),
            RaceSegment(id: 'curve', name: 'Curve', timeEnd: 0.75, tighten: 4.0),
            RaceSegment(id: 'home', name: 'Home', timeEnd: 1.00, tighten: 2.5),
          ],
        );
    }
  }

  static RaceConfig tokyo({required int horseCount}) {
    return build(
      settings: const RaceSettings(
        raceName: 'Horse Race (Dev)',
        trackId: TrackId.tokyo,
        distanceM: 2000,
        condition: TrackCondition.firm,
      ),
      horseCount: horseCount,
    );
  }

  static RaceConfig build({
    required RaceSettings settings,
    required int horseCount,
    List<HorseSpec>? overrideHorses,
    Map<Phase, PhasePlacement>? placements,
  }) {
    final course = courseOf(settings.trackId);

    // horses（UIで後から名前など編集可能）
    final horses = overrideHorses ?? _generateHorses(horseCount);

    return RaceConfig(
      settings: settings.copyWith(),
      course: course,
      horses: horses,
      placements: placements ?? const {},
    );
  }

  static List<HorseSpec> _generateHorses(int horseCount) {
    final rng = math.Random(42);

    return List.generate(horseCount, (i) {
      final horseNo = i + 1;
      final frameNo = frameOfHorseNumber(horseNumber: horseNo, horseCount: horseCount);

      // laneBias は “内好き/外好き” の雰囲気を入れる（後で編集UIで触れる）
      final laneBias = ((frameNo - 4) / 4.0).clamp(-1.0, 1.0) * 0.6 + (rng.nextDouble() - 0.5) * 0.2;

      // 毛色は適当に回す（後でUIで選択）
      final coat = CoatColor.values[horseNo % CoatColor.values.length];

      return HorseSpec(
        id: 'h$horseNo',
        name: 'Horse $horseNo',
        frame: Frame(frameNo),
        coatColor: coat,
        laneBias: laneBias.clamp(-1.0, 1.0),
      );
    });
  }
}
