import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'race_course.dart';

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

  bool get _ready => _ovalRect.width > 0 && _ovalRect.height > 0;

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

    final shrink = trackWidth / 2 + 8;
    _ovalRect = Rect.fromCenter(
      center: Offset(_center.x, _center.y),
      width: (rx * 2) - shrink,
      height: (ry * 2) - shrink,
    );
  }

  // 方向に応じたtheta
  double _thetaForS(double s) {
    // 左回り:+ 2πs / 右回り:- 2πs
    final sign = (course.direction == TrackDirection.left) ? 1.0 : -1.0;
    return (-math.pi / 2) + (math.pi * 2 * s * sign);
  }

  /// 進行度 s(0..1) からトラック上の位置を返す
  Vector2 positionOnTrack(double s, double laneOffset) {
    if (!_ready) return Vector2.zero();

    final theta = _thetaForS(s);

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
    if (!_ready) return Vector2(1, 0);

    final theta = _thetaForS(s);

    // 左回り sign=+1: (-sin, cos)
    // 右回り sign=-1: ( sin, -cos)
    final sign = (course.direction == TrackDirection.left) ? 1.0 : -1.0;
    final tx = -math.sin(theta) * sign;
    final ty = math.cos(theta) * sign;

    return Vector2(tx, ty)..normalize();
  }

  // TrackCoord -> 画面座標
  Vector2 worldFromCoord(TrackCoord c) => positionOnTrack(c.s, c.lane);

  // 画面座標 -> TrackCoord（近似）
  TrackCoord coordFromWorld(Vector2 p) {
    if (!_ready) return const TrackCoord(s: 0.0, lane: 0.0);

    final dx = p.x - _center.x;
    final dy = p.y - _center.y;

    final rx = (_ovalRect.width / 2);
    final ry = (_ovalRect.height / 2);

    final nx = dx / (rx == 0 ? 1 : rx);
    final ny = dy / (ry == 0 ? 1 : ry);

    final theta = math.atan2(ny, nx);

    // direction に応じて s を逆算
    final sign = (course.direction == TrackDirection.left) ? 1.0 : -1.0;

    // theta = (-pi/2) + 2pi*s*sign  =>  s = (theta + pi/2)/(2pi*sign)
    var s = (theta + math.pi / 2) / (math.pi * 2 * sign);
    s = (s % 1.0 + 1.0) % 1.0;

    final centerPos = positionOnTrack(s, 0.0);
    final dir = forwardOnTrack(s);
    final normal = Vector2(-dir.y, dir.x);

    final v = p - centerPos;
    final dist = v.dot(normal);

    final lane = (dist / (trackWidth * 0.35)).clamp(-1.0, 1.0);
    return TrackCoord(s: s, lane: lane);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _grass);

    _track.strokeWidth = trackWidth;
    canvas.drawOval(_ovalRect, _track);

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
