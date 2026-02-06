import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'race_game.dart';
import 'sample_config.dart';

class HorseRaceScreen extends StatefulWidget {
  const HorseRaceScreen({super.key});

  @override
  State<HorseRaceScreen> createState() => _HorseRaceScreenState();
}

class _HorseRaceScreenState extends State<HorseRaceScreen> {
  HorseRaceGame? _game;

  @override
  void initState() {
    super.initState();
    final cfg = SampleConfigs.tokyo6Horses();
    _game = HorseRaceGame(config: cfg);
  }

  @override
  Widget build(BuildContext context) {
    final game = _game!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horse Race (Dev)'),
        actions: [
          TextButton(
            onPressed: () => game.resetRace(),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GameWidget(game: game),
    );
  }
}
