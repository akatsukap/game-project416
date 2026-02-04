import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'horse_component.dart';
import 'race_director.dart';
import 'track_component.dart';

/// 「競馬場」「レース名」「枠番/枠色」「毛色」を選べる“前提”で一旦完成させるためのベースGame
///
/// - ここでは UI はまだ最小（外から RaceConfig を渡せる）
/// - まずは「予想（馬群）→滑らかに隊列変化→映像化」までを完成させる
class HorseRaceGame extends FlameGame {
  HorseRaceGame({
    required this.config,
    this.backgroundColor = const Color(0xFF1B5E20),
  });

  final RaceConfig config;
  final Color backgroundColor;

  late final TrackComponent _track;
  late final RaceDirector _director;
  final List<HorseComponent> _horses = [];

  @override
  Color backgroundColor() => this.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _track = TrackComponent(course: config.course);
    add(_track);

    // 馬コンポーネント生成
    for (final h in config.horses) {
      final c = HorseComponent(spec: h);
      _horses.add(c);
      add(c);
    }

    _director = RaceDirector(
      track: _track,
      horseComponents: _horses,
      config: config,
    );
    add(_director);

    // 初期化
    _director.reset();

    // 画面上部にレース名表示（簡易HUD）
    add(_HudLabel(text: '${config.course.name} / ${config.raceName}'));
  }

  /// 外部UIから「予想更新」→再生し直す等したい場合に使える
  void resetRace() {
    _director.reset();
  }
}

class _HudLabel extends PositionComponent {
  _HudLabel({required this.text});

  final String text;

  final TextPaint _paint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      shadows: [
        Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
      ],
    ),
  );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = Vector2(16, 12);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _paint.render(canvas, text, Vector2.zero());
  }
}
