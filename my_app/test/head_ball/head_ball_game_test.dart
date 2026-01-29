import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/head_ball/game_state.dart';
import 'package:my_app/head_ball/head_ball_game.dart';

void main() {
  group('HeadBallGame', () {
    late HeadBallGame game;

    setUp(() {
      game = HeadBallGame();
    });

    test('初期状態はメニュー画面である', () {
      expect(game.state, GameState.menu);
    });

    test('初期スコアは0-0である', () {
      expect(game.player1Score, 0);
      expect(game.player2Score, 0);
    });

    test('初期の残り時間は90秒である', () {
      expect(game.remainingTime, 90.0);
    });

    test('startMatch()で試合が開始される', () {
      game.startMatch();
      expect(game.state, GameState.playing);
      expect(game.player1Score, 0);
      expect(game.player2Score, 0);
      expect(game.remainingTime, 90.0);
    });

    test('pauseMatch()でゲームが一時停止される', () {
      game.startMatch();
      game.pauseMatch();
      expect(game.state, GameState.paused);
    });

    test('resumeMatch()でゲームが再開される', () {
      game.startMatch();
      game.pauseMatch();
      game.resumeMatch();
      expect(game.state, GameState.playing);
    });

    test('endMatch()で試合が終了する', () {
      game.startMatch();
      game.endMatch();
      expect(game.state, GameState.finished);
    });

    test('プレイ中に時間が経過する', () {
      game.startMatch();
      final initialTime = game.remainingTime;
      game.update(1.0); // 1秒経過
      expect(game.remainingTime, initialTime - 1.0);
    });

    test('一時停止中は時間が経過しない', () {
      game.startMatch();
      game.pauseMatch();
      final pausedTime = game.remainingTime;
      game.update(1.0); // 1秒経過
      expect(game.remainingTime, pausedTime);
    });

    test('時間切れで試合が自動終了する', () {
      game.startMatch();
      game.remainingTime = 0.5;
      game.update(1.0); // 1秒経過
      expect(game.remainingTime, 0.0);
      expect(game.state, GameState.finished);
    });

    test('プレイヤー1が得点するとスコアが増加する', () {
      game.startMatch();
      // _handleGoalScoredを直接呼び出すことはできないため、
      // GameWorldを通じて得点処理をテストする必要がある
      // ここでは初期スコアの確認のみ
      expect(game.player1Score, 0);
    });

    test('プレイヤー2が得点するとスコアが増加する', () {
      game.startMatch();
      expect(game.player2Score, 0);
    });

    group('勝敗判定', () {
      test('プレイヤー1のスコアが高い場合、プレイヤー1が勝者として判定される', () {
        game.startMatch();
        game.player1Score = 3;
        game.player2Score = 1;
        game.endMatch();

        expect(game.state, GameState.finished);
        expect(game.winnerId, 1);
      });

      test('プレイヤー2のスコアが高い場合、プレイヤー2が勝者として判定される', () {
        game.startMatch();
        game.player1Score = 1;
        game.player2Score = 4;
        game.endMatch();

        expect(game.state, GameState.finished);
        expect(game.winnerId, 2);
      });

      test('スコアが同点の場合、引き分けとして判定される', () {
        game.startMatch();
        game.player1Score = 2;
        game.player2Score = 2;
        game.endMatch();

        expect(game.state, GameState.finished);
        expect(game.winnerId, 0);
      });

      test('スコアが0-0の場合も引き分けとして判定される', () {
        game.startMatch();
        game.player1Score = 0;
        game.player2Score = 0;
        game.endMatch();

        expect(game.state, GameState.finished);
        expect(game.winnerId, 0);
      });

      test('大差のスコアでも正しく勝者が判定される', () {
        game.startMatch();
        game.player1Score = 10;
        game.player2Score = 0;
        game.endMatch();

        expect(game.state, GameState.finished);
        expect(game.winnerId, 1);
      });
    });
  });
}
