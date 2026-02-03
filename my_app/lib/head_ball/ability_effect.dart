import 'dart:math' as dart_math;
import 'dart:ui' show Canvas, Offset, Paint, PaintingStyle;

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

import 'sprite_loader.dart';

/// 特殊能力のエフェクトコンポーネント
///
/// 特殊能力が発動されたときに表示される視覚エフェクトです。
/// 要件: 5.5（視覚的フィードバック）
class AbilityEffect extends PositionComponent {
  /// エフェクトの種類
  final String effectType;

  /// エフェクトの持続時間（秒）
  final double duration;

  /// エフェクトの経過時間
  double _elapsedTime = 0.0;

  /// エフェクトのスプライト
  Sprite? _sprite;

  /// エフェクトの色（スプライトがない場合に使用）
  final Color color;

  /// エフェクトのサイズ
  final Vector2 effectSize;

  /// エフェクトが完了したかどうか
  bool get isComplete => _elapsedTime >= duration;

  /// コンストラクタ
  ///
  /// [effectType] エフェクトの種類（speed_boost, power_kick, time_stopなど）
  /// [position] エフェクトの表示位置
  /// [duration] エフェクトの持続時間（秒）
  /// [color] エフェクトの色
  /// [effectSize] エフェクトのサイズ
  AbilityEffect({
    required this.effectType,
    required Vector2 position,
    required this.duration,
    required this.color,
    Vector2? effectSize,
  }) : effectSize = effectSize ?? Vector2.all(64),
       super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // エフェクトのスプライトを読み込む
    _sprite = await SpriteLoader.loadSpriteWithFallback(
      'effects/$effectType.png',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 経過時間を更新
    _elapsedTime += dt;

    // エフェクトが完了したら削除
    if (isComplete) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 透明度を計算（フェードアウト効果）
    final alpha = (1.0 - (_elapsedTime / duration)).clamp(0.0, 1.0);

    // スプライトを描画
    if (_sprite != null) {
      canvas.save();
      canvas.translate(-effectSize.x / 2, -effectSize.y / 2);

      // 透明度を適用
      final paint = Paint()..color = Color.fromRGBO(255, 255, 255, alpha);
      canvas.saveLayer(null, paint);

      _sprite!.render(canvas, size: effectSize);

      canvas.restore();
      canvas.restore();
    }
  }
}

/// パーティクルエフェクトコンポーネント
///
/// 小さなパーティクルを複数生成して視覚エフェクトを作成します。
class ParticleEffect extends PositionComponent {
  /// パーティクルの数
  final int particleCount;

  /// エフェクトの持続時間（秒）
  final double duration;

  /// エフェクトの経過時間
  double _elapsedTime = 0.0;

  /// パーティクルのリスト
  final List<_Particle> _particles = [];

  /// エフェクトの色
  final Color color;

  /// エフェクトが完了したかどうか
  bool get isComplete => _elapsedTime >= duration;

  /// コンストラクタ
  ///
  /// [position] エフェクトの中心位置
  /// [particleCount] パーティクルの数
  /// [duration] エフェクトの持続時間（秒）
  /// [color] パーティクルの色
  ParticleEffect({
    required Vector2 position,
    required this.particleCount,
    required this.duration,
    required this.color,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // パーティクルを生成
    for (int i = 0; i < particleCount; i++) {
      _particles.add(_Particle.random(color));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 経過時間を更新
    _elapsedTime += dt;

    // パーティクルを更新
    for (final particle in _particles) {
      particle.update(dt);
    }

    // エフェクトが完了したら削除
    if (isComplete) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 透明度を計算（フェードアウト効果）
    final alpha = (1.0 - (_elapsedTime / duration)).clamp(0.0, 1.0);

    // パーティクルを描画
    for (final particle in _particles) {
      particle.render(canvas, alpha);
    }
  }
}

/// パーティクルクラス
///
/// 個別のパーティクルの位置、速度、サイズを管理します。
class _Particle {
  /// パーティクルの位置
  Vector2 position;

  /// パーティクルの速度
  Vector2 velocity;

  /// パーティクルのサイズ
  double size;

  /// パーティクルの色
  Color color;

  /// コンストラクタ
  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });

  /// ランダムなパーティクルを生成
  ///
  /// [color] パーティクルの色
  factory _Particle.random(Color color) {
    final random = Vector2.random();
    final angle = random.x * 3.14159 * 2; // 0〜2πのランダムな角度
    final speed = 50.0 + random.y * 100.0; // 50〜150のランダムな速度

    return _Particle(
      position: Vector2.zero(),
      velocity: Vector2(speed * cos(angle), speed * sin(angle)),
      size: 2.0 + random.x * 4.0, // 2〜6のランダムなサイズ
      color: color,
    );
  }

  /// パーティクルを更新
  ///
  /// [dt] 前フレームからの経過時間（秒）
  void update(double dt) {
    // 位置を更新
    position += velocity * dt;

    // 重力を適用
    velocity.y += 200.0 * dt;
  }

  /// パーティクルを描画
  ///
  /// [canvas] 描画先のキャンバス
  /// [alpha] 透明度（0.0〜1.0）
  void render(Canvas canvas, double alpha) {
    final paint = Paint()
      ..color = color.withOpacity(alpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(position.x, position.y), size, paint);
  }
}

/// 数学関数のヘルパー
double cos(double radians) => dart_math.cos(radians);
double sin(double radians) => dart_math.sin(radians);
