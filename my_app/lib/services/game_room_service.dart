import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_room.dart';
import '../models/player.dart';

/// ゲームルームの作成・管理を行うサービス
class GameRoomService {
  final FirebaseFirestore _firestore;

  /// コンストラクタ
  ///
  /// [firestore] Firestoreインスタンス（テスト用にモックを注入可能）
  GameRoomService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ゲームルームコレクションの参照
  CollectionReference get _roomsCollection =>
      _firestore.collection('game_rooms');

  /// 8文字の英数字ルームコードを生成
  ///
  /// 要件 3.2: ルームコードは8文字の英数字である必要がある
  String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Firestoreに新しいゲームルームを作成
  ///
  /// [hostId] ホストプレイヤーのID
  /// [hostNickname] ホストプレイヤーのニックネーム
  ///
  /// 要件 3.3: Firestoreに新しいゲームルームドキュメントを作成
  /// 要件 3.4: プレイヤーをホストとして設定
  Future<GameRoom> createRoom(String hostId, String hostNickname) async {
    try {
      // 一意のルームコードを生成（既存のルームと重複しないまで試行）
      String roomCode;
      bool isUnique = false;
      int attempts = 0;
      const maxAttempts = 10;

      do {
        roomCode = generateRoomCode();
        final existingRoom = await _roomsCollection.doc(roomCode).get();
        isUnique = !existingRoom.exists;
        attempts++;
      } while (!isUnique && attempts < maxAttempts);

      if (!isUnique) {
        throw Exception('一意のルームコードを生成できませんでした');
      }

      // ゲームルームを作成
      final now = DateTime.now();
      final gameRoom = GameRoom(
        roomCode: roomCode,
        hostId: hostId,
        playerIds: [hostId],
        maxPlayers: 4,
        status: RoomStatus.waiting,
        createdAt: now,
      );

      // ホストプレイヤー情報を作成
      final hostPlayer = Player(
        id: hostId,
        nickname: hostNickname,
        hand: [],
        isConnected: true,
        lastSeen: now,
      );

      // Firestoreに保存
      final roomData = gameRoom.toMap();
      roomData['players'] = {hostId: hostPlayer.toMap()};

      await _roomsCollection.doc(roomCode).set(roomData);

      return gameRoom;
    } catch (e) {
      throw Exception('ゲームルームの作成に失敗しました: $e');
    }
  }

  /// ゲームルームに参加
  ///
  /// [roomCode] 参加するルームコード
  /// [playerId] 参加するプレイヤーのID
  /// [playerNickname] 参加するプレイヤーのニックネーム
  ///
  /// 要件 4.3: 入力されたルームコードが存在するか検証
  /// 要件 4.5: ルームが満員でない場合、プレイヤーをゲストとして追加
  Future<void> joinRoom(
    String roomCode,
    String playerId,
    String playerNickname,
  ) async {
    try {
      final roomDoc = _roomsCollection.doc(roomCode);
      final roomSnapshot = await roomDoc.get();

      // ルームが存在するか確認
      if (!roomSnapshot.exists) {
        throw Exception('ルームが見つかりません');
      }

      final roomData = roomSnapshot.data() as Map<String, dynamic>;
      final gameRoom = GameRoom.fromMap(roomData);

      // ルームが満員でないか確認
      if (gameRoom.isFull) {
        throw Exception('ルームは満員です');
      }

      // ゲームが開始されていないか確認
      if (gameRoom.status != RoomStatus.waiting) {
        throw Exception('ゲームは既に開始されています');
      }

      // プレイヤーが既に参加していないか確認
      if (gameRoom.playerIds.contains(playerId)) {
        throw Exception('既にこのルームに参加しています');
      }

      // プレイヤー情報を作成
      final now = DateTime.now();
      final player = Player(
        id: playerId,
        nickname: playerNickname,
        hand: [],
        isConnected: true,
        lastSeen: now,
      );

      // Firestoreを更新
      await roomDoc.update({
        'playerIds': FieldValue.arrayUnion([playerId]),
        'players.$playerId': player.toMap(),
      });
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('ゲームルームへの参加に失敗しました: $e');
    }
  }

  /// ゲームルームから退出
  ///
  /// [roomCode] 退出するルームコード
  /// [playerId] 退出するプレイヤーのID
  ///
  /// 要件 15.2: プレイヤーをルームから削除
  /// 要件 15.4: ホストが退出した場合、次のプレイヤーを新しいホストに昇格
  /// 要件 15.5: すべてのプレイヤーが退出した場合、ゲームルームを削除
  Future<void> leaveRoom(String roomCode, String playerId) async {
    try {
      final roomDoc = _roomsCollection.doc(roomCode);
      final roomSnapshot = await roomDoc.get();

      if (!roomSnapshot.exists) {
        throw Exception('ルームが見つかりません');
      }

      final roomData = roomSnapshot.data() as Map<String, dynamic>;
      final gameRoom = GameRoom.fromMap(roomData);

      // プレイヤーがルームに参加しているか確認
      if (!gameRoom.playerIds.contains(playerId)) {
        throw Exception('このルームに参加していません');
      }

      // プレイヤーリストから削除
      final updatedPlayerIds = gameRoom.playerIds
          .where((id) => id != playerId)
          .toList();

      // すべてのプレイヤーが退出した場合、ルームを削除
      if (updatedPlayerIds.isEmpty) {
        await deleteRoom(roomCode);
        return;
      }

      // ホストが退出した場合、次のプレイヤーをホストに昇格
      String newHostId = gameRoom.hostId;
      if (gameRoom.hostId == playerId) {
        newHostId = updatedPlayerIds.first;
      }

      // Firestoreを更新
      await roomDoc.update({
        'playerIds': updatedPlayerIds,
        'hostId': newHostId,
        'players.$playerId': FieldValue.delete(),
      });
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('ゲームルームからの退出に失敗しました: $e');
    }
  }

