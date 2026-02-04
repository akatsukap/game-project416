import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// レース区間（セグメント）
/// timeEnd: 0.0〜1.0 のレース進行割合で、このセグメントが終わる位置
class RaceSegment {
  final String id;
  final String name;
  final double timeEnd; // 0.0..1.0
  final double tighten; // 馬群の“収束しやすさ”(大きいほど隊列が変わりやすい)

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

  /// トラック形状（楕円）を描くための “外周の半径比”
  /// 例: (1.6, 1.0) なら横長
  final Vector2 ovalScale;

  const RaceCourse({
    required this.id,
    required this.name,
    required this.segments,
    this.ovalScale = const Vector2(1.6, 1.0),
  });
}

/// トラック描画 + セグメント区切りのガイドを表示するコンポーネント
class TrackComponent extends PositionComponent {
  TrackComponent({
    required this.course,
  });

  final RaceCourse course;

  // トラックの見た目
  double trackWidth = 72.0;
  double laneWidth = 12.0;
  int laneCount = 6;

  // 内側余白
  double padding = 24.0;

  // 色
  final Paint _trackFill = Paint()..color = const Color(0xFF2E7D32); // 芝っぽい緑
  final Paint _trackLane = Paint()
    ..color = const Color(0xFF8D6E63) // ダートっぽい茶
    ..style = PaintingStyle.stroke
    ..strokeWidth = 72.0;

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
  double _rx = 1.0;
  double _ry = 1.0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = Vector2.zero();

    final w = size.x;
    final h = size.y;

    _center = Vector2(w / 2, h / 2);

    // 楕円半径（内側余白込み）
    final usableW = w - padding * 2;
    final usableH = h - padding * 2;

    // 横長・縦長は ovalScale で調整
    final base = math.min(usableW / course.ovalScale.x, usableH / course.ovalScale.y);
    _rx = (base * course.ovalScale.x) / 2;
    _ry = (base * course.ovalScale.y) / 2;

    // 外周のstrokeが太いので少し縮める
    final shrink = trackWidth / 2 + 8;
    _ovalRect = Rect.fromCenter(
      center: Offset(_center.x, _center.y),
      width: (_rx * 2) - shrink,
      height: (_ry * 2) - shrink,
    );
  }

  /// 進行度 s(0..1) からトラック上の位置を返す
  /// laneOffset: 0 を中心として -1..+1 程度の横ずれ（外側/内側）
  Vector2 positionOnTrack(double s, double laneOffset) {
    // s(0..1) -> angle(ラジアン)
    // 上(12時)から時計回りに進む感じにする
    final theta = (-math.pi / 2) + (math.pi * 2 * s);

    final x = _center.x + (_ovalRect.width / 2) * math.cos(theta);
    final y = _center.y + (_ovalRect.height / 2) * math.sin(theta);

    // トラックの法線方向に laneOffset 分だけオフセット（簡易）
    // 法線は楕円の勾配に合わせるのが理想だが、MVPは角度ベースでOK
    final nx = math.cos(theta);
    final ny = math.sin(theta);

    final offset = laneOffset * (trackWidth * 0.35);
    return Vector2(x + nx * offset, y + ny * offset);
  }

  /// 進行度 s における進行方向（単位ベクトル）を返す（カメラ向け/向き補正用）
  Vector2 forwardOnTrack(double s) {
    final theta = (-math.pi / 2) + (math.pi * 2 * s);
    // 接線方向（時計回り）
    final tx = -math.sin(theta);
    final ty = math.cos(theta);
    final v = Vector2(tx, ty);
    v.normalize();
    return v;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 芝背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      _trackFill,
    );

    // ダート（太い楕円線）
    _trackLane.strokeWidth = trackWidth;
    canvas.drawOval(_ovalRect, _trackLane);

    // レーン線（内外）
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

    // セグメント境界線（timeEnd 位置に目印を置く）
    for (final seg in course.segments) {
      final s = seg.timeEnd.clamp(0.0, 1.0);
      final p = positionOnTrack(s, 0.0);
      final dir = forwardOnTrack(s);
      final n = Vector2(-dir.y, dir.x); // 垂直方向

      final len = trackWidth * 0.85;
      final a = Offset(p.x - n.x * len, p.y - n.y * len);
      final b = Offset(p.x + n.x * len, p.y + n.y * len);
      canvas.drawLine(a, b, _segmentLine);

      // ラベル
      _labelPaint.render(
        canvas,
        seg.name,
        Vector2(p.x + 8, p.y + 8),
        anchor: Anchor.topLeft,
      );
    }
  }
}
