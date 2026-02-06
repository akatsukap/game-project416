import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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

  RaceCourse({
    required this.id,
    required this.name,
    required this.segments,
    Vector2? ovalScale,
  }) : ovalScale = ovalScale ?? Vector2(1.6, 1.0);
}

/// トラック描画 + セグメント区切りのガイドを表示するコンポーネント
class TrackComponent extends PositionComponent {
  TrackComponent({required this.course});

  final RaceCourse course;

  // 見た目
  double trackWidth = 72.0;
  int laneCount = 6;
  double padding = 24.0;

  final Paint _grass = Paint()..color = const Color(0xFF2E7D32);
  final Paint _track = Paint()
    ..color = const Color(0xFF8D6E63)
    ..style = PaintingStyle.stroke;

  final Paint _laneLine = Paint()
    ..color = const Color(0xB3FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final Paint _segmentLine = Paint()
    ..color = const Color(0x99FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  final TextPaint _labelPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  Rect _ovalRect = Rect.zero;
  Vector2 _center = Vector2.zero();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = Vector2.zero();

    final w = size.x;
    final h = size.y;
    _center = Vector2(w / 2, h / 2);

    final usableW = w - padding * 2;
    final usableH = h - padding * 2;

    final base = math.min(
      usableW / course.ovalScale.x,
      usableH / course.ovalScale.y,
    );

    final rx = (base * course.ovalScale.x) / 2;
    final ry = (base * course.ovalScale.y) / 2;

    final shrink = trackWidth / 2 + 8; // stroke が太いので少し縮める
    _ovalRect = Rect.fromCenter(
      center: Offset(_center.x, _center.y),
      width: (rx * 2) - shrink,
      height: (ry * 2) - shrink,
    );
  }

  /// 進行度 s(0..1) からトラック上の位置を返す
  Vector2 positionOnTrack(double s, double laneOffset) {
    final theta = (-math.pi / 2) + (math.pi * 2 * s);

    final x = _center.x + (_ovalRect.width / 2) * math.cos(theta);
    final y = _center.y + (_ovalRect.height / 2) * math.sin(theta);

    // 法線方向（簡易）
    final nx = math.cos(theta);
    final ny = math.sin(theta);

    final offset = laneOffset * (trackWidth * 0.35);
    return Vector2(x + nx * offset, y + ny * offset);
  }

  /// 進行方向（単位ベクトル）
  Vector2 forwardOnTrack(double s) {
    final theta = (-math.pi / 2) + (math.pi * 2 * s);
    final tx = -math.sin(theta);
    final ty = math.cos(theta);
    final v = Vector2(tx, ty);
    v.normalize();
    return v;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 背景（芝）
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _grass);

    // トラック（楕円）
    _track.strokeWidth = trackWidth;
    canvas.drawOval(_ovalRect, _track);

    // レーン線
    for (int i = 1; i < laneCount; i++) {
      final w = _ovalRect.width - (trackWidth * (i / laneCount));
      final h = _ovalRect.height - (trackWidth * (i / laneCount));
      final r = Rect.fromCenter(
        center: Offset(_center.x, _center.y),
        width: w,
        height: h,
      );
      canvas.drawOval(r, _laneLine);
    }

    // セグメント境界線
    for (final seg in course.segments) {
      final s = seg.timeEnd.clamp(0.0, 1.0);
      final p = positionOnTrack(s, 0.0);
      final dir = forwardOnTrack(s);
      final n = Vector2(-dir.y, dir.x);

      final len = trackWidth * 0.85;
      canvas.drawLine(
        Offset(p.x - n.x * len, p.y - n.y * len),
        Offset(p.x + n.x * len, p.y + n.y * len),
        _segmentLine,
      );

      _labelPaint.render(canvas, seg.name, Vector2(p.x + 8, p.y + 8));
    }
  }
}
