import 'dart:math' as math;
import 'horse_component.dart';
import 'track_component.dart';
import 'models.dart';

class RaceDirector {
  RaceDirector({
    required this.config,
    required this.track,
    required this.horses,
    required this.placements,
    required this.getPhase,
    required this.isEditMode,
  });

  final RaceConfig config;
  final TrackComponent track;
  final List<HorseComponent> horses;

  final Map<Phase, PhasePlacement> placements;
  final Phase Function() getPhase;
  final bool Function() isEditMode;

  double _baseSpeedSPerSec = 0.06;

  void initPositions() {
    // まずは“今のPhaseの配置”を反映できるならする
    if (applyPhasePlacement()) return;

    // なければ既存の並べ方（枠順）
    horses.sort((a, b) => a.spec.frame.number.compareTo(b.spec.frame.number));

    for (int i = 0; i < horses.length; i++) {
      final h = horses[i];
      h.s = 0.02 * i;
      h.lane = ((i % 3) - 1) * 0.18 + h.spec.laneBias * 0.25;

      h.targetS = h.s;
      h.targetLane = h.lane;

      final pos = track.positionOnTrack(h.s, h.lane);
      h.position = pos;
      h.headingRad = 0.0;
    }
  }

  /// 現在Phaseの placements があれば馬に反映する
  /// 反映できたら true
  bool applyPhasePlacement() {
    final p = getPhase();
    final map = placements[p];
    if (map == null || map.isEmpty) return false;

    for (final h in horses) {
      final c = map[h.spec.id];
      if (c == null) continue;
      h.s = c.s;
      h.lane = c.lane;
      h.targetS = h.s;
      h.targetLane = h.lane;
      h.position = track.worldFromCoord(c);
    }
    return true;
  }

  void update(double dt) {
    final seg = _segmentForS(horses.isEmpty ? 0.0 : horses.first.s);
    final tighten = seg?.tighten ?? 2.0;

    for (final h in horses) {
      h.s = (h.s + _baseSpeedSPerSec * dt) % 1.0;

      final noise = (math.sin((h.s * math.pi * 2) + h.spec.frame.number) * 0.15);
      h.targetLane =
          (h.spec.laneBias * 0.25 + noise * (tighten * 0.12)).clamp(-0.95, 0.95);

      final k = 4.0;
      h.lane = h.lane + (h.targetLane - h.lane) * (1 - math.exp(-k * dt));

      h.position = track.positionOnTrack(h.s, h.lane);

      final fwd = track.forwardOnTrack(h.s);
      h.headingRad = math.atan2(fwd.y, fwd.x);
    }
  }

  RaceSegment? _segmentForS(double s) {
    for (final seg in config.course.segments) {
      if (s <= seg.timeEnd) return seg;
    }
    return config.course.segments.isEmpty ? null : config.course.segments.last;
  }
}
