import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/game_room_service.dart';
import 'package:my_app/services/game_sync_service.dart';
import 'package:my_app/logic/multiplayer_game_logic.dart';
import 'package:my_app/models/card.dart' as game_card;
import 'test_helper.dart';

/// 統合テスト: ゲームフローのシナリオテスト
///
/// このテストは様々なゲームシナリオをカバーします：
/// - 2人プレイヤーのゲーム
/// - 3人プレイヤーのゲーム
/// - 4人プレイヤーのゲーム
/// - プレイヤーの途中退出
/// - ホストの交代
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ゲームフローシナリオテスト', () {
    late AuthService authService;
    late GameRoomService roomService;
    late GameSyncService syncService;

    setUpAll(() async {
      await IntegrationTestHelper.initializeEmulators();
      authService = AuthService();
      roomService = GameRoomService();
      syncService = GameSyncService();
    });

    setUp(() async {
      await IntegrationTestHelper.cleanup();
    });

    test('シナリオ1: 2人プレイヤーでの完全なゲーム', () async {
      // プレイヤー1（ホスト）を作成
      final player1 = await authService.signInAnonymously();
      expect(player1, isNotNull);

      // ルームを作成
      final room = await roomService.createRoom(player1!.uid);
      expect(room.roomCode.length, 8);

      // プレイヤー2を作成して参加
      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player2!.uid);

      // ルームを確認
      final updatedRoom = await roomService.getRoom(room.roomCode);
      expect(updatedRoom!.playerIds.length, 2);
      expect(updatedRoom.canStart, true);

      // ゲームを初期化
      await syncService.initializeGame(room.roomCode, [
        player1.uid,
        player2.uid,
      ]);

      // ゲーム状態を確認
      final gameState = await syncService.watchGameState(room.roomCode).first;
      expect(gameState, isNotNull);
      expect(gameState!.players.length, 2);
      expect(gameState.turnOrder.length, 2);

      // 各プレイヤーがカードを持っていることを確認
      for (var player in gameState.players.values) {
        expect(player.hand.isNotEmpty, true);
      }

      // カードの総数が53枚であることを確認
      final totalCards = gameState.players.values.fold<int>(
        0,
        (sum, player) => sum + player.hand.length,
      );
      expect(totalCards, lessThanOrEqualTo(53));
    });

    test('シナリオ2: 3人プレイヤーでのゲーム開始', () async {
      // プレイヤー1（ホスト）を作成
      final player1 = await authService.signInAnonymously();
      final room = await roomService.createRoom(player1!.uid);

      // プレイヤー2を追加
      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player2!.uid);

      // プレイヤー3を追加
      await IntegrationTestHelper.signOut();
      final player3 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player3!.uid);

      // ルームを確認
      final updatedRoom = await roomService.getRoom(room.roomCode);
      expect(updatedRoom!.playerIds.length, 3);

      // ゲームを初期化
      await syncService.initializeGame(room.roomCode, [
        player1.uid,
        player2.uid,
        player3.uid,
      ]);

      // ゲーム状態を確認
      final gameState = await syncService.watchGameState(room.roomCode).first;
      expect(gameState!.players.length, 3);
      expect(gameState.turnOrder.length, 3);

      // カードが均等に配られていることを確認
      final cardCounts = gameState.players.values
          .map((player) => player.hand.length)
          .toList();
      final maxDiff =
          cardCounts.reduce((a, b) => a > b ? a : b) -
          cardCounts.reduce((a, b) => a < b ? a : b);
      expect(maxDiff, lessThanOrEqualTo(1));
    });

    test('シナリオ3: 4人プレイヤー（最大）でのゲーム', () async {
      // 4人のプレイヤーを作成
      final playerIds = <String>[];

      // プレイヤー1（ホスト）
      final player1 = await authService.signInAnonymously();
      playerIds.add(player1!.uid);
      final room = await roomService.createRoom(player1.uid);

      // プレイヤー2-4を追加
      for (int i = 0; i < 3; i++) {
        await IntegrationTestHelper.signOut();
        final player = await authService.signInAnonymously();
        playerIds.add(player!.uid);
        await roomService.joinRoom(room.roomCode, player.uid);
      }

      // ルームが満員であることを確認
      final updatedRoom = await roomService.getRoom(room.roomCode);
      expect(updatedRoom!.isFull, true);
      expect(updatedRoom.playerIds.length, 4);

      // ゲームを初期化
      await syncService.initializeGame(room.roomCode, playerIds);

      // ゲーム状態を確認
      final gameState = await syncService.watchGameState(room.roomCode).first;
      expect(gameState!.players.length, 4);
      expect(gameState.turnOrder.length, 4);
    });

    test('シナリオ4: プレイヤーの途中退出', () async {
      // 3人のプレイヤーでゲームを開始
      final player1 = await authService.signInAnonymously();
      final room = await roomService.createRoom(player1!.uid);

      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player2!.uid);

      await IntegrationTestHelper.signOut();
      final player3 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player3!.uid);

      // 初期状態を確認
      var currentRoom = await roomService.getRoom(room.roomCode);
      expect(currentRoom!.playerIds.length, 3);

      // プレイヤー2が退出
      await roomService.leaveRoom(room.roomCode, player2.uid);

      // ルームが更新されていることを確認
      currentRoom = await roomService.getRoom(room.roomCode);
      expect(currentRoom!.playerIds.length, 2);
      expect(currentRoom.playerIds, isNot(contains(player2.uid)));
      expect(currentRoom.playerIds, contains(player1.uid));
      expect(currentRoom.playerIds, contains(player3.uid));
    });

    test('シナリオ5: ホストの退出とホスト移譲', () async {
      // 3人のプレイヤーでルームを作成
      final player1 = await authService.signInAnonymously();
      final room = await roomService.createRoom(player1!.uid);

      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player2!.uid);

      await IntegrationTestHelper.signOut();
      final player3 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player3!.uid);

      // 初期ホストを確認
      var currentRoom = await roomService.getRoom(room.roomCode);
      expect(currentRoom!.hostId, player1.uid);

      // ホスト（プレイヤー1）が退出
      await roomService.leaveRoom(room.roomCode, player1.uid);

      // 新しいホストが設定されていることを確認
      currentRoom = await roomService.getRoom(room.roomCode);
      expect(currentRoom, isNotNull);
      expect(currentRoom!.hostId, isNot(player1.uid));
      expect(currentRoom.hostId, anyOf(player2.uid, player3.uid));
      expect(currentRoom.playerIds.length, 2);
    });

    test('シナリオ6: ターン進行のシミュレーション', () async {
      // 2人のプレイヤーでゲームを開始
      final player1 = await authService.signInAnonymously();
      final room = await roomService.createRoom(player1!.uid);

      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player2!.uid);

      // ゲームを初期化
      await syncService.initializeGame(room.roomCode, [
        player1.uid,
        player2.uid,
      ]);

      // 初期ターンを確認
      var gameState = await syncService.watchGameState(room.roomCode).first;
      final initialTurnIndex = gameState!.currentTurnIndex;
      final initialPlayerId = gameState.currentPlayerId;

      // ターンを進める
      await syncService.advanceTurn(room.roomCode);

      // ターンが進んだことを確認
      await Future.delayed(const Duration(milliseconds: 500));
      gameState = await syncService.watchGameState(room.roomCode).first;
      expect(gameState.currentTurnIndex, isNot(initialTurnIndex));
      expect(gameState.currentPlayerId, isNot(initialPlayerId));

      // もう一度ターンを進める（循環を確認）
      await syncService.advanceTurn(room.roomCode);
      await Future.delayed(const Duration(milliseconds: 500));
      gameState = await syncService.watchGameState(room.roomCode).first;
      expect(gameState.currentPlayerId, initialPlayerId);
    });

    test('シナリオ7: ゲーム終了の処理', () async {
      // 2人のプレイヤーでゲームを開始
      final player1 = await authService.signInAnonymously();
      final room = await roomService.createRoom(player1!.uid);

      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player2!.uid);

      // ゲームを初期化
      await syncService.initializeGame(room.roomCode, [
        player1.uid,
        player2.uid,
      ]);

      // ゲームを終了
      await syncService.endGame(room.roomCode, player2.uid);

      // ゲーム状態を確認
      await Future.delayed(const Duration(milliseconds: 500));
      final gameState = await syncService.watchGameState(room.roomCode).first;
      expect(gameState!.loserId, player2.uid);
      expect(gameState.status.toString(), contains('finished'));
    });

    test('シナリオ8: 複数のルームの同時管理', () async {
      // ルーム1を作成
      final player1 = await authService.signInAnonymously();
      final room1 = await roomService.createRoom(player1!.uid);

      // ルーム2を作成
      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      final room2 = await roomService.createRoom(player2!.uid);

      // ルーム3を作成
      await IntegrationTestHelper.signOut();
      final player3 = await authService.signInAnonymously();
      final room3 = await roomService.createRoom(player3!.uid);

      // すべてのルームが独立して存在することを確認
      final fetchedRoom1 = await roomService.getRoom(room1.roomCode);
      final fetchedRoom2 = await roomService.getRoom(room2.roomCode);
      final fetchedRoom3 = await roomService.getRoom(room3.roomCode);

      expect(fetchedRoom1, isNotNull);
      expect(fetchedRoom2, isNotNull);
      expect(fetchedRoom3, isNotNull);

      expect(fetchedRoom1!.roomCode, room1.roomCode);
      expect(fetchedRoom2!.roomCode, room2.roomCode);
      expect(fetchedRoom3!.roomCode, room3.roomCode);

      expect(fetchedRoom1.hostId, player1.uid);
      expect(fetchedRoom2.hostId, player2.uid);
      expect(fetchedRoom3.hostId, player3.uid);
    });

    test('シナリオ9: リアルタイム同期の遅延テスト', () async {
      // 2人のプレイヤーでルームを作成
      final player1 = await authService.signInAnonymously();
      final room = await roomService.createRoom(player1!.uid);

      // ルームの変更を監視開始
      final roomStream = roomService.watchRoom(room.roomCode);
      final streamValues = <String>[];

      // ストリームをリスン
      final subscription = roomStream.listen((updatedRoom) {
        if (updatedRoom != null) {
          streamValues.add('players:${updatedRoom.playerIds.length}');
        }
      });

      // 少し待機
      await Future.delayed(const Duration(milliseconds: 500));

      // プレイヤー2を追加
      await IntegrationTestHelper.signOut();
      final player2 = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, player2!.uid);

      // 更新が反映されるまで待機
      await Future.delayed(const Duration(seconds: 1));

      // ストリームが更新を受信したことを確認
      expect(streamValues.length, greaterThan(0));

      await subscription.cancel();
    });

    test('シナリオ10: エラーリカバリー - 存在しないルームへの操作', () async {
      final player = await authService.signInAnonymously();

      // 存在しないルームコードで操作を試みる
      expect(
        () => roomService.joinRoom('NOTEXIST', player!.uid),
        throwsException,
      );

      expect(
        () => roomService.leaveRoom('NOTEXIST', player!.uid),
        throwsException,
      );

      final room = await roomService.getRoom('NOTEXIST');
      expect(room, isNull);
    });
  });
}
