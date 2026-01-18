import 'dart:math';
import '../models/card.dart';

/// ババ抜きゲームのロジックを管理するクラス
class GameLogic {
  /// 53枚のカードデッキを作成（標準の52枚 + ジョーカー1枚）
  static List<Card> createDeck() {
    final List<Card> deck = [];
    final suits = ['hearts', 'diamonds', 'spades', 'clubs'];
    final ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
    ];

    // 標準の52枚のカードを作成
    for (final suit in suits) {
      for (final rank in ranks) {
        deck.add(Card(suit: suit, rank: rank, isJoker: false));
      }
    }

    // ジョーカーを追加
    deck.add(Card(suit: 'joker', rank: 'Joker', isJoker: true));

    return deck;
  }

  /// デッキをシャッフル
  static void shuffleDeck(List<Card> deck) {
    final random = Random();
    for (int i = deck.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = deck[i];
      deck[i] = deck[j];
      deck[j] = temp;
    }
  }

  /// カードを配布（プレイヤーとCPUに均等に配る）
  static Map<String, List<Card>> dealCards(List<Card> deck) {
    final List<Card> playerHand = [];
    final List<Card> cpuHand = [];

    // カードを交互に配る
    for (int i = 0; i < deck.length; i++) {
      if (i % 2 == 0) {
        playerHand.add(deck[i]);
      } else {
        cpuHand.add(deck[i]);
      }
    }

    return {'player': playerHand, 'cpu': cpuHand};
  }

  /// 手札からペアを削除
  static List<Card> removePairs(List<Card> hand) {
    final List<Card> result = List.from(hand);
    bool foundPair = true;

    // ペアが見つからなくなるまで繰り返す
    while (foundPair) {
      foundPair = false;

      for (int i = 0; i < result.length; i++) {
        for (int j = i + 1; j < result.length; j++) {
          if (result[i].canPairWith(result[j])) {
            // ペアを見つけたら削除
            result.removeAt(j);
            result.removeAt(i);
            foundPair = true;
            break;
          }
        }
        if (foundPair) break;
      }
    }

    return result;
  }

  /// ゲーム終了判定
  static bool isGameOver(List<Card> playerHand, List<Card> cpuHand) {
    // 一方の手札が空の場合
    if (playerHand.isEmpty || cpuHand.isEmpty) {
      return true;
    }

    // 両方がジョーカーのみを持っている場合
    if (playerHand.length == 1 && cpuHand.length == 1) {
      if (playerHand[0].isJoker && cpuHand[0].isJoker) {
        return true;
      }
    }

    // 一方のプレイヤーだけがジョーカーを持っている場合
    final playerHasOnlyJoker = playerHand.length == 1 && playerHand[0].isJoker;
    final cpuHasOnlyJoker = cpuHand.length == 1 && cpuHand[0].isJoker;

    if (playerHasOnlyJoker || cpuHasOnlyJoker) {
      return true;
    }

    return false;
  }

  /// 勝者を判定（ジョーカーを持っていないプレイヤーが勝者）
  static String determineWinner(List<Card> playerHand, List<Card> cpuHand) {
    // プレイヤーの手札が空の場合、プレイヤーの勝ち
    if (playerHand.isEmpty) {
      return 'player';
    }

    // CPUの手札が空の場合、CPUの勝ち
    if (cpuHand.isEmpty) {
      return 'cpu';
    }

    // ジョーカーを持っているかチェック
    final playerHasJoker = playerHand.any((card) => card.isJoker);
    final cpuHasJoker = cpuHand.any((card) => card.isJoker);

    if (playerHasJoker && !cpuHasJoker) {
      return 'cpu';
    } else if (!playerHasJoker && cpuHasJoker) {
      return 'player';
    }

    // 両方がジョーカーを持っている場合（通常は発生しない）
    return 'draw';
  }
}
