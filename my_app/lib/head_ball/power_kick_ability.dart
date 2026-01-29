import 'package:flutter/material.dart' show Color;

import 'head_ball_game.dart';
import 'player_character.dart';
import 'special_ability.dart';

/// パワーキック特殊能力
///
/// 次のキックの威力を大幅に増加させます。
/// 要件: 5.1
class PowerKickAbility extends SpecialAbility {
  /// パワーキックの倍率
  static const double powerMultiplier = 3.0;

  /// パワーキック効果が有効かどうか
  bool _isActive = false;

  /// パワーキック前の元のキック力
  double? _originalKickPower;

  /// コンストラクタ
  PowerKickAbility()
    : super(
        name: 'パワーキック',
        cooldownDuration: 8.0, // 8秒のクールダウン
      );

  @override
  void activate(PlayerCharacter player, HeadBallGame game) {
    if (!isReady || _isActive) return;

    // 元のキック力を保存
    _originalKickPower = player.kickPower;

    // キック力を増加
    player.kickPower *= powerMultiplier;

    // パワーキック効果を有効化
    _isActive = true;

    // クールダウンを開始
    startCooldown();

    // 視覚エフェクトを生成
    spawnEffect(player.position, game);
  }

  /// 次のキックが実行されたときに呼び出す
  ///
  /// [player] キックを実行したプレイヤー
  ///
  /// パワーキック効果を解除し、キック力を元に戻します。
  void onKickExecuted(PlayerCharacter player) {
    if (_isActive && _originalKickPower != null) {
      // キック力を元に戻す
      player.kickPower = _originalKickPower!;
      _isActive = false;
      _originalKickPower = null;
    }
  }

  /// パワーキック効果を強制的に解除する
  ///
  /// [player] 効果を解除するプレイヤー
  ///
  /// この関数は、プレイヤーが削除される前や、
  /// 試合がリセットされる前に呼び出す必要があります。
  void forceDeactivate(PlayerCharacter player) {
    if (_isActive && _originalKickPower != null) {
      player.kickPower = _originalKickPower!;
      _isActive = false;
      _originalKickPower = null;
    }
  }

  /// パワーキック効果が有効かどうか
  bool get isActive => _isActive;

  @override
  Color getEffectColor() => const Color(0xFFE74C3C); // 赤色

  @override
  String getEffectType() => 'power_kick';
}
