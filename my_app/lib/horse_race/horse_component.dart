import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'frame_color.dart';
import 'models.dart';

class HorseComponent extends PositionComponent with DragCallbacks {
  HorseComponent({
    required this.spec,
    required this.onDraggedEnd,
    this.radius = 18,
  });

  final HorseSpec spec;
  final void Function(String horseId, Vector2 worldPos) onDraggedEnd;

  final double radius;

  // 再生用（directorが使う）
  double s = 0.0;
  double lane = 0.0;
  double targetS = 0.0;
  double targetLane = 0.0;
  double headingRad = 0.0;

  // 編集用（ドラッグ中の見た目）
  bool _dragging = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(radius * 2);
    anchor = Anchor.center;
    priority = 10; // トラックより手前
  }

  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event); // ★ mustCallSuper 対応
    _dragging = true;
    return true; // このコンポーネントがドラッグを消費する
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event); // ★ mustCallSuper 対応

    // ★ event.delta は「ゲーム(親)座標系」での移動量
    // localDelta を使うと、回転/スケール/カメラ導入後にズレやすい
    position += event.localDelta;
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event); // ★ mustCallSuper 対応
    _dragging = false;

    // position は HorseComponent の親(=game)座標 = world座標
    onDraggedEnd(spec.id, position.clone());

    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event); // ★ mustCallSuper 対応
    _dragging = false;
    onDraggedEnd(spec.id, position.clone());
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final framePaint = Paint()..color = FrameColor.byFrame(spec.frame.number);

    // body
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      framePaint,
    );

    // drag outline（掴んでる感）
    if (_dragging) {
      final o = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(0.9);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2 - 1, o);
    }

    // 表示する番号：horseNo があるなら horseNo、なければ枠番号
    final displayNo = (spec.horseNo != 0) ? spec.horseNo : spec.frame.number;

    final tp = TextPainter(
      text: TextSpan(
        text: displayNo.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
}
