import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'horse_component.dart';
import 'race_director.dart';
import 'sample_config.dart';
import 'track_component.dart';

class HorseRaceGame extends FlameGame {
  HorseRaceGame({required this.config});

  final RaceConfig config;

  late final TrackComponent _track;
  final List<HorseComponent> _horses = [];
  RaceDirector? _director;

  @override
  Color backgroundColor() => const Color(0xFF1B5E20);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _track = TrackComponent(course: config.course);
    add(_track);

    for (final spec in config.horses) {
      final hc = HorseComponent(spec: spec);
      _horses.add(hc);
      add(hc);
    }

    _director = RaceDirector(config: config, track: _track, horses: _horses);
    _director!.initPositions();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _director?.update(dt);
  }

  void resetRace() {
    _director?.initPositions();
  }
}
