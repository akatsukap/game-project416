import 'package:flutter/material.dart' show Color;

import 'ball.dart';
import 'head_ball_game.dart';
import 'player_character.dart';
import 'special_ability.dart';

/// 時間停止特殊能力
///
/// 一定時間、相手プレイヤーとボールの動きを停止させます。
/// 要件: 5.1
class TimeStopAbility extends SpecialAbility {
  /// 時間停止の持続時間（秒）
  static const double duration = 2.0;

  /// 時間停止効果が有効かどうか
  bool _isActive = false;

  /// 時間停止効果の残り時間
  double _remainingDuration = 0.0;

  /// 停止された相手プレイヤーへの参照
  PlayerCharacter? _stoppedPlayer;

  /// 停止されたボールへの参照
  Ball? _stoppedBall;

  /// 相手プレイヤーの元の速度
  double? _originalPlayerSpeed;

  /// ボールの元の速度
  // Vector2? _originalBallVelocity;

  /// コンストラクタ
  TimeStopAbility()
    : super(
        name: '時間停止',
        cooldownDuration: 15.0, // 15秒のクールダウン
      );

  @override
  void activate(PlayerCharacter player, HeadBallGame game) {
    if (!isReady || _isActive) return;

    // 相手プレイヤーを見つける
    final opponent = _findOpponent(player, game);
    if (opponent == null) return;

    // ボールを見つける
    final ball = _findBall(game);
    if (ball == null) return;

    // 相手プレイヤーの速度を保存して停止
    _stoppedPlayer = opponent;
    _originalPlayerSpeed = opponent.speed;
    opponent.speed = 0.0;

    // ボールの速度を保存して停止
    _stoppedBall = ball;
    // _originalBallVelocity = ball.body.linearVelocity.clone();
    ball.body.linearVelocity.setZero();

    // 時間停止効果を有効化
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

    // 時間停止効果の持続時間を更新
    if (_isActive) {
      _remainingDuration -= dt;

      // 停止中は相手プレイヤーとボールの速度を0に保つ
      if (_stoppedPlayer != null) {
        _stoppedPlayer!.body.linearVelocity.setZero();
      }
      if (_stoppedBall != null) {
        _stoppedBall!.body.linearVelocity.setZero();
      }

      // 持続時間が終了したら効果を解除
      if (_remainingDuration <= 0) {
        _deactivate();
      }
    }
  }

  /// 時間停止効果を解除する
  void _deactivate() {
    // 相手プレイヤーの速度を復元
    if (_stoppedPlayer != null && _originalPlayerSpeed != null) {
      _stoppedPlayer!.speed = _originalPlayerSpeed!;
    }

    // ボールの速度は復元しない（停止したまま）
    // これにより、時間停止中にボールが動かなくなる

    // 参照をクリア
    _stoppedPlayer = null;
    _stoppedBall = null;
    _originalPlayerSpeed = null;
    // _originalBallVelocity = null;

    _isActive = false;
    _remainingDuration = 0.0;
  }

  /// 相手プレイヤーを見つける
  ///
  /// [player] 特殊能力を使用するプレイヤー
  /// [game] ゲームインスタンス
  ///
  /// 戻り値: 相手プレイヤー、見つからない場合はnull
  PlayerCharacter? _findOpponent(PlayerCharacter player, HeadBallGame game) {
    // ゲームから相手プレイヤーを取得
    // player1とplayer2のどちらかを返す
    if (game.player1 == player) {
      return game.player2;
    } else if (game.player2 == player) {
      return game.player1;
    }
    return null;
  }

  /// ボールを見つける
  ///
  /// [game] ゲームインスタンス
  ///
  /// 戻り値: ボール、見つからない場合はnull
  Ball? _findBall(HeadBallGame game) {
    return game.ball;
  }

  /// 時間停止効果を強制的に解除する
  ///
  /// この関数は、試合がリセットされる前に呼び出す必要があります。
  void forceDeactivate() {
    if (_isActive) {
      _deactivate();
    }
  }

  /// 時間停止効果が有効かどうか
  bool get isActive => _isActive;

  /// 時間停止効果の残り時間
  double get remainingDuration => _remainingDuration;

  @override
  Color getEffectColor() => const Color(0xFF9B59B6); // 紫色

  @override
  String getEffectType() => 'time_stop';
}
