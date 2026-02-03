import 'dart:ui' show Canvas;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'sprite_loader.dart';

/// サッカーボールコンポーネント
///
/// BodyComponentを継承し、円形の物理ボディを持つボールを実装します。
/// 壁との衝突時の反射、地面との衝突時のバウンドを実装します。
/// 要件: 2.3, 4.3, 4.4
class Ball extends BodyComponent with ContactCallbacks {
  /// ボールの半径（メートル単位）
  static const double radius = 0.3;

  /// ボールの初期位置
  @override
  final Vector2 position;

  /// ボールがゴールに入っているかどうか
  bool isInGoal = false;

  /// ボールのスプライト
  Sprite? _sprite;

  /// コンストラクタ
  ///
  /// [position] ボールの初期位置（デフォルトはフィールド中央）
  Ball({Vector2? position})
    : position = position ?? Vector2(10.0, 6.0); // デフォルトはフィールド中央

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ボールのスプライトを読み込む
    _sprite = await SpriteLoader.loadSpriteWithFallback('game/ball.png');
  }

  @override
  Body createBody() {
    // ボディの定義
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.dynamic, // 動的なボール（物理演算で動く）
      linearDamping: 0.1, // 線形減衰（空気抵抗のような効果）
      angularDamping: 0.1, // 角度減衰（回転の減衰）
    );

    // ボディを作成
    final body = world.createBody(bodyDef);

    // 形状の定義（円形）
    final shape = CircleShape()..radius = radius;

    // フィクスチャの定義
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3, // 摩擦係数
      restitution: 0.7, // 反発係数（バウンドの強さ）
      density: 1.0, // 密度（質量の計算に使用）
    );

    // フィクスチャをボディに追加
    body.createFixture(fixtureDef);

    return body;
  }

  /// ボールにキックの力を加える
  ///
  /// [direction] キックの方向（正規化されたベクトル）
  /// [power] キックの力の大きさ
  void applyKick(Vector2 direction, double power) {
    // 方向ベクトルを正規化して力を適用
    final normalizedDirection = direction.normalized();
    final impulse = normalizedDirection * power;
    body.applyLinearImpulse(impulse);
  }

  /// ボールの位置と速度をリセットする
  ///
  /// 得点後などにボールを初期状態に戻します。
  void reset() {
    // コンポーネントがマウントされていない場合は何もしない
    if (!isMounted) {
      return;
    }

    // 位置をリセット
    body.setTransform(position, 0);

    // 速度をリセット
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;

    // ゴール状態をリセット
    isInGoal = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // スプライトが読み込まれている場合は描画
    if (_sprite != null) {
      // スプライトをボールの位置に描画
      final spriteSize = radius * 2;
      _sprite!.render(
        canvas,
        position: Vector2(-radius, -radius),
        size: Vector2(spriteSize, spriteSize),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 速度が極端に大きくなりすぎないように制限
    final velocity = body.linearVelocity;
    const maxSpeed = 30.0; // 最大速度（メートル/秒）

    if (velocity.length > maxSpeed) {
      body.linearVelocity = velocity.normalized() * maxSpeed;
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);

    // ゴールとの衝突を検出
    // Goalクラスをインポートして型チェックを行う
    // 現時点では、ContactCallbacksを持つオブジェクトとの衝突を処理
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);
  }
}
