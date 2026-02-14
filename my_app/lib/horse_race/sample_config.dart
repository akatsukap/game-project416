import 'dart:math' as math;
import 'package:flame/components.dart';

import 'frame_color.dart';
import 'models.dart';
import 'race_course.dart';

class SampleConfigs {
  /// 競馬場データ（必要ならここに増やす）
  static RaceCourse courseOf(TrackId id) {
    // 指定ルール：左/右回り
    final direction = switch (id) {
      TrackId.tokyo || TrackId.chukyo || TrackId.niigata => TrackDirection.left,
      _ => TrackDirection.right,
    };

    switch (id) {
      case TrackId.tokyo:
        return RaceCourse(
          id: 'tokyo',
          name: '東京',
          direction: direction,
          ovalScale: Vector2(1.6, 1.0),
          segments: const [
            RaceSegment(id: 'start', name: 'Start', timeEnd: 0.15, tighten: 2.0),
            RaceSegment(id: 'back', name: 'Back', timeEnd: 0.50, tighten: 3.0),
            RaceSegment(id: 'curve', name: 'Curve', timeEnd: 0.75, tighten: 4.0),
            RaceSegment(id: 'home', name: 'Home', timeEnd: 1.00, tighten: 2.5),
          ],
        );

      default:
        // まだ未実装の競馬場は仮で同じ形（directionだけは正しい）
        return RaceCourse(
          id: id.name,
          name: id.name,
          direction: direction,
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
      settings: settings.copyWith(),
      course: course,
      horses: horses,
      placements: placements ?? const {},
    );
  }

  static List<HorseSpec> _generateHorses(int horseCount) {
    final rng = math.Random(42);
    final count = horseCount.clamp(2, 18);

    return List.generate(count, (i) {
      final horseNo = i + 1;

      final frameNo = frameOfHorseNumber(
        horseNumber: horseNo,
        horseCount: count,
      );

      final baseBias = ((frameNo - 4) / 4.0).clamp(-1.0, 1.0) * 0.6;
      final jitter = (rng.nextDouble() - 0.5) * 0.2;
      final laneBias = (baseBias + jitter).clamp(-1.0, 1.0);

      final coat = CoatColor.values[horseNo % CoatColor.values.length];
      final runStyle = _pickRunStyle(rng);

      return HorseSpec(
        id: 'h$horseNo',
        horseNo: horseNo,
        name: 'Horse $horseNo',
        shortName: 'H$horseNo',
        frame: Frame(frameNo),
        coatColor: coat,
        runStyle: runStyle,
        memo: '',
        laneBias: laneBias,
        ownerId: '',
      );
    });
  }

  static HorseRunStyle _pickRunStyle(math.Random rng) {
    final r = rng.nextDouble();
    if (r < 0.12) return HorseRunStyle.frontRunner;
    if (r < 0.45) return HorseRunStyle.stalker;
    if (r < 0.80) return HorseRunStyle.midPack;
    return HorseRunStyle.closer;
  }
}
