import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'sample_config.dart';

class HorseComponent extends PositionComponent {
  HorseComponent({required this.spec});

  final HorseSpec spec;

  /// 周回位置（0..1）
  double s = 0.0;

  /// レーンオフセット（-1..+1）
  double lane = 0.0;

  /// 目標（director が更新）
  double targetS = 0.0;
  double targetLane = 0.0;

  /// 向き（ラジアン）
  double headingRad = 0.0;

  final Paint _paint = Paint()..color = const Color(0xFFE53935);

  @override
  void onLoad() {
    super.onLoad();
    size = Vector2.all(18); // 馬の見た目（丸）
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // body（丸）
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);

    // name（簡易）
    final tp = TextPainter(
      text: TextSpan(
        text: spec.frame.number.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
}
