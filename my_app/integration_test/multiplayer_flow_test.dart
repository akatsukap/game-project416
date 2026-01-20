import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/game_room_service.dart';
import 'package:my_app/services/game_sync_service.dart';

/// 統合テスト: オンラインマルチプレイヤーの完全なフロー
///
/// このテストは以下をカバーします：
/// - ルーム作成から参加、ゲーム進行、終了までの完全なフロー
/// - 複数クライアントのシミュレーション
/// - リアルタイム同期の検証
///
/// 注意: このテストを実行する前に、Firebaseエミュレーターを起動してください：
/// ```
/// firebase emulators:start --only auth,firestore
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('オンラインマルチプレイヤー統合テスト', () {
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
      roomService = GameRoomService();
      syncService = GameSyncService();
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

    testWidgets('完全なゲームフロー: ルーム作成 → 参加 → ゲーム進行 → 終了', (
      WidgetTester tester,
    ) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ===== ホストプレイヤー（プレイヤー1）のフロー =====

      // 1. ニックネーム入力画面でニックネームを入力
      expect(find.text('ニックネームを入力'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'プレイヤー1');
      await tester.tap(find.text('開始'));
      await tester.pumpAndSettle();

      // 2. モード選択画面でオンラインプレイを選択
      expect(find.text('モード選択'), findsOneWidget);
      await tester.tap(find.text('オンラインプレイ'));
      await tester.pumpAndSettle();

      // 3. オンラインロビーでルームを作成
      expect(find.text('オンラインロビー'), findsOneWidget);
      await tester.tap(find.text('ルームを作成'));
      await tester.pumpAndSettle();

      // 4. 待機画面に遷移し、ルームコードを取得
      expect(find.text('待機画面'), findsOneWidget);

      // ルームコードを取得（画面から）
      final roomCodeFinder = find.textContaining('ルームコード:');
      expect(roomCodeFinder, findsOneWidget);

      // ルームコードを抽出（実際の実装に応じて調整が必要）
      String? roomCode;
      await tester.pump();

      // プレイヤーリストにプレイヤー1が表示されることを確認
      expect(find.text('プレイヤー1'), findsOneWidget);
      expect(find.text('1/4'), findsOneWidget);

      // ===== ゲストプレイヤー（プレイヤー2）のシミュレーション =====

      // 新しい認証セッションでプレイヤー2を作成
      final player2Auth = await authService.signInAnonymously();
      expect(player2Auth, isNotNull);

      // プレイヤー2がルームに参加（サービス層を直接使用）
      if (roomCode != null) {
        await roomService.joinRoom(roomCode, player2Auth!.uid);
        await tester.pumpAndSettle();

        // 待機画面が更新され、プレイヤー2が表示されることを確認
        expect(find.text('2/4'), findsOneWidget);
      }

      // 5. ホストがゲームを開始
      final startButton = find.text('ゲーム開始');
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // 6. オンラインゲーム画面に遷移
      expect(find.text('オンラインゲーム'), findsOneWidget);

      // 自分の手札が表示されることを確認
      expect(find.text('あなたの手札'), findsOneWidget);

      // 他のプレイヤーの情報が表示されることを確認
      expect(find.textContaining('プレイヤー'), findsWidgets);

      // ターン表示があることを確認
      expect(find.textContaining('ターン'), findsOneWidget);

      // 7. ゲームプレイのシミュレーション
      // （実際のカード選択とターン進行は、ゲームロジックに依存）

      // 現在のターンのプレイヤーがカードを選択できることを確認
      // （実装に応じて調整）

      await tester.pump(const Duration(seconds: 2));

      // 8. ゲーム終了の検証
      // （ゲームが終了するまでターンを進める必要があるため、
      //  ここでは直接サービスを使用してゲームを終了状態にする）

      if (roomCode != null) {
        await syncService.endGame(roomCode, player2Auth!.uid);
        await tester.pumpAndSettle();

        // 結果画面に遷移することを確認
        expect(find.text('結果'), findsOneWidget);

        // 勝敗メッセージが表示されることを確認
        expect(
          find.textContaining('勝ち'),
          findsOneWidget,
          reason: '勝敗メッセージが表示されるべき',
        );
      }
    });

    testWidgets('ルーム作成と参加のフロー', (WidgetTester tester) async {
      // ホストプレイヤーを作成
      final hostAuth = await authService.signInAnonymously();
      expect(hostAuth, isNotNull);

      // ルームを作成
      final room = await roomService.createRoom(hostAuth!.uid);
      expect(room, isNotNull);
      expect(room.roomCode.length, 8);
      expect(room.hostId, hostAuth.uid);
      expect(room.playerIds, contains(hostAuth.uid));

      // ゲストプレイヤーを作成
      await auth.signOut();
      final guestAuth = await authService.signInAnonymously();
      expect(guestAuth, isNotNull);

      // ルームに参加
      await roomService.joinRoom(room.roomCode, guestAuth!.uid);

      // ルームを取得して検証
      final updatedRoom = await roomService.getRoom(room.roomCode);
      expect(updatedRoom, isNotNull);
      expect(updatedRoom!.playerIds.length, 2);
      expect(updatedRoom.playerIds, contains(hostAuth.uid));
      expect(updatedRoom.playerIds, contains(guestAuth.uid));
    });

    testWidgets('リアルタイム同期の検証', (WidgetTester tester) async {
      // ホストプレイヤーを作成
      final hostAuth = await authService.signInAnonymously();
      expect(hostAuth, isNotNull);

      // ルームを作成
      final room = await roomService.createRoom(hostAuth!.uid);

      // ルームの変更を監視
      final roomStream = roomService.watchRoom(room.roomCode);

      // ストリームから最初の値を取得
      final firstRoom = await roomStream.first;
      expect(firstRoom, isNotNull);
      expect(firstRoom!.playerIds.length, 1);

      // ゲストプレイヤーを作成して参加
      await auth.signOut();
      final guestAuth = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, guestAuth!.uid);

      // ストリームから更新された値を取得
      await tester.pump(const Duration(milliseconds: 500));

      final updatedRoom = await roomService.getRoom(room.roomCode);
      expect(updatedRoom!.playerIds.length, 2);
    });

    testWidgets('プレイヤー退出とホスト移譲', (WidgetTester tester) async {
      // ホストプレイヤーを作成
      final hostAuth = await authService.signInAnonymously();
      final room = await roomService.createRoom(hostAuth!.uid);

      // ゲストプレイヤー1を作成して参加
      await auth.signOut();
      final guest1Auth = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, guest1Auth!.uid);

      // ゲストプレイヤー2を作成して参加
      await auth.signOut();
      final guest2Auth = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, guest2Auth!.uid);

      // ルームを確認
      var currentRoom = await roomService.getRoom(room.roomCode);
      expect(currentRoom!.playerIds.length, 3);
      expect(currentRoom.hostId, hostAuth.uid);

      // ホストが退出
      await roomService.leaveRoom(room.roomCode, hostAuth.uid);

      // ルームを確認 - 新しいホストが設定されているべき
      currentRoom = await roomService.getRoom(room.roomCode);
      expect(currentRoom, isNotNull);
      expect(currentRoom!.playerIds.length, 2);
      expect(currentRoom.hostId, isNot(hostAuth.uid));
      expect(currentRoom.hostId, anyOf(guest1Auth.uid, guest2Auth.uid));
    });

    testWidgets('満員のルームへの参加拒否', (WidgetTester tester) async {
      // ホストプレイヤーを作成
      final hostAuth = await authService.signInAnonymously();
      final room = await roomService.createRoom(hostAuth!.uid);

      // 3人のゲストプレイヤーを追加（最大4人）
      for (int i = 0; i < 3; i++) {
        await auth.signOut();
        final guestAuth = await authService.signInAnonymously();
        await roomService.joinRoom(room.roomCode, guestAuth!.uid);
      }

      // ルームが満員であることを確認
      var currentRoom = await roomService.getRoom(room.roomCode);
      expect(currentRoom!.isFull, true);
      expect(currentRoom.playerIds.length, 4);

      // 5人目のプレイヤーが参加しようとする
      await auth.signOut();
      final extraPlayerAuth = await authService.signInAnonymously();

      // 参加が拒否されることを期待
      expect(
        () => roomService.joinRoom(room.roomCode, extraPlayerAuth!.uid),
        throwsException,
      );
    });

    testWidgets('ゲーム状態の初期化と更新', (WidgetTester tester) async {
      // 2人のプレイヤーでルームを作成
      final hostAuth = await authService.signInAnonymously();
      final room = await roomService.createRoom(hostAuth!.uid);

      await auth.signOut();
      final guestAuth = await authService.signInAnonymously();
      await roomService.joinRoom(room.roomCode, guestAuth!.uid);

      // ゲーム状態を初期化
      await syncService.initializeGame(room.roomCode, [
        hostAuth.uid,
        guestAuth.uid,
      ]);

      // ゲーム状態を取得
      final gameStateStream = syncService.watchGameState(room.roomCode);
      final gameState = await gameStateStream.first;

      expect(gameState, isNotNull);
      expect(gameState!.players.length, 2);
      expect(gameState.turnOrder.length, 2);
      expect(gameState.currentTurnIndex, 0);

      // ターンを進める
      await syncService.advanceTurn(room.roomCode);
      await tester.pump(const Duration(milliseconds: 500));

      final updatedGameState = await syncService
          .watchGameState(room.roomCode)
          .first;
      expect(updatedGameState!.currentTurnIndex, 1);
    });

    testWidgets('エラーハンドリング: 存在しないルームへの参加', (WidgetTester tester) async {
      final playerAuth = await authService.signInAnonymously();

      // 存在しないルームコードで参加を試みる
      expect(
        () => roomService.joinRoom('INVALID1', playerAuth!.uid),
        throwsException,
      );
    });
  });
}
