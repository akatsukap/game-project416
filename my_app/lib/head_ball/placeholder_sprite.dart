import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

/// プレースホルダースプライトジェネレーター
///
/// 画像ファイルが存在しない場合に、プログラム的に
/// 色付きの矩形スプライトを生成します。
class PlaceholderSpriteGenerator {
  /// キャラクターIDに対応する色マップ
  static const Map<String, Color> characterColors = {
    'local_hero_1': Color(0xFF3498DB), // 青
    'shop_owner': Color(0xFFE74C3C), // 赤
    'student': Color(0xFF2ECC71), // 緑
    'firefighter': Color(0xFFE67E22), // オレンジ
    'security_guard': Color(0xFF9B59B6), // 紫
  };

  /// ゲームオブジェクトの色マップ
  static const Map<String, Color> gameObjectColors = {
    'ball': Color(0xFFFFFFFF), // 白
    'goal': Color(0xFFECF0F1), // 明るいグレー
    'field': Color(0xFF27AE60), // 濃い緑
  };

  /// エフェクトの色マップ
  static const Map<String, Color> effectColors = {
    'speed_boost': Color(0xFF3498DB), // 青
    'power_kick': Color(0xFFE74C3C), // 赤
    'time_stop': Color(0xFF9B59B6), // 紫
    'jump_boost': Color(0xFFE67E22), // オレンジ
    'shield': Color(0xFF2ECC71), // 緑
    'particle': Color(0xFFFFFFFF), // 白
  };

  /// 単色の矩形スプライトを生成
  ///
  /// [width] スプライトの幅
  /// [height] スプライトの高さ
  /// [color] スプライトの色
  /// 戻り値: 生成されたSprite
  static Future<Sprite> generateColoredSprite(
    int width,
    int height,
    Color color,
  ) async {
    // PictureRecorderを使用してキャンバスに描画
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = color;

    // 矩形を描画
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    // 境界線を描画
    final borderPaint = ui.Paint()
      ..color = const Color(0xFF000000)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      borderPaint,
    );

    // Pictureを終了してImageに変換
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    // SpriteとしてImageをラップ
    return Sprite(image);
  }

  /// 円形のスプライトを生成
  ///
  /// [diameter] 円の直径
  /// [color] スプライトの色
  /// 戻り値: 生成されたSprite
  static Future<Sprite> generateCircleSprite(int diameter, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = color;

    final radius = diameter / 2.0;
    final center = ui.Offset(radius, radius);

    // 円を描画
    canvas.drawCircle(center, radius - 2, paint);

    // 境界線を描画
    final borderPaint = ui.Paint()
      ..color = const Color(0xFF000000)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius - 2, borderPaint);

    // Pictureを終了してImageに変換
    final picture = recorder.endRecording();
    final image = await picture.toImage(diameter, diameter);

    return Sprite(image);
  }

  /// キャラクターIDからプレースホルダースプライトを生成
  ///
  /// [characterId] キャラクターID
  /// 戻り値: 生成されたSprite
  static Future<Sprite> generateCharacterSprite(String characterId) async {
    final color = characterColors[characterId] ?? const Color(0xFF95A5A6);
    return generateCircleSprite(64, color);
  }

  /// ボールのプレースホルダースプライトを生成
  ///
  /// 戻り値: 生成されたSprite
  static Future<Sprite> generateBallSprite() async {
    return generateCircleSprite(32, gameObjectColors['ball']!);
  }

  /// ゴールのプレースホルダースプライトを生成
  ///
  /// 戻り値: 生成されたSprite
  static Future<Sprite> generateGoalSprite() async {
    return generateColoredSprite(128, 256, gameObjectColors['goal']!);
  }

  /// フィールド背景のプレースホルダースプライトを生成
  ///
  /// [width] 背景の幅
  /// [height] 背景の高さ
  /// 戻り値: 生成されたSprite
  static Future<Sprite> generateFieldSprite(int width, int height) async {
    return generateColoredSprite(width, height, gameObjectColors['field']!);
  }

  /// エフェクト名からプレースホルダースプライトを生成
  ///
  /// [effectName] エフェクト名
  /// 戻り値: 生成されたSprite
  static Future<Sprite> generateEffectSprite(String effectName) async {
    final color = effectColors[effectName] ?? const Color(0xFFFFFFFF);
    final size = effectName == 'particle' ? 8 : 64;
    return generateCircleSprite(size, color);
  }
}
