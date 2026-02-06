import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../horse_race/race_game.dart';
import '../horse_race/race_director.dart';
import 'sample_config.dart';

/// ここから「コピペで起動」できる画面の
/// - 競馬場（サンプル2種）とレース名を選べる
/// - GameWidget でレース映像（馬群が滑らかに変化）を再生
class HorseRaceScreen extends StatefulWidget {
  const HorseRaceScreen({super.key});

  @override
  State<HorseRaceScreen> createState() => _HorseRaceScreenState();
}

class _HorseRaceScreenState extends State<HorseRaceScreen> {
  late final List<RaceConfig> _configs;
  int _index = 0;

  final TextEditingController _raceNameController = TextEditingController();

  HorseRaceGame? _game;

  @override
  void initState() {
    super.initState();
    _configs = HorseRaceSampleConfigs.all();
    _raceNameController.text = _configs[_index].raceName;
    _buildGame();
  }

  @override
  void dispose() {
    _raceNameController.dispose();
    super.dispose();
  }

  void _buildGame() {
    final base = _configs[_index];

    // 画面でレース名を編集できるよう、ここで上書き
    final cfg = RaceConfig(
      course: base.course,
      raceName: _raceNameController.text.trim().isEmpty ? base.raceName : _raceNameController.text.trim(),
      horses: base.horses,
      predictionBySegment: base.predictionBySegment,
    );

    _game = HorseRaceGame(config: cfg);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[_index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Horse Race (MVP)'),
        actions: [
          TextButton(
            onPressed: () {
              _game?.resetRace();
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // コントロール（最小）
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text('競馬場:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _index,
                      items: List.generate(_configs.length, (i) {
                        return DropdownMenuItem(
                          value: i,
                          child: Text(_configs[i].course.name),
                        );
                      }),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _index = v;
                          _raceNameController.text = _configs[_index].raceName;
                          _buildGame();
                        });
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _buildGame();
                        });
                      },
                      child: const Text('APPLY'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _raceNameController,
                  decoration: const InputDecoration(
                    labelText: 'レース名（任意）',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) {
                    setState(() {
                      _buildGame();
                    });
                  },
                ),
                const SizedBox(height: 8),
                _LegendCard(courseName: cfg.course.name),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          // レース画面
          Expanded(
            child: _game == null
                ? const Center(child: CircularProgressIndicator())
                : GameWidget(game: _game!),
          ),
        ],
      ),
    );
  }
}

/// 枠色と毛色の“選択肢がある”ことを画面で確認できるようにする最小表示
class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.courseName});

  final String courseName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('コース: $courseName', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _frameChip('1枠', Colors.white, textColor: Colors.black),
                _frameChip('2枠', Colors.black, textColor: Colors.white),
                _frameChip('3枠', const Color(0xFFE53935)),
                _frameChip('4枠', const Color(0xFF1E88E5)),
                _frameChip('5枠', const Color(0xFFFDD835), textColor: Colors.black),
                _frameChip('6枠', const Color(0xFF43A047)),
                _frameChip('7枠', const Color(0xFFFB8C00)),
                _frameChip('8枠', const Color(0xFFEC407A)),
              ],
            ),
            const SizedBox(height: 10),
            const Text('毛色（デフォルメ）: 鹿毛/黒鹿毛/青鹿毛/青毛/栗毛/栃栗毛/芦毛/白毛（サンプルに反映）'),
          ],
        ),
      ),
    );
  }

  static Widget _frameChip(String label, Color bg, {Color? textColor}) {
    final tc = textColor ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x33000000)),
      ),
      child: Text(label, style: TextStyle(color: tc, fontWeight: FontWeight.w700)),
    );
  }
}
