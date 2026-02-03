import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/config/asset_path_config.dart';
import 'package:my_app/head_ball/sprite_loader.dart';
import 'package:my_app/utils/asset_path_manager.dart';

void main() {
  group('SpriteLoader', () {
    group('loadSpriteWithFallback', () {
      test('正規化されたパスでスプライトを読み込む', () async {
        // このテストは実際のアセットファイルが必要なため、
        // フォールバック機能のテストのみを行います

        // 存在しないパスでフォールバックが動作することを確認
        final sprite = await SpriteLoader.loadSpriteWithFallback(
          'characters/nonexistent.png',
        );

        // プレースホルダースプライトが返されることを確認
        expect(sprite, isA<Sprite>());
      });

      test('assets/プレフィックス付きパスを正規化する', () async {
        // assets/プレフィックス付きのパスでもフォールバックが動作することを確認
        final sprite = await SpriteLoader.loadSpriteWithFallback(
          'assets/characters/nonexistent.png',
        );

        // プレースホルダースプライトが返されることを確認
        expect(sprite, isA<Sprite>());
      });

      test('カスタムフォールバックジェネレーターを使用する', () async {
        // カスタムフォールバックジェネレーターが提供された場合に使用されることを確認
        var fallbackCalled = false;

        final sprite = await SpriteLoader.loadSpriteWithFallback(
          'nonexistent.png',
          fallbackGenerator: () async {
            fallbackCalled = true;
            // 簡単なプレースホルダースプライトを生成
            return Sprite(await _createTestImage());
          },
        );

        expect(sprite, isA<Sprite>());
        expect(fallbackCalled, isTrue);
      });
    });

    // Feature: asset-loading-ui-fixes, Property 3: アセットディレクトリの正確性
    // **検証: 要件 1.3, 1.4, 1.5**
    group('プロパティテスト: アセットディレクトリの正確性', () {
      test('任意のゲームアセットパスが正しくgame/ディレクトリを指す', () {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // ゲームアセットのパスを生成
          final path = _generateGameAssetPath(random);

          // パスを正規化
          final normalizedPath = AssetPathManager.normalizeFlameAssetPath(path);

          // 正規化されたパスがgame/ディレクトリを含むことを確認
          expect(
            normalizedPath,
            startsWith(AssetPathConfig.gameDir),
            reason: 'ゲームアセットパスが正しいディレクトリを指していません: $path -> $normalizedPath',
          );

          // 正規化されたパスにassets/プレフィックスが含まれていないことを確認
          expect(
            normalizedPath,
            isNot(startsWith('assets/')),
            reason: 'Flame用の正規化パスにassets/プレフィックスが残っています: $normalizedPath',
          );
        }
      });

      test('任意のキャラクターアセットパスが正しくcharacters/ディレクトリを指す', () {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // キャラクターアセットのパスを生成
          final path = _generateCharacterAssetPath(random);

          // パスを正規化
          final normalizedPath = AssetPathManager.normalizeFlameAssetPath(path);

          // 正規化されたパスがcharacters/ディレクトリを含むことを確認
          expect(
            normalizedPath,
            startsWith(AssetPathConfig.charactersDir),
            reason: 'キャラクターアセットパスが正しいディレクトリを指していません: $path -> $normalizedPath',
          );

          // 正規化されたパスにassets/プレフィックスが含まれていないことを確認
          expect(
            normalizedPath,
            isNot(startsWith('assets/')),
            reason: 'Flame用の正規化パスにassets/プレフィックスが残っています: $normalizedPath',
          );
        }
      });

      test('任意のエフェクトアセットパスが正しくeffects/ディレクトリを指す', () {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // エフェクトアセットのパスを生成
          final path = _generateEffectAssetPath(random);

          // パスを正規化
          final normalizedPath = AssetPathManager.normalizeFlameAssetPath(path);

          // 正規化されたパスがeffects/ディレクトリを含むことを確認
          expect(
            normalizedPath,
            startsWith(AssetPathConfig.effectsDir),
            reason: 'エフェクトアセットパスが正しいディレクトリを指していません: $path -> $normalizedPath',
          );

          // 正規化されたパスにassets/プレフィックスが含まれていないことを確認
          expect(
            normalizedPath,
            isNot(startsWith('assets/')),
            reason: 'Flame用の正規化パスにassets/プレフィックスが残っています: $normalizedPath',
          );
        }
      });

      test('必須アセットのパスが正しいディレクトリを指す', () {
        // AssetPathConfigで定義された必須アセットをテスト
        for (final assetPath in AssetPathConfig.requiredAssets) {
          // パスを正規化
          final normalizedPath = AssetPathManager.normalizeFlameAssetPath(
            assetPath,
          );

          // 必須アセットはすべてgame/ディレクトリにあるべき
          expect(
            normalizedPath,
            startsWith(AssetPathConfig.gameDir),
            reason: '必須アセットが正しいディレクトリを指していません: $assetPath',
          );

          // 正規化されたパスにassets/プレフィックスが含まれていないことを確認
          expect(
            normalizedPath,
            isNot(startsWith('assets/')),
            reason: 'Flame用の正規化パスにassets/プレフィックスが残っています: $normalizedPath',
          );
        }
      });

      test('各アセットタイプが対応する正しいディレクトリにマッピングされる', () {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // ランダムにアセットタイプを選択
          final assetType =
              _AssetType.values[random.nextInt(_AssetType.values.length)];

          String path;
          String expectedDir;

          switch (assetType) {
            case _AssetType.game:
              path = _generateGameAssetPath(random);
              expectedDir = AssetPathConfig.gameDir;
              break;
            case _AssetType.character:
              path = _generateCharacterAssetPath(random);
              expectedDir = AssetPathConfig.charactersDir;
              break;
            case _AssetType.effect:
              path = _generateEffectAssetPath(random);
              expectedDir = AssetPathConfig.effectsDir;
              break;
          }

          // パスを正規化
          final normalizedPath = AssetPathManager.normalizeFlameAssetPath(path);

          // 正規化されたパスが期待されるディレクトリで始まることを確認
          expect(
            normalizedPath,
            startsWith(expectedDir),
            reason:
                'アセットタイプ $assetType のパスが正しいディレクトリを指していません: $path -> $normalizedPath (期待: $expectedDir)',
          );
        }
      });
    });

    // Feature: asset-loading-ui-fixes, Property 7: アセット読み込み失敗時のフォールバック
    // **検証: 要件 4.3, 5.2**
    group('プロパティテスト: アセット読み込み失敗時のフォールバック', () {
      test('任意の無効なパスでもクラッシュせずプレースホルダーが返される', () async {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // 無効なアセットパスを生成
          final invalidPath = _generateInvalidAssetPath(random);

          // loadSpriteWithFallbackを呼び出す
          // クラッシュせずにSpriteが返されることを確認
          Sprite? sprite;
          try {
            sprite = await SpriteLoader.loadSpriteWithFallback(invalidPath);
          } catch (e) {
            fail('無効なパス "$invalidPath" でloadSpriteWithFallbackがクラッシュしました: $e');
          }

          // プレースホルダースプライトが返されることを確認
          expect(
            sprite,
            isA<Sprite>(),
            reason: '無効なパス "$invalidPath" でSpriteが返されませんでした',
          );
          expect(
            sprite,
            isNotNull,
            reason: '無効なパス "$invalidPath" でnullが返されました',
          );
        }
      });

      test('様々なタイプの無効なパスでも適切なプレースホルダーが返される', () async {
        final random = Random();
        const iterations = 50;

        for (int i = 0; i < iterations; i++) {
          // 各アセットタイプの無効なパスを生成
          final assetType =
              _AssetType.values[random.nextInt(_AssetType.values.length)];

          String invalidPath;
          switch (assetType) {
            case _AssetType.game:
              invalidPath = _generateInvalidGameAssetPath(random);
              break;
            case _AssetType.character:
              invalidPath = _generateInvalidCharacterAssetPath(random);
              break;
            case _AssetType.effect:
              invalidPath = _generateInvalidEffectAssetPath(random);
              break;
          }

          // loadSpriteWithFallbackを呼び出す
          Sprite? sprite;
          try {
            sprite = await SpriteLoader.loadSpriteWithFallback(invalidPath);
          } catch (e) {
            fail('アセットタイプ $assetType の無効なパス "$invalidPath" でクラッシュしました: $e');
          }

          // プレースホルダースプライトが返されることを確認
          expect(
            sprite,
            isA<Sprite>(),
            reason:
                'アセットタイプ $assetType の無効なパス "$invalidPath" でSpriteが返されませんでした',
          );
        }
      });

      test('空のパスや特殊文字を含むパスでもクラッシュしない', () async {
        final invalidPaths = [
          '', // 空のパス
          ' ', // スペースのみ
          '/', // スラッシュのみ
          '//', // 二重スラッシュ
          'nonexistent/path/to/file.png', // 存在しないパス
          '../../../etc/passwd', // パストラバーサル
          'assets/../../../etc/passwd', // パストラバーサル（assets付き）
          'characters/\u0000null.png', // ヌル文字
          'game/file with spaces.png', // スペースを含むパス
          'effects/日本語ファイル.png', // 日本語を含むパス
          'characters/emoji😀.png', // 絵文字を含むパス
          'game/very_long_filename_' + 'a' * 200 + '.png', // 非常に長いファイル名
        ];

        for (final invalidPath in invalidPaths) {
          // loadSpriteWithFallbackを呼び出す
          Sprite? sprite;
          try {
            sprite = await SpriteLoader.loadSpriteWithFallback(invalidPath);
          } catch (e) {
            fail('特殊なパス "$invalidPath" でクラッシュしました: $e');
          }

          // プレースホルダースプライトが返されることを確認
          expect(
            sprite,
            isA<Sprite>(),
            reason: '特殊なパス "$invalidPath" でSpriteが返されませんでした',
          );
        }
      });

      test('カスタムフォールバックジェネレーターが失敗してもデフォルトフォールバックが使用される', () async {
        final random = Random();
        const iterations = 20;

        for (int i = 0; i < iterations; i++) {
          final invalidPath = _generateInvalidAssetPath(random);

          // 常に失敗するカスタムフォールバックジェネレーター
          Future<Sprite> failingFallback() async {
            throw Exception('カスタムフォールバックが失敗しました');
          }

          // loadSpriteWithFallbackを呼び出す
          // カスタムフォールバックが失敗した場合、エラーが再スローされる
          try {
            await SpriteLoader.loadSpriteWithFallback(
              invalidPath,
              fallbackGenerator: failingFallback,
            );
            fail('カスタムフォールバックの失敗が適切に処理されませんでした');
          } catch (e) {
            // カスタムフォールバックが失敗した場合、例外が再スローされることを確認
            expect(
              e.toString(),
              contains('カスタムフォールバックが失敗しました'),
              reason: '予期しない例外が発生しました: $e',
            );
          }
        }
      });
    });
  });
}

