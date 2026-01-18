import 'card.dart';

enum GameStatus { playing, finished }

class GameState {
  final List<Card> playerHand;
  final List<Card> cpuHand;
  final bool isPlayerTurn;
  final GameStatus status;
  final String? winner;

  GameState({
    required this.playerHand,
    required this.cpuHand,
    required this.isPlayerTurn,
    required this.status,
    this.winner,
  });

  GameState copyWith({
    List<Card>? playerHand,
    List<Card>? cpuHand,
    bool? isPlayerTurn,
    GameStatus? status,
    String? winner,
  }) {
    return GameState(
      playerHand: playerHand ?? this.playerHand,
      cpuHand: cpuHand ?? this.cpuHand,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      status: status ?? this.status,
      winner: winner ?? this.winner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        _listEquals(other.playerHand, playerHand) &&
        _listEquals(other.cpuHand, cpuHand) &&
        other.isPlayerTurn == isPlayerTurn &&
        other.status == status &&
        other.winner == winner;
  }

  @override
  int get hashCode =>
      playerHand.hashCode ^
      cpuHand.hashCode ^
      isPlayerTurn.hashCode ^
      status.hashCode ^
      winner.hashCode;

  bool _listEquals(List<Card> a, List<Card> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
