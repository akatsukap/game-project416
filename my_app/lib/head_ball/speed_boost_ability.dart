import 'package:flutter/material.dart' show Color;

import 'head_ball_game.dart';
import 'player_character.dart';
import 'special_ability.dart';

/// スピードブースト特殊能力
///
/// 一定時間、プレイヤーの移動速度を増加させます。
/// 要件: 5.1
class SpeedBoostAbility extends SpecialAbility {
  /// スピードブーストの倍率
  static const double boostMultiplier = 2.0;

  /// スピードブーストの持続時間（秒）
  static const double duration = 3.0;

  /// ブースト効果が有効かどうか
  bool _isActive = false;

  /// ブースト効果の残り時間
  double _remainingDuration = 0.0;

  /// ブースト前の元の速度
  double? _originalSpeed;

  /// コンストラクタ
  SpeedBoostAbility()
    : super(
        name: 'スピードブースト',
        cooldownDuration: 10.0, // 10秒のクールダウン
      );

  @override
  void activate(PlayerCharacter player, HeadBallGame game) {
    if (!isReady || _isActive) return;

    // 元の速度を保存
    _originalSpeed = player.speed;

    // 速度を増加
    player.speed *= boostMultiplier;

    // ブースト効果を有効化
    _isActive = true;
    _remainingDuration = duration;

    // クールダウンを開始
    startCooldown();

    // 視覚エフェクトを生成
    spawnEffect(player.position, game);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ブースト効果の持続時間を更新
    if (_isActive) {
      _remainingDuration -= dt;

      // 持続時間が終了したら効果を解除
      if (_remainingDuration <= 0) {
        _deactivate();
      }
    }
  }

  /// ブースト効果を解除する
  void _deactivate() {
    _isActive = false;
    _remainingDuration = 0.0;
  }

  /// プレイヤーの速度を元に戻す
  ///
  /// [player] 速度を戻すプレイヤー
  ///
  /// この関数は、プレイヤーが削除される前や、
  /// 試合がリセットされる前に呼び出す必要があります。
  void restoreSpeed(PlayerCharacter player) {
    if (_originalSpeed != null && _isActive) {
      player.speed = _originalSpeed!;
      _deactivate();
    }
  }

  /// ブースト効果が有効かどうか
  bool get isActive => _isActive;

  /// ブースト効果の残り時間
  double get remainingDuration => _remainingDuration;

  @override
  Color getEffectColor() => const Color(0xFF3498DB); // 青色

  @override
  String getEffectType() => 'speed_boost';
}
