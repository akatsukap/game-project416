import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/character_registry.dart';

void main() {
  group('CharacterRegistry', () {
    group('基本機能', () {
      test('すべてのキャラクターを取得できる', () {
        final characters = CharacterRegistry.getAllCharacters();
        expect(characters, isNotEmpty);
        expect(characters.length, CharacterRegistry.characterCount);
      });

      test('IDでキャラクターを取得できる', () {
        final character = CharacterRegistry.getById('local_hero_1');
        expect(character, isNotNull);
        expect(character?.id, 'local_hero_1');
      });

      test('存在しないIDの場合はnullを返す', () {
        final character = CharacterRegistry.getById('nonexistent_id');
        expect(character, isNull);
      });

      test('インデックスでキャラクターを取得できる', () {
        final character = CharacterRegistry.getByIndex(0);
        expect(character, isNotNull);
      });

      test('範囲外のインデックスの場合はnullを返す', () {
        final character = CharacterRegistry.getByIndex(-1);
        expect(character, isNull);

        final character2 = CharacterRegistry.getByIndex(999);
        expect(character2, isNull);
      });
    });

    // Feature: asset-loading-ui-fixes, Property 1: アセットパス形式の一貫性
    // **検証: 要件 1.1**
    group('プロパティテスト: アセットパス形式の一貫性', () {
      test('すべてのキャラクターのspritePathが一貫したパターンに従う', () {
        final characters = CharacterRegistry.getAllCharacters();

        // すべてのキャラクターに対してテスト
        for (final character in characters) {
          // spritePathが空でないことを確認
          expect(
            character.spritePath,
            isNotEmpty,
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePathが空です',
          );

          // spritePathが"characters/"で始まることを確認
          expect(
            character.spritePath,
            startsWith('characters/'),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" が "characters/" で始まっていません',
          );

          // spritePathが".png"で終わることを確認
          expect(
            character.spritePath,
            endsWith('.png'),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" が ".png" で終わっていません',
          );

          // spritePathに"assets/"プレフィックスが含まれていないことを確認
          // （Flameエンジンが自動的に追加するため）
          expect(
            character.spritePath,
            isNot(startsWith('assets/')),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" に不要な "assets/" プレフィックスが含まれています',
          );

          // spritePathに重複したセグメントがないことを確認
          expect(
            character.spritePath,
            isNot(contains('characters/characters')),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" に重複セグメント "characters/characters" が含まれています',
          );

          expect(
            character.spritePath,
            isNot(contains('assets/assets')),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" に重複セグメント "assets/assets" が含まれています',
          );

          expect(
            character.spritePath,
            isNot(contains('images/images')),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" に重複セグメント "images/images" が含まれています',
          );

          // spritePathが正しい形式であることを確認（characters/xxx.png）
          final pathPattern = RegExp(r'^characters/[a-z_0-9]+\.png$');
          expect(
            character.spritePath,
            matches(pathPattern),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" が期待される形式 "characters/xxx.png" に一致しません',
          );
        }
      });

      test('すべてのキャラクターが一意のspritePathを持つ', () {
        final characters = CharacterRegistry.getAllCharacters();
        final spritePaths = <String>{};

        for (final character in characters) {
          // 重複がないことを確認
          expect(
            spritePaths.contains(character.spritePath),
            isFalse,
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のspritePath "${character.spritePath}" が重複しています',
          );

          spritePaths.add(character.spritePath);
        }

        // すべてのキャラクターが異なるspritePathを持つことを確認
        expect(spritePaths.length, equals(characters.length));
      });

      test('すべてのキャラクターが一意のIDを持つ', () {
        final characters = CharacterRegistry.getAllCharacters();
        final ids = <String>{};

        for (final character in characters) {
          // 重複がないことを確認
          expect(
            ids.contains(character.id),
            isFalse,
            reason: 'キャラクターID "${character.id}" が重複しています',
          );

          ids.add(character.id);
        }

        // すべてのキャラクターが異なるIDを持つことを確認
        expect(ids.length, equals(characters.length));
      });

      test('すべてのキャラクターが有効な能力値を持つ', () {
        final characters = CharacterRegistry.getAllCharacters();

        for (final character in characters) {
          // 速度が正の値であることを確認
          expect(
            character.speed,
            greaterThan(0),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) の速度が0以下です: ${character.speed}',
          );

          // ジャンプ力が正の値であることを確認
          expect(
            character.jumpPower,
            greaterThan(0),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のジャンプ力が0以下です: ${character.jumpPower}',
          );

          // キック力が正の値であることを確認
          expect(
            character.kickPower,
            greaterThan(0),
            reason:
                'キャラクター "${character.name}" (ID: ${character.id}) のキック力が0以下です: ${character.kickPower}',
          );

          // 名前が空でないことを確認
          expect(
            character.name,
            isNotEmpty,
            reason: 'キャラクター (ID: ${character.id}) の名前が空です',
          );

          // 説明が空でないことを確認
          expect(
            character.description,
            isNotEmpty,
            reason: 'キャラクター "${character.name}" (ID: ${character.id}) の説明が空です',
          );
        }
      });
    });
  });
}
