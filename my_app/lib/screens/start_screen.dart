import 'package:flutter/material.dart';

/// スタート画面
///
/// ゲームタイトルとスタートボタンを表示し、
/// ボタンタップでゲーム画面に遷移する
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

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
                child: Icon(Icons.style, size: 80, color: Colors.white),
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
              // スタートボタン
              ElevatedButton(
                onPressed: () {
                  // ゲーム画面に遷移
                  Navigator.pushNamed(context, '/game');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('スタート'),
                    SizedBox(width: 12),
                    Icon(Icons.play_arrow, size: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
