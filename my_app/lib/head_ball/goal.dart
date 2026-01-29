import 'dart:ui' show Canvas;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'ball.dart';
import 'sprite_loader.dart';

/// ゴールコンポーネント
///
/// フィールドの両端に配置され、ボールの侵入を検出して得点イベントを発火します。
/// 要件: 4.5
class Goal extends BodyComponent with ContactCallbacks {
  /// どちらのプレイヤーのゴールか（1 or 2）
  /// プレイヤー1のゴールは右側、プレイヤー2のゴールは左側
  final int playerNumber;

  /// ゴールの位置
  @override
  final Vector2 position;

  /// ゴールのサイズ（幅、高さ）
  final Vector2 size;

  /// 得点コールバック
  /// ボールがゴールに入ったときに呼び出されます
  final Function(int playerNumber)? onGoalScored;

  /// ゴールのスプライト
  Sprite? _sprite;

  /// コンストラクタ
  ///
  /// [playerNumber] どちらのプレイヤーのゴールか（1 or 2）
  /// [position] ゴールの中心位置
  /// [size] ゴールのサイズ（幅、高さ）
  /// [onGoalScored] 得点時のコールバック関数
  Goal({
    required this.playerNumber,
    required this.position,
    required this.size,
    this.onGoalScored,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ゴールのスプライトを読み込む
    _sprite = await SpriteLoader.loadSpriteWithFallback('assets/game/goal.png');
  }

  @override
  Body createBody() {
    // ボディの定義
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static, // 静的なゴール（動かない）
    );

    // ボディを作成
    final body = world.createBody(bodyDef);

    // 形状の定義（矩形）
    final shape = PolygonShape()
      ..setAsBox(
        size.x / 2, // 半幅
        size.y / 2, // 半高
        Vector2.zero(),
        0,
      );

    // フィクスチャの定義
    final fixtureDef = FixtureDef(
      shape,
      isSensor: true, // センサーとして設定（物理的な衝突はしない）
      density: 0.0, // 密度（静的オブジェクトなので0）
    );

    // フィクスチャをボディに追加
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // スプライトが読み込まれている場合は描画
    if (_sprite != null) {
      // スプライトをゴールの位置に描画
      _sprite!.render(
        canvas,
        position: Vector2(-size.x / 2, -size.y / 2),
        size: size,
      );
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);

    // ボールとの衝突を検出
    if (other is Ball) {
      _handleGoalScored();
    }
  }

  /// 得点処理
  ///
  /// ボールがゴールに入ったときに呼び出されます。
  /// 相手プレイヤーに得点が入ります（自分のゴールに入れられた場合）。
  void _handleGoalScored() {
    if (onGoalScored != null) {
      // 自分のゴールに入ったので、相手プレイヤーに得点
      final scoringPlayer = playerNumber == 1 ? 2 : 1;
      onGoalScored!(scoringPlayer);
    }
  }
}