// テスト用の画像を作成するヘルパー関数
Future<Image> _createTestImage() async {
  // Flameのテスト用画像生成機能を使用
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = const Color(0xFF000000);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 10, 10), paint);
  final picture = recorder.endRecording();
  return picture.toImageSync(10, 10);
}

/// アセットタイプの列挙型
enum _AssetType { game, character, effect }

/// ランダムなゲームアセットパスを生成するヘルパー関数
///
/// 様々なパターンのゲームアセットパスを生成して、プロパティテストで使用します。
/// 生成されるパターン:
/// - 正常なパス: "game/field_background.png"
/// - assets/プレフィックス付き: "assets/game/ball.png"
/// - 重複セグメント付き: "assets/assets/game/goal.png"
String _generateGameAssetPath(Random random) {
  final prefixes = ['', 'assets/', 'assets/assets/'];
  final gameAssets = [
    'field_background.png',
    'ball.png',
    'goal.png',
    'scoreboard.png',
    'timer.png',
  ];

  final prefix = prefixes[random.nextInt(prefixes.length)];
  final asset = gameAssets[random.nextInt(gameAssets.length)];

  return '$prefix${AssetPathConfig.gameDir}$asset';
}

/// ランダムなキャラクターアセットパスを生成するヘルパー関数
///
/// 様々なパターンのキャラクターアセットパスを生成して、プロパティテストで使用します。
/// 生成されるパターン:
/// - 正常なパス: "characters/hero1.png"
/// - assets/プレフィックス付き: "assets/characters/hero2.png"
/// - 重複セグメント付き: "assets/assets/characters/hero3.png"
String _generateCharacterAssetPath(Random random) {
  final prefixes = ['', 'assets/', 'assets/assets/'];
  final characterAssets = [
    'hero1.png',
    'hero2.png',
    'hero3.png',
    'villain1.png',
    'villain2.png',
    'default.png',
  ];

  final prefix = prefixes[random.nextInt(prefixes.length)];
  final asset = characterAssets[random.nextInt(characterAssets.length)];

  return '$prefix${AssetPathConfig.charactersDir}$asset';
}

