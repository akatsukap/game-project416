import 'dart:math' as math;

import 'horse_component.dart';
import 'track_component.dart';
import 'models.dart';
import 'race_course.dart';

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

  /// Phase -> (horseId -> TrackCoord)
  final Map<Phase, PhasePlacement> placements;

  final Phase Function() getPhase;
  final bool Function() isEditMode;

  double _baseSpeedSPerSec = 0.06;

  void initPositions() {
    // まずは“今のPhaseの配置”を反映（なければ自動生成して反映）
    applyPhasePlacement(forceGenerateIfEmpty: true);

    // もし track の resize 前などで座標がまだ作れないケースがあるなら、
    // TrackComponent側の_readyで弾かれるので、最初のフレームで再反映してもOK。
  }

  /// 現在Phaseの placements を馬に反映する
  ///
  /// - placements が空/無い場合:
  ///   - forceGenerateIfEmpty=true なら「馬番順に内→外で整列」配置を自動生成して反映
  ///   - false なら何もしない
  void applyPhasePlacement({bool forceGenerateIfEmpty = false}) {
    final p = getPhase();
    final map = placements[p];

    if (map == null || map.isEmpty) {
      if (!forceGenerateIfEmpty) return;

      // ★ここが今回の要件：Phaseを選んだ瞬間、馬番順に内→外へ整列
      final generated = _defaultPlacementForPhase(p);
      placements[p] = generated;
    }

    final now = placements[p]!;
    for (final h in horses) {
      final c = now[h.spec.id];
      if (c == null) continue;

      h.s = c.s;
      h.lane = c.lane;
      h.targetS = h.s;
      h.targetLane = h.lane;

      // TrackCoord -> 画面座標
      h.position = track.worldFromCoord(c);

      // headingも更新しておくと見た目が安定
      final fwd = track.forwardOnTrack(h.s);
      h.headingRad = math.atan2(fwd.y, fwd.x);
    }
  }

  void update(double dt) {
    // 編集中は“勝手に動かない”（race_game側で return してる前提）
    // ここはレース再生時だけ使う
    final seg = _segmentForS(horses.isEmpty ? 0.0 : horses.first.s);
    final tighten = seg?.tighten ?? 2.0;

    for (final h in horses) {
      h.s = (h.s + _baseSpeedSPerSec * dt) % 1.0;

      final noise = math.sin((h.s * math.pi * 2) + h.spec.frame.number) * 0.15;
      h.targetLane =
          (h.spec.laneBias * 0.25 + noise * (tighten * 0.12)).clamp(-0.95, 0.95);

      // lane補間（なめらか）
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

  // ---------------------------------------------------------------------------
  // ★追加：Phaseごとの「初期整列」配置
  // ---------------------------------------------------------------------------

  PhasePlacement _defaultPlacementForPhase(Phase phase) {
    // Phaseごとのアンカーs（course側の簡易テーブル）
    final phaseId = switch (phase) {
      Phase.start => 'start',
      Phase.firstCorner => 'firstCorner',
      Phase.backStretch => 'backStretch',
      Phase.thirdFourthCorner => 'thirdFourthCorner',
      Phase.homestretch => 'homestretch',
      Phase.goal => 'goal',
    };
    final baseS = config.course.anchorSForPhase(phaseId);

    // horseNoで昇順に並べる（馬番順）
    final sorted = [...horses]
      ..sort((a, b) => a.spec.horseNo.compareTo(b.spec.horseNo));

    // laneを -1..+1 に均等割り（内→外）
    final n = sorted.length;
    double laneAt(int i) {
      if (n <= 1) return 0.0;
      return -1.0 + (2.0 * i / (n - 1));
    }

    final map = <String, TrackCoord>{};
    for (int i = 0; i < n; i++) {
      final h = sorted[i];
      map[h.spec.id] = TrackCoord(
        s: baseS,
        lane: laneAt(i),
      );
    }
    return map;
  }
}
