import 'dart:math' as math;
import 'horse_component.dart';
import 'sample_config.dart';
import 'track_component.dart';

class RaceDirector {
  RaceDirector({
    required this.config,
    required this.track,
    required this.horses,
  });

  final RaceConfig config;
  final TrackComponent track;
  final List<HorseComponent> horses;

  double _baseSpeedSPerSec = 0.06; // 周回速度（調整用）

  void initPositions() {
    // 枠順で並べる（frame.number）
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

  void update(double dt) {
    // セグメント tighten をざっくり反映（現在位置から該当セグメントを拾う）
    final seg = _segmentForS(horses.isEmpty ? 0.0 : horses.first.s);
    final tighten = seg?.tighten ?? 2.0;

    for (final h in horses) {
      // 進行
      h.s = (h.s + _baseSpeedSPerSec * dt) % 1.0;

      // 目標レーンをゆっくり変える（tighten が大きいほど揺れやすい）
      final noise = (math.sin((h.s * math.pi * 2) + h.spec.frame.number) * 0.15);
      h.targetLane = (h.spec.laneBias * 0.25 + noise * (tighten * 0.12)).clamp(-0.95, 0.95);

      // lane を追従（指数平滑）
      final k = 4.0;
      h.lane = h.lane + (h.targetLane - h.lane) * (1 - math.exp(-k * dt));

      // 位置反映
      final pos = track.positionOnTrack(h.s, h.lane);
      h.position = pos;

      // 向き
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
