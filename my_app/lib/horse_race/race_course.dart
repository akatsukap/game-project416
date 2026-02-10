import 'package:flame/components.dart';

/// レース区間（セグメント）
class RaceSegment {
  final String id;
  final String name;
  final double timeEnd; // 0.0..1.0
  final double tighten; // 馬群の“収束しやすさ”

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

  // NOTE:
  // Vector2 は const 生成できない（const Vector2(...) が不可）
  // なので RaceCourse を const にしない（＝non-const constructor）にするのが安全。
  RaceCourse({
    required this.id,
    required this.name,
    required this.segments,
    Vector2? ovalScale,
  }) : ovalScale = ovalScale ?? Vector2(1.6, 1.0);
}
