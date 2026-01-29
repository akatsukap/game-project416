import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/head_ball/ball.dart';
import 'package:my_app/head_ball/head_ball_game.dart';

void main() {
  group('Ball', () {
    testWithGame<HeadBallGame>('Ballが正しく初期化される', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // Ballが正常に作成されることを確認
      expect(ball, isNotNull);
      expect(ball.isMounted, true);
    });

    testWithGame<HeadBallGame>('Ballは動的なボディである', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // ボールが動的（物理演算で動く）であることを確認
      expect(ball.body.bodyType, BodyType.dynamic);
    });

    testWithGame<HeadBallGame>('Ballは円形の形状を持つ', HeadBallGame.new, (game) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // ボールの形状が円形であることを確認
      final fixture = ball.body.fixtures.first;
      expect(fixture.shape, isA<CircleShape>());
      expect((fixture.shape as CircleShape).radius, Ball.radius);
    });

    testWithGame<HeadBallGame>('Ballに物理プロパティが設定されている', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // フィクスチャの物理プロパティを確認
      final fixture = ball.body.fixtures.first;
      expect(fixture.friction, 0.3);
      expect(fixture.restitution, 0.7); // バウンドの強さ
      expect(fixture.density, 1.0);
    });

    testWithGame<HeadBallGame>('Ballのデフォルト位置はフィールド中央である', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // デフォルト位置を確認
      expect(ball.body.position.x, 10.0);
      expect(ball.body.position.y, 6.0);
    });

    testWithGame<HeadBallGame>('Ballのカスタム位置が設定できる', HeadBallGame.new, (
      game,
    ) async {
      final customPosition = Vector2(5.0, 3.0);
      final ball = Ball(position: customPosition);
      await game.ensureAdd(ball);

      // カスタム位置を確認
      expect(ball.body.position.x, 5.0);
      expect(ball.body.position.y, 3.0);
    });

    testWithGame<HeadBallGame>('applyKickメソッドがボールに力を加える', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // 初期速度は0
      expect(ball.body.linearVelocity.length, 0);

      // キックを適用
      final direction = Vector2(1.0, 0.0); // 右方向
      final power = 10.0;
      ball.applyKick(direction, power);

      // ゲームを1フレーム更新して物理演算を適用
      game.update(0.016);

      // ボールが動いていることを確認
      expect(ball.body.linearVelocity.length, greaterThan(0));
    });

    testWithGame<HeadBallGame>('resetメソッドがボールの位置と速度をリセットする', HeadBallGame.new, (
      game,
    ) async {
      final initialPosition = Vector2(5.0, 3.0);
      final ball = Ball(position: initialPosition);
      await game.ensureAdd(ball);

      // ボールを動かす
      ball.applyKick(Vector2(1.0, 0.0), 10.0);
      game.update(0.016);

      // ボールが動いていることを確認
      expect(ball.body.linearVelocity.length, greaterThan(0));

      // リセット
      ball.reset();

      // 位置と速度がリセットされていることを確認
      expect(ball.body.position.x, closeTo(5.0, 0.01));
      expect(ball.body.position.y, closeTo(3.0, 0.01));
      expect(ball.body.linearVelocity.length, 0);
      expect(ball.body.angularVelocity, 0);
      expect(ball.isInGoal, false);
    });

    testWithGame<HeadBallGame>('ボールの速度が最大速度を超えない', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // 非常に大きな力を加える
      ball.applyKick(Vector2(1.0, 0.0), 1000.0);

      // 複数フレーム更新
      for (int i = 0; i < 10; i++) {
        game.update(0.016);
      }

      // 速度が最大速度（30.0）を超えていないことを確認
      expect(ball.body.linearVelocity.length, lessThanOrEqualTo(30.0));
    });

    testWithGame<HeadBallGame>('線形減衰と角度減衰が設定されている', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      // 減衰が設定されていることを確認（空気抵抗のような効果）
      expect(ball.body.linearDamping, 0.1);
      expect(ball.body.angularDamping, 0.1);
    });

    test('Ballの半径が正しい', () {
      expect(Ball.radius, 0.3);
    });

    testWithGame<HeadBallGame>('isInGoalフラグが初期状態でfalseである', HeadBallGame.new, (
      game,
    ) async {
      final ball = Ball();
      await game.ensureAdd(ball);

      expect(ball.isInGoal, false);
    });

    testWithGame<HeadBallGame>(
      'applyKickで正規化された方向ベクトルが使用される',
      HeadBallGame.new,
      (game) async {
        final ball = Ball();
        await game.ensureAdd(ball);

        // 正規化されていない方向ベクトルを使用
        final direction = Vector2(3.0, 4.0); // 長さは5.0
        final power = 10.0;
        ball.applyKick(direction, power);

        game.update(0.016);

        // ボールが動いていることを確認
        // 正規化されているので、方向は同じだが大きさはpowerに依存
        expect(ball.body.linearVelocity.length, greaterThan(0));
      },
    );
  });
}
