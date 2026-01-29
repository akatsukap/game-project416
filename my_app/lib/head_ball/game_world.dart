import 'dart:ui' show Canvas, Color, Paint, Rect;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'goal.dart';
import 'sprite_loader.dart';

/// ゲームの物理世界を管理するコンポーネント
///
/// Forge2D Worldの設定、フィールド境界の作成、重力の設定を担当します。
/// 要件: 4.1, 4.2, 4.6
class GameWorld extends Component with HasGameReference<Forge2DGame> {
  /// フィールドの幅（メートル単位）
  static const double fieldWidth = 20.0;

  /// フィールドの高さ（メートル単位）
  static const double fieldHeight = 12.0;

  /// 壁の厚さ（メートル単位）
  static const double wallThickness = 0.5;

  /// ゴールの幅（メートル単位）
  static const double goalWidth = 0.5;

  /// ゴールの高さ（メートル単位）
  static const double goalHeight = 4.0;

  /// 上部境界
  late final BodyComponent topBoundary;

  /// 下部境界（地面）
  late final BodyComponent bottomBoundary;

  /// 左側の壁
  late final BodyComponent leftWall;

  /// 右側の壁
  late final BodyComponent rightWall;

  /// 左側のゴール（プレイヤー2のゴール）
  late final Goal leftGoal;

  /// 右側のゴール（プレイヤー1のゴール）
  late final Goal rightGoal;

  /// 得点コールバック
  final Function(int playerNumber)? onGoalScored;

  /// フィールド背景のスプライト
  Sprite? _fieldSprite;

  /// 背景コンポーネント
  late final _FieldBackground _background;

  /// コンストラクタ
  GameWorld({this.onGoalScored}) : super(priority: -100); // 背景として最背面に配置

  @override
  Future<void> onLoad() async {
    try {
      await super.onLoad();

      print('GameWorld: onLoad開始');

      // フィールド背景のスプライトを読み込む
      _fieldSprite = await SpriteLoader.loadSpriteWithFallback(
        'assets/game/field_background.png',
      );

      // 背景コンポーネントを作成して追加
      _background = _FieldBackground(sprite: _fieldSprite);
      await game.world.add(_background);
      print('GameWorld: 背景追加完了');

      setupPhysics();
      createBoundaries();
      print('GameWorld: 境界作成完了');
      createGoals();
      print('GameWorld: ゴール作成完了');
    } catch (e) {
      // 物理世界の初期化エラーをログに記録
      print('ゲームワールドの初期化に失敗しました: $e');
      rethrow; // 上位レイヤーでエラーを処理できるように再スロー
    }
  }

  /// 物理エンジンの設定
  ///
  /// 重力をVector2(0, 9.8)に設定します。
  /// Y軸正方向が下なので、9.8は下向きの重力を意味します。
  void setupPhysics() {
    // Forge2DGameの重力は既にコンストラクタで設定されているため、
    // ここでは追加の物理設定を行います
    // 重力はHeadBallGameのコンストラクタで設定されます
  }

  /// フィールド境界を作成
  ///
  /// 上下左右の壁を作成し、ボールとプレイヤーがフィールド外に出ないようにします。
  void createBoundaries() {
    try {
      // 上部境界
      topBoundary = _createWall(
        position: Vector2(fieldWidth / 2, -wallThickness / 2),
        size: Vector2(fieldWidth, wallThickness),
      );

      // 下部境界（地面）
      bottomBoundary = _createWall(
        position: Vector2(fieldWidth / 2, fieldHeight + wallThickness / 2),
        size: Vector2(fieldWidth, wallThickness),
      );

      // 左側の壁
      leftWall = _createWall(
        position: Vector2(-wallThickness / 2, fieldHeight / 2),
        size: Vector2(wallThickness, fieldHeight),
      );

      // 右側の壁
      rightWall = _createWall(
        position: Vector2(fieldWidth + wallThickness / 2, fieldHeight / 2),
        size: Vector2(wallThickness, fieldHeight),
      );

      // ゲームに境界を追加
      game.world.add(topBoundary);
      game.world.add(bottomBoundary);
      game.world.add(leftWall);
      game.world.add(rightWall);
    } catch (e) {
      // 境界作成エラーをログに記録
      print('フィールド境界の作成に失敗しました: $e');
      rethrow;
    }
  }

  /// ゴールを作成
  ///
  /// フィールドの左右にゴールを配置します。
  /// 左側のゴールはプレイヤー2のゴール、右側のゴールはプレイヤー1のゴールです。
  void createGoals() {
    try {
      // 左側のゴール（プレイヤー2のゴール）
      // フィールドの左端、地面から少し上に配置
      leftGoal = Goal(
        playerNumber: 2,
        position: Vector2(goalWidth / 2, fieldHeight - goalHeight / 2),
        size: Vector2(goalWidth, goalHeight),
        onGoalScored: onGoalScored,
      );

      // 右側のゴール（プレイヤー1のゴール）
      // フィールドの右端、地面から少し上に配置
      rightGoal = Goal(
        playerNumber: 1,
        position: Vector2(
          fieldWidth - goalWidth / 2,
          fieldHeight - goalHeight / 2,
        ),
        size: Vector2(goalWidth, goalHeight),
        onGoalScored: onGoalScored,
      );

      // ゲームにゴールを追加
      game.world.add(leftGoal);
      game.world.add(rightGoal);
    } catch (e) {
      // ゴール作成エラーをログに記録
      print('ゴールの作成に失敗しました: $e');
      rethrow;
    }
  }

  /// 壁を作成するヘルパーメソッド
  ///
  /// [position] 壁の中心位置
  /// [size] 壁のサイズ（幅、高さ）
  BodyComponent _createWall({
    required Vector2 position,
    required Vector2 size,
  }) {
    return _WallBody(position: position, size: size);
  }
}

/// フィールド背景を描画するコンポーネント
class _FieldBackground extends PositionComponent {
  /// 背景スプライト
  final Sprite? sprite;

  /// コンストラクタ
  _FieldBackground({this.sprite})
    : super(
        position: Vector2.zero(),
        size: Vector2(GameWorld.fieldWidth, GameWorld.fieldHeight),
        anchor: Anchor.topLeft,
        priority: -1000, // 最背面に配置
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // フィールド背景を描画（緑色の矩形）
    if (sprite != null) {
      sprite!.render(canvas, position: Vector2.zero(), size: size);
    } else {
      // スプライトがない場合は緑色の矩形を描画
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFF2E7D32), // 濃い緑色
      );
    }
  }
}

/// 壁の物理ボディを表すクラス
class _WallBody extends BodyComponent {
  /// 壁の位置
  @override
  final Vector2 position;

  /// 壁のサイズ
  final Vector2 size;

  /// コンストラクタ
  _WallBody({required this.position, required this.size});

  @override
  Body createBody() {
    // ボディの定義
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static, // 静的な壁（動かない）
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
      friction: 0.3, // 摩擦係数
      restitution: 0.5, // 反発係数（バウンド）
      density: 0.0, // 密度（静的オブジェクトなので0）
    );

    // フィクスチャをボディに追加
    body.createFixture(fixtureDef);

    return body;
  }
}