  /// ゲームルームを取得
  ///
  /// [roomCode] 取得するルームコード
  ///
  /// ルームが存在しない場合はnullを返す
  Future<GameRoom?> getRoom(String roomCode) async {
    try {
      final roomSnapshot = await _roomsCollection.doc(roomCode).get();

      if (!roomSnapshot.exists) {
        return null;
      }

      final roomData = roomSnapshot.data() as Map<String, dynamic>;
      return GameRoom.fromMap(roomData);
    } catch (e) {
      throw Exception('ゲームルームの取得に失敗しました: $e');
    }
  }

  /// ゲームルームをリアルタイムで監視
  ///
  /// [roomCode] 監視するルームコード
  ///
  /// 要件 5.4: プレイヤーが参加または退出した場合、リアルタイムで更新
  /// 要件 8.1: ゲーム中、Firestoreのゲームルームドキュメントをリアルタイムで監視
  Stream<GameRoom?> watchRoom(String roomCode) {
    return _roomsCollection.doc(roomCode).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final roomData = snapshot.data() as Map<String, dynamic>;
      return GameRoom.fromMap(roomData);
    });
  }

  /// ホストを変更
  ///
  /// [roomCode] ルームコード
  /// [newHostId] 新しいホストのプレイヤーID
  ///
  /// 要件 15.4: ホストを変更
  Future<void> transferHost(String roomCode, String newHostId) async {
    try {
      final roomDoc = _roomsCollection.doc(roomCode);
      final roomSnapshot = await roomDoc.get();

      if (!roomSnapshot.exists) {
        throw Exception('ルームが見つかりません');
      }

      final roomData = roomSnapshot.data() as Map<String, dynamic>;
      final gameRoom = GameRoom.fromMap(roomData);

      // 新しいホストがルームに参加しているか確認
      if (!gameRoom.playerIds.contains(newHostId)) {
        throw Exception('指定されたプレイヤーはこのルームに参加していません');
      }

      // Firestoreを更新
      await roomDoc.update({'hostId': newHostId});
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('ホストの変更に失敗しました: $e');
    }
  }

  /// ゲームルームを削除
  ///
  /// [roomCode] 削除するルームコード
  ///
  /// 要件 15.5: すべてのプレイヤーが退出した場合、ゲームルームを削除
  Future<void> deleteRoom(String roomCode) async {
    try {
      await _roomsCollection.doc(roomCode).delete();
    } catch (e) {
      throw Exception('ゲームルームの削除に失敗しました: $e');
    }
  }

  /// ゲームルームのステータスを更新
  ///
  /// [roomCode] ルームコード
  /// [status] 新しいステータス
  Future<void> updateRoomStatus(String roomCode, RoomStatus status) async {
    try {
      final roomDoc = _roomsCollection.doc(roomCode);
      final roomSnapshot = await roomDoc.get();

      if (!roomSnapshot.exists) {
        throw Exception('ルームが見つかりません');
      }

      await roomDoc.update({'status': _statusToString(status)});
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('ルームステータスの更新に失敗しました: $e');
    }
  }

  /// ゲームルームのプレイヤー情報を取得
  ///
  /// [roomCode] ルームコード
  ///
  /// プレイヤーIDをキーとするプレイヤー情報のマップを返す
  Future<Map<String, Player>> getPlayers(String roomCode) async {
    try {
      final roomSnapshot = await _roomsCollection.doc(roomCode).get();

      if (!roomSnapshot.exists) {
        return {};
      }

      final roomData = roomSnapshot.data() as Map<String, dynamic>;
      final playersData = roomData['players'] as Map<String, dynamic>?;

      if (playersData == null) {
        return {};
      }

      final players = <String, Player>{};
      playersData.forEach((playerId, playerData) {
        players[playerId] = Player.fromMap(playerData as Map<String, dynamic>);
      });

      return players;
    } catch (e) {
      throw Exception('プレイヤー情報の取得に失敗しました: $e');
    }
  }

  /// RoomStatusを文字列に変換
  String _statusToString(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return 'waiting';
      case RoomStatus.playing:
        return 'playing';
      case RoomStatus.finished:
        return 'finished';
    }
  }
}
