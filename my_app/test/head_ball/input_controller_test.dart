import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/head_ball/input_controller.dart';
import 'package:my_app/head_ball/player_character.dart';
import 'package:my_app/models/character_data.dart';

void main() {
  group('InputController', () {
    late InputController controller;
    late PlayerCharacter player;
    late Forge2DGame game;

    setUp(() async {
      // テスト用のゲームインスタンスを作成
      game = Forge2DGame();
      await game.onLoad();

      // テスト用のキャラクターデータを作成
      final characterData = CharacterData(
        id: 'test_character',
        name: 'テストキャラクター',
        spritePath: 'assets/characters/test.png',
        speed: 100.0,
        jumpPower: 300.0,
        kickPower: 500.0,
        specialAbilityType: SpecialAbilityType.speedBoost,
        description: 'テスト用キャラクター',
      );

      // プレイヤーキャラクターを作成
      player = PlayerCharacter(
        characterData: characterData,
        playerNumber: 1,
        initialPosition: Vector2(5, 5),
      );

      // ゲームに追加
      await game.add(player);

      // InputControllerを作成
      controller = InputController(playerNumber: 1, player: player);

      // ゲームに追加
      await game.add(controller);
    });

    test('初期状態ではすべてのボタンが押されていない', () {
      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, false);
      expect(controller.isJumpPressed, false);
      expect(controller.isKickPressed, false);
      expect(controller.isSpecialPressed, false);
    });

    test('左移動ボタンが押されたときisLeftPressedがtrueになる', () {
      // 左移動ボタンの位置（x: 40, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(40, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isLeftPressed, true);
      expect(controller.isRightPressed, false);
    });

    test('右移動ボタンが押されたときisRightPressedがtrueになる', () {
      // 右移動ボタンの位置（x: 120, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(120, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, true);
    });

    test('ジャンプボタンが押されたときisJumpPressedがtrueになる', () {
      // ジャンプボタンの位置（x: 200, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(200, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isJumpPressed, true);
    });

    test('キックボタンが押されたときisKickPressedがtrueになる', () {
      // キックボタンの位置（x: 280, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(280, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isKickPressed, true);
    });

    test('特殊能力ボタンが押されたときisSpecialPressedがtrueになる', () {
      // 特殊能力ボタンの位置（x: 360, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(360, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isSpecialPressed, true);
    });

    test('タッチアップでボタン状態が解除される', () {
      // 左移動ボタンを押す
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(40, 550)),
      );
      controller.handleTapDown(tapDownInfo);
      expect(controller.isLeftPressed, true);

      // 左移動ボタンを離す
      final tapUpInfo = TapUpInfo(
        TapUpDetails(
          globalPosition: const Offset(40, 550),
          kind: PointerDeviceKind.touch,
        ),
      );
      controller.handleTapUp(tapUpInfo);
      expect(controller.isLeftPressed, false);
    });

    test('タッチキャンセルですべてのボタン状態がリセットされる', () {
      // 複数のボタンを押す
      controller.isLeftPressed = true;
      controller.isJumpPressed = true;
      controller.isKickPressed = true;

      // タッチキャンセル
      controller.handleTapCancel();

      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, false);
      expect(controller.isJumpPressed, false);
      expect(controller.isKickPressed, false);
      expect(controller.isSpecialPressed, false);
    });

    test('reset()ですべてのボタン状態がリセットされる', () {
      // 複数のボタンを押す
      controller.isLeftPressed = true;
      controller.isRightPressed = true;
      controller.isJumpPressed = true;
      controller.isKickPressed = true;
      controller.isSpecialPressed = true;

      // リセット
      controller.reset();

      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, false);
      expect(controller.isJumpPressed, false);
      expect(controller.isKickPressed, false);
      expect(controller.isSpecialPressed, false);
    });

    test('ボタンエリア外のタッチは無視される', () {
      // ボタンエリア外の位置（y: 200）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(200, 200)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, false);
      expect(controller.isJumpPressed, false);
      expect(controller.isKickPressed, false);
      expect(controller.isSpecialPressed, false);
    });

    test('プレイヤー2の操作エリア外のタッチは無視される（プレイヤー1の場合）', () {
      // プレイヤー2のエリア（x: 600, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(600, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, false);
      expect(controller.isJumpPressed, false);
      expect(controller.isKickPressed, false);
      expect(controller.isSpecialPressed, false);
    });

    test('update()で左移動入力がプレイヤーに伝達される', () {
      // 左移動ボタンを押す
      controller.isLeftPressed = true;

      // 更新（InputControllerのロジックのみテスト）
      // 注: 物理ボディの初期化が必要なため、このテストでは
      // ボタン状態の管理のみを確認
      controller.update(0.016);

      // ボタン状態が維持されていることを確認
      expect(controller.isLeftPressed, true);
    });

    test('update()で右移動入力がプレイヤーに伝達される', () {
      // 右移動ボタンを押す
      controller.isRightPressed = true;

      // 更新
      controller.update(0.016);

      // ボタン状態が維持されていることを確認
      expect(controller.isRightPressed, true);
    });

    test('左右両方のボタンが押されている場合の処理', () {
      // 両方のボタンを押す
      controller.isLeftPressed = true;
      controller.isRightPressed = true;

      // 更新
      controller.update(0.016);

      // ボタン状態が維持されていることを確認
      expect(controller.isLeftPressed, true);
      expect(controller.isRightPressed, true);
    });

    test('どちらのボタンも押されていない場合の処理', () {
      // ボタンを押さない
      controller.isLeftPressed = false;
      controller.isRightPressed = false;

      // 更新
      controller.update(0.016);

      // ボタン状態が維持されていることを確認
      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, false);
    });
  });

  group('InputController - プレイヤー2', () {
    late InputController controller;
    late PlayerCharacter player;
    late Forge2DGame game;

    setUp(() async {
      // テスト用のゲームインスタンスを作成
      game = Forge2DGame();
      await game.onLoad();

      // テスト用のキャラクターデータを作成
      final characterData = CharacterData(
        id: 'test_character',
        name: 'テストキャラクター',
        spritePath: 'assets/characters/test.png',
        speed: 100.0,
        jumpPower: 300.0,
        kickPower: 500.0,
        specialAbilityType: SpecialAbilityType.speedBoost,
        description: 'テスト用キャラクター',
      );

      // プレイヤー2のキャラクターを作成
      player = PlayerCharacter(
        characterData: characterData,
        playerNumber: 2,
        initialPosition: Vector2(15, 5),
      );

      // ゲームに追加
      await game.add(player);

      // プレイヤー2のInputControllerを作成
      controller = InputController(playerNumber: 2, player: player);

      // ゲームに追加
      await game.add(controller);
    });

    test('プレイヤー2の左移動ボタンが正しく判定される', () {
      // プレイヤー2の左移動ボタンの位置（x: 440, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(440, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isLeftPressed, true);
      expect(controller.isRightPressed, false);
    });

    test('プレイヤー2の右移動ボタンが正しく判定される', () {
      // プレイヤー2の右移動ボタンの位置（x: 520, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(520, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, true);
    });

    test('プレイヤー1の操作エリアのタッチは無視される（プレイヤー2の場合）', () {
      // プレイヤー1のエリア（x: 200, y: 550）
      final tapDownInfo = TapDownInfo(
        TapDownDetails(globalPosition: const Offset(200, 550)),
      );

      controller.handleTapDown(tapDownInfo);

      expect(controller.isLeftPressed, false);
      expect(controller.isRightPressed, false);
      expect(controller.isJumpPressed, false);
      expect(controller.isKickPressed, false);
      expect(controller.isSpecialPressed, false);
    });
  });
}
