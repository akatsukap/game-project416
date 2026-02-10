import 'dart:math' as math;
import 'package:flame/components.dart';

import 'frame_color.dart';
import 'models.dart';
import 'track_component.dart';
import 'race_course.dart';


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

    final horses = overrideHorses ?? _generateHorses(horseCount);

    return RaceConfig(
      settings: settings,
      course: course,
      horses: horses,
      placements: placements ?? const {},
    );
  }

  static List<HorseSpec> _generateHorses(int horseCount) {
    final rng = math.Random(42);

    return List.generate(horseCount, (i) {
      final horseNo = i + 1;

      // 「馬番 -> 枠番」計算（frame_color.dart側の関数を利用）
      final frameNo =
          frameOfHorseNumber(horseNumber: horseNo, horseCount: horseCount);

      final laneBias =
          (((frameNo - 4) / 4.0).clamp(-1.0, 1.0) * 0.6) +
              ((rng.nextDouble() - 0.5) * 0.2);

      final coat = CoatColor.values[horseNo % CoatColor.values.length];

      // 脚質も軽く散らす（UIで後から編集）
      final style =
          HorseRunStyle.values[horseNo % HorseRunStyle.values.length];

      return HorseSpec(
        id: 'h$horseNo',
        horseNo: horseNo,
        name: 'Horse $horseNo',
        shortName: 'H$horseNo',
        frame: Frame(frameNo),
        coatColor: coat,
        runStyle: style,
        memo: '',
        laneBias: laneBias,
      );
    });
  }
}
