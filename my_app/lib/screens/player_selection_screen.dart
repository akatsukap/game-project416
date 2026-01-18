import 'package:flutter/material.dart';

/// プレイヤー数選択画面
///
/// 2〜6人のプレイヤー数を選択する画面
class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  int _selectedPlayerCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイヤー数選択'),
        backgroundColor: Colors.green.shade700,
        actions: [
          // ホームボタン
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'ホームに戻る',
            onPressed: () {
              // ゲームホーム画面に戻る
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade300, Colors.green.shade100],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // タイトル
              Text(
                'プレイヤー数を選択',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
              const SizedBox(height: 60),
              // プレイヤー数選択
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // マイナスボタン
                  IconButton(
                    onPressed: _selectedPlayerCount > 2
                        ? () {
                            setState(() {
                              _selectedPlayerCount--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle),
                    iconSize: 48,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 40),
                  // プレイヤー数表示
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$_selectedPlayerCount',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  // プラスボタン
                  IconButton(
                    onPressed: _selectedPlayerCount < 6
                        ? () {
                            setState(() {
                              _selectedPlayerCount++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add_circle),
                    iconSize: 48,
                    color: Colors.green.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 人数表示
              Text(
                '$_selectedPlayerCount人',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 80),
              // スタートボタン
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/multiplayer-game',
                    arguments: _selectedPlayerCount,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ゲーム開始'),
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
