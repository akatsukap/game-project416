import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/head_ball/ball.dart';
import 'package:my_app/head_ball/head_ball_game.dart';
import 'package:my_app/head_ball/player_character.dart';
import 'package:my_app/models/character_data.dart';

void main() {
  group('PlayerCharacter', () {
    // テスト用のキャラクターデータ
    const testCharacterData = CharacterData(
      id: 'test_character',
      name: 'テストキャラクター',
      spritePath: 'assets/characters/test.png',
      speed: 100.0,
      jumpPower: 300.0,
      kickPower: 500.0,
      specialAbilityType: SpecialAbilityType.speedBoost,
      description: 'テスト用のキャラクター',
    );

    testWithGame<HeadBallGame>('PlayerCharacterが正しく初期化される', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // PlayerCharacterが正常に作成されることを確認
      expect(player, isNotNull);
      expect(player.isMounted, true);
    });

    testWithGame<HeadBallGame>(
      'CharacterDataから能力値が正しく初期化される',
      HeadBallGame.new,
      (game) async {
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: Vector2(5.0, 5.0),
        );
        await game.ensureAdd(player);

        // 能力値がCharacterDataから正しく設定されていることを確認
        expect(player.speed, testCharacterData.speed);
        expect(player.jumpPower, testCharacterData.jumpPower);
        expect(player.kickPower, testCharacterData.kickPower);
      },
    );

    testWithGame<HeadBallGame>('PlayerCharacterは動的なボディである', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // プレイヤーが動的（物理演算で動く）であることを確認
      expect(player.body.bodyType, BodyType.dynamic);
    });

    testWithGame<HeadBallGame>('PlayerCharacterの回転が固定されている', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // 回転が固定されていることを確認（キャラクターが倒れない）
      expect(player.body.isFixedRotation(), true);
    });

    testWithGame<HeadBallGame>('PlayerCharacterは矩形の形状を持つ', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // プレイヤーの形状が矩形であることを確認
      final fixture = player.body.fixtures.first;
      expect(fixture.shape, isA<PolygonShape>());
    });

    testWithGame<HeadBallGame>(
      'PlayerCharacterに足元センサーが設定されている',
      HeadBallGame.new,
      (game) async {
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: Vector2(5.0, 5.0),
        );
        await game.ensureAdd(player);

        // フィクスチャが2つあることを確認（本体 + 足元センサー）
        expect(player.body.fixtures.length, 2);

        // 2つ目のフィクスチャがセンサーであることを確認
        final fixtures = player.body.fixtures.toList();
        expect(fixtures[1].isSensor, true);
      },
    );

    testWithGame<HeadBallGame>(
      'PlayerCharacterの初期位置が正しく設定される',
      HeadBallGame.new,
      (game) async {
        final initialPosition = Vector2(7.0, 8.0);
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: initialPosition,
        );
        await game.ensureAdd(player);

        // 初期位置を確認
        expect(player.body.position.x, closeTo(7.0, 0.01));
        expect(player.body.position.y, closeTo(8.0, 0.01));
      },
    );

    testWithGame<HeadBallGame>('moveLeftメソッドがプレイヤーを左に移動させる', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // 左に移動
      player.moveLeft();

      // 速度が負（左方向）になっていることを確認
      expect(player.body.linearVelocity.x, lessThan(0));
    });

    testWithGame<HeadBallGame>(
      'moveRightメソッドがプレイヤーを右に移動させる',
      HeadBallGame.new,
      (game) async {
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: Vector2(5.0, 5.0),
        );
        await game.ensureAdd(player);

        // 右に移動
        player.moveRight();

        // 速度が正（右方向）になっていることを確認
        expect(player.body.linearVelocity.x, greaterThan(0));
      },
    );

    testWithGame<HeadBallGame>(
      'resetメソッドがプレイヤーの位置と速度をリセットする',
      HeadBallGame.new,
      (game) async {
        final initialPosition = Vector2(5.0, 5.0);
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: initialPosition,
        );
        await game.ensureAdd(player);

        // プレイヤーを動かす
        player.moveRight();
        game.update(0.016);

        // プレイヤーが動いていることを確認
        expect(player.body.linearVelocity.length, greaterThan(0));

        // リセット
        player.reset();

        // 位置と速度がリセットされていることを確認
        expect(player.body.position.x, closeTo(5.0, 0.01));
        expect(player.body.position.y, closeTo(5.0, 0.01));
        expect(player.body.linearVelocity.length, 0);
        expect(player.body.angularVelocity, 0);
        expect(player.isOnGround, false);
        expect(player.canJump, true);
      },
    );

    testWithGame<HeadBallGame>('プレイヤー番号が正しく設定される', HeadBallGame.new, (
      game,
    ) async {
      final player1 = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player1);

      final player2 = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 2,
        initialPosition: Vector2(15.0, 5.0),
      );
      await game.ensureAdd(player2);

      // プレイヤー番号を確認
      expect(player1.playerNumber, 1);
      expect(player2.playerNumber, 2);
    });

    testWithGame<HeadBallGame>('特殊能力のクールダウンが初期状態で0である', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // 初期状態でクールダウンが0であることを確認
      expect(player.specialAbilityCooldown, 0.0);
    });

    testWithGame<HeadBallGame>(
      'updateメソッドで特殊能力のクールダウンが減少する',
      HeadBallGame.new,
      (game) async {
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: Vector2(5.0, 5.0),
        );
        await game.ensureAdd(player);

        // 特殊能力が初期化されていることを確認
        expect(player.specialAbility, isNotNull);

        // 特殊能力を使用してクールダウンを開始
        if (player.specialAbility != null) {
          player.specialAbility!.startCooldown();
          final initialCooldown = player.specialAbility!.currentCooldown;

          // 1秒更新
          player.update(1.0);

          // クールダウンが減少していることを確認
          expect(
            player.specialAbility!.currentCooldown,
            lessThan(initialCooldown),
          );
          // specialAbilityCooldownも同期されていることを確認
          expect(
            player.specialAbilityCooldown,
            equals(player.specialAbility!.currentCooldown),
          );
        }
      },
    );

    testWithGame<HeadBallGame>('クールダウンが0未満にならない', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // 特殊能力が初期化されていることを確認
      expect(player.specialAbility, isNotNull);

      if (player.specialAbility != null) {
        // 小さいクールダウンを設定
        player.specialAbility!.currentCooldown = 0.5;

        // 1秒更新（クールダウンより長い）
        player.update(1.0);

        // クールダウンが0で止まることを確認
        expect(player.specialAbility!.currentCooldown, 0.0);
        expect(player.specialAbilityCooldown, 0.0);
      }
    });

    testWithGame<HeadBallGame>('横方向の速度が最大速度を超えない', HeadBallGame.new, (
      game,
    ) async {
      final player = PlayerCharacter(
        characterData: testCharacterData,
        playerNumber: 1,
        initialPosition: Vector2(5.0, 5.0),
      );
      await game.ensureAdd(player);

      // 複数回移動コマンドを実行
      for (int i = 0; i < 100; i++) {
        player.moveRight();
        player.update(0.016);
      }

      // 横方向の速度が最大速度（5.0）を超えていないことを確認
      expect(player.body.linearVelocity.x.abs(), lessThanOrEqualTo(5.0));
    });

    test('PlayerCharacterの幅と高さが正しい', () {
      expect(PlayerCharacter.width, 0.8);
      expect(PlayerCharacter.height, 1.2);
    });

    testWithGame<HeadBallGame>(
      'PlayerCharacterに物理プロパティが設定されている',
      HeadBallGame.new,
      (game) async {
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: Vector2(5.0, 5.0),
        );
        await game.ensureAdd(player);

        // フィクスチャの物理プロパティを確認
        final fixture = player.body.fixtures.first;
        expect(fixture.friction, 0.3);
        expect(fixture.restitution, 0.0); // キャラクターはバウンドしない
        expect(fixture.density, 1.0);
      },
    );

    // タスク5.4: ボールとの衝突処理とキック機能のテスト
    group('ボールとの衝突処理（タスク5.4）', () {
      testWithGame<HeadBallGame>('プレイヤーとボールが衝突するとボールに力が加わる', HeadBallGame.new, (
        game,
      ) async {
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: Vector2(5.0, 5.0),
        );
        await game.ensureAdd(player);

        final ball = Ball(position: Vector2(6.0, 5.0));
        await game.ensureAdd(ball);

        // 初期速度を記録
        final initialBallVelocity = ball.body.linearVelocity.length;

        // プレイヤーを右に移動させてボールに衝突させる
        player.moveRight();

        // 物理演算を進める
        for (int i = 0; i < 60; i++) {
          game.update(0.016);
        }

        // ボールの速度が増加していることを確認（衝突により力が加わった）
        expect(
          ball.body.linearVelocity.length,
          greaterThan(initialBallVelocity),
        );
      });

      testWithGame<HeadBallGame>(
        'kickメソッドでボールが近くにある場合にボールに力が加わる',
        HeadBallGame.new,
        (game) async {
          final player = PlayerCharacter(
            characterData: testCharacterData,
            playerNumber: 1,
            initialPosition: Vector2(5.0, 5.0),
          );
          await game.ensureAdd(player);

          // プレイヤーの近くにボールを配置
          final ball = Ball(position: Vector2(5.5, 5.0));
          await game.ensureAdd(ball);

          // 物理演算を少し進めて衝突を検出させる
          for (int i = 0; i < 10; i++) {
            game.update(0.016);
          }

          // 初期速度を記録
          final initialBallVelocity = ball.body.linearVelocity.length;

          // キックを実行
          player.kick();

          // 物理演算を進める
          for (int i = 0; i < 10; i++) {
            game.update(0.016);
          }

          // ボールの速度が増加していることを確認
          expect(
            ball.body.linearVelocity.length,
            greaterThan(initialBallVelocity),
          );
        },
      );

      testWithGame<HeadBallGame>(
        'kickメソッドでボールが遠い場合は何も起こらない',
        HeadBallGame.new,
        (game) async {
          final player = PlayerCharacter(
            characterData: testCharacterData,
            playerNumber: 1,
            initialPosition: Vector2(5.0, 5.0),
          );
          await game.ensureAdd(player);

          // プレイヤーから遠い位置にボールを配置
          final ball = Ball(position: Vector2(10.0, 5.0));
          await game.ensureAdd(ball);

          // 物理演算を少し進める
          for (int i = 0; i < 10; i++) {
            game.update(0.016);
          }

          // ボールを静止させる
          ball.body.linearVelocity = Vector2.zero();
          ball.body.angularVelocity = 0;

          // キックを実行
          player.kick();

          // 物理演算を少し進める（重力の影響を最小限にする）
          for (int i = 0; i < 5; i++) {
            game.update(0.016);
          }

          // ボールの速度が大きく変化していないことを確認（遠すぎてキックできない）
          // 重力の影響で少し動くことは許容する
          expect(ball.body.linearVelocity.length, lessThan(2.0));
        },
      );

      testWithGame<HeadBallGame>('キック範囲の定数が正しく設定されている', HeadBallGame.new, (
        game,
      ) async {
        // キック範囲が1.5メートルであることを確認
        expect(PlayerCharacter.kickRange, 1.5);
      });

      testWithGame<HeadBallGame>('ボールとの接触が終了すると参照がクリアされる', HeadBallGame.new, (
        game,
      ) async {
        final player = PlayerCharacter(
          characterData: testCharacterData,
          playerNumber: 1,
          initialPosition: Vector2(5.0, 5.0),
        );
        await game.ensureAdd(player);

        final ball = Ball(position: Vector2(5.5, 5.0));
        await game.ensureAdd(ball);

        // 物理演算を進めて衝突させる
        for (int i = 0; i < 10; i++) {
          game.update(0.016);
        }

        // ボールを遠くに移動
        ball.body.setTransform(Vector2(20.0, 5.0), 0);

        // 物理演算を進めて接触を終了させる
        for (int i = 0; i < 10; i++) {
          game.update(0.016);
        }

        // キックを試みる（ボールが遠いので何も起こらない）
        player.kick();

        // エラーが発生しないことを確認（参照がクリアされている）
        expect(() => player.kick(), returnsNormally);
      });
    });
  });
}
