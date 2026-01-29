import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authenticationを使用したプレイヤー認証を管理するサービス
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 匿名認証でサインイン
  ///
  /// Firebase匿名認証を使用してユーザーを認証します。
  /// 成功した場合は[User]オブジェクトを返し、失敗した場合はnullを返します。
  ///
  /// 例外:
  /// - [FirebaseAuthException]: 認証に失敗した場合
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // エラーログを出力（本番環境では適切なロギングサービスを使用）
      print('匿名認証エラー: ${e.code} - ${e.message}');

      // より詳細なエラーメッセージを提供
      if (e.code == 'api-key-not-valid' || e.code == 'invalid-api-key') {
        throw Exception(
          'Firebase APIキーが無効です。\n'
          'FIREBASE_SETUP_INSTRUCTIONS.mdを参照して、\n'
          'Firebaseプロジェクトを設定してください。',
        );
      } else if (e.code == 'network-request-failed') {
        throw Exception(
          'ネットワークエラーが発生しました。\n'
          'インターネット接続を確認してください。',
        );
      }

      rethrow;
    } catch (e) {
      print('予期しないエラー: $e');
      throw Exception(
        'Firebase設定エラー: $e\n\n'
        'Firebaseプロジェクトが正しく設定されていない可能性があります。\n'
        'FIREBASE_SETUP_INSTRUCTIONS.mdを参照してください。',
      );
    }
  }

  /// ニックネームを検証
  ///
  /// ニックネームが有効かどうかを検証します。
  /// 有効なニックネームは3文字以上20文字以内です。
  ///
  /// [nickname]: 検証するニックネーム
  ///
  /// 戻り値: ニックネームが有効な場合はtrue、無効な場合はfalse
  bool validateNickname(String nickname) {
    // 空白を除去
    final trimmedNickname = nickname.trim();

    // 3文字以上20文字以内であることを確認
    return trimmedNickname.length >= 3 && trimmedNickname.length <= 20;
  }

  /// 現在のユーザーを取得
  ///
  /// 現在認証されているユーザーを返します。
  /// 認証されていない場合はnullを返します。
  ///
  /// 戻り値: 現在のユーザー、または認証されていない場合はnull
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// サインアウト
  ///
  /// 現在のユーザーをサインアウトします。
  ///
  /// 例外:
  /// - [FirebaseAuthException]: サインアウトに失敗した場合
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      // エラーログを出力
      print('サインアウトエラー: ${e.code} - ${e.message}');
      rethrow;
    }
  }
}
