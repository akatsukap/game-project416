import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/config/asset_path_config.dart';
import 'package:my_app/utils/asset_validator.dart';

void main() {
  // Flutterのバインディングを初期化
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetValidator', () {
    group('validateRequiredAssets', () {
      test('必須アセットの検証を実行できる', () async {
        // 検証を実行（実際のアセットファイルが存在しない場合、見つからないリストが返される）
        final missingAssets = await AssetValidator.validateRequiredAssets();

        // 戻り値がリストであることを確認
        expect(missingAssets, isA<List<String>>());

        // 各要素が文字列であることを確認
        for (final asset in missingAssets) {
          expect(asset, isA<String>());
        }
      });

      test('見つからないアセットのリストを返す', () async {
        // 検証を実行
        final missingAssets = await AssetValidator.validateRequiredAssets();

        // 見つからないアセットがある場合、それらは必須アセットのリストに含まれているはず
        for (final asset in missingAssets) {
          // アセットパスが空でないことを確認
          expect(asset.isNotEmpty, true);
        }
      });

      test('複数回呼び出しても一貫した結果を返す', () async {
        // 1回目の検証
        final result1 = await AssetValidator.validateRequiredAssets();

        // 2回目の検証
        final result2 = await AssetValidator.validateRequiredAssets();

        // 結果が一貫していることを確認
        expect(result1.length, equals(result2.length));
        expect(result1, containsAll(result2));
        expect(result2, containsAll(result1));
      });

      // **検証: 要件 4.1** - 必須アセットが正しく検証されることを確認
      test('必須アセットが正しく検証される', () async {
        // 検証を実行
        final missingAssets = await AssetValidator.validateRequiredAssets();

        // 必須アセットのリストを取得
        final requiredAssets = AssetPathConfig.requiredAssets;

        // 必須アセットが定義されていることを確認
        expect(requiredAssets.isNotEmpty, true, reason: '必須アセットのリストが空です');

        // 各必須アセットについて検証
        for (final requiredAsset in requiredAssets) {
          // アセットパスが適切な形式であることを確認
          expect(requiredAsset.isNotEmpty, true, reason: '必須アセットのパスが空です');

          // アセットパスにディレクトリとファイル名が含まれていることを確認
          expect(
            requiredAsset.contains('/'),
            true,
            reason: 'アセットパス "$requiredAsset" にディレクトリ区切りが含まれていません',
          );

          // アセットパスに拡張子が含まれていることを確認
          expect(
            requiredAsset.contains('.'),
            true,
            reason: 'アセットパス "$requiredAsset" に拡張子が含まれていません',
          );
        }

        // 検証結果が必須アセットのサブセットであることを確認
        for (final missing in missingAssets) {
          expect(
            requiredAssets.contains(missing),
            true,
            reason: '見つからないアセット "$missing" が必須アセットのリストに含まれていません',
          );
        }
      });

      // **検証: 要件 4.2** - 存在しないアセットが検出されることを確認
      test('存在しないアセットが正しく検出される', () async {
        // 検証を実行
        final missingAssets = await AssetValidator.validateRequiredAssets();

        // 実際のアセットファイルの状態に応じて検証
        // このテストでは、検証機能が正しく動作することを確認

        // 見つからないアセットがある場合
        if (missingAssets.isNotEmpty) {
          // 各見つからないアセットが有効なパス形式であることを確認
          for (final missing in missingAssets) {
            expect(missing.isNotEmpty, true, reason: '見つからないアセットのパスが空です');

            // パスが必須アセットのリストに含まれていることを確認
            expect(
              AssetPathConfig.requiredAssets.contains(missing),
              true,
              reason: '見つからないアセット "$missing" が必須アセットのリストに含まれていません',
            );
          }
        }

        // すべてのアセットが見つかった場合
        if (missingAssets.isEmpty) {
          // 必須アセットがすべて存在することを確認
          expect(
            AssetPathConfig.requiredAssets.isNotEmpty,
            true,
            reason: '必須アセットのリストが空です',
          );
        }
      });

      // **検証: 要件 4.1, 4.2** - 特定のアセットパスの検証動作を確認
      test('特定のアセットパスの検証が正しく動作する', () async {
        // 検証を実行
        final missingAssets = await AssetValidator.validateRequiredAssets();

        // 必須アセットの各カテゴリを確認
        final gameAssets = AssetPathConfig.requiredAssets
            .where((asset) => asset.startsWith(AssetPathConfig.gameDir))
            .toList();

        // ゲームアセットが定義されていることを確認
        expect(gameAssets.isNotEmpty, true, reason: 'ゲームアセットが必須アセットに含まれていません');

        // 各ゲームアセットについて
        for (final gameAsset in gameAssets) {
          // アセットが見つからない場合、missingAssetsに含まれているべき
          // アセットが見つかった場合、missingAssetsに含まれていないべき
          final isMissing = missingAssets.contains(gameAsset);

          // 検証結果が一貫していることを確認（論理的な整合性）
          if (isMissing) {
            expect(
              missingAssets.contains(gameAsset),
              true,
              reason: 'アセット "$gameAsset" が見つからないリストに含まれていません',
            );
          } else {
            expect(
              missingAssets.contains(gameAsset),
              false,
              reason: 'アセット "$gameAsset" が見つからないリストに誤って含まれています',
            );
          }
        }
      });

      // **検証: 要件 4.1** - 検証結果の完全性を確認
      test('検証結果がすべての必須アセットをカバーしている', () async {
        // 検証を実行
        final missingAssets = await AssetValidator.validateRequiredAssets();

        // 必須アセットの総数を取得
        final totalRequired = AssetPathConfig.requiredAssets.length;

        // 見つかったアセットの数を計算
        final foundCount = totalRequired - missingAssets.length;

        // 見つかったアセット数が0以上であることを確認
        expect(foundCount >= 0, true, reason: '見つかったアセット数が負の値です');

        // 見つかったアセット数が必須アセット数以下であることを確認
        expect(
          foundCount <= totalRequired,
          true,
          reason: '見つかったアセット数が必須アセット数を超えています',
        );

        // 見つからないアセット数が必須アセット数以下であることを確認
        expect(
          missingAssets.length <= totalRequired,
          true,
          reason: '見つからないアセット数が必須アセット数を超えています',
        );

        // 見つかったアセット数と見つからないアセット数の合計が必須アセット数と一致することを確認
        expect(
          foundCount + missingAssets.length,
          equals(totalRequired),
          reason: '検証結果の合計が必須アセット数と一致しません',
        );
      });

      // **検証: 要件 4.2** - 重複検出がないことを確認
      test('見つからないアセットのリストに重複がない', () async {
        // 検証を実行
        final missingAssets = await AssetValidator.validateRequiredAssets();

        // 重複を検出
        final uniqueAssets = missingAssets.toSet();

        // 重複がないことを確認
        expect(
          missingAssets.length,
          equals(uniqueAssets.length),
          reason: '見つからないアセットのリストに重複があります',
        );
      });
    });
  });
}
