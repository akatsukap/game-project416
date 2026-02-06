import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'sample_config.dart';

class HorseComponent extends PositionComponent {
  final HorseSpec spec;

  HorseComponent({required this.spec});

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = spec.gateColor.toColor().withValues(alpha: 0.9);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${spec.gateNumber}',
        style: TextStyle(
          color: spec.gateColor == GateColor.white ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x);

    textPainter.paint(canvas, Offset(6, (size.y - textPainter.height) / 2));
  }
}
