class Card {
  final String suit;
  final String rank;
  final bool isJoker;

  Card({required this.suit, required this.rank, required this.isJoker});

  /// ペアを形成できるか判定
  /// 同じランクのカード同士がペアを形成する
  /// ジョーカーはどのカードともペアを形成しない
  bool canPairWith(Card other) {
    if (isJoker || other.isJoker) {
      return false;
    }
    return rank == other.rank;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card &&
        other.suit == suit &&
        other.rank == rank &&
        other.isJoker == isJoker;
  }

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode ^ isJoker.hashCode;

  @override
  String toString() => isJoker ? 'Joker' : '$rank of $suit';
}
