import 'package:flutter/material.dart';

/// 結果画面
///
/// ゲーム終了時に勝敗メッセージを表示し、
/// もう一度プレイボタンでスタート画面に戻る
class ResultScreen extends StatelessWidget {
  final String winner;

  const ResultScreen({super.key, required this.winner});

  @override
  Widget build(BuildContext context) {
    // 勝敗メッセージを決定
    final isPlayerWin = winner == 'player';
    final resultMessage = isPlayerWin ? '勝ちました！' : '負けました...';
    final resultColor = isPlayerWin ? Colors.orange : Colors.blue;
    final resultIcon = isPlayerWin
        ? Icons.emoji_events
        : Icons.sentiment_dissatisfied;
    final resultEmoji = isPlayerWin ? '🎉' : '😢';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              resultColor.shade400,
              resultColor.shade600,
              resultColor.shade800,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 結果アイコン（アニメーション付き）
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(resultIcon, size: 100, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // 絵文字
              Text(resultEmoji, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              // 勝敗メッセージ
              Text(
                resultMessage,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              // ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ホームに戻るボタン
                  ElevatedButton(
                    onPressed: () {
                      // ゲームホーム画面に戻る
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      foregroundColor: resultColor.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home, size: 28),
                        SizedBox(width: 8),
                        Text('ホーム'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // もう一度プレイボタン
                  ElevatedButton(
                    onPressed: () {
                      // ババ抜きのモード選択画面に戻る
                      Navigator.of(context).popUntil(
                        (route) =>
                            route.settings.name == '/babanuki-mode-selection' ||
                            route.isFirst,
                      );
                      if (Navigator.of(context).canPop()) {
                        // すでにモード選択画面にいる場合は何もしない
                      } else {
                        // ゲームホームからの場合は、モード選択画面に遷移
                        Navigator.pushNamed(
                          context,
                          '/babanuki-mode-selection',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: resultColor.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay, size: 28),
                        SizedBox(width: 8),
                        Text('もう一度'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
