import 'card.dart';

/// オンラインマルチプレイヤーゲームのプレイヤーを表すモデル
class Player {
  final String id; // Firebase UID
  final String nickname; // ニックネーム
  final List<Card> hand; // 手札
  final bool isConnected; // 接続状態
  final DateTime lastSeen; // 最終接続時刻

  Player({
    required this.id,
    required this.nickname,
    required this.hand,
    this.isConnected = true,
    required this.lastSeen,
  });

  /// FirestoreドキュメントからPlayerオブジェクトを作成
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      nickname: map['nickname'] as String,
      hand: (map['hand'] as List<dynamic>)
          .map(
            (cardMap) => Card(
              suit: cardMap['suit'] as String,
              rank: cardMap['rank'] as String,
              isJoker: cardMap['isJoker'] as bool,
            ),
          )
          .toList(),
      isConnected: map['isConnected'] as bool? ?? true,
      lastSeen: DateTime.parse(map['lastSeen'] as String),
    );
  }

  /// PlayerオブジェクトをFirestoreドキュメント用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'hand': hand
          .map(
            (card) => {
              'suit': card.suit,
              'rank': card.rank,
              'isJoker': card.isJoker,
            },
          )
          .toList(),
      'isConnected': isConnected,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  /// プレイヤーのコピーを作成（一部のプロパティを変更可能）
  Player copyWith({
    String? id,
    String? nickname,
    List<Card>? hand,
    bool? isConnected,
    DateTime? lastSeen,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      hand: hand ?? this.hand,
      isConnected: isConnected ?? this.isConnected,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player &&
        other.id == id &&
        other.nickname == nickname &&
        _listEquals(other.hand, hand) &&
        other.isConnected == isConnected &&
        other.lastSeen == lastSeen;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      nickname.hashCode ^
      hand.hashCode ^
      isConnected.hashCode ^
      lastSeen.hashCode;

  bool _listEquals(List<Card> a, List<Card> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'Player(id: $id, nickname: $nickname, handSize: ${hand.length}, isConnected: $isConnected)';
}