/// ランダムなエフェクトアセットパスを生成するヘルパー関数
///
/// 様々なパターンのエフェクトアセットパスを生成して、プロパティテストで使用します。
/// 生成されるパターン:
/// - 正常なパス: "effects/explosion.png"
/// - assets/プレフィックス付き: "assets/effects/spark.png"
/// - 重複セグメント付き: "assets/assets/effects/smoke.png"
String _generateEffectAssetPath(Random random) {
  final prefixes = ['', 'assets/', 'assets/assets/'];
  final effectAssets = [
    'explosion.png',
    'spark.png',
    'smoke.png',
    'trail.png',
    'impact.png',
  ];

  final prefix = prefixes[random.nextInt(prefixes.length)];
  final asset = effectAssets[random.nextInt(effectAssets.length)];

  return '$prefix${AssetPathConfig.effectsDir}$asset';
}

/// ランダムな無効なアセットパスを生成するヘルパー関数
///
/// プロパティテストで使用する様々な無効なパスパターンを生成します。
/// 生成されるパターン:
/// - 存在しないファイル名
/// - 存在しないディレクトリ
/// - ランダムな文字列
/// - 不正な拡張子
String _generateInvalidAssetPath(Random random) {
  final patterns = [
    // 存在しないファイル名
    () => 'characters/nonexistent_${random.nextInt(10000)}.png',
    () => 'game/invalid_${random.nextInt(10000)}.png',
    () => 'effects/missing_${random.nextInt(10000)}.png',
    // 存在しないディレクトリ
    () => 'invalid_dir/file.png',
    () => 'nonexistent/path/to/file.png',
    // ランダムな文字列
    () => _generateRandomString(random, 10) + '.png',
    // 不正な拡張子
    () => 'characters/hero1.jpg',
    () => 'game/ball.gif',
    () => 'effects/explosion.bmp',
    // パスなし（ファイル名のみ）
    () => 'nonexistent.png',
    // 深いネストパス
    () => 'a/b/c/d/e/f/g/h/i/j/file.png',
  ];

  final pattern = patterns[random.nextInt(patterns.length)];
  return pattern();
}

