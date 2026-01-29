/// プレイヤー統計のデータモデル
///
/// プレイヤーの累積統計情報を記録します。
/// JSON形式でのシリアライズ/デシリアライズに対応しています。
class PlayerStats {
  /// 総試合数
  final int totalMatches;

  /// 勝利数
  final int wins;

  /// 敗北数
  final int losses;

  /// 引き分け数
  final int draws;

  /// 総得点数
  final int totalGoals;

  /// 総プレイ時間（秒）
  final double totalPlayTime;

  /// キャラクター使用回数（キャラクターID -> 使用回数）
  final Map<String, int> characterUsage;

  /// コンストラクタ
  const PlayerStats({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.totalGoals,
    required this.totalPlayTime,
    required this.characterUsage,
  });

  /// 空の統計データを作成する
  ///
  /// 戻り値: すべての値が0の新しいPlayerStatsインスタンス
  factory PlayerStats.empty() {
    return const PlayerStats(
      totalMatches: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      totalGoals: 0,
      totalPlayTime: 0.0,
      characterUsage: {},
    );
  }

  /// 勝率を計算する
  ///
  /// 戻り値: 勝率（0.0〜1.0）、試合数が0の場合は0.0
  double get winRate {
    if (totalMatches == 0) return 0.0;
    return wins / totalMatches;
  }

  /// JSONからPlayerStatsを作成する
  ///
  /// [json] JSON形式のマップ
  /// 戻り値: PlayerStatsインスタンス
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    // characterUsageをMap<String, int>に変換
    final Map<String, int> usage = {};
    if (json['characterUsage'] != null) {
      final usageJson = json['characterUsage'] as Map<String, dynamic>;
      usageJson.forEach((key, value) {
        usage[key] = value as int;
      });
    }

    return PlayerStats(
      totalMatches: json['totalMatches'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      totalGoals: json['totalGoals'] as int,
      totalPlayTime: (json['totalPlayTime'] as num).toDouble(),
      characterUsage: usage,
    );
  }

  /// PlayerStatsをJSON形式に変換する
  ///
  /// 戻り値: JSON形式のマップ
  Map<String, dynamic> toJson() {
    return {
      'totalMatches': totalMatches,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'totalGoals': totalGoals,
      'totalPlayTime': totalPlayTime,
      'characterUsage': characterUsage,
    };
  }

  /// 試合結果を反映した新しい統計データを作成する
  ///
  /// [matchResult] 反映する試合結果
  /// [playerNumber] このプレイヤーの番号（1または2）
  /// [playTime] 試合のプレイ時間（秒）
  /// 戻り値: 更新された新しいPlayerStatsインスタンス
  PlayerStats updateWithMatch({
    required int playerNumber,
    required int playerScore,
    required int opponentScore,
    required String characterId,
    required double playTime,
  }) {
    // 勝敗を判定
    int newWins = wins;
    int newLosses = losses;
    int newDraws = draws;

    if (playerScore > opponentScore) {
      newWins++;
    } else if (playerScore < opponentScore) {
      newLosses++;
    } else {
      newDraws++;
    }

    // キャラクター使用回数を更新
    final newCharacterUsage = Map<String, int>.from(characterUsage);
    newCharacterUsage[characterId] = (newCharacterUsage[characterId] ?? 0) + 1;

    return PlayerStats(
      totalMatches: totalMatches + 1,
      wins: newWins,
      losses: newLosses,
      draws: newDraws,
      totalGoals: totalGoals + playerScore,
      totalPlayTime: totalPlayTime + playTime,
      characterUsage: newCharacterUsage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerStats &&
        other.totalMatches == totalMatches &&
        other.wins == wins &&
        other.losses == losses &&
        other.draws == draws &&
        other.totalGoals == totalGoals &&
        other.totalPlayTime == totalPlayTime &&
        _mapsEqual(other.characterUsage, characterUsage);
  }

  /// 2つのマップが等しいかを判定する
  bool _mapsEqual(Map<String, int> map1, Map<String, int> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    int usageHash = 0;
    characterUsage.forEach((key, value) {
      usageHash ^= key.hashCode ^ value.hashCode;
    });

    return totalMatches.hashCode ^
        wins.hashCode ^
        losses.hashCode ^
        draws.hashCode ^
        totalGoals.hashCode ^
        totalPlayTime.hashCode ^
        usageHash;
  }

  @override
  String toString() {
    return 'PlayerStats(matches: $totalMatches, wins: $wins, losses: $losses, draws: $draws, goals: $totalGoals, playTime: ${totalPlayTime}s, winRate: ${(winRate * 100).toStringAsFixed(1)}%)';
  }
}
