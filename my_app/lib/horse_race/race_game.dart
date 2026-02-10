import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'horse_component.dart';
import 'models.dart';
import 'race_course.dart';
import 'race_director.dart';
import 'track_component.dart';

class HorseRaceGame extends FlameGame {
  HorseRaceGame({required RaceConfig config}) : _config = config;

  RaceConfig _config;

  late TrackComponent _track;
  final List<HorseComponent> _horses = [];

  RaceDirector? _director;
  bool _loaded = false;

  Phase _phase = Phase.start;
  bool _editMode = true;

  // 編集データの本体（mutable）
  late Map<Phase, PhasePlacement> _placements =
      _clonePlacements(_config.placements);

  @override
  Color backgroundColor() => const Color(0xFF1B5E20);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _buildWorldFromConfig(_config);
    _loaded = true;
  }

  Future<void> _buildWorldFromConfig(RaceConfig cfg) async {
    // 既存を掃除（コース切り替え/再構築用）
    _loaded = false;
    _director = null;
    _horses.clear();
    removeAll(children.toList());// FlameGame の子コンポーネント全削除

    _config = cfg;
    _placements = _clonePlacements(cfg.placements);
    _phase = Phase.start;
    _editMode = true;

    _track = TrackComponent(course: cfg.course);
    add(_track);

    for (final spec in cfg.horses) {
      final hc = HorseComponent(
        spec: spec,
        radius: 20,
        onDraggedEnd: _onHorseDraggedEnd,
      );
      _horses.add(hc);
      add(hc);
    }

    _director = RaceDirector(
      config: cfg,
      track: _track,
      horses: _horses,
      placements: _placements,
      getPhase: () => _phase,
      isEditMode: () => _editMode,
    );

    // Start で「馬番 内→外」の初期整列
    _director!.initPositions();

    _loaded = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final director = _director;
    if (!_loaded || director == null) return;

    // 編集中は動かさない（ドラッグ位置を尊重）
    if (_editMode) return;

    director.update(dt);
  }

  // ---------------------------------------------------------------------------
  // UIから呼ぶ
  // ---------------------------------------------------------------------------

  /// 競馬場を変えた / 馬情報を変えた 等、config自体を差し替えたい時
  Future<void> setConfig(RaceConfig cfg) async {
    await _buildWorldFromConfig(cfg);
  }

  void resetRace() {
    _director?.initPositions();
  }

  void setPhase(Phase p) {
    _phase = p;

    // ★ここが最重要：
    // placements が空なら自動生成（馬番内→外の整列）してから反映する
    _director?.ensureAndApplyPlacementForPhase(p);
  }

  void setEditMode(bool value) {
    _editMode = value;

    // 例：編集モードONにした瞬間、そのPhaseの整列を確実に見せたいなら
    if (_editMode) {
      _director?.ensureAndApplyPlacementForPhase(_phase);
    }
  }

  void copyPrevPhaseIntoCurrent() {
    final prev = _previousPhase(_phase);
    final prevMap = _placements[prev];
    if (prevMap == null || prevMap.isEmpty) return;

    _placements[_phase] = Map<String, TrackCoord>.from(prevMap);

    // 反映（空生成じゃなく、コピーしたものを適用）
    _director?.ensureAndApplyPlacementForPhase(_phase);
  }

  // ---------------------------------------------------------------------------
  // ドラッグ結果を保存
  // ---------------------------------------------------------------------------
  void _onHorseDraggedEnd(String horseId, Vector2 worldPos) {
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

  static Map<Phase, PhasePlacement> _clonePlacements(
    Map<Phase, PhasePlacement> src,
  ) {
    return src.map((k, v) => MapEntry(k, Map<String, TrackCoord>.from(v)));
  }
}