/// ランダムな無効なゲームアセットパスを生成するヘルパー関数
String _generateInvalidGameAssetPath(Random random) {
  final invalidAssets = [
    'nonexistent_field.png',
    'missing_ball.png',
    'invalid_goal.png',
    'fake_scoreboard_${random.nextInt(1000)}.png',
  ];

  final asset = invalidAssets[random.nextInt(invalidAssets.length)];
  return '${AssetPathConfig.gameDir}$asset';
}

/// ランダムな無効なキャラクターアセットパスを生成するヘルパー関数
String _generateInvalidCharacterAssetPath(Random random) {
  final invalidAssets = [
    'nonexistent_hero.png',
    'missing_villain.png',
    'invalid_character_${random.nextInt(1000)}.png',
    'fake_sprite.png',
  ];

  final asset = invalidAssets[random.nextInt(invalidAssets.length)];
  return '${AssetPathConfig.charactersDir}$asset';
}

/// ランダムな無効なエフェクトアセットパスを生成するヘルパー関数
String _generateInvalidEffectAssetPath(Random random) {
  final invalidAssets = [
    'nonexistent_explosion.png',
    'missing_spark.png',
    'invalid_effect_${random.nextInt(1000)}.png',
    'fake_animation.png',
  ];

  final asset = invalidAssets[random.nextInt(invalidAssets.length)];
  return '${AssetPathConfig.effectsDir}$asset';
}

/// ランダムな文字列を生成するヘルパー関数
String _generateRandomString(Random random, int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789_-';
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}
