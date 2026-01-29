import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../models/character_data.dart';
import 'ball.dart';
import 'game_state.dart';
import 'game_world.dart';
import 'player_character.dart';

/// ヘッドボールサッカーゲームのメインゲームクラス
///
/// Forge2DGameを継承し、物理エンジンを使用した2D横スクロール型サッカーゲームを実装します。
/// HasCollisionDetectionミックスインにより、衝突検出機能を提供します。
class HeadBallGame extends Forge2DGame with HasCollisionDetection {
  /// 現在のゲーム状態
  GameState state = GameState.menu;

  /// プレイヤー1のスコア
  int player1Score = 0;

  /// プレイヤー2のスコア
  int player2Score = 0;

  /// 残り時間（秒）
  double remainingTime = 90.0;

  /// ゲームワールド（物理世界管理）
  late final GameWorld gameWorld;

  /// ボール
  late final Ball ball;

  /// ボールが初期化されているかどうか
  bool _isBallInitialized = false;

  /// プレイヤー1のキャラクター
  PlayerCharacter? player1;

  /// プレイヤー2のキャラクター
  PlayerCharacter? player2;

  /// プレイヤーが初期化されているかどうか
  bool _arePlayersInitialized = false;

  /// コンストラクタ
  ///
  /// Forge2Dの重力を設定します（Y軸正方向が下）
  /// 重力は9.8 m/s²（地球の重力加速度）
  HeadBallGame() : super(gravity: Vector2(0, 9.8)) {
    // デバッグモードを有効にして物理ボディを表示
    debugMode = true;
  }

