import 'package:flutter/material.dart' show Color;

import 'head_ball_game.dart';
import 'player_character.dart';
import 'special_ability.dart';

/// シールド特殊能力
///
/// 一定時間、ボールとの衝突時にノックバックを受けなくなる能力です。
/// 要件: 5.1, 5.2
class ShieldAbility extends SpecialAbility {
  /// 効果時間（秒）
  static const double duration = 5.0;

  /// 効果が有効かどうか
  bool _isActive = false;

  /// 残り効果時間
  double _remainingDuration = 0.0;

  /// コンストラクタ
  ShieldAbility() : super(name: 'シールド', cooldownDuration: 20.0);

  @override
  Color getEffectColor() => const Color(0xFF0000FF); // 青色

  @override
  String getEffectType() => 'shield';

  @override
  void activate(PlayerCharacter player, HeadBallGame game) {
    if (!isReady || _isActive) return;

    // 効果を有効化
    _isActive = true;
    _remainingDuration = duration;

    // クールダウンを開始
    startCooldown();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 効果時間を減算
    if (_isActive) {
      _remainingDuration -= dt;

      // 効果時間が終了したら解除
      if (_remainingDuration <= 0) {
        _isActive = false;
      }
    }
  }

  /// 効果を強制的に解除する
  void forceDeactivate() {
    _isActive = false;
    _remainingDuration = 0.0;
  }

  /// 効果が有効かどうか
  bool get isEffectActive => _isActive;

  /// 残り効果時間
  double get remainingEffectDuration => _remainingDuration;
}
