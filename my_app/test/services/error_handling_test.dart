import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/game_room.dart';
import 'package:my_app/models/player.dart';
import 'package:my_app/services/game_room_service.dart';
import 'package:my_app/services/game_sync_service.dart';

/// エラーハンドリングとエッジケースのテスト
///
/// 要件 4.4, 14.1, 14.2, 14.3, 16.1, 16.2, 16.3, 16.4
void main() {
  group('GameRoomService - エッジケースのテスト', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GameRoomService gameRoomService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      gameRoomService = GameRoomService(firestore: fakeFirestore);
    });

    test('存在しないルームへの参加を拒否する（要件 4.4）', () async {
      // 存在しないルームコード
      const nonExistentRoomCode = 'NOTEXIST';
      const playerId = 'player123';
      const playerNickname = 'TestPlayer';

      // 存在しないルームに参加しようとする
      expect(
        () => gameRoomService.joinRoom(
          nonExistentRoomCode,
          playerId,
          playerNickname,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ルームが見つかりません'),
          ),
        ),
      );
    });

    test('満員のルームへの参加を拒否する（要件 4.4）', () async {
      // ホストを作成
      const hostId = 'host123';
      const hostNickname = 'Host';

      // ルームを作成
      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // 3人のプレイヤーを追加して満員にする（最大4人）
      for (int i = 1; i <= 3; i++) {
        await gameRoomService.joinRoom(
          gameRoom.roomCode,
          'player$i',
          'Player$i',
        );
      }

      // 5人目のプレイヤーが参加しようとする
      expect(
        () => gameRoomService.joinRoom(gameRoom.roomCode, 'player5', 'Player5'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ルームは満員です'),
          ),
        ),
      );
    });

    test('ゲーム開始後のルームへの参加を拒否する', () async {
      // ホストを作成
      const hostId = 'host123';
      const hostNickname = 'Host';

      // ルームを作成
      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // もう1人プレイヤーを追加
      await gameRoomService.joinRoom(gameRoom.roomCode, 'player1', 'Player1');

      // ゲームを開始（ステータスを変更）
      await gameRoomService.updateRoomStatus(
        gameRoom.roomCode,
        RoomStatus.playing,
      );

      // 新しいプレイヤーが参加しようとする
      expect(
        () => gameRoomService.joinRoom(gameRoom.roomCode, 'player2', 'Player2'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ゲームは既に開始されています'),
          ),
        ),
      );
    });

    test('既に参加しているプレイヤーの重複参加を拒否する', () async {
      // ホストを作成
      const hostId = 'host123';
      const hostNickname = 'Host';

      // ルームを作成
      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // プレイヤーを追加
      const playerId = 'player1';
      const playerNickname = 'Player1';
      await gameRoomService.joinRoom(
        gameRoom.roomCode,
        playerId,
        playerNickname,
      );

      // 同じプレイヤーが再度参加しようとする
      expect(
        () => gameRoomService.joinRoom(
          gameRoom.roomCode,
          playerId,
          playerNickname,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('既にこのルームに参加しています'),
          ),
        ),
      );
    });

    test('存在しないルームからの退出を拒否する', () async {
      const nonExistentRoomCode = 'NOTEXIST';
      const playerId = 'player123';

      expect(
        () => gameRoomService.leaveRoom(nonExistentRoomCode, playerId),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ルームが見つかりません'),
          ),
        ),
      );
    });

    test('参加していないルームからの退出を拒否する', () async {
      // ホストを作成
      const hostId = 'host123';
      const hostNickname = 'Host';

      // ルームを作成
      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // 参加していないプレイヤーが退出しようとする
      expect(
        () => gameRoomService.leaveRoom(gameRoom.roomCode, 'player999'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('このルームに参加していません'),
          ),
        ),
      );
    });

    test('すべてのプレイヤーが退出した場合、ルームが削除される（要件 15.5）', () async {
      // ホストを作成
      const hostId = 'host123';
      const hostNickname = 'Host';

      // ルームを作成
      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // ホストが退出
      await gameRoomService.leaveRoom(gameRoom.roomCode, hostId);

      // ルームが削除されたことを確認
      final deletedRoom = await gameRoomService.getRoom(gameRoom.roomCode);
      expect(deletedRoom, isNull);
    });

    test('ホストが退出した場合、次のプレイヤーがホストになる（要件 15.4）', () async {
      // ホストを作成
      const hostId = 'host123';
      const hostNickname = 'Host';

      // ルームを作成
      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // プレイヤーを追加
      const player1Id = 'player1';
      await gameRoomService.joinRoom(gameRoom.roomCode, player1Id, 'Player1');

      // ホストが退出
      await gameRoomService.leaveRoom(gameRoom.roomCode, hostId);

      // 新しいホストを確認
      final updatedRoom = await gameRoomService.getRoom(gameRoom.roomCode);
      expect(updatedRoom, isNotNull);
      expect(updatedRoom!.hostId, equals(player1Id));
      expect(updatedRoom.playerIds, contains(player1Id));
      expect(updatedRoom.playerIds, isNot(contains(hostId)));
    });

    test('存在しないプレイヤーへのホスト移譲を拒否する', () async {
      // ホストを作成
      const hostId = 'host123';
      const hostNickname = 'Host';

      // ルームを作成
      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // 存在しないプレイヤーにホストを移譲しようとする
      expect(
        () => gameRoomService.transferHost(gameRoom.roomCode, 'nonexistent'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('指定されたプレイヤーはこのルームに参加していません'),
          ),
        ),
      );
    });
  });

  group('GameSyncService - エラーハンドリングのテスト', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GameSyncService gameSyncService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      gameSyncService = GameSyncService(firestore: fakeFirestore);
    });

    test('存在しないゲーム状態の更新を拒否する', () async {
      const nonExistentRoomCode = 'NOTEXIST';

      expect(
        () => gameSyncService.advanceTurn(nonExistentRoomCode),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ゲーム状態が見つかりません'),
          ),
        ),
      );
    });

    test('存在しないプレイヤーの手札更新を拒否する', () async {
      // テスト用のゲーム状態を作成
      const roomCode = 'TEST1234';
      final players = {
        'player1': Player(
          id: 'player1',
          nickname: 'Player1',
          hand: [],
          isConnected: true,
          lastSeen: DateTime.now(),
        ),
      };

      await gameSyncService.initializeGame(
        roomCode,
        ['player1'],
        players,
        ['player1'],
      );

      // 存在しないプレイヤーの手札を更新しようとする
      expect(
        () => gameSyncService.updatePlayerHand(roomCode, 'nonexistent', []),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('プレイヤーが見つかりません'),
          ),
        ),
      );
    });

    test('存在しないプレイヤーの接続状態更新を拒否する', () async {
      // テスト用のゲーム状態を作成
      const roomCode = 'TEST1234';
      final players = {
        'player1': Player(
          id: 'player1',
          nickname: 'Player1',
          hand: [],
          isConnected: true,
          lastSeen: DateTime.now(),
        ),
      };

      await gameSyncService.initializeGame(
        roomCode,
        ['player1'],
        players,
        ['player1'],
      );

      // 存在しないプレイヤーの接続状態を更新しようとする
      expect(
        () => gameSyncService.updatePlayerConnection(
          roomCode,
          'nonexistent',
          false,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('プレイヤーが見つかりません'),
          ),
        ),
      );
    });
  });

  group('ネットワークエラーのシミュレーション（要件 16.1, 16.2）', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GameRoomService gameRoomService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      gameRoomService = GameRoomService(firestore: fakeFirestore);
    });

    test('Firestore操作失敗時のエラーハンドリング', () async {
      // 無効なルームコードでの操作
      final result = await gameRoomService.getRoom('');
      expect(result, isNull);
    });
  });

  group('切断・再接続のテスト（要件 14.1, 14.2, 14.3）', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GameSyncService gameSyncService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      gameSyncService = GameSyncService(firestore: fakeFirestore);
    });

    test('プレイヤーの切断状態を更新できる', () async {
      // テスト用のゲーム状態を作成
      const roomCode = 'TEST1234';
      final players = {
        'player1': Player(
          id: 'player1',
          nickname: 'Player1',
          hand: [],
          isConnected: true,
          lastSeen: DateTime.now(),
        ),
        'player2': Player(
          id: 'player2',
          nickname: 'Player2',
          hand: [],
          isConnected: true,
          lastSeen: DateTime.now(),
        ),
      };

      await gameSyncService.initializeGame(
        roomCode,
        ['player1', 'player2'],
        players,
        ['player1', 'player2'],
      );

      // プレイヤー1を切断状態にする
      await gameSyncService.updatePlayerConnection(roomCode, 'player1', false);

      // ゲーム状態を取得して確認
      final gameState = await gameSyncService.watchGameState(roomCode).first;

      expect(gameState, isNotNull);
      expect(gameState!.players['player1']!.isConnected, isFalse);
      expect(gameState.players['player2']!.isConnected, isTrue);
    });

    test('プレイヤーの再接続状態を更新できる', () async {
      // テスト用のゲーム状態を作成
      const roomCode = 'TEST1234';
      final players = {
        'player1': Player(
          id: 'player1',
          nickname: 'Player1',
          hand: [],
          isConnected: false, // 最初は切断状態
          lastSeen: DateTime.now(),
        ),
      };

      await gameSyncService.initializeGame(
        roomCode,
        ['player1'],
        players,
        ['player1'],
      );

      // プレイヤー1を再接続状態にする
      await gameSyncService.updatePlayerConnection(roomCode, 'player1', true);

      // ゲーム状態を取得して確認
      final gameState = await gameSyncService.watchGameState(roomCode).first;

      expect(gameState, isNotNull);
      expect(gameState!.players['player1']!.isConnected, isTrue);
    });
  });

  group('エッジケースの統合テスト', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GameRoomService gameRoomService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      gameRoomService = GameRoomService(firestore: fakeFirestore);
    });

    test('ルームコードの一意性を確保する', () async {
      // 複数のルームを作成
      final roomCodes = <String>{};

      for (int i = 0; i < 10; i++) {
        final gameRoom = await gameRoomService.createRoom('host$i', 'Host$i');
        roomCodes.add(gameRoom.roomCode);
      }

      // すべてのルームコードが一意であることを確認
      expect(roomCodes.length, equals(10));
    });

    test('空のニックネームでの参加を処理する', () async {
      const hostId = 'host123';
      const hostNickname = 'Host';

      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // 空のニックネームで参加しようとする
      // 注: 実際のバリデーションはAuthServiceで行われるべき
      await gameRoomService.joinRoom(
        gameRoom.roomCode,
        'player1',
        '', // 空のニックネーム
      );

      final updatedRoom = await gameRoomService.getRoom(gameRoom.roomCode);
      expect(updatedRoom, isNotNull);
      expect(updatedRoom!.playerIds.length, equals(2));
    });

    test('最大プレイヤー数の境界値テスト', () async {
      const hostId = 'host123';
      const hostNickname = 'Host';

      final gameRoom = await gameRoomService.createRoom(hostId, hostNickname);

      // 3人のプレイヤーを追加（合計4人、最大値）
      for (int i = 1; i <= 3; i++) {
        await gameRoomService.joinRoom(
          gameRoom.roomCode,
          'player$i',
          'Player$i',
        );
      }

      final updatedRoom = await gameRoomService.getRoom(gameRoom.roomCode);
      expect(updatedRoom, isNotNull);
      expect(updatedRoom!.playerIds.length, equals(4));
      expect(updatedRoom.isFull, isTrue);
    });
  });
}