  @override
  Future<void> onLoad() async {
    try {
      await super.onLoad();

      print('HeadBallGame: onLoad開始');

      // GameWorldコンポーネントを初期化して追加
      gameWorld = GameWorld(onGoalScored: _handleGoalScored);
      await world.add(gameWorld);
      print('HeadBallGame: GameWorld追加完了');

      // ボールを初期化して追加
      ball = Ball(
        position: Vector2(GameWorld.fieldWidth / 2, GameWorld.fieldHeight / 2),
      );
      await world.add(ball);
      _isBallInitialized = true;
      print('HeadBallGame: Ball追加完了');
    } catch (e) {
      // 物理エンジンの初期化エラーをログに記録
      print('物理エンジンの初期化に失敗しました: $e');
      print('スタックトレース: ${StackTrace.current}');
      // エラーが発生してもアプリがクラッシュしないようにする
      // 最小限の状態で続行
      rethrow; // 上位レイヤーでエラーを処理できるように再スロー
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    print('HeadBallGame: onGameResize - size: $size');

    // フィールド全体が画面に収まるようにズームレベルを計算
    // フィールドサイズ: 20m x 12m
    final fieldWidth = GameWorld.fieldWidth;
    final fieldHeight = GameWorld.fieldHeight;

    // 画面のアスペクト比とフィールドのアスペクト比を考慮
    final screenAspect = size.x / size.y;
    final fieldAspect = fieldWidth / fieldHeight;

    double zoom;
    if (screenAspect > fieldAspect) {
      // 画面が横長の場合、高さに合わせる
      zoom = size.y / fieldHeight;
    } else {
      // 画面が縦長の場合、幅に合わせる
      zoom = size.x / fieldWidth;
    }

    // 少し余白を持たせるために0.9倍にする
    zoom *= 0.9;

    camera.viewfinder.zoom = zoom;

    // カメラをフィールドの中心に配置
    camera.viewfinder.position = Vector2(fieldWidth / 2, fieldHeight / 2);

    print(
      'HeadBallGame: カメラズーム設定 - zoom: $zoom, position: ${camera.viewfinder.position}',
    );
  }

  /// 得点処理
  ///
  /// ゴールにボールが入ったときに呼び出されます。
  /// [playerNumber] 得点したプレイヤー（1 or 2）
  void _handleGoalScored(int playerNumber) {
    // スコアを更新
    if (playerNumber == 1) {
      player1Score++;
    } else if (playerNumber == 2) {
      player2Score++;
    }

    // 位置をリセット
    resetPositions();

    // TODO: 得点時のエフェクトやサウンドを追加
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ゲームプレイ中のみ時間を減算
    if (state == GameState.playing) {
      remainingTime -= dt;

      // 時間切れで試合終了
      if (remainingTime <= 0) {
        remainingTime = 0;
        endMatch();
      }
    }
  }

  /// 試合を開始する
  void startMatch() {
    state = GameState.playing;
    player1Score = 0;
    player2Score = 0;
    remainingTime = 90.0;
    resetPositions();
  }

  /// 試合を一時停止する
  void pauseMatch() {
    if (state == GameState.playing) {
      state = GameState.paused;
      pauseEngine();
    }
  }

  /// 試合を再開する
  void resumeMatch() {
    if (state == GameState.paused) {
      state = GameState.playing;
      resumeEngine();
    }
  }

  /// 試合を終了する
  ///
  /// スコアを比較して勝者を判定します。
  /// - player1Scoreが高い場合: プレイヤー1の勝利
  /// - player2Scoreが高い場合: プレイヤー2の勝利
  /// - 同点の場合: 引き分け
  ///
  /// 勝者IDは以下のように設定されます：
  /// - 1: プレイヤー1の勝利
  /// - 2: プレイヤー2の勝利
  /// - 0: 引き分け
  void endMatch() {
    state = GameState.finished;
    pauseEngine();

    // スコアを比較して勝者を判定
    int winnerId;
    if (player1Score > player2Score) {
      winnerId = 1; // プレイヤー1の勝利
    } else if (player2Score > player1Score) {
      winnerId = 2; // プレイヤー2の勝利
    } else {
      winnerId = 0; // 引き分け
    }

    // 勝者IDを保存（結果画面で使用）
    _winnerId = winnerId;

    // TODO: 結果画面への遷移
  }

  /// 勝者ID（1: プレイヤー1, 2: プレイヤー2, 0: 引き分け）
  int _winnerId = 0;

  /// 勝者IDを取得する
  int get winnerId => _winnerId;

  /// ボールとプレイヤーの位置をリセットする
  void resetPositions() {
    // ボールが初期化されている場合のみリセット
    if (_isBallInitialized) {
      ball.reset();
    }

    // プレイヤーが初期化されている場合のみリセット
    if (_arePlayersInitialized) {
      player1?.reset();
      player2?.reset();
    }
  }

  /// プレイヤーキャラクターを初期化する
  ///
  /// [character1Data] プレイヤー1のキャラクターデータ
  /// [character2Data] プレイヤー2のキャラクターデータ
  Future<void> initializePlayers({
    required CharacterData character1Data,
    required CharacterData character2Data,
  }) async {
    print('HeadBallGame: プレイヤー初期化開始');

    // 既存のプレイヤーを削除
    if (player1 != null) {
      world.remove(player1!);
    }
    if (player2 != null) {
      world.remove(player2!);
    }

    // プレイヤー1を作成（左側に配置）
    player1 = PlayerCharacter(
      characterData: character1Data,
      playerNumber: 1,
      initialPosition: Vector2(
        GameWorld.fieldWidth * 0.25, // フィールドの1/4の位置
        GameWorld.fieldHeight - 2.0, // 地面から少し上
      ),
    );

    // プレイヤー2を作成（右側に配置）
    player2 = PlayerCharacter(
      characterData: character2Data,
      playerNumber: 2,
      initialPosition: Vector2(
        GameWorld.fieldWidth * 0.75, // フィールドの3/4の位置
        GameWorld.fieldHeight - 2.0, // 地面から少し上
      ),
    );

    // ゲームに追加
    await world.add(player1!);
    print('HeadBallGame: プレイヤー1追加完了');
    await world.add(player2!);
    print('HeadBallGame: プレイヤー2追加完了');

    _arePlayersInitialized = true;
  }
}
