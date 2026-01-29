/// 試合結果のデータモデル
///
/// 1対1の試合の結果を記録します。
/// JSON形式でのシリアライズ/デシリアライズに対応しています。
class MatchResult {
  /// プレイヤー1のキャラクターID
  final String player1CharacterId;

  /// プレイヤー2のキャラクターID
  final String player2CharacterId;

  /// プレイヤー1のスコア
  final int player1Score;

  /// プレイヤー2のスコア
  final int player2Score;

  /// 試合が行われた日時
  final DateTime timestamp;

  /// 勝者のID（1: プレイヤー1, 2: プレイヤー2, 0: 引き分け）
  final int winnerId;

  /// コンストラクタ
  const MatchResult({
    required this.player1CharacterId,
    required this.player2CharacterId,
    required this.player1Score,
    required this.player2Score,
    required this.timestamp,
    required this.winnerId,
  });

  /// JSONからMatchResultを作成する
  ///
  /// [json] JSON形式のマップ
  /// 戻り値: MatchResultインスタンス
  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      player1CharacterId: json['player1CharacterId'] as String,
      player2CharacterId: json['player2CharacterId'] as String,
      player1Score: json['player1Score'] as int,
      player2Score: json['player2Score'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      winnerId: json['winnerId'] as int,
    );
  }

  /// MatchResultをJSON形式に変換する
  ///
  /// 戻り値: JSON形式のマップ
  Map<String, dynamic> toJson() {
    return {
      'player1CharacterId': player1CharacterId,
      'player2CharacterId': player2CharacterId,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'timestamp': timestamp.toIso8601String(),
      'winnerId': winnerId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MatchResult &&
        other.player1CharacterId == player1CharacterId &&
        other.player2CharacterId == player2CharacterId &&
        other.player1Score == player1Score &&
        other.player2Score == player2Score &&
        other.timestamp == timestamp &&
        other.winnerId == winnerId;
  }

  @override
  int get hashCode {
    return player1CharacterId.hashCode ^
        player2CharacterId.hashCode ^
        player1Score.hashCode ^
        player2Score.hashCode ^
        timestamp.hashCode ^
        winnerId.hashCode;
  }

  @override
  String toString() {
    return 'MatchResult(player1: $player1CharacterId($player1Score), player2: $player2CharacterId($player2Score), winner: $winnerId, timestamp: $timestamp)';
  }
}
