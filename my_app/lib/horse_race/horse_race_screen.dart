import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'dev_panel.dart';
import 'race_game.dart';
import 'models.dart';
import 'sample_config.dart';

class HorseRaceScreen extends StatefulWidget {
  const HorseRaceScreen({super.key});

  @override
  State<HorseRaceScreen> createState() => _HorseRaceScreenState();
}

class _HorseRaceScreenState extends State<HorseRaceScreen> {
  late RaceConfig _cfg;
  HorseRaceGame? _game;

  // UIはGameの状態を操作するので、表示用にも保持（Game再生成時に同期）
  Phase _phase = Phase.start;
  bool _editMode = true;

  @override
  void initState() {
    super.initState();
    _cfg = SampleConfigs.tokyo(horseCount: 6);
    _spawnGame(_cfg);
  }

  void _spawnGame(RaceConfig cfg) {
    final g = HorseRaceGame(config: cfg);

    // 初期UI状態
    _phase = Phase.start;
    _editMode = true;

    // Game側状態
    g.setPhase(_phase);
    g.setEditMode(_editMode);

    _game = g;
  }

  void _applyConfig(RaceConfig cfg) {
    setState(() {
      _cfg = cfg;
      _spawnGame(_cfg);
    });
  }

  void _setPhase(Phase p) {
    final g = _game;
    if (g == null) return;
    setState(() => _phase = p);
    g.setPhase(p);
  }

  void _toggleEditMode(bool value) {
    final g = _game;
    if (g == null) return;
    setState(() => _editMode = value);
    g.setEditMode(value);
  }

  void _copyPrevPhase() {
    final g = _game;
    if (g == null) return;
    g.copyPrevPhaseIntoCurrent();
    // 画面側の状態は変わらないので setState 不要（必要なら軽く更新してもOK）
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final game = _game!;
    final key = ValueKey(
      '${_cfg.settings.trackId.name}-${_cfg.horses.length}-${_cfg.settings.distanceM}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text(_cfg.settings.raceName)),
            const SizedBox(width: 8),
            _ModeChip(editMode: _editMode),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: () => game.resetRace(),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ① 基礎設定（頭数など）: RaceConfigを作り直す層
          DevPanel(
            onChanged: _applyConfig,
            initialHorseCount: _cfg.horses.length,
          ),

          // ② Phase 操作 + Edit/Play + Copy
          _PhaseToolbar(
            phase: _phase,
            editMode: _editMode,
            onPhaseChanged: _setPhase,
            onEditModeChanged: _toggleEditMode,
            onCopyPrev: _copyPrevPhase,
          ),

          // ③ Game表示（最下部）
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GameWidget(
                key: key,
                game: game,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.editMode});

  final bool editMode;

  @override
  Widget build(BuildContext context) {
    final color = editMode ? Colors.orange : Colors.lightBlueAccent;
    final text = editMode ? 'EDIT' : 'PLAY';
    final icon = editMode ? Icons.edit : Icons.play_arrow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        border: Border.all(color: color.withOpacity(0.55)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseToolbar extends StatelessWidget {
  const _PhaseToolbar({
    required this.phase,
    required this.editMode,
    required this.onPhaseChanged,
    required this.onEditModeChanged,
    required this.onCopyPrev,
  });

  final Phase phase;
  final bool editMode;
  final ValueChanged<Phase> onPhaseChanged;
  final ValueChanged<bool> onEditModeChanged;
  final VoidCallback onCopyPrev;

  @override
  Widget build(BuildContext context) {
    final phases = Phase.values;

    String labelOf(Phase p) {
      // models.dart側に label があるならそれを使うのが理想
      switch (p) {
        case Phase.start:
          return 'スタート';
        case Phase.firstCorner:
          return '1角';
        case Phase.backStretch:
          return '向正面';
        case Phase.thirdFourthCorner:
          return '3-4角';
        case Phase.homestretch:
          return '直線';
        case Phase.goal:
          return 'ゴール';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 上段：Edit/Play + Copy
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('編集'),
                          icon: Icon(Icons.edit),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('再生'),
                          icon: Icon(Icons.play_arrow),
                        ),
                      ],
                      selected: {editMode},
                      onSelectionChanged: (set) => onEditModeChanged(set.first),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonalIcon(
                    onPressed: editMode ? onCopyPrev : null,
                    icon: const Icon(Icons.copy),
                    label: const Text('前Phaseコピー'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 下段：Phaseタブ
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final p in phases) ...[
                      ChoiceChip(
                        label: Text(labelOf(p)),
                        selected: p == phase,
                        onSelected: (_) => onPhaseChanged(p),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Text(
                editMode
                    ? 'コマをドラッグして配置 → Phaseを切り替えて予想を作っていこう'
                    : '再生モード（今は仮）。次は「Phase間補間」で映像化する',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
