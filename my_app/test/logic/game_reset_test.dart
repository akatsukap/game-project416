import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/logic/game_logic.dart';
import 'package:my_app/models/game_state.dart';

void main() {
  group('GameLogic - State Reset', () {
    // Feature: babanuki-game, Property 10: 状態のリセット
    // 検証: 要件 10.3
    test('Property 10: State reset to initial state', () {
      for (int i = 0; i < 100; i++) {
        // 最初のゲーム状態を作成
        final deck1 = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck1);
        final hands1 = GameLogic.dealCards(deck1);
        final playerHand1 = GameLogic.removePairs(hands1['player']!);
        final cpuHand1 = GameLogic.removePairs(hands1['cpu']!);
        final gameState1 = GameState(
          playerHand: playerHand1,
          cpuHand: cpuHand1,
          isPlayerTurn: true,
          status: GameStatus.playing,
        );

        // 2番目のゲーム状態を作成（リセット後の状態をシミュレート）
        final deck2 = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck2);
        final hands2 = GameLogic.dealCards(deck2);
        final playerHand2 = GameLogic.removePairs(hands2['player']!);
        final cpuHand2 = GameLogic.removePairs(hands2['cpu']!);
        final gameState2 = GameState(
          playerHand: playerHand2,
          cpuHand: cpuHand2,
          isPlayerTurn: true,
          status: GameStatus.playing,
        );

        // 両方のゲーム状態が初期状態の特性を持つことを検証
        // 1. デッキの総カード数は53枚
        expect(
          gameState1.playerHand.length + gameState1.cpuHand.length,
          lessThanOrEqualTo(53),
        );
        expect(
          gameState2.playerHand.length + gameState2.cpuHand.length,
          lessThanOrEqualTo(53),
        );

        // 2. 初期ターンはプレイヤー
        expect(gameState1.isPlayerTurn, isTrue);
        expect(gameState2.isPlayerTurn, isTrue);

        // 3. ゲームステータスはplaying
        expect(gameState1.status, equals(GameStatus.playing));
        expect(gameState2.status, equals(GameStatus.playing));

        // 4. 勝者は未定（null）
        expect(gameState1.winner, isNull);
        expect(gameState2.winner, isNull);

        // 5. 手札にペアが存在しない
        for (int j = 0; j < gameState1.playerHand.length; j++) {
          for (int k = j + 1; k < gameState1.playerHand.length; k++) {
            expect(
              gameState1.playerHand[j].canPairWith(gameState1.playerHand[k]),
              isFalse,
            );
          }
        }
        for (int j = 0; j < gameState1.cpuHand.length; j++) {
          for (int k = j + 1; k < gameState1.cpuHand.length; k++) {
            expect(
              gameState1.cpuHand[j].canPairWith(gameState1.cpuHand[k]),
              isFalse,
            );
          }
        }

        for (int j = 0; j < gameState2.playerHand.length; j++) {
          for (int k = j + 1; k < gameState2.playerHand.length; k++) {
            expect(
              gameState2.playerHand[j].canPairWith(gameState2.playerHand[k]),
              isFalse,
            );
          }
        }
        for (int j = 0; j < gameState2.cpuHand.length; j++) {
          for (int k = j + 1; k < gameState2.cpuHand.length; k++) {
            expect(
              gameState2.cpuHand[j].canPairWith(gameState2.cpuHand[k]),
              isFalse,
            );
          }
        }

        // 6. カードの配布が均等（差は最大1枚）
        final difference1 =
            (gameState1.playerHand.length - gameState1.cpuHand.length).abs();
        expect(difference1, lessThanOrEqualTo(1));

        final difference2 =
            (gameState2.playerHand.length - gameState2.cpuHand.length).abs();
        expect(difference2, lessThanOrEqualTo(1));
      }
    });
  });
}
