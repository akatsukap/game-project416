import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

import '../utils/asset_path_manager.dart';
import 'placeholder_sprite.dart';

/// スプライト読み込みユーティリティ
///
/// スプライトの読み込みエラーをハンドリングし、
/// エラー時にはプログラム的に生成されたプレースホルダースプライトを返します。
/// 要件: 1.3
class SpriteLoader {
  /// デフォルトスプライトのパス
  static const String defaultSpritePath = 'assets/characters/default.png';

  /// スプライトを読み込む
  ///
  /// [path] 読み込むスプライトのパス
  /// 戻り値: 読み込まれたSprite、エラー時はnull
  ///
  /// エラーが発生した場合はログに記録し、nullを返します。
  /// 呼び出し側でnullチェックを行い、デフォルトスプライトを使用してください。
  static Future<Sprite?> loadSprite(String path) async {
    try {
      return await Sprite.load(path);
    } catch (e) {
      // スプライト読み込みエラーをログに記録
      print('スプライトの読み込みに失敗しました: $path, エラー: $e');
      return null;
    }
  }

  /// スプライトを読み込む（プレースホルダーへのフォールバック付き）
  ///
  /// [path] 読み込むスプライトのパス
  /// [fallbackGenerator] フォールバック用のスプライト生成関数（オプション）
  /// 戻り値: 読み込まれたSprite、エラー時はプレースホルダースプライト
  ///
  /// 指定されたパスのスプライト読み込みに失敗した場合、
  /// プログラム的に生成されたプレースホルダースプライトを返します。
  static Future<Sprite> loadSpriteWithFallback(
    String path, {
    Future<Sprite> Function()? fallbackGenerator,
  }) async {
    try {
      // パスを正規化（Flame用）
      final normalizedPath = AssetPathManager.normalizeFlameAssetPath(path);
      return await Sprite.load(normalizedPath);
    } catch (e) {
      // スプライト読み込みエラーをログに記録（詳細なパス情報を含む）
      print('スプライトの読み込みに失敗しました');
      print('  元のパス: $path');
      print('  正規化されたパス: ${AssetPathManager.normalizeFlameAssetPath(path)}');
      print('  エラー: $e');
      print('プレースホルダースプライトを生成します');

      try {
        // カスタムフォールバックジェネレーターが提供されている場合はそれを使用
        if (fallbackGenerator != null) {
          return await fallbackGenerator();
        }

        // パスからスプライトタイプを推測してプレースホルダーを生成
        if (path.contains('characters/')) {
          // キャラクタースプライト
          final characterId = path.split('/').last.replaceAll('.png', '');
          return await PlaceholderSpriteGenerator.generateCharacterSprite(
            characterId,
          );
        } else if (path.contains('ball')) {
          // ボールスプライト
          return await PlaceholderSpriteGenerator.generateBallSprite();
        } else if (path.contains('goal')) {
          // ゴールスプライト
          return await PlaceholderSpriteGenerator.generateGoalSprite();
        } else if (path.contains('field')) {
          // フィールドスプライト
          return await PlaceholderSpriteGenerator.generateFieldSprite(
            1920,
            1080,
          );
        } else if (path.contains('effects/')) {
          // エフェクトスプライト
          final effectName = path.split('/').last.replaceAll('.png', '');
          return await PlaceholderSpriteGenerator.generateEffectSprite(
            effectName,
          );
        } else {
          // デフォルトのプレースホルダー（グレーの矩形）
          return await PlaceholderSpriteGenerator.generateColoredSprite(
            64,
            64,
            const Color(0xFF95A5A6),
          );
        }
      } catch (fallbackError) {
        // プレースホルダー生成にも失敗した場合
        print('プレースホルダースプライトの生成に失敗しました: $fallbackError');
        // 上位レイヤーでエラーを処理できるように再スロー
        rethrow;
      }
    }
  }

  /// 複数のスプライトを読み込む
  ///
  /// [paths] 読み込むスプライトのパスのリスト
  /// 戻り値: 読み込まれたSpriteのリスト（エラーが発生したものはnull）
  ///
  /// 各スプライトの読み込みは独立して行われ、
  /// 一部のスプライトの読み込みに失敗しても他のスプライトは読み込まれます。
  static Future<List<Sprite?>> loadMultipleSprites(List<String> paths) async {
    final sprites = <Sprite?>[];

    for (final path in paths) {
      final sprite = await loadSprite(path);
      sprites.add(sprite);
    }

    return sprites;
  }

  /// スプライトシートを読み込む
  ///
  /// [path] スプライトシートのパス
  /// [textureSize] 各スプライトのサイズ
  /// 戻り値: 読み込まれたSpriteSheet、エラー時はnull
  ///
  /// 注: この機能は現在未実装です
  /*
  static Future<SpriteSheet?> loadSpriteSheet(
    String path,
    Vector2 textureSize,
  ) async {
    try {
      final image = await Sprite.load(path);
      // SpriteSheetの実装は必要に応じて追加
      return null; // TODO: SpriteSheetの実装
    } catch (e) {
      // スプライトシート読み込みエラーをログに記録
      print('スプライトシートの読み込みに失敗しました: $path, エラー: $e');
      return null;
    }
  }
  */
}
