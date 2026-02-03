import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/utils/asset_path_manager.dart';

void main() {
  group('AssetPathManager', () {
    group('normalizeFlameAssetPath', () {
      test('assets/プレフィックスを削除する', () {
        final result = AssetPathManager.normalizeFlameAssetPath(
          'assets/characters/hero1.png',
        );
        expect(result, 'characters/hero1.png');
      });

      test('assets/プレフィックスがない場合はそのまま返す', () {
        final result = AssetPathManager.normalizeFlameAssetPath(
          'characters/hero1.png',
        );
        expect(result, 'characters/hero1.png');
      });

      test('空文字列を処理する', () {
        final result = AssetPathManager.normalizeFlameAssetPath('');
        expect(result, '');
      });

      test('assets/のみの場合は空文字列を返す', () {
        final result = AssetPathManager.normalizeFlameAssetPath('assets/');
        expect(result, '');
      });
    });

    group('normalizeFlutterAssetPath', () {
      test('assets/プレフィックスを追加する', () {
        final result = AssetPathManager.normalizeFlutterAssetPath(
          'characters/hero1.png',
        );
        expect(result, 'assets/characters/hero1.png');
      });

      test('assets/プレフィックスが既にある場合はそのまま返す', () {
        final result = AssetPathManager.normalizeFlutterAssetPath(
          'assets/characters/hero1.png',
        );
        expect(result, 'assets/characters/hero1.png');
      });

      test('空文字列にassets/を追加する', () {
        final result = AssetPathManager.normalizeFlutterAssetPath('');
        expect(result, 'assets/');
      });
    });

    group('validateAssetPath', () {
      test('存在しないアセットパスに対してfalseを返す', () async {
        final result = await AssetPathManager.validateAssetPath(
          'nonexistent/path.png',
        );
        expect(result, false);
      });

      // 注: 実際のアセットファイルが存在する場合のテストは、
      // 実際のアセットファイルが配置された後に追加する必要があります
    });

    // Feature: asset-loading-ui-fixes, Property 2: パス正規化の冪等性
    // **検証: 要件 1.2**
    group('プロパティテスト: パス正規化の冪等性', () {
      test('任意のアセットパスに対して正規化後に重複セグメントがない', () {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          final path = _generateRandomAssetPath(random);

          // Flame用のパス正規化をテスト
          final normalizedFlame = AssetPathManager.normalizeFlameAssetPath(
            path,
          );

          // 重複セグメントがないことを確認
          expect(
            normalizedFlame,
            isNot(contains('assets/assets')),
            reason:
                'Flameパス正規化で"assets/assets"の重複が検出されました: $path -> $normalizedFlame',
          );
          expect(
            normalizedFlame,
            isNot(contains('images/images')),
            reason:
                'Flameパス正規化で"images/images"の重複が検出されました: $path -> $normalizedFlame',
          );
          expect(
            normalizedFlame,
            isNot(contains('characters/characters')),
            reason:
                'Flameパス正規化で"characters/characters"の重複が検出されました: $path -> $normalizedFlame',
          );
          expect(
            normalizedFlame,
            isNot(contains('game/game')),
            reason:
                'Flameパス正規化で"game/game"の重複が検出されました: $path -> $normalizedFlame',
          );
          expect(
            normalizedFlame,
            isNot(contains('effects/effects')),
            reason:
                'Flameパス正規化で"effects/effects"の重複が検出されました: $path -> $normalizedFlame',
          );

          // Flutter用のパス正規化をテスト
          final normalizedFlutter = AssetPathManager.normalizeFlutterAssetPath(
            path,
          );

          // 重複セグメントがないことを確認
          expect(
            normalizedFlutter,
            isNot(contains('assets/assets')),
            reason:
                'Flutterパス正規化で"assets/assets"の重複が検出されました: $path -> $normalizedFlutter',
          );
          expect(
            normalizedFlutter,
            isNot(contains('images/images')),
            reason:
                'Flutterパス正規化で"images/images"の重複が検出されました: $path -> $normalizedFlutter',
          );
          expect(
            normalizedFlutter,
            isNot(contains('characters/characters')),
            reason:
                'Flutterパス正規化で"characters/characters"の重複が検出されました: $path -> $normalizedFlutter',
          );
          expect(
            normalizedFlutter,
            isNot(contains('game/game')),
            reason:
                'Flutterパス正規化で"game/game"の重複が検出されました: $path -> $normalizedFlutter',
          );
          expect(
            normalizedFlutter,
            isNot(contains('effects/effects')),
            reason:
                'Flutterパス正規化で"effects/effects"の重複が検出されました: $path -> $normalizedFlutter',
          );
        }
      });

      test('冪等性: 正規化を複数回適用しても結果が変わらない', () {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          final path = _generateRandomAssetPath(random);

          // Flame用のパス正規化の冪等性をテスト
          final normalizedOnce = AssetPathManager.normalizeFlameAssetPath(path);
          final normalizedTwice = AssetPathManager.normalizeFlameAssetPath(
            normalizedOnce,
          );
          final normalizedThrice = AssetPathManager.normalizeFlameAssetPath(
            normalizedTwice,
          );

          expect(
            normalizedOnce,
            equals(normalizedTwice),
            reason:
                'Flameパス正規化が冪等ではありません: $path -> $normalizedOnce -> $normalizedTwice',
          );
          expect(
            normalizedTwice,
            equals(normalizedThrice),
            reason:
                'Flameパス正規化が冪等ではありません: $normalizedOnce -> $normalizedTwice -> $normalizedThrice',
          );

          // Flutter用のパス正規化の冪等性をテスト
          final flutterNormalizedOnce =
              AssetPathManager.normalizeFlutterAssetPath(path);
          final flutterNormalizedTwice =
              AssetPathManager.normalizeFlutterAssetPath(flutterNormalizedOnce);
          final flutterNormalizedThrice =
              AssetPathManager.normalizeFlutterAssetPath(
                flutterNormalizedTwice,
              );

          expect(
            flutterNormalizedOnce,
            equals(flutterNormalizedTwice),
            reason:
                'Flutterパス正規化が冪等ではありません: $path -> $flutterNormalizedOnce -> $flutterNormalizedTwice',
          );
          expect(
            flutterNormalizedTwice,
            equals(flutterNormalizedThrice),
            reason:
                'Flutterパス正規化が冪等ではありません: $flutterNormalizedOnce -> $flutterNormalizedTwice -> $flutterNormalizedThrice',
          );
        }
      });
    });
  });
}

/// ランダムなアセットパスを生成するヘルパー関数
///
/// 様々なパターンのアセットパスを生成して、プロパティテストで使用します。
/// 生成されるパターン:
/// - 正常なパス: "characters/hero1.png"
/// - assets/プレフィックス付き: "assets/characters/hero1.png"
/// - 重複セグメント付き: "assets/assets/characters/hero1.png"
/// - 複数の重複: "assets/images/assets/game/field.png"
String _generateRandomAssetPath(Random random) {
  final directories = ['characters', 'game', 'effects', 'images'];
  final prefixes = ['', 'assets/', 'assets/assets/', 'assets/images/'];
  final filenames = [
    'hero1.png',
    'ball.png',
    'field.png',
    'explosion.png',
    'goal.png',
  ];

  final prefix = prefixes[random.nextInt(prefixes.length)];
  final directory = directories[random.nextInt(directories.length)];
  final filename = filenames[random.nextInt(filenames.length)];

  // ランダムに重複セグメントを追加する可能性
  if (random.nextBool()) {
    // 重複セグメントを追加
    final duplicateSegment = directories[random.nextInt(directories.length)];
    return '$prefix$directory/$duplicateSegment/$filename';
  }

  return '$prefix$directory/$filename';
}
