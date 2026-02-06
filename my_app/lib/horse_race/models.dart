import 'package:flame/components.dart';

/// 競馬場ID（拡張前提）
enum TrackId { tokyo /* , kyoto, nakayama ... */ }

/// 馬場状態（拡張前提）
enum TrackCondition { firm, good, yielding, heavy }

/// 毛色（サラブレッド公認の8種）
enum CoatColor {
  bay, // 鹿毛
  darkBay, // 黒鹿毛
  brown, // 青鹿毛（表示名で青鹿毛にする）
  black, // 青毛
  chestnut, // 栗毛
  darkChestnut, // 栃栗毛
  gray, // 芦毛
  white, // 白毛
}

enum Phase {
  start,
  firstCorner,
  backStretch,
  thirdFourthCorner,
  homestretch,
  goal,
}

extension PhaseLabel on Phase {
  String get label => switch (this) {
        Phase.start => 'スタート',
        Phase.firstCorner => '1角',
        Phase.backStretch => '向正面',
        Phase.thirdFourthCorner => '3-4角',
        Phase.homestretch => '直線',
        Phase.goal => 'ゴール',
      };
}

extension TrackConditionLabel on TrackCondition {
  String get label => switch (this) {
        TrackCondition.firm => '良',
        TrackCondition.good => '稍重',
        TrackCondition.yielding => '重',
        TrackCondition.heavy => '不良',
      };
}

extension CoatColorLabel on CoatColor {
  String get label => switch (this) {
        CoatColor.bay => '鹿毛',
        CoatColor.darkBay => '黒鹿毛',
        CoatColor.brown => '青鹿毛',
        CoatColor.black => '青毛',
        CoatColor.chestnut => '栗毛',
        CoatColor.darkChestnut => '栃栗毛',
        CoatColor.gray => '芦毛',
        CoatColor.white => '白毛',
      };
}

/// レース設定（UIで編集される）
class RaceSettings {
  final String raceName;
  final TrackId trackId;
  final int distanceM; // 1000..3600
  final TrackCondition condition;

  const RaceSettings({
    required this.raceName,
    required this.trackId,
    required this.distanceM,
    required this.condition,
  });

  RaceSettings copyWith({
    String? raceName,
    TrackId? trackId,
    int? distanceM,
    TrackCondition? condition,
  }) {
    return RaceSettings(
      raceName: raceName ?? this.raceName,
      trackId: trackId ?? this.trackId,
      distanceM: distanceM ?? this.distanceM,
      condition: condition ?? this.condition,
    );
  }
}

/// 枠
class Frame {
  final int number; // 1..8
  const Frame(this.number);
}

/// 馬の素性（設定画面で編集される）
class HorseSpec {
  final String id;
  final String name;
  final Frame frame;
  final CoatColor coatColor;

  /// 内外の好み（-1..+1）
  final double laneBias;

  const HorseSpec({
    required this.id,
    required this.name,
    required this.frame,
    required this.coatColor,
    this.laneBias = 0.0,
  });

  HorseSpec copyWith({
    String? name,
    Frame? frame,
    CoatColor? coatColor,
    double? laneBias,
  }) {
    return HorseSpec(
      id: id,
      name: name ?? this.name,
      frame: frame ?? this.frame,
      coatColor: coatColor ?? this.coatColor,
      laneBias: laneBias ?? this.laneBias,
    );
  }
}

/// トラック上の座標（周回位置 s と lane）
class TrackCoord {
  final double s; // 0..1
  final double lane; // -1..+1
  const TrackCoord({required this.s, required this.lane});

  TrackCoord copyWith({double? s, double? lane}) =>
      TrackCoord(s: s ?? this.s, lane: lane ?? this.lane);
}

/// Phaseごとの配置（horseId -> TrackCoord）
typedef PhasePlacement = Map<String, TrackCoord>;

/// レース区間（セグメント）
class RaceSegment {
  final String id;
  final String name;
  final double timeEnd; // 0.0..1.0
  final double tighten; // 馬群の“収束しやすさ”

  const RaceSegment({
    required this.id,
    required this.name,
    required this.timeEnd,
    this.tighten = 2.0,
  });
}

/// 競馬場（コース）設定
class RaceCourse {
  final String id;
  final String name;
  final List<RaceSegment> segments;

  /// 例: (1.6, 1.0) なら横長
  final Vector2 ovalScale;

  RaceCourse({
    required this.id,
    required this.name,
    required this.segments,
    Vector2? ovalScale,
  }) : ovalScale = ovalScale ?? Vector2(1.6, 1.0);
}

/// レース構成（ゲーム/再生の元データ）
class RaceConfig {
  final RaceSettings settings;
  final RaceCourse course;
  final List<HorseSpec> horses;

  /// Phase別の配置（編集で増える）
  final Map<Phase, PhasePlacement> placements;

  const RaceConfig({
    required this.settings,
    required this.course,
    required this.horses,
    this.placements = const {},
  });

  RaceConfig copyWith({
    RaceSettings? settings,
    RaceCourse? course,
    List<HorseSpec>? horses,
    Map<Phase, PhasePlacement>? placements,
  }) {
    return RaceConfig(
      settings: settings ?? this.settings,
      course: course ?? this.course,
      horses: horses ?? this.horses,
      placements: placements ?? this.placements,
    );
  }
}
