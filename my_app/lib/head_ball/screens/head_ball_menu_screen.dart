import 'package:flutter/material.dart';

/// ヘッドボールサッカーゲームのメインメニュー画面
///
/// ローカル対戦、統計表示、設定などのメニューを提供します。
/// 要件: 8.1
class HeadBallMenuScreen extends StatelessWidget {
  const HeadBallMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
              Colors.teal.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // 左側：タイトルとアイコン
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ゲームアイコン
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sports_soccer,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ゲームタイトル
                      Text(
                        'ヘッドボール',
                        style: TextStyle(
                          fontSize: 40,
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
                      const SizedBox(height: 8),
                      Text(
                        'Head Ball Soccer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 右側：メニューボタン
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMenuButton(
                        context: context,
                        label: 'ローカル対戦',
                        icon: Icons.people,
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/head-ball-local-match',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context: context,
                        label: '統計',
                        icon: Icons.bar_chart,
                        color: Colors.orange,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('統計機能は準備中です')),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context: context,
                        label: '設定',
                        icon: Icons.settings,
                        color: Colors.purple,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('設定機能は準備中です')),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // ホームに戻るボタン
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.home, color: Colors.white),
                        label: const Text(
                          'ホームに戻る',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
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

  /// メニューボタンを構築
  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
