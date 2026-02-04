import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// 枠番（1〜8）と枠色
enum FrameNumber {
  n1(1, '1枠', Color(0xFFFFFFFF)),
  n2(2, '2枠', Color(0xFF000000)),
  n3(3, '3枠', Color(0xFFE53935)),
  n4(4, '4枠', Color(0xFF1E88E5)),
  n5(5, '5枠', Color(0xFFFDD835)),
  n6(6, '6枠', Color(0xFF43A047)),
  n7(7, '7枠', Color(0xFFFB8C00)),
  n8(8, '8枠', Color(0xFFEC407A));

  final int number;
  final String label;
  final Color frameColor;

  const FrameNumber(this.number, this.label, this.frameColor);
}

/// 毛色（ゲームのデフォルメ用に baseColor を持つ）
enum CoatColor {
  kaga('鹿毛', '王道の茶色。たてがみ/脚先が黒いことが多い', Color(0xFF8D6E63)),
  kurokage('黒鹿毛', '鹿毛より黒みが強いダークブラウン', Color(0xFF5D4037)),
  aokage('青鹿毛', 'ほぼ黒。ハイライトに温かみ', Color(0xFF3E2723)),
  aoge('青毛', '全身完全な黒に近い', Color(0xFF212121)),
  kurige('栗毛', '明るい黄褐色。長毛も明るいことが多い', Color(0xFFB87333)),
  tochikurige('栃栗毛', '栗毛より濃く希少。チョコレートっぽい', Color(0xFF4E342E)),
  ashige('芦毛', '加齢で白〜灰に。斑点も出る', Color(0xFFB0BEC5)),
  shiroge('白毛', '生まれた時から白。非常に稀', Color(0xFFF5F5F5));

  final String label;
  final String description;
  final Color baseColor;

  const CoatColor(this.label, this.description, this.baseColor);
}

/// 馬（表示・レース挙動用モデル）
class HorseSpec {
  final String id;
  final String name;
  final FrameNumber frame;
  final CoatColor coat;

  /// “個性”として、レーン（横方向）に出やすい/内に入りやすいなども持てる
  /// -1.0..+1.0 を想定
  final double laneBias;

  const HorseSpec({
    required this.id,
    required this.name,
    required this.frame,
    required this.coat,
    this.laneBias = 0.0,
  });
}

/// デフォルメ馬駒（Canvas描画）
/// - position は RaceDirector が更新
/// - s (進行度) と lane (横ズレ) を持つ
class HorseComponent extends PositionComponent {
  HorseComponent({
    required this.spec,
  }) {
    anchor = Anchor.center;
    size = Vector2.all(28); // ベースサイズ（後で拡張）
  }

  final HorseSpec spec;

  /// 進行度（0..1）
  double s = 0.0;

  /// トラック中心からの横ずれ（-1..+1）
  double lane = 0.0;

  /// 向き（ラジアン）表示用
  double headingRad = 0.0;

  /// “目標” への追従用（RaceDirector が更新する）
  double targetS = 0.0;
  double targetLane = 0.0;

  // 描画
  late final Paint _bodyPaint = Paint()..color = spec.coat.baseColor;
  late final Paint _manePaint = Paint()..color = _darken(spec.coat.baseColor, 0.35);
  late final Paint _framePaint = Paint()..color = spec.frame.frameColor;
  late final Paint _stroke = Paint()
    ..color = const Color(0x66000000)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  final TextPainter _numPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );
  final TextPainter _namePainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    // 向き
    canvas.rotate(headingRad);

    // ボディ（楕円）
    final rect = Rect.fromCenter(
      center: const Offset(0, 2),
      width: size.x * 0.95,
      height: size.y * 0.65,
    );
    canvas.drawOval(rect, _bodyPaint);
    canvas.drawOval(rect, _stroke);

    // 頭（小さな円）
    final head = Rect.fromCircle(
      center: Offset(size.x * 0.35, -size.y * 0.05),
      radius: size.x * 0.22,
    );
    canvas.drawOval(head, _bodyPaint);
    canvas.drawOval(head, _stroke);

    // たてがみ（簡易）
    final mane = Path()
      ..moveTo(size.x * 0.18, -size.y * 0.20)
      ..quadraticBezierTo(size.x * 0.05, -size.y * 0.05, size.x * 0.12, size.y * 0.05)
      ..quadraticBezierTo(size.x * 0.18, size.y * 0.00, size.x * 0.22, -size.y * 0.10)
      ..close();
    canvas.drawPath(mane, _manePaint);

    // 枠色バッジ（背中に小円）
    final badge = Rect.fromCircle(
      center: Offset(-size.x * 0.10, -size.y * 0.08),
      radius: size.x * 0.18,
    );
    canvas.drawOval(badge, _framePaint);
    canvas.drawOval(badge, _stroke);

    // 馬番（バッジ内）
    final textColor = _contrastColor(spec.frame.frameColor);
    _numPainter.text = TextSpan(
      text: '${spec.frame.number}',
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    );
    _numPainter.layout();
    _numPainter.paint(
      canvas,
      Offset(
        badge.center.dx - _numPainter.width / 2,
        badge.center.dy - _numPainter.height / 2,
      ),
    );

    canvas.restore();

    // 名前（小さく下に）
    _namePainter.text = TextSpan(
      text: spec.name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
        ],
      ),
    );
    _namePainter.layout(maxWidth: 120);
    _namePainter.paint(canvas, Offset(-_namePainter.width / 2, size.y * 0.55));
  }

  static Color _darken(Color c, double amount) {
    final f = (1.0 - amount).clamp(0.0, 1.0);
    return Color.fromARGB(
      c.alpha,
      (c.red * f).round(),
      (c.green * f).round(),
      (c.blue * f).round(),
    );
  }

  static Color _contrastColor(Color bg) {
    // ざっくり輝度で白/黒を決める
    final lum = (0.299 * bg.red + 0.587 * bg.green + 0.114 * bg.blue) / 255.0;
    return lum > 0.55 ? Colors.black : Colors.white;
  }
}
