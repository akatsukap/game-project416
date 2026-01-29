import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/head_ball/game_world.dart';
import 'package:my_app/head_ball/head_ball_game.dart';

void main() {
  group('GameWorld', () {
    testWithGame<HeadBallGame>('GameWorldが正しく初期化される', HeadBallGame.new, (
      game,
    ) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // GameWorldが正常に作成されることを確認
      expect(gameWorld, isNotNull);
      expect(gameWorld.isMounted, true);
    });

    testWithGame<HeadBallGame>('フィールド境界が作成される', HeadBallGame.new, (game) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // 境界が作成されていることを確認
      expect(gameWorld.topBoundary, isNotNull);
      expect(gameWorld.bottomBoundary, isNotNull);
      expect(gameWorld.leftWall, isNotNull);
      expect(gameWorld.rightWall, isNotNull);
    });

    test('フィールドの寸法が正しい', () {
      expect(GameWorld.fieldWidth, 20.0);
      expect(GameWorld.fieldHeight, 12.0);
      expect(GameWorld.wallThickness, 0.5);
    });

    testWithGame<HeadBallGame>('境界の位置が正しく設定されている', HeadBallGame.new, (
      game,
    ) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // 上部境界の位置
      expect(gameWorld.topBoundary.body.position.x, GameWorld.fieldWidth / 2);
      expect(
        gameWorld.topBoundary.body.position.y,
        -GameWorld.wallThickness / 2,
      );

      // 下部境界の位置
      expect(
        gameWorld.bottomBoundary.body.position.x,
        GameWorld.fieldWidth / 2,
      );
      expect(
        gameWorld.bottomBoundary.body.position.y,
        GameWorld.fieldHeight + GameWorld.wallThickness / 2,
      );

      // 左側の壁の位置
      expect(gameWorld.leftWall.body.position.x, -GameWorld.wallThickness / 2);
      expect(gameWorld.leftWall.body.position.y, GameWorld.fieldHeight / 2);

      // 右側の壁の位置
      expect(
        gameWorld.rightWall.body.position.x,
        GameWorld.fieldWidth + GameWorld.wallThickness / 2,
      );
      expect(gameWorld.rightWall.body.position.y, GameWorld.fieldHeight / 2);
    });

    testWithGame<HeadBallGame>('境界は静的なボディである', HeadBallGame.new, (game) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // すべての境界が静的（動かない）であることを確認
      expect(gameWorld.topBoundary.body.bodyType, BodyType.static);
      expect(gameWorld.bottomBoundary.body.bodyType, BodyType.static);
      expect(gameWorld.leftWall.body.bodyType, BodyType.static);
      expect(gameWorld.rightWall.body.bodyType, BodyType.static);
    });

    testWithGame<HeadBallGame>('境界に物理プロパティが設定されている', HeadBallGame.new, (
      game,
    ) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // フィクスチャの物理プロパティを確認
      final topFixture = gameWorld.topBoundary.body.fixtures.first;
      expect(topFixture.friction, 0.3);
      expect(topFixture.restitution, 0.5);
      expect(topFixture.density, 0.0);
    });

    testWithGame<HeadBallGame>('ゴールが作成される', HeadBallGame.new, (game) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // ゴールが作成されていることを確認
      expect(gameWorld.leftGoal, isNotNull);
      expect(gameWorld.rightGoal, isNotNull);
    });

    testWithGame<HeadBallGame>('左側のゴールはプレイヤー2のゴールである', HeadBallGame.new, (
      game,
    ) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      expect(gameWorld.leftGoal.playerNumber, 2);
    });

    testWithGame<HeadBallGame>('右側のゴールはプレイヤー1のゴールである', HeadBallGame.new, (
      game,
    ) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      expect(gameWorld.rightGoal.playerNumber, 1);
    });

    testWithGame<HeadBallGame>('ゴールの位置が正しく設定されている', HeadBallGame.new, (
      game,
    ) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // 左側のゴールの位置
      expect(gameWorld.leftGoal.body.position.x, GameWorld.goalWidth / 2);
      expect(
        gameWorld.leftGoal.body.position.y,
        GameWorld.fieldHeight - GameWorld.goalHeight / 2,
      );

      // 右側のゴールの位置
      expect(
        gameWorld.rightGoal.body.position.x,
        GameWorld.fieldWidth - GameWorld.goalWidth / 2,
      );
      expect(
        gameWorld.rightGoal.body.position.y,
        GameWorld.fieldHeight - GameWorld.goalHeight / 2,
      );
    });

    testWithGame<HeadBallGame>('ゴールは静的なボディである', HeadBallGame.new, (game) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // ゴールが静的（動かない）であることを確認
      expect(gameWorld.leftGoal.body.bodyType, BodyType.static);
      expect(gameWorld.rightGoal.body.bodyType, BodyType.static);
    });

    testWithGame<HeadBallGame>('ゴールはセンサーとして設定されている', HeadBallGame.new, (
      game,
    ) async {
      final gameWorld = GameWorld(game: game);
      await game.ensureAdd(gameWorld);

      // ゴールがセンサー（物理的な衝突はしない）であることを確認
      final leftGoalFixture = gameWorld.leftGoal.body.fixtures.first;
      final rightGoalFixture = gameWorld.rightGoal.body.fixtures.first;

      expect(leftGoalFixture.isSensor, true);
      expect(rightGoalFixture.isSensor, true);
    });

    test('ゴールの寸法が正しい', () {
      expect(GameWorld.goalWidth, 0.5);
      expect(GameWorld.goalHeight, 4.0);
    });
  });
}
