/// ゲームルームのステータスを表す列挙型
enum RoomStatus {
  waiting, // 待機中
  playing, // ゲーム進行中
  finished, // ゲーム終了
}

/// オンラインマルチプレイヤーゲームのルームを表すモデル
class GameRoom {
  final String roomCode; // ルームコード（8文字）
  final String hostId; // ホストのプレイヤーID
  final List<String> playerIds; // 参加プレイヤーIDリスト
  final int maxPlayers; // 最大プレイヤー数（デフォルト4）
  final RoomStatus status; // ルームステータス
  final DateTime createdAt; // 作成日時

  GameRoom({
    required this.roomCode,
    required this.hostId,
    required this.playerIds,
    this.maxPlayers = 4,
    required this.status,
    required this.createdAt,
  });

  /// ルームが満員かどうかを判定
  bool get isFull => playerIds.length >= maxPlayers;

  /// ゲームを開始できるかどうかを判定（2人以上必要）
  bool get canStart => playerIds.length >= 2;

  /// FirestoreドキュメントからGameRoomオブジェクトを作成
  factory GameRoom.fromMap(Map<String, dynamic> map) {
    return GameRoom(
      roomCode: map['roomCode'] as String,
      hostId: map['hostId'] as String,
      playerIds: List<String>.from(map['playerIds'] as List<dynamic>),
      maxPlayers: map['maxPlayers'] as int? ?? 4,
      status: _statusFromString(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// GameRoomオブジェクトをFirestoreドキュメント用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'roomCode': roomCode,
      'hostId': hostId,
      'playerIds': playerIds,
      'maxPlayers': maxPlayers,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// ゲームルームのコピーを作成（一部のプロパティを変更可能）
  GameRoom copyWith({
    String? roomCode,
    String? hostId,
    List<String>? playerIds,
    int? maxPlayers,
    RoomStatus? status,
    DateTime? createdAt,
  }) {
    return GameRoom(
      roomCode: roomCode ?? this.roomCode,
      hostId: hostId ?? this.hostId,
      playerIds: playerIds ?? this.playerIds,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameRoom &&
        other.roomCode == roomCode &&
        other.hostId == hostId &&
        _listEquals(other.playerIds, playerIds) &&
        other.maxPlayers == maxPlayers &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      roomCode.hashCode ^
      hostId.hashCode ^
      playerIds.hashCode ^
      maxPlayers.hashCode ^
      status.hashCode ^
      createdAt.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'GameRoom(roomCode: $roomCode, hostId: $hostId, players: ${playerIds.length}/$maxPlayers, status: $status)';

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
