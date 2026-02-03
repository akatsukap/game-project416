import 'package:flutter/services.dart';

/// アセットパス管理クラス
///
/// Flameエンジンとflutterの両方で使用されるアセットパスを正規化し、
/// 一貫性のあるパス管理を提供します。
class AssetPathManager {
  /// Flameエンジン用のアセットパスを正規化
  ///
  /// Flameは自動的に"assets/"をプレフィックスとして追加するため、
  /// 相対パスのみを返します。
  ///
  /// 例:
  /// - "assets/characters/hero1.png" -> "characters/hero1.png"
  /// - "characters/hero1.png" -> "characters/hero1.png"
  ///
  /// [relativePath] 正規化するアセットパス
  /// 戻り値: Flame用に正規化されたパス（"assets/"プレフィックスなし）
  static String normalizeFlameAssetPath(String relativePath) {
    // "assets/"で始まる場合は削除
    if (relativePath.startsWith('assets/')) {
      return relativePath.substring(7);
    }
    return relativePath;
  }

  /// Flutter用のアセットパスを正規化
  ///
  /// Image.assetなどのFlutter APIは"assets/"プレフィックスが必要なため、
  /// プレフィックスが存在しない場合は追加します。
  ///
  /// 例:
  /// - "characters/hero1.png" -> "assets/characters/hero1.png"
  /// - "assets/characters/hero1.png" -> "assets/characters/hero1.png"
  ///
  /// [relativePath] 正規化するアセットパス
  /// 戻り値: Flutter用に正規化されたパス（"assets/"プレフィックス付き）
  static String normalizeFlutterAssetPath(String relativePath) {
    // "assets/"で始まらない場合は追加
    if (!relativePath.startsWith('assets/')) {
      return 'assets/$relativePath';
    }
    return relativePath;
  }

  /// アセットパスの存在を検証
  ///
  /// 指定されたアセットパスが実際に存在するかを確認します。
  /// Flutter用のパスに正規化してから検証を行います。
  ///
  /// [path] 検証するアセットパス
  /// 戻り値: アセットが存在する場合はtrue、存在しない場合はfalse
  static Future<bool> validateAssetPath(String path) async {
    try {
      await rootBundle.load(normalizeFlutterAssetPath(path));
      return true;
    } catch (e) {
      return false;
    }
  }
}
