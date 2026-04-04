import 'dart:math';

import 'package:flutter/material.dart';

class HorseRaceScreen extends StatefulWidget {
  const HorseRaceScreen({super.key});

  @override
  State<HorseRaceScreen> createState() => _HorseRaceScreenState();
}

class _HorseRaceScreenState extends State<HorseRaceScreen> {
  static const int _maxPlayers = 6;
  static const double _goalDistance = 100;

  final Random _random = Random();
  int _playerCount = 4;
  bool _isFinished = false;
  int? _winnerIndex;
  List<double> _positions = List<double>.filled(_maxPlayers, 0);

  void _resetRace() {
    setState(() {
      _positions = List<double>.filled(_maxPlayers, 0);
      _winnerIndex = null;
      _isFinished = false;
    });
  }

  void _advanceHorse(int playerIndex) {
    if (_isFinished || playerIndex >= _playerCount) return;

    setState(() {
      final move = 3 + _random.nextInt(8);
      _positions[playerIndex] = (_positions[playerIndex] + move).clamp(
        0,
        _goalDistance,
      );

      if (_positions[playerIndex] >= _goalDistance) {
        _isFinished = true;
        _winnerIndex = playerIndex;
      }
    });

    if (_isFinished && _winnerIndex != null) {
      _showResultDialog(_winnerIndex!);
    }
  }

  Future<void> _showResultDialog(int winnerIndex) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🏇 レース終了！'),
        content: Text('プレイヤー${winnerIndex + 1} の勝利！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetRace();
            },
            child: const Text('もう一度遊ぶ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ホームへ戻る'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerLane(int playerIndex) {
    final progress = _positions[playerIndex] / _goalDistance;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'プレイヤー${playerIndex + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 16,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.primaries[playerIndex % Colors.primaries.length],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isFinished ? null : () => _advanceHorse(playerIndex),
              icon: const Icon(Icons.touch_app),
              label: const Text('連打でダッシュ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('飲み会競馬ダッシュ'),
        actions: [
          IconButton(
            onPressed: _resetRace,
            icon: const Icon(Icons.refresh),
            tooltip: 'レースをリセット',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '最優先ゲーム: 競馬レース',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('各プレイヤーが自分のボタンを連打し、最初に100%へ到達した人が勝利。'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('参加人数: '),
                        DropdownButton<int>(
                          value: _playerCount,
                          items: List.generate(
                            _maxPlayers - 1,
                            (index) => DropdownMenuItem(
                              value: index + 2,
                              child: Text('${index + 2}人'),
                            ),
                          ),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _playerCount = value;
                              _positions = List<double>.filled(_maxPlayers, 0);
                              _winnerIndex = null;
                              _isFinished = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _playerCount,
                itemBuilder: (context, index) => _buildPlayerLane(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
