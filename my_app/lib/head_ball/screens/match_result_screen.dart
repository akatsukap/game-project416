import 'package:flutter/material.dart';
import '../../models/match_result.dart';
import '../../models/character_registry.dart';

/// 試合結果画面
///
/// 試合終了後に勝者、スコア、統計を表示する画面
class MatchResultScreen extends StatelessWidget {
  /// 試合結果
  final MatchResult matchResult;

  const MatchResultScreen({super.key, required this.matchResult});

  @override
  Widget build(BuildContext context) {
    // 勝者を判定
    final isDraw = matchResult.winnerId == 0;
    final isPlayer1Win = matchResult.winnerId == 1;

    // 結果に応じた色とメッセージ
    final resultColor = isDraw
        ? Colors.grey
        : (isPlayer1Win ? Colors.blue : Colors.red);
    final resultMessage = isDraw
        ? '引き分け'
        : (isPlayer1Win ? 'プレイヤー1の勝利！' : 'プレイヤー2の勝利！');
    final resultIcon = isDraw
        ? Icons.handshake
        : (isPlayer1Win ? Icons.emoji_events : Icons.emoji_events);

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
        child: SafeArea(
          child: Row(
            children: [
              // 左側：結果アイコンとメッセージ
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                resultIcon,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // 勝敗メッセージ
                      Text(
                        resultMessage,
                        style: TextStyle(
                          fontSize: 32,
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
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // 右側：スコア、統計、ボタン
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // スコア表示
                      _buildScoreDisplay(),
                      const SizedBox(height: 20),
                      // 統計表示
                      _buildStatistics(),
                      const SizedBox(height: 24),
                      // ボタン
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // メニューに戻るボタン
                          Expanded(
                            child: _buildButton(
                              context: context,
                              label: 'メニュー',
                              icon: Icons.home,
                              color: Colors.white.withValues(alpha: 0.9),
                              textColor: resultColor.shade700,
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // リプレイボタン
                          Expanded(
                            child: _buildButton(
                              context: context,
                              label: 'リプレイ',
                              icon: Icons.replay,
                              color: Colors.white,
                              textColor: resultColor.shade700,
                              onPressed: () {
                                // キャラクター選択画面に戻る
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// スコア表示を構築
  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // プレイヤー1
          Expanded(
            child: _buildPlayerScore(
              playerNumber: 1,
              characterId: matchResult.player1CharacterId,
              score: matchResult.player1Score,
              isWinner: matchResult.winnerId == 1,
            ),
          ),
          // 区切り
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '-',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          // プレイヤー2
          Expanded(
            child: _buildPlayerScore(
              playerNumber: 2,
              characterId: matchResult.player2CharacterId,
              score: matchResult.player2Score,
              isWinner: matchResult.winnerId == 2,
            ),
          ),
        ],
      ),
    );
  }

  /// プレイヤーのスコア表示を構築
  Widget _buildPlayerScore({
    required int playerNumber,
    required String characterId,
    required int score,
    required bool isWinner,
  }) {
    final character = CharacterRegistry.getById(characterId);
    final characterName = character?.name ?? '不明';

    return Column(
      children: [
        // プレイヤー番号
        Text(
          'P$playerNumber',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: playerNumber == 1 ? Colors.blue : Colors.red,
          ),
        ),
        const SizedBox(height: 4),
        // キャラクター名
        Text(
          characterName,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // スコア
        Text(
          '$score',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: isWinner ? Colors.yellow.shade700 : Colors.grey.shade700,
          ),
        ),
        // 勝者マーク
        if (isWinner)
          Icon(Icons.emoji_events, color: Colors.yellow.shade700, size: 24),
      ],
    );
  }

  /// 統計表示を構築
  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // タイトル
          Text(
            '試合統計',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          // 試合日時
          _buildStatRow(
            icon: Icons.calendar_today,
            label: '試合日時',
            value: _formatDateTime(matchResult.timestamp),
          ),
          const SizedBox(height: 6),
          // 総得点
          _buildStatRow(
            icon: Icons.sports_soccer,
            label: '総得点',
            value: '${matchResult.player1Score + matchResult.player2Score}',
          ),
        ],
      ),
    );
  }

  /// 統計行を構築
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  /// ボタンを構築
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 20), const SizedBox(width: 6), Text(label)],
      ),
    );
  }

  /// 日時をフォーマット
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
