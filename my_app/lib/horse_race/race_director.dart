import 'dart:math' as math;
import 'package:flame/components.dart';

import 'horse_component.dart';
import 'track_component.dart';

/// レース設定（競馬場/レース名/出走馬/区間ごとの予想）を束ねる
class RaceConfig {
  final RaceCourse course;
  final String raceName;
  final List<HorseSpec> horses;

  /// 予想（区間ごと）
  /// key: segmentId
  /// value: 前→後ろの順に、同じ馬群（グループ）を HorseId のListで表す
  final Map<String, List<List<String>>> predictionBySegment;

  const RaceConfig({
    required this.course,
    required this.raceName,
    required this.horses,
    required this.predictionBySegment,
  });
}

/// レースを進行させ、区間ごとの“馬群ターゲット”を生成し、滑らかに追従させる
class RaceDirector extends Component {
  RaceDirector({
    required this.track,
    required this.horseComponents,
    required this.config,
  });

  final TrackComponent track;
  final List<HorseComponent> horseComponents;
  final RaceConfig config;

  // レース時間（秒）
  double raceDurationSec = 22.0;

  // 内部進行
  double _t = 0.0; // 0..raceDurationSec
  double _progress = 0.0; // 0..1

  // ベース速度（1周を raceDurationSec で回る）
  double get _baseSpeedSPerSec => 1.0 / raceDurationSec;

  // 現在セグメント
  int _segIndex = 0;

  @override
  void onMount() {
    super.onMount();
    _applyTargetsForCurrentSegment();
  }

  void reset() {
    _t = 0;
    _progress = 0;
    _segIndex = 0;

    // 初期位置を少し散らす（同じ場所だと重なる）
    for (int i = 0; i < horseComponents.length; i++) {
      final h = horseComponents[i];
      h.s = 0.02 * i;
      h.lane = ((i % 3) - 1) * 0.15;
      h.targetS = h.s;
      h.targetLane = h.lane;
    }
    _applyTargetsForCurrentSegment();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 時間進行
    _t += dt;
    _progress = (_t / raceDurationSec).clamp(0.0, 1.0);

    // セグメント切替
    final segments = config.course.segments;
    while (_segIndex < segments.length && _progress > segments[_segIndex].timeEnd) {
      _segIndex = math.min(_segIndex + 1, segments.length - 1);
      _applyTargetsForCurrentSegment();
    }

    // ベース進行（全馬前に進む）
    for (final h in horseComponents) {
      h.s = (h.s + _baseSpeedSPerSec * dt) % 1.0;
    }

    // ターゲットへ追従（滑らかさのコア）
    final seg = segments[_segIndex];
    final tighten = seg.tighten;

    for (final h in horseComponents) {
      // 進行度ターゲットは “現在の周回” に合わせて同一周回内で解釈
      // targetS が過去側にあるときは +1 して前方として扱う
      double currentS = h.s;
      double targetS = h.targetS;

      if (targetS < currentS - 0.5) {
        targetS += 1.0;
      } else if (targetS > currentS + 0.5) {
        currentS += 1.0;
      }

      // 指数追従
      final kS = 1.2 * tighten; // 縦方向の追従係数
      final kL = 2.0 * tighten; // 横方向の追従係数

      final newS = currentS + (targetS - currentS) * (1 - math.exp(-kS * dt));
      final newLane = h.lane + (h.targetLane - h.lane) * (1 - math.exp(-kL * dt));

      h.s = newS % 1.0;
      h.lane = newLane.clamp(-1.0, 1.0);

      // 実座標へ反映
      final pos = track.positionOnTrack(h.s, h.lane);
      h.position = pos;

      final fwd = track.forwardOnTrack(h.s);
      h.headingRad = math.atan2(fwd.y, fwd.x);
    }
  }

  void _applyTargetsForCurrentSegment() {
    final segments = config.course.segments;
    final seg = segments[_segIndex];

    final groups = config.predictionBySegment[seg.id];
    if (groups == null || groups.isEmpty) {
      // 予想がない場合：枠番順に仮ターゲット
      _applyFallbackTargets(seg);
      return;
    }

    // セグメント終端の “形” を作る。
    // - 前のグループほど targetS を大きく（前へ）
    // - グループ内は少しずつズラして重なり防止
    final sBase = (seg.timeEnd - 0.02).clamp(0.0, 1.0);

    // 馬ID -> component
    final map = {for (final h in horseComponents) h.spec.id: h};

    double groupGap = 0.018; // 馬群間の縦差（小さいほど密集）
    double withinGap = 0.007; // 馬群内の縦差

    for (int gi = 0; gi < groups.length; gi++) {
      final ids = groups[gi];

      // 前のグループほど前（= sを少し大きく）
      final groupFrontS = (sBase + (groups.length - 1 - gi) * groupGap) % 1.0;

      for (int j = 0; j < ids.length; j++) {
        final h = map[ids[j]];
        if (h == null) continue;

        // 同じ群内で少し縦ズラし
        final ts = (groupFrontS - j * withinGap) % 1.0;

        // 横方向：群内で散らす + 馬の laneBias を反映
        // 例: 内外に3列程度
        final laneSlots = math.max(2, math.min(4, ids.length));
        final slot = j % laneSlots;
        final centered = (slot - (laneSlots - 1) / 2.0);
        final tl = (centered * 0.18) + h.spec.laneBias * 0.25;

        h.targetS = ts;
        h.targetLane = tl.clamp(-0.95, 0.95);
      }
    }

    // groupsに入ってない馬がいたらフォールバックで埋める
    for (final h in horseComponents) {
      final found = groups.any((g) => g.contains(h.spec.id));
      if (!found) {
        h.targetS = (sBase - 0.05) % 1.0;
        h.targetLane = h.spec.laneBias * 0.25;
      }
    }
  }

  void _applyFallbackTargets(RaceSegment seg) {
    final sBase = (seg.timeEnd - 0.02).clamp(0.0, 1.0);

    // 枠番（馬番）順で前後を作る
    final sorted = [...horseComponents]
      ..sort((a, b) => a.spec.frame.number.compareTo(b.spec.frame.number));

    for (int i = 0; i < sorted.length; i++) {
      final h = sorted[i];
      h.targetS = (sBase - i * 0.01) % 1.0;
      // 交互に内外へ
      final tl = ((i % 2 == 0) ? -0.2 : 0.2) + h.spec.laneBias * 0.2;
      h.targetLane = tl;
    }
  }
}
