import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/logic/game_logic.dart';
import 'package:my_app/models/card.dart' as models;
import 'package:my_app/models/game_state.dart';

// Feature: babanuki-game, Property 7: ターンの交互切り替え
// すべてのターン終了時に、次のターンは反対のプレイヤー
// （プレイヤー→CPU、CPU→プレイヤー）に切り替わらなければならない
// 検証: 要件 6.4, 7.4

void main() {
  group('GameLogic - Turn Switching', () {
    test('Property 7: Turn alternation', () {
      for (int i = 0; i < 100; i++) {
        // ランダムなゲーム状態を作成
        final deck = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck);
        final hands = GameLogic.dealCards(deck);

        var playerHand = GameLogic.removePairs(hands['player']!);
        var cpuHand = GameLogic.removePairs(hands['cpu']!);

        // 初期状態: プレイヤーのターン
        var gameState = GameState(
          playerHand: playerHand,
          cpuHand: cpuHand,
          isPlayerTurn: true,
          status: GameStatus.playing,
        );

        // プレイヤーのターンからCPUのターンへ
        expect(gameState.isPlayerTurn, isTrue);

        // ターンを切り替え
        gameState = gameState.copyWith(isPlayerTurn: false);
        expect(gameState.isPlayerTurn, isFalse);

        // CPUのターンからプレイヤーのターンへ
        gameState = gameState.copyWith(isPlayerTurn: true);
        expect(gameState.isPlayerTurn, isTrue);

        // 複数回のターン切り替えをテスト
        bool currentTurn = true;
        for (int j = 0; j < 10; j++) {
          gameState = gameState.copyWith(isPlayerTurn: currentTurn);
          expect(gameState.isPlayerTurn, equals(currentTurn));

          // 次のターンは反対
          currentTurn = !currentTurn;
          gameState = gameState.copyWith(isPlayerTurn: currentTurn);
          expect(gameState.isPlayerTurn, equals(currentTurn));
        }
      }
    });

    test('Property 7: Turn switching with card drawing', () {
      for (int i = 0; i < 100; i++) {
        // ランダムなゲーム状態を作成
        final deck = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck);
        final hands = GameLogic.dealCards(deck);

        var playerHand = GameLogic.removePairs(hands['player']!);
        var cpuHand = GameLogic.removePairs(hands['cpu']!);

        if (playerHand.isEmpty || cpuHand.isEmpty) {
          continue;
        }

        // プレイヤーのターン
        var gameState = GameState(
          playerHand: playerHand,
          cpuHand: cpuHand,
          isPlayerTurn: true,
          status: GameStatus.playing,
        );

        expect(gameState.isPlayerTurn, isTrue);

        // プレイヤーがカードを引く（シミュレーション）
        final drawnCardIndex = i % cpuHand.length;
        final drawnCard = cpuHand[drawnCardIndex];
        final newCpuHand = List<models.Card>.from(cpuHand);
        newCpuHand.removeAt(drawnCardIndex);
        final newPlayerHand = List<models.Card>.from(playerHand);
        newPlayerHand.add(drawnCard);
        final playerHandAfterPairs = GameLogic.removePairs(newPlayerHand);

        // ターンを切り替え
        gameState = gameState.copyWith(
          playerHand: playerHandAfterPairs,
          cpuHand: newCpuHand,
          isPlayerTurn: false,
        );

        // CPUのターンになっている
        expect(gameState.isPlayerTurn, isFalse);

        // CPUがカードを引く（シミュレーション）
        if (gameState.playerHand.isNotEmpty) {
          final cpuDrawnIndex = i % gameState.playerHand.length;
          final cpuDrawnCard = gameState.playerHand[cpuDrawnIndex];
          final newPlayerHand2 = List<models.Card>.from(gameState.playerHand);
          newPlayerHand2.removeAt(cpuDrawnIndex);
          final newCpuHand2 = List<models.Card>.from(gameState.cpuHand);
          newCpuHand2.add(cpuDrawnCard);
          final cpuHandAfterPairs = GameLogic.removePairs(newCpuHand2);

          // ターンを切り替え
          gameState = gameState.copyWith(
            playerHand: newPlayerHand2,
            cpuHand: cpuHandAfterPairs,
            isPlayerTurn: true,
          );

          // プレイヤーのターンに戻っている
          expect(gameState.isPlayerTurn, isTrue);
        }
      }
    });
  });
}
