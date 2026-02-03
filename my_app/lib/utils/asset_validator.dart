import 'package:flutter/foundation.dart';
import '../config/asset_path_config.dart';
import 'asset_path_manager.dart';

/// アセット検証ユーティリティ
///
/// アプリケーション起動時に必須アセットの存在を検証し、
/// 見つからないアセットをログに記録します。
class AssetValidator {
  /// 必須アセットの存在を検証
  ///
  /// [AssetPathConfig.requiredAssets]に定義されたすべてのアセットの
  /// 存在を確認し、見つからないアセットがある場合はログに記録します。
  ///
  /// 戻り値: 見つからないアセットのリスト（すべて存在する場合は空リスト）
  static Future<List<String>> validateRequiredAssets() async {
    final missingAssets = <String>[];

    debugPrint('=== アセット検証を開始 ===');
    debugPrint('検証対象: ${AssetPathConfig.requiredAssets.length}個のアセット');

    for (final assetPath in AssetPathConfig.requiredAssets) {
      final exists = await AssetPathManager.validateAssetPath(assetPath);

      if (!exists) {
        missingAssets.add(assetPath);
        debugPrint('❌ 見つかりません: $assetPath');
      } else {
        debugPrint('✓ 確認済み: $assetPath');
      }
    }

    if (missingAssets.isNotEmpty) {
      debugPrint('');
      debugPrint('⚠️ 警告: 以下の${missingAssets.length}個のアセットが見つかりません:');
      for (final asset in missingAssets) {
        debugPrint('  - $asset');
      }
      debugPrint('');
      debugPrint('これらのアセットが存在しない場合、アプリケーションの動作に');
      debugPrint('問題が発生する可能性があります。pubspec.yamlとassetsディレクトリを');
      debugPrint('確認してください。');
    } else {
      debugPrint('✓ すべての必須アセットが確認されました');
    }

    debugPrint('=== アセット検証完了 ===');

    return missingAssets;
  }
}
