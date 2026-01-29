/// キャラクターの特殊能力タイプを表す列挙型
enum SpecialAbilityType {
  /// スピードブースト - 一定時間移動速度が上昇
  speedBoost,

  /// パワーキック - 次のキックの威力が大幅に上昇
  powerKick,

  /// 時間停止 - 相手プレイヤーとボールの動きを一時停止
  timeStop,

  /// ジャンプブースト - 一定時間ジャンプ力が上昇
  jumpBoost,

  /// シールド - 一定時間ボールの影響を受けない
  shield,
}

/// キャラクターのデータモデル
///
/// 各キャラクターの基本情報、能力値、特殊能力を定義します。
class CharacterData {
  /// キャラクターの一意なID
  final String id;

  /// キャラクターの名前
  final String name;

  /// キャラクタースプライトのパス
  final String spritePath;

  /// 移動速度（ピクセル/秒）
  final double speed;

  /// ジャンプ力（初速度）
  final double jumpPower;

  /// キック力（ボールに加える力）
  final double kickPower;

  /// 特殊能力のタイプ
  final SpecialAbilityType specialAbilityType;

  /// キャラクターの説明
  final String description;

  /// コンストラクタ
  const CharacterData({
    required this.id,
    required this.name,
    required this.spritePath,
    required this.speed,
    required this.jumpPower,
    required this.kickPower,
    required this.specialAbilityType,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CharacterData &&
        other.id == id &&
        other.name == name &&
        other.spritePath == spritePath &&
        other.speed == speed &&
        other.jumpPower == jumpPower &&
        other.kickPower == kickPower &&
        other.specialAbilityType == specialAbilityType &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        spritePath.hashCode ^
        speed.hashCode ^
        jumpPower.hashCode ^
        kickPower.hashCode ^
        specialAbilityType.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'CharacterData(id: $id, name: $name, speed: $speed, jumpPower: $jumpPower, kickPower: $kickPower, specialAbility: $specialAbilityType)';
  }
}
