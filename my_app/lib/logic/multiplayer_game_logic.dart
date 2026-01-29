import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/multiplayer_game_state.dart';

/// マルチプレイヤーババ抜きゲームのロジックを管理するクラス
class MultiplayerGameLogic {
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

  /// カードを配布（2-4人のプレイヤーに均等に配る）
  ///
  /// [deck] シャッフル済みのカードデッキ
  /// [playerIds] プレイヤーIDのリスト
  ///
  /// 戻り値: プレイヤーID -> 手札のマップ
  static Map<String, List<Card>> dealCardsMultiplayer(
    List<Card> deck,
    List<String> playerIds,
  ) {
    if (playerIds.isEmpty || playerIds.length > 4) {
      throw ArgumentError('プレイヤー数は2-4人である必要があります');
    }

    final Map<String, List<Card>> hands = {};

    // 各プレイヤーの手札を初期化
    for (final playerId in playerIds) {
      hands[playerId] = [];
    }

    // カードを順番に配る
    for (int i = 0; i < deck.length; i++) {
      final playerIndex = i % playerIds.length;
      hands[playerIds[playerIndex]]!.add(deck[i]);
    }

    // 各プレイヤーの手札からペアを削除
    hands.forEach((playerId, hand) {
      hands[playerId] = removePairs(hand);
    });

    return hands;
  }

  /// ターン順序をランダムに決定
  ///
  /// [playerIds] プレイヤーIDのリスト
  ///
  /// 戻り値: シャッフルされたプレイヤーIDのリスト
  static List<String> randomizeTurnOrder(List<String> playerIds) {
    final List<String> turnOrder = List.from(playerIds);
    final random = Random();

    // Fisher-Yatesシャッフルアルゴリズム
    for (int i = turnOrder.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = turnOrder[i];
      turnOrder[i] = turnOrder[j];
      turnOrder[j] = temp;
    }

    return turnOrder;
  }

  /// 手札からペアを削除
  ///
  /// [hand] プレイヤーの手札
  ///
  /// 戻り値: ペアを削除した後の手札
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

  /// カードを引く（マルチプレイヤー用）
  ///
  /// [state] 現在のゲーム状態
  /// [fromPlayerId] カードを引かれるプレイヤーのID
  /// [cardIndex] 引くカードのインデックス
  ///
  /// 戻り値: 更新されたゲーム状態
  static MultiplayerGameState drawCard(
    MultiplayerGameState state,
    String fromPlayerId,
    int cardIndex,
  ) {
    final currentPlayerId = state.currentPlayerId;
    final fromPlayer = state.players[fromPlayerId]!;
    final currentPlayer = state.players[currentPlayerId]!;

    // カードを引く
    final drawnCard = fromPlayer.hand[cardIndex];
    final newFromHand = List<Card>.from(fromPlayer.hand);
    newFromHand.removeAt(cardIndex);

    // 現在のプレイヤーの手札に追加
    final newCurrentHand = List<Card>.from(currentPlayer.hand);
    newCurrentHand.add(drawnCard);

    // ペアを削除
    final handAfterPairs = removePairs(newCurrentHand);

    // プレイヤー情報を更新
    final updatedPlayers = Map<String, Player>.from(state.players);
    updatedPlayers[fromPlayerId] = fromPlayer.copyWith(hand: newFromHand);
    updatedPlayers[currentPlayerId] = currentPlayer.copyWith(
      hand: handAfterPairs,
    );

    // ターンを進める
    final nextTurnIndex = (state.currentTurnIndex + 1) % state.turnOrder.length;

    return state.copyWith(
      players: updatedPlayers,
      currentTurnIndex: nextTurnIndex,
      lastUpdated: DateTime.now(),
    );
  }

  /// ゲーム終了判定（マルチプレイヤー用）
  ///
  /// [players] プレイヤーマップ
  ///
  /// 戻り値: ゲームが終了している場合はtrue
  static bool isGameOverMultiplayer(Map<String, Player> players) {
    // 手札が空でないプレイヤーの数をカウント
    int playersWithCards = 0;

    for (final player in players.values) {
      if (player.hand.isNotEmpty) {
        playersWithCards++;
      }
    }

    // 1人のプレイヤーを除いてすべてのプレイヤーの手札が空の場合、ゲーム終了
    return playersWithCards <= 1;
  }

  /// 敗者を判定（ジョーカーを持っているプレイヤー）
  ///
  /// [players] プレイヤーマップ
  ///
  /// 戻り値: 敗者のプレイヤーID、または見つからない場合はnull
  static String? determineLoser(Map<String, Player> players) {
    for (final entry in players.entries) {
      final player = entry.value;
      // ジョーカーを持っているプレイヤーを探す
      if (player.hand.any((card) => card.isJoker)) {
        return entry.key;
      }
    }

    // ジョーカーを持っているプレイヤーが見つからない場合
    // （通常は発生しないが、念のため）
    return null;
  }

  /// 切断されたプレイヤーを処理
  ///
  /// [state] 現在のゲーム状態
  /// [disconnectedPlayerId] 切断されたプレイヤーのID
  ///
  /// 戻り値: 更新されたゲーム状態
  static MultiplayerGameState handleDisconnectedPlayer(
    MultiplayerGameState state,
    String disconnectedPlayerId,
  ) {
    final disconnectedPlayer = state.players[disconnectedPlayerId];
    if (disconnectedPlayer == null) {
      return state;
    }

    // 切断されたプレイヤーの手札を取得
    final disconnectedHand = disconnectedPlayer.hand;

    // ターン順序から切断されたプレイヤーを除外
    final newTurnOrder = state.turnOrder
        .where((id) => id != disconnectedPlayerId)
        .toList();

    if (newTurnOrder.isEmpty) {
      // すべてのプレイヤーが切断された場合
      return state;
    }

    // 次のプレイヤーを決定
    final currentIndex = state.turnOrder.indexOf(disconnectedPlayerId);
    final nextPlayerIndex = currentIndex % newTurnOrder.length;
    final nextPlayerId = newTurnOrder[nextPlayerIndex];

    // 次のプレイヤーに手札を配布
    final nextPlayer = state.players[nextPlayerId]!;
    final newNextHand = List<Card>.from(nextPlayer.hand);
    newNextHand.addAll(disconnectedHand);

    // ペアを削除
    final handAfterPairs = removePairs(newNextHand);

    // プレイヤー情報を更新
    final updatedPlayers = Map<String, Player>.from(state.players);
    updatedPlayers.remove(disconnectedPlayerId);
    updatedPlayers[nextPlayerId] = nextPlayer.copyWith(hand: handAfterPairs);

    // 現在のターンインデックスを調整
    int newCurrentTurnIndex = state.currentTurnIndex;
    if (state.currentPlayerId == disconnectedPlayerId) {
      // 切断されたプレイヤーがターン中だった場合、次のプレイヤーに移動
      newCurrentTurnIndex = nextPlayerIndex;
    } else {
      // 現在のプレイヤーのインデックスを新しいターン順序で見つける
      final currentPlayerId = state.currentPlayerId;
      newCurrentTurnIndex = newTurnOrder.indexOf(currentPlayerId);
      if (newCurrentTurnIndex == -1) {
        newCurrentTurnIndex = 0;
      }
    }

    return state.copyWith(
      players: updatedPlayers,
      turnOrder: newTurnOrder,
      currentTurnIndex: newCurrentTurnIndex,
      lastUpdated: DateTime.now(),
    );
  }
}
