import 'game_room.dart';
import 'player.dart';

/// オンラインマルチプレイヤーゲームの状態を表すモデル
class MultiplayerGameState {
  final String roomCode; // ルームコード
  final Map<String, Player> players; // プレイヤーマップ（ID -> Player）
  final List<String> turnOrder; // ターン順序
  final int currentTurnIndex; // 現在のターンインデックス
  final RoomStatus status; // ゲームステータス
  final String? loserId; // 敗者のID（ゲーム終了時）
  final DateTime lastUpdated; // 最終更新時刻

  MultiplayerGameState({
    required this.roomCode,
    required this.players,
    required this.turnOrder,
    required this.currentTurnIndex,
    required this.status,
    this.loserId,
    required this.lastUpdated,
  });

  /// 現在のターンのプレイヤーIDを取得
  String get currentPlayerId => turnOrder[currentTurnIndex];

  /// 現在のターンのプレイヤーを取得
  Player get currentPlayer => players[currentPlayerId]!;

  /// FirestoreドキュメントからMultiplayerGameStateオブジェクトを作成
  factory MultiplayerGameState.fromMap(Map<String, dynamic> map) {
    // プレイヤーマップを変換
    final playersMap = <String, Player>{};
    final playersData = map['players'] as Map<String, dynamic>;
    playersData.forEach((key, value) {
      playersMap[key] = Player.fromMap(value as Map<String, dynamic>);
    });

    return MultiplayerGameState(
      roomCode: map['roomCode'] as String,
      players: playersMap,
      turnOrder: List<String>.from(map['turnOrder'] as List<dynamic>),
      currentTurnIndex: map['currentTurnIndex'] as int,
      status: _statusFromString(map['status'] as String),
      loserId: map['loserId'] as String?,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  /// MultiplayerGameStateオブジェクトをFirestoreドキュメント用のMapに変換
  Map<String, dynamic> toMap() {
    // プレイヤーマップを変換
    final playersMap = <String, dynamic>{};
    players.forEach((key, value) {
      playersMap[key] = value.toMap();
    });

    return {
      'roomCode': roomCode,
      'players': playersMap,
      'turnOrder': turnOrder,
      'currentTurnIndex': currentTurnIndex,
      'status': _statusToString(status),
      'loserId': loserId,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// ゲーム状態のコピーを作成（一部のプロパティを変更可能）
  MultiplayerGameState copyWith({
    String? roomCode,
    Map<String, Player>? players,
    List<String>? turnOrder,
    int? currentTurnIndex,
    RoomStatus? status,
    String? loserId,
    DateTime? lastUpdated,
  }) {
    return MultiplayerGameState(
      roomCode: roomCode ?? this.roomCode,
      players: players ?? this.players,
      turnOrder: turnOrder ?? this.turnOrder,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      status: status ?? this.status,
      loserId: loserId ?? this.loserId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MultiplayerGameState &&
        other.roomCode == roomCode &&
        _mapEquals(other.players, players) &&
        _listEquals(other.turnOrder, turnOrder) &&
        other.currentTurnIndex == currentTurnIndex &&
        other.status == status &&
        other.loserId == loserId &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode =>
      roomCode.hashCode ^
      players.hashCode ^
      turnOrder.hashCode ^
      currentTurnIndex.hashCode ^
      status.hashCode ^
      (loserId?.hashCode ?? 0) ^
      lastUpdated.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals(Map<String, Player> a, Map<String, Player> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'MultiplayerGameState(roomCode: $roomCode, players: ${players.length}, currentTurn: $currentTurnIndex/${turnOrder.length}, status: $status)';

  /// RoomStatusを文字列に変換
  static String _statusToString(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return 'waiting';
      case RoomStatus.playing:
        return 'playing';
      case RoomStatus.finished:
        return 'finished';
    }
  }

  /// 文字列からRoomStatusに変換
  static RoomStatus _statusFromString(String status) {
    switch (status) {
      case 'waiting':
        return RoomStatus.waiting;
      case 'playing':
        return RoomStatus.playing;
      case 'finished':
        return RoomStatus.finished;
      default:
        throw ArgumentError('Invalid room status: $status');
    }
  }
}
