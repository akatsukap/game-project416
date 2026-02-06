import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'horse_component.dart';
import 'sample_config.dart';

class HorseRaceGame extends FlameGame {
  final RaceConfig config;
  final Color bgColor;

  HorseRaceGame({
    required this.config,
    this.bgColor = const Color(0xFF0B1020),
  });

  final List<HorseComponent> _horses = [];

  @override
  Color backgroundColor() => bgColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // とりあえず配置して「動く土台」を確認する
    double x = 40;
    for (final h in config.horses) {
      final c = HorseComponent(spec: h)
        ..size = Vector2(36, 24)
        ..position = Vector2(x, size.y / 2);
      _horses.add(c);
      add(c);
      x += 48;
    }
  }
}
