import 'package:flutter/material.dart';

/// ゲームHUD（ヘッドアップディスプレイ）
///
/// スコアと残り時間を画面上部に表示するウィジェット
class GameHUD extends StatelessWidget {
  /// プレイヤー1のスコア
  final int player1Score;

  /// プレイヤー2のスコア
  final int player2Score;

  /// 残り時間（秒）
  final double remainingTime;

  /// 一時停止ボタンが押されたときのコールバック
  final VoidCallback? onPausePressed;

  const GameHUD({
    super.key,
    required this.player1Score,
    required this.player2Score,
    required this.remainingTime,
    this.onPausePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // スコア表示
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: ScoreDisplay(
            player1Score: player1Score,
            player2Score: player2Score,
          ),
        ),
        // タイマー表示
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: TimerDisplay(remainingTime: remainingTime),
        ),
        // 一時停止ボタン
        if (onPausePressed != null)
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.pause, color: Colors.white, size: 32),
              onPressed: onPausePressed,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
      ],
    );
  }
}

/// スコア表示ウィジェット
class ScoreDisplay extends StatelessWidget {
  /// プレイヤー1のスコア
  final int player1Score;

  /// プレイヤー2のスコア
  final int player2Score;

  const ScoreDisplay({
    super.key,
    required this.player1Score,
    required this.player2Score,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // プレイヤー1のスコア
            _buildPlayerScore(
              playerNumber: 1,
              score: player1Score,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            // 区切り
            Text(
              ':',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // プレイヤー2のスコア
            _buildPlayerScore(
              playerNumber: 2,
              score: player2Score,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// プレイヤーのスコア表示を構築
  Widget _buildPlayerScore({
    required int playerNumber,
    required int score,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // プレイヤー番号
        Text(
          'P$playerNumber',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // スコア
        Text(
          '$score',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: color.withOpacity(0.8),
                offset: const Offset(0, 0),
                blurRadius: 8,
              ),
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// タイマー表示ウィジェット
class TimerDisplay extends StatelessWidget {
  /// 残り時間（秒）
  final double remainingTime;

  const TimerDisplay({super.key, required this.remainingTime});

  @override
  Widget build(BuildContext context) {
    // 分と秒に変換
    final minutes = (remainingTime / 60).floor();
    final seconds = (remainingTime % 60).floor();

    // 時間が少なくなったら色を変える
    final isLowTime = remainingTime <= 10;
    final timerColor = isLowTime ? Colors.red : Colors.white;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLowTime
                ? Colors.red.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 時計アイコン
            Icon(Icons.timer, color: timerColor, size: 20),
            const SizedBox(width: 8),
            // 時間表示
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: timerColor,
                fontFeatures: const [
                  FontFeature.tabularFigures(), // 等幅数字
                ],
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
