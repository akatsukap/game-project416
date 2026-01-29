import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'player_character.dart';

/// 入力コントローラー
///
/// プレイヤーの入力を管理し、PlayerCharacterに伝達します。
/// タッチ入力とボタン状態を管理します。
/// 要件: 2.1, 2.2, 2.4, 5.1, 7.3
class InputController extends Component {
  /// プレイヤー番号（1 or 2）
  final int playerNumber;

  /// 制御するプレイヤーキャラクター
  final PlayerCharacter player;

  /// 左移動ボタンが押されているか
  bool isLeftPressed = false;

  /// 右移動ボタンが押されているか
  bool isRightPressed = false;

  /// ジャンプボタンが押されているか
  bool isJumpPressed = false;

  /// キックボタンが押されているか
  bool isKickPressed = false;

  /// 特殊能力ボタンが押されているか
  bool isSpecialPressed = false;

  /// 前フレームのジャンプボタン状態（エッジ検出用）
  bool _wasJumpPressed = false;

  /// 前フレームのキックボタン状態（エッジ検出用）
  bool _wasKickPressed = false;

  /// 前フレームの特殊能力ボタン状態（エッジ検出用）
  bool _wasSpecialPressed = false;

  /// コンストラクタ
  ///
  /// [playerNumber] プレイヤー番号（1 or 2）
  /// [player] 制御するプレイヤーキャラクター
  InputController({required this.playerNumber, required this.player});

  @override
  void update(double dt) {
    super.update(dt);

    // プレイヤーの物理ボディが初期化されていない場合は何もしない
    if (!player.isMounted) {
      return;
    }

    // 移動入力の処理（継続的な入力）
    if (isLeftPressed && !isRightPressed) {
      player.moveLeft();
    } else if (isRightPressed && !isLeftPressed) {
      player.moveRight();
    } else if (!isLeftPressed && !isRightPressed) {
      // どちらも押されていない場合は横方向の速度を減衰させる
      final velocity = player.body.linearVelocity;
      player.body.linearVelocity = Vector2(velocity.x * 0.8, velocity.y);
    }
    // 両方押されている場合は何もしない（現在の速度を維持）

    // ジャンプ入力の処理（エッジトリガー：押された瞬間のみ）
    if (isJumpPressed && !_wasJumpPressed) {
      player.jump();
    }
    _wasJumpPressed = isJumpPressed;

    // キック入力の処理（エッジトリガー：押された瞬間のみ）
    if (isKickPressed && !_wasKickPressed) {
      player.kick();
    }
    _wasKickPressed = isKickPressed;

    // 特殊能力入力の処理（エッジトリガー：押された瞬間のみ）
    if (isSpecialPressed && !_wasSpecialPressed) {
      player.useSpecialAbility();
    }
    _wasSpecialPressed = isSpecialPressed;
  }

  /// タッチダウンイベントを処理する
  ///
  /// 画面領域に応じてボタンを判定し、対応するボタン状態を更新します。
  /// 要件: 7.3
  ///
  /// [info] タッチダウン情報
  void handleTapDown(TapDownInfo info) {
    final position = info.eventPosition.globalPosition;
    final buttonType = _determineButtonType(position);

    switch (buttonType) {
      case ButtonType.left:
        isLeftPressed = true;
        break;
      case ButtonType.right:
        isRightPressed = true;
        break;
      case ButtonType.jump:
        isJumpPressed = true;
        break;
      case ButtonType.kick:
        isKickPressed = true;
        break;
      case ButtonType.special:
        isSpecialPressed = true;
        break;
      case ButtonType.none:
        break;
    }
  }

  /// タッチアップイベントを処理する
  ///
  /// 画面領域に応じてボタンを判定し、対応するボタン状態を解除します。
  /// 要件: 7.3
  ///
  /// [info] タッチアップ情報
  void handleTapUp(TapUpInfo info) {
    final position = info.eventPosition.globalPosition;
    final buttonType = _determineButtonType(position);

    switch (buttonType) {
      case ButtonType.left:
        isLeftPressed = false;
        break;
      case ButtonType.right:
        isRightPressed = false;
        break;
      case ButtonType.jump:
        isJumpPressed = false;
        break;
      case ButtonType.kick:
        isKickPressed = false;
        break;
      case ButtonType.special:
        isSpecialPressed = false;
        break;
      case ButtonType.none:
        break;
    }
  }

  /// タッチキャンセルイベントを処理する
  ///
  /// すべてのボタン状態をリセットします。
  void handleTapCancel() {
    isLeftPressed = false;
    isRightPressed = false;
    isJumpPressed = false;
    isKickPressed = false;
    isSpecialPressed = false;
  }

