import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/game_room_service.dart';
import 'package:my_app/services/game_sync_service.dart';
import 'package:my_app/models/player.dart';
import 'package:my_app/models/game_room.dart';

/// 統合テスト: エラーハンドリングとエッジケース
///
/// 要件 4.4, 14.1, 14.2, 14.3, 16.1, 16.2, 16.3, 16.4
///
/// このテストは以下をカバーします：
/// - ネットワークエラーのシミュレーション
/// - 切断・再接続のテスト
/// - 満員のルーム、存在しないルームなどのエッジケース
///
/// 注意: このテストを実行する前に、Firebaseエミュレーターを起動してください：
/// ```
/// firebase emulators:start --only auth,firestore
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('エラーハンドリングとエッジケースの統合テスト', () {
    late FirebaseFirestore firestore;
    late FirebaseAuth auth;
    late AuthService authService;
    late GameRoomService roomService;
    late GameSyncService syncService;

    setUpAll(() async {
      // Firebaseエミュレーターに接続
      await Firebase.initializeApp();

      firestore = FirebaseFirestore.instance;
      auth = FirebaseAuth.instance;

      // エミュレーターの設定
      firestore.useFirestoreEmulator('localhost', 8080);
      await auth.useAuthEmulator('localhost', 9099);

      authService = AuthService();
      roomService = GameRoomService(firestore: firestore);
      syncService = GameSyncService(firestore: firestore);
    });

    setUp(() async {
      // 各テスト前にFirestoreをクリア
      final collections = await firestore.collection('game_rooms').get();
      for (var doc in collections.docs) {
        await doc.reference.delete();
      }

      // 認証状態をクリア
      if (auth.currentUser != null) {
        await auth.signOut();
      }
    });

    group('エッジケースのテスト（要件 4.4）', () {
      test('存在しないルームへの参加を拒否する', () async {
        final playerAuth = await authService.signInAnonymously();
        expect(playerAuth, isNotNull);

        // 存在しないルームコードで参加を試みる
        expect(
          () => roomService.joinRoom('NOTEXIST', playerAuth!.uid, 'TestPlayer'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('ルームが見つかりません'),
            ),
          ),
        );
      });

      test('満員のルームへの参加を拒否する', () async {
        // ホストプレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // 3人のゲストプレイヤーを追加（最大4人）
        for (int i = 1; i <= 3; i++) {
          await auth.signOut();
          final guestAuth = await authService.signInAnonymously();
          await roomService.joinRoom(room.roomCode, guestAuth!.uid, 'Player$i');
        }

        // ルームが満員であることを確認
        final currentRoom = await roomService.getRoom(room.roomCode);
        expect(currentRoom!.isFull, true);
        expect(currentRoom.playerIds.length, 4);

        // 5人目のプレイヤーが参加しようとする
        await auth.signOut();
        final extraPlayerAuth = await authService.signInAnonymously();

        // 参加が拒否されることを期待
        expect(
          () => roomService.joinRoom(
            room.roomCode,
            extraPlayerAuth!.uid,
            'Player5',
          ),
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
        // ホストプレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // もう1人プレイヤーを追加
        await auth.signOut();
        final guest1Auth = await authService.signInAnonymously();
        await roomService.joinRoom(room.roomCode, guest1Auth!.uid, 'Player1');

        // ゲームを開始（ステータスを変更）
        await roomService.updateRoomStatus(room.roomCode, RoomStatus.playing);

        // 新しいプレイヤーが参加しようとする
        await auth.signOut();
        final guest2Auth = await authService.signInAnonymously();

        expect(
          () => roomService.joinRoom(room.roomCode, guest2Auth!.uid, 'Player2'),
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
        // ホストプレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // プレイヤーを追加
        await auth.signOut();
        final guestAuth = await authService.signInAnonymously();
        await roomService.joinRoom(room.roomCode, guestAuth!.uid, 'Player1');

        // 同じプレイヤーが再度参加しようとする
        expect(
          () => roomService.joinRoom(room.roomCode, guestAuth.uid, 'Player1'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('既にこのルームに参加しています'),
            ),
          ),
        );
      });

      test('参加していないルームからの退出を拒否する', () async {
        // ホストプレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // 参加していないプレイヤーが退出しようとする
        await auth.signOut();
        final otherPlayerAuth = await authService.signInAnonymously();

        expect(
          () => roomService.leaveRoom(room.roomCode, otherPlayerAuth!.uid),
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
        // ホストプレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // ホストが退出
        await roomService.leaveRoom(room.roomCode, hostAuth.uid);

        // ルームが削除されたことを確認
        final deletedRoom = await roomService.getRoom(room.roomCode);
        expect(deletedRoom, isNull);
      });

      test('ホストが退出した場合、次のプレイヤーがホストになる（要件 15.4）', () async {
        // ホストプレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // プレイヤーを追加
        await auth.signOut();
        final guest1Auth = await authService.signInAnonymously();
        await roomService.joinRoom(room.roomCode, guest1Auth!.uid, 'Player1');

        // ホストが退出
        await roomService.leaveRoom(room.roomCode, hostAuth.uid);

        // 新しいホストを確認
        final updatedRoom = await roomService.getRoom(room.roomCode);
        expect(updatedRoom, isNotNull);
        expect(updatedRoom!.hostId, equals(guest1Auth.uid));
        expect(updatedRoom.playerIds, contains(guest1Auth.uid));
        expect(updatedRoom.playerIds, isNot(contains(hostAuth.uid)));
      });
    });

    group('切断・再接続のテスト（要件 14.1, 14.2, 14.3）', () {
      test('プレイヤーの切断状態を更新できる', () async {
        // 2人のプレイヤーでルームを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        await auth.signOut();
        final guestAuth = await authService.signInAnonymously();
        await roomService.joinRoom(room.roomCode, guestAuth!.uid, 'Player1');

        // ゲーム状態を初期化
        final players = {
          hostAuth.uid: Player(
            id: hostAuth.uid,
            nickname: 'Host',
            hand: [],
            isConnected: true,
            lastSeen: DateTime.now(),
          ),
          guestAuth.uid: Player(
            id: guestAuth.uid,
            nickname: 'Player1',
            hand: [],
            isConnected: true,
            lastSeen: DateTime.now(),
          ),
        };

        await syncService.initializeGame(
          room.roomCode,
          [hostAuth.uid, guestAuth.uid],
          players,
          [hostAuth.uid, guestAuth.uid],
        );

        // プレイヤー1を切断状態にする
        await syncService.updatePlayerConnection(
          room.roomCode,
          guestAuth.uid,
          false,
        );

        // ゲーム状態を取得して確認
        final gameState = await syncService.watchGameState(room.roomCode).first;

        expect(gameState, isNotNull);
        expect(gameState!.players[guestAuth.uid]!.isConnected, isFalse);
        expect(gameState.players[hostAuth.uid]!.isConnected, isTrue);
      });

      test('プレイヤーの再接続状態を更新できる', () async {
        // プレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // ゲーム状態を初期化（最初は切断状態）
        final players = {
          hostAuth.uid: Player(
            id: hostAuth.uid,
            nickname: 'Host',
            hand: [],
            isConnected: false,
            lastSeen: DateTime.now(),
          ),
        };

        await syncService.initializeGame(
          room.roomCode,
          [hostAuth.uid],
          players,
          [hostAuth.uid],
        );

        // プレイヤーを再接続状態にする
        await syncService.updatePlayerConnection(
          room.roomCode,
          hostAuth.uid,
          true,
        );

        // ゲーム状態を取得して確認
        final gameState = await syncService.watchGameState(room.roomCode).first;

        expect(gameState, isNotNull);
        expect(gameState!.players[hostAuth.uid]!.isConnected, isTrue);
      });

      test('切断されたプレイヤーのlastSeenが更新される', () async {
        // プレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // ゲーム状態を初期化
        final initialTime = DateTime.now();
        final players = {
          hostAuth.uid: Player(
            id: hostAuth.uid,
            nickname: 'Host',
            hand: [],
            isConnected: true,
            lastSeen: initialTime,
          ),
        };

        await syncService.initializeGame(
          room.roomCode,
          [hostAuth.uid],
          players,
          [hostAuth.uid],
        );

        // 少し待機
        await Future.delayed(const Duration(milliseconds: 100));

        // プレイヤーを切断状態にする
        await syncService.updatePlayerConnection(
          room.roomCode,
          hostAuth.uid,
          false,
        );

        // ゲーム状態を取得して確認
        final gameState = await syncService.watchGameState(room.roomCode).first;

        expect(gameState, isNotNull);
        expect(
          gameState!.players[hostAuth.uid]!.lastSeen.isAfter(initialTime),
          isTrue,
        );
      });
    });

    group('ネットワークエラーのシミュレーション（要件 16.1, 16.2）', () {
      test('存在しないゲーム状態の更新を拒否する', () async {
        const nonExistentRoomCode = 'NOTEXIST';

        expect(
          () => syncService.advanceTurn(nonExistentRoomCode),
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
        // プレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // ゲーム状態を初期化
        final players = {
          hostAuth.uid: Player(
            id: hostAuth.uid,
            nickname: 'Host',
            hand: [],
            isConnected: true,
            lastSeen: DateTime.now(),
          ),
        };

        await syncService.initializeGame(
          room.roomCode,
          [hostAuth.uid],
          players,
          [hostAuth.uid],
        );

        // 存在しないプレイヤーの手札を更新しようとする
        expect(
          () => syncService.updatePlayerHand(room.roomCode, 'nonexistent', []),
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
        // プレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // ゲーム状態を初期化
        final players = {
          hostAuth.uid: Player(
            id: hostAuth.uid,
            nickname: 'Host',
            hand: [],
            isConnected: true,
            lastSeen: DateTime.now(),
          ),
        };

        await syncService.initializeGame(
          room.roomCode,
          [hostAuth.uid],
          players,
          [hostAuth.uid],
        );

        // 存在しないプレイヤーの接続状態を更新しようとする
        expect(
          () => syncService.updatePlayerConnection(
            room.roomCode,
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

    group('境界値とエッジケースのテスト', () {
      test('ルームコードの一意性を確保する', () async {
        final roomCodes = <String>{};

        // 10個のルームを作成
        for (int i = 0; i < 10; i++) {
          await auth.signOut();
          final playerAuth = await authService.signInAnonymously();
          final room = await roomService.createRoom(playerAuth!.uid, 'Host$i');
          roomCodes.add(room.roomCode);
        }

        // すべてのルームコードが一意であることを確認
        expect(roomCodes.length, equals(10));
      });

      test('最大プレイヤー数の境界値テスト', () async {
        // ホストプレイヤーを作成
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        // 3人のプレイヤーを追加（合計4人、最大値）
        for (int i = 1; i <= 3; i++) {
          await auth.signOut();
          final guestAuth = await authService.signInAnonymously();
          await roomService.joinRoom(room.roomCode, guestAuth!.uid, 'Player$i');
        }

        final updatedRoom = await roomService.getRoom(room.roomCode);
        expect(updatedRoom, isNotNull);
        expect(updatedRoom!.playerIds.length, equals(4));
        expect(updatedRoom.isFull, isTrue);
        expect(updatedRoom.canStart, isTrue);
      });

      test('最小プレイヤー数の境界値テスト', () async {
        // ホストプレイヤーのみ（1人）
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        expect(room.playerIds.length, equals(1));
        expect(room.canStart, isFalse); // 2人未満なので開始できない

        // もう1人追加（2人、最小値）
        await auth.signOut();
        final guestAuth = await authService.signInAnonymously();
        await roomService.joinRoom(room.roomCode, guestAuth!.uid, 'Player1');

        final updatedRoom = await roomService.getRoom(room.roomCode);
        expect(updatedRoom!.playerIds.length, equals(2));
        expect(updatedRoom.canStart, isTrue); // 2人以上なので開始できる
      });

      test('空のルームコードでの操作', () async {
        final result = await roomService.getRoom('');
        expect(result, isNull);
      });

      test('非常に長いニックネームでの参加', () async {
        final hostAuth = await authService.signInAnonymously();
        final room = await roomService.createRoom(hostAuth!.uid, 'Host');

        await auth.signOut();
        final guestAuth = await authService.signInAnonymously();

        // 非常に長いニックネーム（100文字）
        final longNickname = 'A' * 100;

        // 参加できることを確認（バリデーションはAuthServiceで行われるべき）
        await roomService.joinRoom(room.roomCode, guestAuth!.uid, longNickname);

        final players = await roomService.getPlayers(room.roomCode);
        expect(players[guestAuth.uid]!.nickname, equals(longNickname));
      });
    });
  });
}
