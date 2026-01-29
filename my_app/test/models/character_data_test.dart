import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/character_data.dart';
import 'package:my_app/models/character_registry.dart';

void main() {
  group('CharacterData', () {
    test('CharacterDataの初期化が正しく行われる', () {
      const character = CharacterData(
        id: 'test_char',
        name: 'テストキャラクター',
        spritePath: 'assets/test.png',
        speed: 100.0,
        jumpPower: 300.0,
        kickPower: 500.0,
        specialAbilityType: SpecialAbilityType.speedBoost,
        description: 'テスト用キャラクター',
      );

      expect(character.id, 'test_char');
      expect(character.name, 'テストキャラクター');
      expect(character.spritePath, 'assets/test.png');
      expect(character.speed, 100.0);
      expect(character.jumpPower, 300.0);
      expect(character.kickPower, 500.0);
      expect(character.specialAbilityType, SpecialAbilityType.speedBoost);
      expect(character.description, 'テスト用キャラクター');
    });

    test('同じ値を持つCharacterDataは等しい', () {
      const character1 = CharacterData(
        id: 'test_char',
        name: 'テストキャラクター',
        spritePath: 'assets/test.png',
        speed: 100.0,
        jumpPower: 300.0,
        kickPower: 500.0,
        specialAbilityType: SpecialAbilityType.speedBoost,
        description: 'テスト用キャラクター',
      );

      const character2 = CharacterData(
        id: 'test_char',
        name: 'テストキャラクター',
        spritePath: 'assets/test.png',
        speed: 100.0,
        jumpPower: 300.0,
        kickPower: 500.0,
        specialAbilityType: SpecialAbilityType.speedBoost,
        description: 'テスト用キャラクター',
      );

      expect(character1, equals(character2));
      expect(character1.hashCode, equals(character2.hashCode));
    });

    test('異なる値を持つCharacterDataは等しくない', () {
      const character1 = CharacterData(
        id: 'test_char_1',
        name: 'テストキャラクター1',
        spritePath: 'assets/test1.png',
        speed: 100.0,
        jumpPower: 300.0,
        kickPower: 500.0,
        specialAbilityType: SpecialAbilityType.speedBoost,
        description: 'テスト用キャラクター1',
      );

      const character2 = CharacterData(
        id: 'test_char_2',
        name: 'テストキャラクター2',
        spritePath: 'assets/test2.png',
        speed: 120.0,
        jumpPower: 280.0,
        kickPower: 450.0,
        specialAbilityType: SpecialAbilityType.powerKick,
        description: 'テスト用キャラクター2',
      );

      expect(character1, isNot(equals(character2)));
    });

    test('toStringメソッドが正しい文字列を返す', () {
      const character = CharacterData(
        id: 'test_char',
        name: 'テストキャラクター',
        spritePath: 'assets/test.png',
        speed: 100.0,
        jumpPower: 300.0,
        kickPower: 500.0,
        specialAbilityType: SpecialAbilityType.speedBoost,
        description: 'テスト用キャラクター',
      );

      final result = character.toString();
      expect(result, contains('test_char'));
      expect(result, contains('テストキャラクター'));
      expect(result, contains('100.0'));
      expect(result, contains('300.0'));
      expect(result, contains('500.0'));
      expect(result, contains('speedBoost'));
    });
  });

  group('CharacterRegistry', () {
    test('最低5種類のキャラクターが定義されている', () {
      final characters = CharacterRegistry.getAllCharacters();
      expect(characters.length, greaterThanOrEqualTo(5));
    });

    test('すべてのキャラクターが一意なIDを持つ', () {
      final characters = CharacterRegistry.getAllCharacters();
      final ids = characters.map((c) => c.id).toSet();
      expect(ids.length, equals(characters.length));
    });

    test('すべてのキャラクターが一意なスプライトパスを持つ', () {
      final characters = CharacterRegistry.getAllCharacters();
      final spritePaths = characters.map((c) => c.spritePath).toSet();
      expect(spritePaths.length, equals(characters.length));
    });

    test('すべてのキャラクターが一意な特殊能力タイプを持つ', () {
      final characters = CharacterRegistry.getAllCharacters();
      final specialAbilities = characters
          .map((c) => c.specialAbilityType)
          .toSet();
      expect(specialAbilities.length, equals(characters.length));
    });

    test('getByIdで正しいキャラクターを取得できる', () {
      final character = CharacterRegistry.getById('local_hero_1');
      expect(character, isNotNull);
      expect(character!.id, 'local_hero_1');
      expect(character.name, '地元のヒーロー');
    });

    test('存在しないIDでgetByIdを呼ぶとnullを返す', () {
      final character = CharacterRegistry.getById('non_existent_id');
      expect(character, isNull);
    });

    test('getByIndexで正しいキャラクターを取得できる', () {
      final character = CharacterRegistry.getByIndex(0);
      expect(character, isNotNull);
      expect(character!.id, 'local_hero_1');
    });

    test('範囲外のインデックスでgetByIndexを呼ぶとnullを返す', () {
      final character1 = CharacterRegistry.getByIndex(-1);
      expect(character1, isNull);

      final character2 = CharacterRegistry.getByIndex(100);
      expect(character2, isNull);
    });

    test('characterCountが正しい値を返す', () {
      expect(CharacterRegistry.characterCount, greaterThanOrEqualTo(5));
      expect(
        CharacterRegistry.characterCount,
        equals(CharacterRegistry.getAllCharacters().length),
      );
    });

    test('すべてのキャラクターが正の能力値を持つ', () {
      final characters = CharacterRegistry.getAllCharacters();
      for (final character in characters) {
        expect(character.speed, greaterThan(0));
        expect(character.jumpPower, greaterThan(0));
        expect(character.kickPower, greaterThan(0));
      }
    });

    test('すべてのキャラクターが名前と説明を持つ', () {
      final characters = CharacterRegistry.getAllCharacters();
      for (final character in characters) {
        expect(character.name.isNotEmpty, isTrue);
        expect(character.description.isNotEmpty, isTrue);
      }
    });
  });

  group('SpecialAbilityType', () {
    test('すべての特殊能力タイプが定義されている', () {
      expect(SpecialAbilityType.values.length, greaterThanOrEqualTo(5));
      expect(
        SpecialAbilityType.values,
        contains(SpecialAbilityType.speedBoost),
      );
      expect(SpecialAbilityType.values, contains(SpecialAbilityType.powerKick));
      expect(SpecialAbilityType.values, contains(SpecialAbilityType.timeStop));
      expect(SpecialAbilityType.values, contains(SpecialAbilityType.jumpBoost));
      expect(SpecialAbilityType.values, contains(SpecialAbilityType.shield));
    });
  });
}
