/**
 * Firestoreセキュリティルールのテスト
 * 
 * このファイルは、Firebaseエミュレーターを使用してセキュリティルールをテストします。
 * 
 * 実行方法:
 * 1. Firebase CLIをインストール: npm install -g firebase-tools
 * 2. Firebaseエミュレーターを起動: firebase emulators:start
 * 3. テストを実行: npm test
 */

const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const { setDoc, getDoc, updateDoc, deleteDoc, doc } = require('firebase/firestore');

let testEnv;

// テスト環境のセットアップ
beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'test-project',
    firestore: {
      rules: require('fs').readFileSync('firestore.rules', 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

// 各テスト後にデータをクリア
afterEach(async () => {
  await testEnv.clearFirestore();
});

// テスト環境のクリーンアップ
afterAll(async () => {
  await testEnv.cleanup();
});

describe('Firestoreセキュリティルール', () => {
  describe('ゲームルームの作成', () => {
    test('認証済みユーザーは新しいルームを作成できる', async () => {
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      
      await assertSucceeds(
        setDoc(roomRef, {
          roomCode: 'ROOM1234',
          hostId: 'alice',
          playerIds: ['alice'],
          maxPlayers: 4,
          status: 'waiting',
          createdAt: new Date(),
          players: {
            alice: {
              id: 'alice',
              nickname: 'Alice',
              hand: [],
              isConnected: true,
              lastSeen: new Date(),
            },
          },
        })
      );
    });

    test('未認証ユーザーはルームを作成できない', async () => {
      const unauth = testEnv.unauthenticatedContext();
      const roomRef = doc(unauth.firestore(), 'game_rooms', 'ROOM1234');
      
      await assertFails(
        setDoc(roomRef, {
          roomCode: 'ROOM1234',
          hostId: 'alice',
          playerIds: ['alice'],
          maxPlayers: 4,
          status: 'waiting',
          createdAt: new Date(),
        })
      );
    });

    test('ホストIDが自分のUIDと一致しない場合、ルームを作成できない', async () => {
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      
      await assertFails(
        setDoc(roomRef, {
          roomCode: 'ROOM1234',
          hostId: 'bob', // 自分のUIDではない
          playerIds: ['alice'],
          maxPlayers: 4,
          status: 'waiting',
          createdAt: new Date(),
        })
      );
    });
  });

  describe('ゲームルームの読み取り', () => {
    test('認証済みユーザーはルームを読み取れる', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // 別のユーザーが読み取り
      const bob = testEnv.authenticatedContext('bob');
      const bobRoomRef = doc(bob.firestore(), 'game_rooms', 'ROOM1234');
      await assertSucceeds(getDoc(bobRoomRef));
    });

    test('未認証ユーザーはルームを読み取れない', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // 未認証ユーザーが読み取り
      const unauth = testEnv.unauthenticatedContext();
      const unauthRoomRef = doc(unauth.firestore(), 'game_rooms', 'ROOM1234');
      await assertFails(getDoc(unauthRoomRef));
    });
  });

  describe('ゲームルームの更新', () => {
    test('参加プレイヤーはルームを更新できる', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice', 'bob'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // 参加プレイヤーが更新
      const bob = testEnv.authenticatedContext('bob');
      const bobRoomRef = doc(bob.firestore(), 'game_rooms', 'ROOM1234');
      await assertSucceeds(
        updateDoc(bobRoomRef, {
          status: 'playing',
        })
      );
    });

    test('非参加プレイヤーはルームを更新できない', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // 非参加プレイヤーが更新
      const charlie = testEnv.authenticatedContext('charlie');
      const charlieRoomRef = doc(charlie.firestore(), 'game_rooms', 'ROOM1234');
      await assertFails(
        updateDoc(charlieRoomRef, {
          status: 'playing',
        })
      );
    });

    test('参加プレイヤーはホストを移譲できる', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice', 'bob'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // ホストを移譲
      await assertSucceeds(
        updateDoc(roomRef, {
          hostId: 'bob', // bobは参加者リストに含まれている
          roomCode: 'ROOM1234',
          maxPlayers: 4,
        })
      );
    });

    test('maxPlayersは変更できない', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // maxPlayersを変更しようとする
      await assertFails(
        updateDoc(roomRef, {
          maxPlayers: 6, // 変更不可
          roomCode: 'ROOM1234',
          hostId: 'alice',
        })
      );
    });
  });

  describe('ゲームルームの削除', () => {
    test('ホストはルームを削除できる', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // ホストが削除
      await assertSucceeds(deleteDoc(roomRef));
    });

    test('ホスト以外はルームを削除できない', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice', 'bob'],
        maxPlayers: 4,
        status: 'waiting',
        createdAt: new Date(),
        players: {},
      });

      // ゲストが削除しようとする
      const bob = testEnv.authenticatedContext('bob');
      const bobRoomRef = doc(bob.firestore(), 'game_rooms', 'ROOM1234');
      await assertFails(deleteDoc(bobRoomRef));
    });
  });

  describe('ゲーム状態サブコレクション', () => {
    test('参加プレイヤーはゲーム状態を読み取れる', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice', 'bob'],
        maxPlayers: 4,
        status: 'playing',
        createdAt: new Date(),
        players: {},
      });

      // ゲーム状態を作成
      const gameStateRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234', 'game_state', 'current');
      await setDoc(gameStateRef, {
        turnOrder: ['alice', 'bob'],
        currentTurnIndex: 0,
        status: 'playing',
        lastUpdated: new Date(),
      });

      // 参加プレイヤーが読み取り
      const bob = testEnv.authenticatedContext('bob');
      const bobGameStateRef = doc(bob.firestore(), 'game_rooms', 'ROOM1234', 'game_state', 'current');
      await assertSucceeds(getDoc(bobGameStateRef));
    });

    test('非参加プレイヤーはゲーム状態を読み取れない', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice', 'bob'],
        maxPlayers: 4,
        status: 'playing',
        createdAt: new Date(),
        players: {},
      });

      // ゲーム状態を作成
      const gameStateRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234', 'game_state', 'current');
      await setDoc(gameStateRef, {
        turnOrder: ['alice', 'bob'],
        currentTurnIndex: 0,
        status: 'playing',
        lastUpdated: new Date(),
      });

      // 非参加プレイヤーが読み取り
      const charlie = testEnv.authenticatedContext('charlie');
      const charlieGameStateRef = doc(charlie.firestore(), 'game_rooms', 'ROOM1234', 'game_state', 'current');
      await assertFails(getDoc(charlieGameStateRef));
    });

    test('参加プレイヤーはゲーム状態を更新できる', async () => {
      // ルームを作成
      const alice = testEnv.authenticatedContext('alice');
      const roomRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234');
      await setDoc(roomRef, {
        roomCode: 'ROOM1234',
        hostId: 'alice',
        playerIds: ['alice', 'bob'],
        maxPlayers: 4,
        status: 'playing',
        createdAt: new Date(),
        players: {},
      });

      // ゲーム状態を作成
      const gameStateRef = doc(alice.firestore(), 'game_rooms', 'ROOM1234', 'game_state', 'current');
      await setDoc(gameStateRef, {
        turnOrder: ['alice', 'bob'],
        currentTurnIndex: 0,
        status: 'playing',
        lastUpdated: new Date(),
      });

      // 参加プレイヤーが更新
      const bob = testEnv.authenticatedContext('bob');
      const bobGameStateRef = doc(bob.firestore(), 'game_rooms', 'ROOM1234', 'game_state', 'current');
      await assertSucceeds(
        updateDoc(bobGameStateRef, {
          currentTurnIndex: 1,
        })
      );
    });
  });
});
