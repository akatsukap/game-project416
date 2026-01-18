import 'card.dart';

/// マルチプレイヤーゲームの状態
class MultiplayerGameState {
  final List<List<Card>> playerHands; // 各プレイヤーの手札
  final int currentPlayerIndex; // 現在のターンのプレイヤー
  final GameStatus status; // ゲームの状態
  final int? winner; // 勝者のインデックス（null=進行中）
  final int playerCount; // プレイヤー数

  MultiplayerGameState({
    required this.playerHands,
    required this.currentPlayerIndex,
    required this.status,
    this.winner,
    required this.playerCount,
  });

  /// 状態をコピーして一部を更新
  MultiplayerGameState copyWith({
    List<List<Card>>? playerHands,
    int? currentPlayerIndex,
    GameStatus? status,
    int? winner,
    int? playerCount,
  }) {
    return MultiplayerGameState(
      playerHands: playerHands ?? this.playerHands,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      playerCount: playerCount ?? this.playerCount,
    );
  }
}

/// ゲームの状態
enum GameStatus {
  playing, // ゲーム進行中
  finished, // ゲーム終了
}
