import 'package:flutter/material.dart';

import 'frame_color.dart';
import 'models.dart';
import 'sample_config.dart';

class DevPanel extends StatefulWidget {
  const DevPanel({
    super.key,
    required this.onChanged,
    this.initialHorseCount = 6,
  });

  final void Function(RaceConfig cfg) onChanged;
  final int initialHorseCount;

  @override
  State<DevPanel> createState() => _DevPanelState();
}

class _DevPanelState extends State<DevPanel> {
  late int _horseCount;

  TrackId _trackId = TrackId.tokyo;
  TrackCondition _condition = TrackCondition.firm;

  final _raceNameCtrl = TextEditingController(text: 'Horse Race (Dev)');
  final _distanceCtrl = TextEditingController(text: '2000');

  @override
  void initState() {
    super.initState();
    _horseCount = widget.initialHorseCount;
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    _raceNameCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  int _distanceValue() {
    final v = int.tryParse(_distanceCtrl.text.trim()) ?? 2000;
    return v.clamp(1000, 3600);
  }

  void _emit() {
    final settings = RaceSettings(
      raceName: _raceNameCtrl.text.trim().isEmpty ? 'Horse Race' : _raceNameCtrl.text.trim(),
      trackId: _trackId,
      distanceM: _distanceValue(),
      condition: _condition,
    );

    final cfg = SampleConfigs.build(settings: settings, horseCount: _horseCount);
    widget.onChanged(cfg);
  }

  @override
  Widget build(BuildContext context) {
    final ranges = frameRanges(_horseCount);

    return Material(
      color: const Color(0xFFF7F7F7),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('レース設定', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _raceNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'レース名',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _distanceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '距離(m)',
                      border: OutlineInputBorder(),
                      isDense: true,
                      helperText: '1000〜3600',
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<TrackId>(
                    value: _trackId,
                    items: TrackId.values
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: '競馬場',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _trackId = v);
                      _emit();
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<TrackCondition>(
                    value: _condition,
                    items: TrackCondition.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: '馬場',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _condition = v);
                      _emit();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Text('出走頭数', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    min: 2,
                    max: 18,
                    divisions: 16,
                    value: _horseCount.toDouble(),
                    label: '$_horseCount',
                    onChanged: (v) {
                      setState(() => _horseCount = v.round());
                      _emit();
                    },
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text('$_horseCount', textAlign: TextAlign.right),
                ),
              ],
            ),

            const SizedBox(height: 6),
            const Text('枠割りプレビュー（JRA色）', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in ranges)
                  _FrameChip(frameNo: r.$1, startNo: r.$2, endNo: r.$3),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FrameChip extends StatelessWidget {
  const _FrameChip({
    required this.frameNo,
    required this.startNo,
    required this.endNo,
  });

  final int frameNo;
  final int startNo;
  final int endNo;

  @override
  Widget build(BuildContext context) {
    final c = FrameColor.byFrame(frameNo);
    final textColor = frameNo == 2 ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        '枠$frameNo：$startNo-${endNo}',
        style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
      ),
    );
  }
}
