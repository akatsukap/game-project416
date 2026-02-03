import 'package:firebase_auth/firebase_auth.dart';

/// Firebase認証サービス
///
/// ユーザーの匿名認証を管理するサービスクラス
class AuthService {
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  /// 匿名でサインイン
  ///
  /// Returns: サインインしたユーザー、失敗時はnull
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      throw Exception('匿名認証に失敗しました: $e');
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('サインアウトに失敗しました: $e');
    }
  }

  /// ニックネームのバリデーション
  ///
  /// [nickname] 検証するニックネーム
  /// Returns: 有効な場合true、無効な場合false
  bool validateNickname(String nickname) {
    final trimmed = nickname.trim();
    return trimmed.length >= 3 && trimmed.length <= 20;
  }

  /// 認証状態の変更を監視
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

