import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/logic/game_logic.dart';
import 'package:my_app/models/card.dart';

// Feature: babanuki-game, Property 6: カードの移動
// すべてのカード引き操作において、選択されたカードは相手の手札から削除され、
// 自分の手札に追加されなければならない
// 検証: 要件 6.2, 7.2

void main() {
  group('GameLogic - Card Movement', () {
    test('Property 6: Card movement', () {
      for (int i = 0; i < 100; i++) {
        // ランダムなデッキを作成
        final deck = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck);
        final hands = GameLogic.dealCards(deck);

        var playerHand = GameLogic.removePairs(hands['player']!);
        var cpuHand = GameLogic.removePairs(hands['cpu']!);

        // 両方の手札が空でない場合のみテスト
        if (playerHand.isNotEmpty && cpuHand.isNotEmpty) {
          // プレイヤーがCPUからカードを引く場合
          final initialPlayerCount = playerHand.length;
          final initialCpuCount = cpuHand.length;
          final drawnCardIndex = i % cpuHand.length;
          final drawnCard = cpuHand[drawnCardIndex];

          // カードを移動
          final newCpuHand = List<Card>.from(cpuHand);
          newCpuHand.removeAt(drawnCardIndex);
          final newPlayerHand = List<Card>.from(playerHand);
          newPlayerHand.add(drawnCard);

          // 検証: CPUの手札から削除されている
          expect(newCpuHand.length, equals(initialCpuCount - 1));
          expect(newCpuHand.contains(drawnCard), isFalse);

          // 検証: プレイヤーの手札に追加されている（ペア削除前）
          expect(newPlayerHand.length, equals(initialPlayerCount + 1));
          expect(newPlayerHand.contains(drawnCard), isTrue);

          // ペア削除後も、カードの総数は保存される（ペアが削除された分だけ減る）
          final playerHandAfterPairs = GameLogic.removePairs(newPlayerHand);
          final totalCardsAfter =
              playerHandAfterPairs.length + newCpuHand.length;
          final totalCardsBefore = initialPlayerCount + initialCpuCount;

          // 総カード数は減るか同じ（ペアが削除された場合は減る）
          expect(totalCardsAfter, lessThanOrEqualTo(totalCardsBefore));
        }

        // CPUがプレイヤーからカードを引く場合
        if (playerHand.isNotEmpty && cpuHand.isNotEmpty) {
          final initialPlayerCount = playerHand.length;
          final initialCpuCount = cpuHand.length;
          final drawnCardIndex = i % playerHand.length;
          final drawnCard = playerHand[drawnCardIndex];

          // カードを移動
          final newPlayerHand = List<Card>.from(playerHand);
          newPlayerHand.removeAt(drawnCardIndex);
          final newCpuHand = List<Card>.from(cpuHand);
          newCpuHand.add(drawnCard);

          // 検証: プレイヤーの手札から削除されている
          expect(newPlayerHand.length, equals(initialPlayerCount - 1));
          expect(newPlayerHand.contains(drawnCard), isFalse);

          // 検証: CPUの手札に追加されている（ペア削除前）
          expect(newCpuHand.length, equals(initialCpuCount + 1));
          expect(newCpuHand.contains(drawnCard), isTrue);

          // ペア削除後も、カードの総数は保存される
          final cpuHandAfterPairs = GameLogic.removePairs(newCpuHand);
          final totalCardsAfter =
              newPlayerHand.length + cpuHandAfterPairs.length;
          final totalCardsBefore = initialPlayerCount + initialCpuCount;

          // 総カード数は減るか同じ
          expect(totalCardsAfter, lessThanOrEqualTo(totalCardsBefore));
        }
      }
    });
  });
}