  /// 画面位置からボタンタイプを判定する
  ///
  /// [position] 画面上の位置
  /// 戻り値: ボタンタイプ
  ///
  /// 画面レイアウト（要件: 7.1, 7.3）:
  /// - プレイヤー1: 画面左側（x < 画面幅の50%）
  /// - プレイヤー2: 画面右側（x >= 画面幅の50%）
  ///
  /// ボタン配置（画面下部）:
  /// - 左移動: 左下隅
  /// - 右移動: 左移動の右隣
  /// - ジャンプ: 中央下部
  /// - キック: 右下部
  /// - 特殊能力: 右下隅
  ButtonType _determineButtonType(Offset position) {
    // ゲームのサイズを取得
    // Flameのゲームサイズは実行時に決定されるため、
    // ここでは一般的なモバイル画面サイズを想定
    // 実際のUIコンポーネントと統合する際に、正確な座標を使用する

    // 画面の幅と高さ（仮の値）
    // 実際の実装では、GameWidgetから取得する必要がある
    const screenWidth = 800.0;
    const screenHeight = 600.0;

    // ボタンの高さ（画面下部の領域）
    const buttonAreaHeight = 120.0;
    const buttonAreaTop = screenHeight - buttonAreaHeight;

    // ボタン領域外の場合
    if (position.dy < buttonAreaTop) {
      return ButtonType.none;
    }

    // プレイヤー1の操作エリア（画面左側）
    if (playerNumber == 1 && position.dx < screenWidth / 2) {
      return _determinePlayer1Button(position, screenWidth, buttonAreaTop);
    }
    // プレイヤー2の操作エリア（画面右側）
    else if (playerNumber == 2 && position.dx >= screenWidth / 2) {
      return _determinePlayer2Button(position, screenWidth, buttonAreaTop);
    }

    return ButtonType.none;
  }

  /// プレイヤー1のボタンを判定する
  ///
  /// [position] 画面上の位置
  /// [screenWidth] 画面の幅
  /// [buttonAreaTop] ボタンエリアの上端Y座標
  /// 戻り値: ボタンタイプ
  ButtonType _determinePlayer1Button(
    Offset position,
    double screenWidth,
    double buttonAreaTop,
  ) {
    // プレイヤー1のボタン配置（画面左側）
    // 左移動: 0 ~ 80
    // 右移動: 80 ~ 160
    // ジャンプ: 160 ~ 240
    // キック: 240 ~ 320
    // 特殊能力: 320 ~ 400

    const buttonWidth = 80.0;

    if (position.dx < buttonWidth) {
      return ButtonType.left;
    } else if (position.dx < buttonWidth * 2) {
      return ButtonType.right;
    } else if (position.dx < buttonWidth * 3) {
      return ButtonType.jump;
    } else if (position.dx < buttonWidth * 4) {
      return ButtonType.kick;
    } else if (position.dx < buttonWidth * 5) {
      return ButtonType.special;
    }

    return ButtonType.none;
  }

  /// プレイヤー2のボタンを判定する
  ///
  /// [position] 画面上の位置
  /// [screenWidth] 画面の幅
  /// [buttonAreaTop] ボタンエリアの上端Y座標
  /// 戻り値: ボタンタイプ
  ButtonType _determinePlayer2Button(
    Offset position,
    double screenWidth,
    double buttonAreaTop,
  ) {
    // プレイヤー2のボタン配置（画面右側）
    // 画面右半分の座標系に変換
    final relativeX = position.dx - screenWidth / 2;

    // 左移動: 0 ~ 80
    // 右移動: 80 ~ 160
    // ジャンプ: 160 ~ 240
    // キック: 240 ~ 320
    // 特殊能力: 320 ~ 400

    const buttonWidth = 80.0;

    if (relativeX < buttonWidth) {
      return ButtonType.left;
    } else if (relativeX < buttonWidth * 2) {
      return ButtonType.right;
    } else if (relativeX < buttonWidth * 3) {
      return ButtonType.jump;
    } else if (relativeX < buttonWidth * 4) {
      return ButtonType.kick;
    } else if (relativeX < buttonWidth * 5) {
      return ButtonType.special;
    }

    return ButtonType.none;
  }

  /// すべてのボタン状態をリセットする
  void reset() {
    isLeftPressed = false;
    isRightPressed = false;
    isJumpPressed = false;
    isKickPressed = false;
    isSpecialPressed = false;
    _wasJumpPressed = false;
    _wasKickPressed = false;
    _wasSpecialPressed = false;
  }
}

/// ボタンタイプの列挙型
enum ButtonType {
  /// 左移動ボタン
  left,

  /// 右移動ボタン
  right,

  /// ジャンプボタン
  jump,

  /// キックボタン
  kick,

  /// 特殊能力ボタン
  special,

  /// ボタンなし
  none,
}

/// タッチダウン情報
///
/// Flameのタッチイベントをラップします。
class TapDownInfo {
  /// イベント位置
  final TapDownDetails eventPosition;

  /// コンストラクタ
  TapDownInfo(this.eventPosition);
}

/// タッチアップ情報
///
/// Flameのタッチイベントをラップします。
class TapUpInfo {
  /// イベント位置
  final TapUpDetails eventPosition;

  /// コンストラクタ
  TapUpInfo(this.eventPosition);
}
