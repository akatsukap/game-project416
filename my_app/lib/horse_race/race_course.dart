import 'package:flame/components.dart';

/// 回り方向
enum TrackDirection {
  right, // 右回り（時計回り）
  left, // 左回り（反時計回り）
}

extension TrackDirectionLabel on TrackDirection {
  String get label => switch (this) {
        TrackDirection.right => '右回り',
        TrackDirection.left => '左回り',
      };
}

/// レース区間（セグメント）
class RaceSegment {
  final String id;
  final String name;

  /// 0.0..1.0 の進行率（この地点まで来たら次セグメント）
  final double timeEnd;

  /// 馬群の“収束しやすさ”
  final double tighten;

  const RaceSegment({
    required this.id,
    required this.name,
    required this.timeEnd,
    this.tighten = 2.0,
  });
}

/// 競馬場（コース）設定
class RaceCourse {
  final String id;
  final String name;
  final List<RaceSegment> segments;

  /// 例: (1.6, 1.0) なら横長
  final Vector2 ovalScale;

  /// 右回り/左回り
  final TrackDirection direction;

  RaceCourse({
    required this.id,
    required this.name,
    required this.segments,
    required this.direction,
    Vector2? ovalScale,
  }) : ovalScale = ovalScale ?? Vector2(1.6, 1.0);

  /// Phaseごとの基準s（簡易）
  /// ※将来「競馬場ごとのPhase定義テーブル」に差し替え
  double anchorSForPhase(String phaseId) {
    return switch (phaseId) {
      'start' => 0.00,
      'firstCorner' => 0.20,
      'backStretch' => 0.45,
      'thirdFourthCorner' => 0.70,
      'homestretch' => 0.85,
      'goal' => 1.00,
      _ => 0.00,
    };
  }
}
