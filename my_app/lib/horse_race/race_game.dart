import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'horse_component.dart';
import 'race_director.dart';
import 'track_component.dart';
import 'models.dart';

class HorseRaceGame extends FlameGame {
  HorseRaceGame({required this.config});

  final RaceConfig config;

  late final TrackComponent _track;
  final List<HorseComponent> _horses = [];

  RaceDirector? _director; // ★ nullable にする
  bool _loaded = false;    // ★ ロード完了フラグ

  Phase _phase = Phase.start;
  bool _editMode = true;

  // ここが“編集データの本体”（config.placements は immutable のままでOK）
  late final Map<Phase, PhasePlacement> _placements =
      config.placements.map((k, v) => MapEntry(k, Map<String, TrackCoord>.from(v)));

  @override
  Color backgroundColor() => const Color(0xFF1B5E20);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _track = TrackComponent(course: config.course);
    add(_track);

    for (final spec in config.horses) {
      final hc = HorseComponent(
        spec: spec,
        radius: 20,
        onDraggedEnd: _onHorseDraggedEnd,
      );
      _horses.add(hc);
      add(hc);
    }

    _director = RaceDirector(
      config: config,
      track: _track,
      horses: _horses,
      placements: _placements,
      getPhase: () => _phase,
      isEditMode: () => _editMode,
    );

    _director!.initPositions();
    _loaded = true; // ★ ここでロード完了
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ★ onLoadが終わる前は何もしない（ここが重要）
    final director = _director;
    if (!_loaded || director == null) return;

    if (_editMode) return;

    director.update(dt);
  }

  void resetRace() {
    _director?.initPositions();
  }

  // ---------------------------------------------------------------------------
  // UIから呼ぶ
  // ---------------------------------------------------------------------------

  void setPhase(Phase p) {
    _phase = p;
    _director?.applyPhasePlacement(); // ★ null ガード
  }

  void setEditMode(bool value) {
    _editMode = value;
  }

  void copyPrevPhaseIntoCurrent() {
    final prev = _previousPhase(_phase);
    final prevMap = _placements[prev];
    if (prevMap == null) return;

    _placements[_phase] = Map<String, TrackCoord>.from(prevMap);
    _director?.applyPhasePlacement(); // ★ null ガード
  }

  // ---------------------------------------------------------------------------
  // ドラッグ結果を保存
  // ---------------------------------------------------------------------------
  void _onHorseDraggedEnd(String horseId, Vector2 worldPos) {
    // ★ まだロード途中なら無視
    if (!_loaded) return;
    if (!_editMode) return;

    final coord = _track.coordFromWorld(worldPos);
    final map = _placements.putIfAbsent(_phase, () => <String, TrackCoord>{});
    map[horseId] = coord;
  }

  Phase _previousPhase(Phase p) {
    final list = Phase.values;
    final i = list.indexOf(p);
    return i <= 0 ? list.first : list[i - 1];
  }
}
