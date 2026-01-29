import 'package:flutter/material.dart' show Color;

import 'head_ball_game.dart';
import 'player_character.dart';
import 'special_ability.dart';

/// ジャンプブースト特殊能力
///
/// 一定時間、ジャンプ力を大幅に増加させる能力です。
/// 要件: 5.1, 5.2
class JumpBoostAbility extends SpecialAbility {
  /// ジャンプ力の増加倍率
  static const double jumpBoostMultiplier = 2.0;

  /// 効果時間（秒）
  static const double duration = 5.0;

  /// 元のジャンプ力を保存
  double? _originalJumpPower;

  /// 効果が有効かどうか
  bool _isActive = false;

  /// 残り効果時間
  double _remainingDuration = 0.0;

  /// コンストラクタ
  JumpBoostAbility() : super(name: 'ジャンプブースト', cooldownDuration: 15.0);

  @override
  Color getEffectColor() => const Color(0xFF00FF00); // 緑色

  @override
  String getEffectType() => 'jump_boost';

  @override
  void activate(PlayerCharacter player, HeadBallGame game) {
    if (!isReady || _isActive) return;

    // 元のジャンプ力を保存
    _originalJumpPower = player.jumpPower;

    // ジャンプ力を増加
    player.jumpPower *= jumpBoostMultiplier;

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

      // 効果時間が終了したら元に戻す
      if (_remainingDuration <= 0) {
        _isActive = false;
      }
    }
  }

  /// ジャンプ力を元に戻す
  ///
  /// [player] プレイヤーキャラクター
  void restoreJumpPower(PlayerCharacter player) {
    if (_originalJumpPower != null) {
      player.jumpPower = _originalJumpPower!;
      _originalJumpPower = null;
    }
    _isActive = false;
    _remainingDuration = 0.0;
  }

  /// 効果を強制的に解除する
  ///
  /// [player] プレイヤーキャラクター
  void forceDeactivate(PlayerCharacter player) {
    restoreJumpPower(player);
  }

  /// 効果が有効かどうか
  bool get isEffectActive => _isActive;

  /// 残り効果時間
  double get remainingEffectDuration => _remainingDuration;
}
