import 'character_data.dart';

/// キャラクターレジストリ
///
/// ゲームで使用可能なすべてのキャラクターを管理します。
class CharacterRegistry {
  /// 使用可能なすべてのキャラクターのリスト
  static final List<CharacterData> characters = [
    // キャラクター1: バランス型のヒーロー
    const CharacterData(
      id: 'local_hero_1',
      name: '地元のヒーロー',
      spritePath: 'assets/characters/hero1.png',
      speed: 100.0,
      jumpPower: 300.0,
      kickPower: 500.0,
      specialAbilityType: SpecialAbilityType.speedBoost,
      description: 'スピードに優れたバランス型キャラクター。特殊能力でさらに加速できます。',
    ),

    // キャラクター2: パワー型の商店主
    const CharacterData(
      id: 'shop_owner',
      name: '商店のおやじ',
      spritePath: 'assets/characters/shop_owner.png',
      speed: 80.0,
      jumpPower: 250.0,
      kickPower: 700.0,
      specialAbilityType: SpecialAbilityType.powerKick,
      description: '力強いキックが持ち味。パワーキックで一撃必殺を狙えます。',
    ),

    // キャラクター3: テクニック型の学生
    const CharacterData(
      id: 'student',
      name: '地元の学生',
      spritePath: 'assets/characters/student.png',
      speed: 120.0,
      jumpPower: 280.0,
      kickPower: 450.0,
      specialAbilityType: SpecialAbilityType.timeStop,
      description: '素早い動きが得意。時間停止で相手を翻弄できます。',
    ),

    // キャラクター4: ジャンプ型の消防士
    const CharacterData(
      id: 'firefighter',
      name: '地元の消防士',
      spritePath: 'assets/characters/firefighter.png',
      speed: 90.0,
      jumpPower: 400.0,
      kickPower: 550.0,
      specialAbilityType: SpecialAbilityType.jumpBoost,
      description: '高いジャンプ力を持つ。ジャンプブーストでさらに高く跳べます。',
    ),

    // キャラクター5: 防御型の警備員
    const CharacterData(
      id: 'security_guard',
      name: '地元の警備員',
      spritePath: 'assets/characters/security_guard.png',
      speed: 85.0,
      jumpPower: 270.0,
      kickPower: 480.0,
      specialAbilityType: SpecialAbilityType.shield,
      description: '堅実な守りが得意。シールドでボールの影響を無効化できます。',
    ),
  ];

  /// IDからキャラクターを取得する
  ///
  /// [id] 取得したいキャラクターのID
  /// 戻り値: 該当するCharacterData、見つからない場合はnull
  static CharacterData? getById(String id) {
    try {
      return characters.firstWhere((character) => character.id == id);
    } catch (e) {
      // キャラクターが見つからない場合はログに記録
      print('キャラクターが見つかりません: $id');
      return null;
    }
  }

  /// すべてのキャラクターを取得する
  ///
  /// 戻り値: すべてのキャラクターのリスト
  static List<CharacterData> getAllCharacters() {
    return List.unmodifiable(characters);
  }

  /// キャラクターの総数を取得する
  ///
  /// 戻り値: キャラクターの総数
  static int get characterCount => characters.length;

  /// 指定されたインデックスのキャラクターを取得する
  ///
  /// [index] 取得したいキャラクターのインデックス（0から始まる）
  /// 戻り値: 該当するCharacterData、範囲外の場合はnull
  static CharacterData? getByIndex(int index) {
    try {
      if (index < 0 || index >= characters.length) {
        print('キャラクターインデックスが範囲外です: $index (有効範囲: 0-${characters.length - 1})');
        return null;
      }
      return characters[index];
    } catch (e) {
      // 予期しないエラーをログに記録
      print('キャラクターの取得に失敗しました: インデックス=$index, エラー: $e');
      return null;
    }
  }
}
