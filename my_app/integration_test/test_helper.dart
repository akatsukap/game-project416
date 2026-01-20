import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// 統合テスト用のヘルパークラス
///
/// Firebaseエミュレーターの設定とテストデータのクリーンアップを提供します。
class IntegrationTestHelper {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static bool _initialized = false;

  /// Firebaseエミュレーターを初期化
  static Future<void> initializeEmulators() async {
    if (_initialized) return;

    await Firebase.initializeApp();

    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    // エミュレーターに接続
    _firestore!.useFirestoreEmulator('localhost', 8080);
    await _auth!.useAuthEmulator('localhost', 9099);

    _initialized = true;
  }

  /// Firestoreのすべてのデータをクリア
  static Future<void> clearFirestore() async {
    if (_firestore == null) {
      throw Exception(
        'Firestore is not initialized. Call initializeEmulators() first.',
      );
    }

    // game_roomsコレクションをクリア
    final gameRooms = await _firestore!.collection('game_rooms').get();
    for (var doc in gameRooms.docs) {
      // サブコレクションも削除
      final gameStates = await doc.reference.collection('game_state').get();
      for (var stateDoc in gameStates.docs) {
        await stateDoc.reference.delete();
      }
      await doc.reference.delete();
    }
  }

  /// 現在の認証ユーザーをサインアウト
  static Future<void> signOut() async {
    if (_auth == null) {
      throw Exception(
        'Auth is not initialized. Call initializeEmulators() first.',
      );
    }

    if (_auth!.currentUser != null) {
      await _auth!.signOut();
    }
  }

  /// テストデータをクリーンアップ
  static Future<void> cleanup() async {
    await clearFirestore();
    await signOut();
  }

  /// Firestoreインスタンスを取得
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception(
        'Firestore is not initialized. Call initializeEmulators() first.',
      );
    }
    return _firestore!;
  }

  /// Authインスタンスを取得
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception(
        'Auth is not initialized. Call initializeEmulators() first.',
      );
    }
    return _auth!;
  }

  /// エミュレーターが初期化されているかチェック
  static bool get isInitialized => _initialized;
}

/// テストデータ生成用のヘルパークラス
class TestDataGenerator {
  /// ランダムなニックネームを生成
  static String generateNickname(int index) {
    return 'プレイヤー$index';
  }

  /// テスト用のプレイヤーIDリストを生成
  static List<String> generatePlayerIds(int count) {
    return List.generate(count, (index) => 'player_${index + 1}');
  }

  /// テスト用のルームコードを生成
  static String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      8,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }
}

/// テストアサーション用のヘルパークラス
class TestAssertions {
  /// ルームコードが有効な形式かチェック
  static bool isValidRoomCode(String roomCode) {
    return roomCode.length == 8 && RegExp(r'^[A-Z0-9]+$').hasMatch(roomCode);
  }

  /// ニックネームが有効な形式かチェック
  static bool isValidNickname(String nickname) {
    return nickname.length >= 3 && nickname.length <= 20;
  }

  /// プレイヤー数が有効な範囲かチェック
  static bool isValidPlayerCount(int count) {
    return count >= 2 && count <= 4;
  }
}
