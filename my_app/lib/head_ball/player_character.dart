import 'dart:ui' show Canvas, Paint, Rect, PaintingStyle;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';

import '../models/character_data.dart';
import 'ball.dart';
import 'head_ball_game.dart';
import 'jump_boost_ability.dart';
import 'power_kick_ability.dart';
import 'shield_ability.dart';
import 'special_ability.dart';
import 'speed_boost_ability.dart';
import 'sprite_loader.dart';
import 'time_stop_ability.dart';

/// プレイヤーキャラクターコンポーネント
///
/// BodyComponentを継承し、矩形の物理ボディを持つプレイヤーキャラクターを実装します。
/// ContactCallbacksで衝突検出、KeyboardHandlerでキーボード入力を処理します。
/// 要件: 1.5, 2.1, 2.2
class PlayerCharacter extends BodyComponent
    with ContactCallbacks, KeyboardHandler {
  /// キャラクターの幅（メートル単位）
  static const double width = 0.8;

  /// キャラクターの高さ（メートル単位）
  static const double height = 1.2;

  /// キャラクターデータ
  final CharacterData characterData;

  /// プレイヤー番号（1 or 2）
  final int playerNumber;

  /// 初期位置
  final Vector2 initialPosition;

  /// 移動速度（メートル/秒）
  late double speed;

  /// ジャンプ力（初速度、メートル/秒）
  late double jumpPower;

  /// キック力（ボールに加える力）
  late double kickPower;

  /// 地面にいるかどうか
  bool isOnGround = false;

  /// ジャンプ可能かどうか
  bool canJump = true;

  /// 特殊能力
  SpecialAbility? specialAbility;

  /// 特殊能力のクールダウン時間（秒）
  double specialAbilityCooldown = 0.0;

  /// 地面接触カウンター（複数の接触点を管理）
  int _groundContactCount = 0;

  /// ボールへの参照（キック用）
  Ball? _nearbyBall;

  /// ボールとの距離の閾値（メートル単位）
  static const double kickRange = 2.5;

  /// キャラクタースプライト
  Sprite? _sprite;

  /// キャラクターの色（スプライトがない場合の代替）
  late final Color _characterColor;

  /// コンストラクタ
  ///
  /// [characterData] キャラクターのデータ
  /// [playerNumber] プレイヤー番号（1 or 2）
  /// [initialPosition] 初期位置
  PlayerCharacter({
    required this.characterData,
    required this.playerNumber,
    required this.initialPosition,
  }) {
    try {
      // CharacterDataから能力値を初期化
      speed = characterData.speed;
      jumpPower = characterData.jumpPower;
      kickPower = characterData.kickPower;

      // 能力値の妥当性チェック
      if (speed <= 0 || jumpPower <= 0 || kickPower <= 0) {
        print('警告: キャラクター能力値が無効です (id: ${characterData.id})');
        // デフォルト値を設定
        speed = speed <= 0 ? 100.0 : speed;
        jumpPower = jumpPower <= 0 ? 300.0 : jumpPower;
        kickPower = kickPower <= 0 ? 500.0 : kickPower;
      }

      // 特殊能力を初期化
      _initializeSpecialAbility();

      // キャラクターの色を設定
      _characterColor = _getCharacterColor(characterData.id);
    } catch (e) {
      // 初期化エラーをログに記録
      print('プレイヤーキャラクターの初期化に失敗しました: $e');
      // デフォルト値を設定
      speed = 100.0;
      jumpPower = 300.0;
      kickPower = 500.0;
      _characterColor = const Color(0xFF95A5A6);
    }
  }

  /// キャラクターIDから色を取得
  Color _getCharacterColor(String characterId) {
    const colorMap = {
      'local_hero_1': Color(0xFF3498DB), // 青
      'shop_owner': Color(0xFFE74C3C), // 赤
      'student': Color(0xFF2ECC71), // 緑
      'firefighter': Color(0xFFE67E22), // オレンジ
      'security_guard': Color(0xFF9B59B6), // 紫
      'local_ace': Color(0xFFF39C12), // 金色（エースらしい色）
    };
    return colorMap[characterId] ?? const Color(0xFF95A5A6);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // キャラクタースプライトを読み込む
    try {
      _sprite = await SpriteLoader.loadSpriteWithFallback(
        characterData.spritePath,
      );
    } catch (e) {
      print('キャラクタースプライトの読み込みに失敗しました: $e');
      // スプライトなしで続行
    }
  }

  /// 特殊能力を初期化する
  ///
  /// キャラクターデータの特殊能力タイプに基づいて、
  /// 対応する特殊能力インスタンスを作成します。
  void _initializeSpecialAbility() {
    switch (characterData.specialAbilityType) {
      case SpecialAbilityType.speedBoost:
        specialAbility = SpeedBoostAbility();
        break;
      case SpecialAbilityType.powerKick:
        specialAbility = PowerKickAbility();
        break;
      case SpecialAbilityType.timeStop:
        specialAbility = TimeStopAbility();
        break;
      case SpecialAbilityType.jumpBoost:
        specialAbility = JumpBoostAbility();
        break;
      case SpecialAbilityType.shield:
        specialAbility = ShieldAbility();
        break;
    }
  }

  @override
  Body createBody() {
    // ボディの定義
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic, // 動的なキャラクター（物理演算で動く）
      fixedRotation: true, // 回転を固定（キャラクターが倒れないようにする）
    );

    // ボディを作成
    final body = world.createBody(bodyDef);

    // 形状の定義（矩形）
    final shape = PolygonShape()
      ..setAsBox(
        width / 2, // 半幅
        height / 2, // 半高
        Vector2.zero(), // 中心からのオフセット
        0, // 回転角度
      );

    // フィクスチャの定義
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.3, // 摩擦係数
      restitution: 0.0, // 反発係数（キャラクターはバウンドしない）
      density: 1.0, // 密度（質量の計算に使用）
    );

    // フィクスチャをボディに追加
    body.createFixture(fixtureDef);

    // 足元の地面検出用センサーを追加
    final footSensorShape = PolygonShape()
      ..setAsBox(
        width / 2 * 0.9, // 幅を広めに
        0.1, // センサーの高さを増やす
        Vector2(0, height / 2 + 0.05), // 足元より少し下に配置
        0,
      );

    final footSensorDef = FixtureDef(
      footSensorShape,
      isSensor: true, // センサーとして設定（物理的な衝突はしない）
    );

    body.createFixture(footSensorDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // スプライトが読み込まれている場合は描画
    if (_sprite != null) {
      _sprite!.render(
        canvas,
        position: Vector2(-width / 2, -height / 2),
        size: Vector2(width, height),
      );
    } else {
      // スプライトがない場合は色付きの矩形を描画
      final paint = Paint()..color = _characterColor;
      canvas.drawRect(
        Rect.fromLTWH(-width / 2, -height / 2, width, height),
        paint,
      );

      // 境界線を描画
      final borderPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05;
      canvas.drawRect(
        Rect.fromLTWH(-width / 2, -height / 2, width, height),
        borderPaint,
      );

      // プレイヤー番号を表示
      // TODO: テキストレンダリングを追加
    }
  }

  /// 左に移動する
  ///
  /// 要件: 2.1
  void moveLeft() {
    // 速度をメートル/秒に変換（speedはピクセル/秒として定義されている）
    // ここでは簡易的に1ピクセル = 0.01メートルとして扱う
    final velocityX = -(speed * 0.01);
    body.linearVelocity = Vector2(velocityX, body.linearVelocity.y);
  }

  /// 右に移動する
  ///
  /// 要件: 2.1
  void moveRight() {
    // 速度をメートル/秒に変換
    final velocityX = speed * 0.01;
    body.linearVelocity = Vector2(velocityX, body.linearVelocity.y);
  }

  /// ジャンプする
  ///
  /// 地面にいるときのみジャンプ可能です。
  /// 要件: 2.2
  void jump() {
    // 地面にいるか、地面接触カウントが0より大きい場合にジャンプ可能
    if ((isOnGround || _groundContactCount > 0) && canJump) {
      // ジャンプ力を上向きの速度として適用（Y軸負方向が上）
      // jumpPowerをメートル/秒に変換し、より強いジャンプにする
      final jumpVelocity = -(jumpPower * 0.015);
      body.linearVelocity = Vector2(body.linearVelocity.x, jumpVelocity);
      canJump = false;
      isOnGround = false;
    }
  }

  /// キックする
  ///
  /// ボールが近くにある場合、ボールに力を加えます。
  /// 要件: 2.4
  void kick() {
    // ボールが近くにある場合、ボールに力を加える
    if (_nearbyBall != null) {
      // プレイヤーからボールへの方向ベクトルを計算
      final toBall = _nearbyBall!.body.position - body.position;
      final distance = toBall.length;

      // キック範囲内にある場合のみキック
      if (distance <= kickRange) {
        // キックの方向を計算（プレイヤーの向きを考慮）
        // プレイヤーが向いている方向にキック
        final kickDirection = toBall.normalized();

        // キック力を適用（kickPowerを使用）
        // kickPowerはピクセル単位なので、メートル単位に変換
        final kickForce = kickPower * 0.1; // 調整係数
        _nearbyBall!.applyKick(kickDirection, kickForce);

        // パワーキック能力が有効な場合、キック後に解除
        if (specialAbility is PowerKickAbility) {
          final powerKick = specialAbility as PowerKickAbility;
          powerKick.onKickExecuted(this);
        }
      }
    }
  }

  /// 特殊能力を使用する
  ///
  /// クールダウン中でない場合、特殊能力を発動します。
  /// 要件: 5.1, 5.2, 5.3
  void useSpecialAbility() {
    // 特殊能力が存在し、使用可能な場合のみ発動
    if (specialAbility != null && specialAbility!.isReady) {
      // ゲームインスタンスを取得
      final game = findParent<HeadBallGame>();
      if (game != null) {
        // 特殊能力を発動
        specialAbility!.activate(this, game);
      }
    }
  }

  /// 位置をリセットする
  ///
  /// 得点後などにキャラクターを初期位置に戻します。
  void reset() {
    // コンポーネントがマウントされていない場合は何もしない
    if (!isMounted) {
      return;
    }

    body.setTransform(initialPosition, 0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0;
    isOnGround = false;
    canJump = true;
    _groundContactCount = 0;

    // 特殊能力の効果を解除
    if (specialAbility != null) {
      if (specialAbility is SpeedBoostAbility) {
        (specialAbility as SpeedBoostAbility).restoreSpeed(this);
      } else if (specialAbility is PowerKickAbility) {
        (specialAbility as PowerKickAbility).forceDeactivate(this);
      } else if (specialAbility is TimeStopAbility) {
        (specialAbility as TimeStopAbility).forceDeactivate();
      } else if (specialAbility is JumpBoostAbility) {
        (specialAbility as JumpBoostAbility).forceDeactivate(this);
      } else if (specialAbility is ShieldAbility) {
        (specialAbility as ShieldAbility).forceDeactivate();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 特殊能力のクールダウンを更新
    if (specialAbility != null) {
      specialAbility!.update(dt);
      // 後方互換性のため、specialAbilityCooldownも更新
      specialAbilityCooldown = specialAbility!.currentCooldown;

      // JumpBoostAbilityの効果時間が終了したらジャンプ力を元に戻す
      if (specialAbility is JumpBoostAbility) {
        final jumpBoost = specialAbility as JumpBoostAbility;
        if (!jumpBoost.isEffectActive &&
            jumpBoost.remainingEffectDuration <= 0) {
          jumpBoost.restoreJumpPower(this);
        }
      }
    }

    // 地面接触状態を更新
    isOnGround = _groundContactCount > 0;

    // 地面にいる場合、ジャンプ可能にする
    if (isOnGround) {
      canJump = true;
    }

    // 速度制限（横方向）
    final velocity = body.linearVelocity;
    const maxHorizontalSpeed = 5.0; // 最大横方向速度（メートル/秒）

    if (velocity.x.abs() > maxHorizontalSpeed) {
      body.linearVelocity = Vector2(
        velocity.x.sign * maxHorizontalSpeed,
        velocity.y,
      );
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);

    // ボールとの衝突を検出
    if (other is Ball) {
      _nearbyBall = other;

      // シールドが有効な場合は衝突時の力を無効化
      if (specialAbility is ShieldAbility) {
        final shield = specialAbility as ShieldAbility;
        if (shield.isEffectActive) {
          // シールドが有効な場合は何もしない
          return;
        }
      }

      // 衝突時にボールに力を加える（要件: 2.3）
      // プレイヤーの速度に基づいてボールに力を加える
      final playerVelocity = body.linearVelocity;

      // プレイヤーからボールへの方向を計算
      final toBall = other.body.position - body.position;
      final direction = toBall.normalized();

      // プレイヤーの速度とキャラクターの能力値に基づいて力を計算
      final impulseMagnitude = playerVelocity.length * 2.0 + (speed * 0.01);
      final impulse = direction * impulseMagnitude;

      // ボールに力を加える
      other.body.applyLinearImpulse(impulse);
    }

    // センサーフィクスチャとの接触を検出
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;

    // どちらかが足元センサーで、もう一方が地面の場合
    if ((fixtureA.isSensor && fixtureA.body == body) ||
        (fixtureB.isSensor && fixtureB.body == body)) {
      // 地面との接触をカウント
      _groundContactCount++;
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    super.endContact(other, contact);

    // ボールとの接触が終了した場合
    if (other is Ball && _nearbyBall == other) {
      _nearbyBall = null;
    }

    // センサーフィクスチャとの接触終了を検出
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;

    // どちらかが足元センサーで、もう一方が地面の場合
    if ((fixtureA.isSensor && fixtureA.body == body) ||
        (fixtureB.isSensor && fixtureB.body == body)) {
      // 地面との接触をデクリメント
      _groundContactCount--;
      if (_groundContactCount < 0) {
        _groundContactCount = 0;
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // キーボード入力処理（デバッグ用）
    // プレイヤー1: WASD、プレイヤー2: 矢印キー
    if (playerNumber == 1) {
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        moveLeft();
      } else if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        moveRight();
      }

      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.keyW) {
        jump();
      }

      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.space) {
        kick();
      }

      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.keyE) {
        useSpecialAbility();
      }
    } else if (playerNumber == 2) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        moveLeft();
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        moveRight();
      }

      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        jump();
      }

      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter) {
        kick();
      }

      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.keyI) {
        useSpecialAbility();
      }
    }

    return true;
  }
}
