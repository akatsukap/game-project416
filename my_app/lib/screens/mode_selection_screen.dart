import 'package:flutter/material.dart';

/// モード選択画面
///
/// シングルプレイとマルチプレイを選択する画面
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          tooltip: 'ホームに戻る',
          onPressed: () {
            Navigator.of(context).pop(); // ゲームホーム画面に戻る
          },
        ),
      ),
      extendBodyBehindAppBar: true,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // カードアイコン
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.style, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 40),
              // ゲームタイトル
              Text(
                'ババ抜き',
                style: TextStyle(
                  fontSize: 56,
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
              const SizedBox(height: 16),
              Text(
                'Old Maid Card Game',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 80),
              // シングルプレイボタン
              _buildModeButton(context, 'シングルプレイ', 'CPUと対戦', Icons.person, () {
                Navigator.pushNamed(context, '/game');
              }),
              const SizedBox(height: 24),
              // マルチプレイボタン
              _buildModeButton(context, 'マルチプレイ', '2〜6人でプレイ', Icons.people, () {
                Navigator.pushNamed(context, '/player-selection');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      child: SizedBox(
        width: 250,
        child: Row(
          children: [
            Icon(icon, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade600,
                    ),
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
