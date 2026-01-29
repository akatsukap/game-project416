import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;

import 'ability_effect.dart';
import 'head_ball_game.dart';
import 'player_character.dart';

/// 特殊能力の抽象基底クラス
///
/// すべての特殊能力はこのクラスを継承して実装します。
/// 要件: 5.1, 5.2, 5.3
abstract class SpecialAbility {
  /// 特殊能力の名前
  final String name;

  /// クールダウン時間（秒）
  final double cooldownDuration;

  /// 現在のクールダウン残り時間（秒）
  double currentCooldown;

  /// コンストラクタ
  ///
  /// [name] 特殊能力の名前
  /// [cooldownDuration] クールダウン時間（秒）
  SpecialAbility({required this.name, required this.cooldownDuration})
    : currentCooldown = 0.0;

  /// 特殊能力が使用可能かどうか
  ///
  /// クールダウンが終了している場合にtrueを返します。
  bool get isReady => currentCooldown <= 0;

  /// 特殊能力を発動する
  ///
  /// [player] 特殊能力を使用するプレイヤー
  /// [game] ゲームインスタンス
  ///
  /// サブクラスで具体的な効果を実装します。
  void activate(PlayerCharacter player, HeadBallGame game);

  /// クールダウンを更新する
  ///
  /// [dt] 前フレームからの経過時間（秒）
  ///
  /// 毎フレーム呼び出され、クールダウン時間を減少させます。
  void update(double dt) {
    if (currentCooldown > 0) {
      currentCooldown -= dt;
      if (currentCooldown < 0) {
        currentCooldown = 0;
      }
    }
  }

  /// クールダウンを開始する
  ///
  /// 特殊能力発動後に呼び出され、クールダウンタイマーをリセットします。
  void startCooldown() {
    currentCooldown = cooldownDuration;
  }

  /// クールダウンの進行度を取得する（0.0〜1.0）
  ///
  /// 0.0 = クールダウン完了、1.0 = クールダウン開始直後
  double get cooldownProgress {
    if (cooldownDuration <= 0) return 0.0;
    return (currentCooldown / cooldownDuration).clamp(0.0, 1.0);
  }

  /// エフェクトの色を取得する
  ///
  /// サブクラスでオーバーライドして、特殊能力ごとの色を返します。
  Color getEffectColor();

  /// エフェクトの種類を取得する
  ///
  /// サブクラスでオーバーライドして、エフェクトの種類を返します。
  String getEffectType();

  /// 視覚エフェクトを生成する
  ///
  /// [position] エフェクトの表示位置
  /// [game] ゲームインスタンス
  ///
  /// 特殊能力発動時に視覚エフェクトを生成してゲームに追加します。
  void spawnEffect(Vector2 position, HeadBallGame game) {
    // エフェクトを生成
    final effect = AbilityEffect(
      effectType: getEffectType(),
      position: position,
      duration: 1.0, // 1秒間表示
      color: getEffectColor(),
    );

    // ゲームにエフェクトを追加
    game.add(effect);

    // パーティクルエフェクトも追加
    final particleEffect = ParticleEffect(
      position: position,
      particleCount: 20,
      duration: 1.0,
      color: getEffectColor(),
    );

    game.add(particleEffect);
  }
}
