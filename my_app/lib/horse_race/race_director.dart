import 'dart:math' as math;

import 'horse_component.dart';
import 'models.dart';
import 'race_course.dart';
import 'track_component.dart';

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

  /// Phaseごとの配置（編集で変わる）
  final Map<Phase, PhasePlacement> placements;

  final Phase Function() getPhase;
  final bool Function() isEditMode;

  double _baseSpeedSPerSec = 0.06;

  /// 初期配置：まず placements があればそれを反映。
  /// なければ「Start整列（馬番が内→外）」にする。
  void initPositions() {
    if (applyPhasePlacement()) return;

    _applyDefaultLineup(phase: Phase.start);
  }

  /// 現在Phaseの placements があれば馬に反映する（なければ false）
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

      final fwd = track.forwardOnTrack(h.s);
      h.headingRad = math.atan2(fwd.y, fwd.x);
    }
    return true;
  }

  /// Phase が切り替わった時に呼ぶ想定：
  /// - placementsが無ければ自動生成
  /// - 生成/既存を反映
  void ensureAndApplyPlacementForPhase(Phase phase) {
    final current = placements[phase];
    if (current == null || current.isEmpty) {
      placements[phase] = _defaultPlacementForPhase(phase);
    }

    final now = placements[phase]!;
    for (final h in horses) {
      final c = now[h.spec.id];
      if (c == null) continue;
      h.s = c.s;
      h.lane = c.lane;
      h.targetS = h.s;
      h.targetLane = h.lane;
      h.position = track.worldFromCoord(c);

      final fwd = track.forwardOnTrack(h.s);
      h.headingRad = math.atan2(fwd.y, fwd.x);
    }
  }

  /// レース更新（通常モード）
  void update(double dt) {
    if (horses.isEmpty) return;

    final seg = _segmentForS(horses.first.s);
    final tighten = seg?.tighten ?? 2.0;

    for (final h in horses) {
      // 編集モードでは update しない（ドラッグ位置を尊重）
      if (isEditMode()) continue;

      h.s = (h.s + _baseSpeedSPerSec * dt) % 1.0;

      final noise = math.sin((h.s * math.pi * 2) + h.spec.horseNo) * 0.15;
      h.targetLane =
          (h.spec.laneBias * 0.25 + noise * (tighten * 0.12)).clamp(-0.95, 0.95);

      const k = 4.0;
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
  // Default lineup / placements
  // ---------------------------------------------------------------------------

  void _applyDefaultLineup({required Phase phase}) {
    final baseS = _anchorSForPhase(phase);

    // 馬番昇順（1が内側の先頭になるように）
    final sorted = [...horses]
      ..sort((a, b) => a.spec.horseNo.compareTo(b.spec.horseNo));

    final n = sorted.length;

    // 内→外 を lane: -0.85 .. +0.85 に均等割り
    double laneAt(int i) {
      if (n <= 1) return 0.0;
      final t = i / (n - 1);
      return (-0.85 + (1.70 * t)).clamp(-0.95, 0.95);
    }

    for (int i = 0; i < n; i++) {
      final h = sorted[i];
      final lane = laneAt(i);

      h.s = baseS;
      h.lane = lane;

      h.targetS = h.s;
      h.targetLane = h.lane;

      h.position = track.positionOnTrack(h.s, h.lane);

      final fwd = track.forwardOnTrack(h.s);
      h.headingRad = math.atan2(fwd.y, fwd.x);
    }
  }

  Map<String, TrackCoord> _defaultPlacementForPhase(Phase phase) {
    final baseS = _anchorSForPhase(phase);

    final sorted = [...horses]
      ..sort((a, b) => a.spec.horseNo.compareTo(b.spec.horseNo));

    final n = sorted.length;

    double laneAt(int i) {
      if (n <= 1) return 0.0;
      final t = i / (n - 1);
      return (-0.85 + (1.70 * t)).clamp(-0.95, 0.95);
    }

    final map = <String, TrackCoord>{};
    for (int i = 0; i < n; i++) {
      final h = sorted[i];
      map[h.spec.id] = TrackCoord(s: baseS, lane: laneAt(i));
    }
    return map;
  }

  double _anchorSForPhase(Phase phase) {
    final phaseId = switch (phase) {
      Phase.start => 'start',
      Phase.firstCorner => 'firstCorner',
      Phase.backStretch => 'backStretch',
      Phase.thirdFourthCorner => 'thirdFourthCorner',
      Phase.homestretch => 'homestretch',
      Phase.goal => 'goal',
    };
    return config.course.anchorSForPhase(phaseId);
  }
}
