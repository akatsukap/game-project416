import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/card.dart';
import '../models/game_room.dart';
import '../models/multiplayer_game_state.dart';
import '../models/player.dart';

/// ゲーム状態のリアルタイム同期を管理するサービス
class GameSyncService {
  final FirebaseFirestore _firestore;

  /// コンストラクタ
  ///
  /// [firestore] Firestoreインスタンス（テスト用にモックを注入可能）
  GameSyncService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ゲーム状態を初期化
  ///
  /// [roomCode] ルームコード
  /// [playerIds] プレイヤーIDのリスト
  /// [players] プレイヤーマップ（ID -> Player）
  /// [turnOrder] ターン順序
  Future<void> initializeGame(
    String roomCode,
    List<String> playerIds,
    Map<String, Player> players,
    List<String> turnOrder,
  ) async {
    try {
      final gameState = MultiplayerGameState(
        roomCode: roomCode,
        players: players,
        turnOrder: turnOrder,
        currentTurnIndex: 0,
        status: RoomStatus.playing,
        loserId: null,
        lastUpdated: DateTime.now(),
      );

      // ゲーム状態をFirestoreに保存
      await _firestore
          .collection('game_rooms')
          .doc(roomCode)
          .collection('game_state')
          .doc('current')
          .set(gameState.toMap());
    } catch (e) {
      throw Exception('ゲーム状態の初期化に失敗しました: $e');
    }
  }

  /// ゲーム状態を更新
  ///
  /// [state] 更新するゲーム状態
  Future<void> updateGameState(MultiplayerGameState state) async {
    try {
      final updatedState = state.copyWith(lastUpdated: DateTime.now());

      await _firestore
          .collection('game_rooms')
          .doc(state.roomCode)
          .collection('game_state')
          .doc('current')
          .set(updatedState.toMap());
    } catch (e) {
      throw Exception('ゲーム状態の更新に失敗しました: $e');
    }
  }

  /// プレイヤーの手札を更新
  ///
  /// [roomCode] ルームコード
  /// [playerId] プレイヤーID
  /// [hand] 新しい手札
  Future<void> updatePlayerHand(
    String roomCode,
    String playerId,
    List<Card> hand,
  ) async {
    try {
      // 現在のゲーム状態を取得
      final gameStateDoc = await _firestore
          .collection('game_rooms')
          .doc(roomCode)
          .collection('game_state')
          .doc('current')
          .get();

      if (!gameStateDoc.exists) {
        throw Exception('ゲーム状態が見つかりません');
      }

      final gameState = MultiplayerGameState.fromMap(
        gameStateDoc.data() as Map<String, dynamic>,
      );

      // プレイヤーの手札を更新
      final updatedPlayers = Map<String, Player>.from(gameState.players);
      final player = updatedPlayers[playerId];

      if (player == null) {
        throw Exception('プレイヤーが見つかりません: $playerId');
      }

      updatedPlayers[playerId] = player.copyWith(
        hand: hand,
        lastSeen: DateTime.now(),
      );

      // ゲーム状態を更新
      final updatedState = gameState.copyWith(
        players: updatedPlayers,
        lastUpdated: DateTime.now(),
      );

      await updateGameState(updatedState);
    } catch (e) {
      throw Exception('プレイヤーの手札の更新に失敗しました: $e');
    }
  }

  /// ターンを進める
  ///
  /// [roomCode] ルームコード
  Future<void> advanceTurn(String roomCode) async {
    try {
      // 現在のゲーム状態を取得
      final gameStateDoc = await _firestore
          .collection('game_rooms')
          .doc(roomCode)
          .collection('game_state')
          .doc('current')
          .get();

      if (!gameStateDoc.exists) {
        throw Exception('ゲーム状態が見つかりません');
      }

      final gameState = MultiplayerGameState.fromMap(
        gameStateDoc.data() as Map<String, dynamic>,
      );

      // 次のターンインデックスを計算（循環）
      final nextTurnIndex =
          (gameState.currentTurnIndex + 1) % gameState.turnOrder.length;

      // ゲーム状態を更新
      final updatedState = gameState.copyWith(
        currentTurnIndex: nextTurnIndex,
        lastUpdated: DateTime.now(),
      );

      await updateGameState(updatedState);
    } catch (e) {
      throw Exception('ターンの進行に失敗しました: $e');
    }
  }

  /// ゲーム状態をリアルタイムで監視
  ///
  /// [roomCode] ルームコード
  ///
  /// Returns: ゲーム状態のストリーム
  Stream<MultiplayerGameState?> watchGameState(String roomCode) {
    return _firestore
        .collection('game_rooms')
        .doc(roomCode)
        .collection('game_state')
        .doc('current')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            return null;
          }

          try {
            return MultiplayerGameState.fromMap(
              snapshot.data() as Map<String, dynamic>,
            );
          } catch (e) {
            print('ゲーム状態の解析に失敗しました: $e');
            return null;
          }
        });
  }

  /// プレイヤーの接続状態を更新
  ///
  /// [roomCode] ルームコード
  /// [playerId] プレイヤーID
  /// [isConnected] 接続状態
  Future<void> updatePlayerConnection(
    String roomCode,
    String playerId,
    bool isConnected,
  ) async {
    try {
      // 現在のゲーム状態を取得
      final gameStateDoc = await _firestore
          .collection('game_rooms')
          .doc(roomCode)
          .collection('game_state')
          .doc('current')
          .get();

      if (!gameStateDoc.exists) {
        throw Exception('ゲーム状態が見つかりません');
      }

      final gameState = MultiplayerGameState.fromMap(
        gameStateDoc.data() as Map<String, dynamic>,
      );

      // プレイヤーの接続状態を更新
      final updatedPlayers = Map<String, Player>.from(gameState.players);
      final player = updatedPlayers[playerId];

      if (player == null) {
        throw Exception('プレイヤーが見つかりません: $playerId');
      }

      updatedPlayers[playerId] = player.copyWith(
        isConnected: isConnected,
        lastSeen: DateTime.now(),
      );

      // ゲーム状態を更新
      final updatedState = gameState.copyWith(
        players: updatedPlayers,
        lastUpdated: DateTime.now(),
      );

      await updateGameState(updatedState);
    } catch (e) {
      throw Exception('プレイヤーの接続状態の更新に失敗しました: $e');
    }
  }

  /// ゲームを終了
  ///
  /// [roomCode] ルームコード
  /// [loserId] 敗者のプレイヤーID
  Future<void> endGame(String roomCode, String loserId) async {
    try {
      // 現在のゲーム状態を取得
      final gameStateDoc = await _firestore
          .collection('game_rooms')
          .doc(roomCode)
          .collection('game_state')
          .doc('current')
          .get();

      if (!gameStateDoc.exists) {
        throw Exception('ゲーム状態が見つかりません');
      }

      final gameState = MultiplayerGameState.fromMap(
        gameStateDoc.data() as Map<String, dynamic>,
      );

      // ゲーム状態を終了状態に更新
      final updatedState = gameState.copyWith(
        status: RoomStatus.finished,
        loserId: loserId,
        lastUpdated: DateTime.now(),
      );

      await updateGameState(updatedState);

      // ゲームルームのステータスも更新
      await _firestore.collection('game_rooms').doc(roomCode).update({
        'status': 'finished',
      });
    } catch (e) {
      throw Exception('ゲームの終了に失敗しました: $e');
    }
  }
}
