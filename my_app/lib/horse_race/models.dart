import 'package:flame/components.dart';

// NOTE:
// 以前は track_component.dart 側に RaceCourse / RaceSegment を置いていたため、ここで
// import 'track_component.dart'; // ← RaceCourse型を使うため（将来は別ファイルへ分離推奨）
// のように参照していました。
// ただし TrackComponent（描画/UI）と Model（データ定義）が絡むと循環参照やビルド崩れの原因になるので、
// 今回は RaceCourse を「純粋なモデル」として race_course.dart に分離しています。
import 'race_course.dart';

// import 'track_component.dart'; // ← 旧：RaceCourse型を使うため（将来は別ファイルへ分離推奨）
// → 推奨：RaceCourse は race_course.dart に分離して参照する（描画とデータの分離）

/// 競馬場ID（拡張前提）
enum TrackId { tokyo /* , kyoto, nakayama ... */ }

/// 馬場状態（拡張前提）
enum TrackCondition { firm, good, yielding, heavy }

/// 毛色（サラブレッド公認の8種）
enum CoatColor {
  bay, // 鹿毛
  darkBay, // 黒鹿毛
  brown, // 青鹿毛（表示名で青鹿毛）
  black, // 青毛
  chestnut, // 栗毛
  darkChestnut, // 栃栗毛
  gray, // 芦毛
  white, // 白毛
}

/// 脚質（UI/AI分析で使う）
enum HorseRunStyle {
  frontRunner, // 逃げ
  stalker, // 先行
  midPack, // 差し
  closer, // 追込
}

extension HorseRunStyleLabel on HorseRunStyle {
  String get label => switch (this) {
        HorseRunStyle.frontRunner => '逃げ',
        HorseRunStyle.stalker => '先行',
        HorseRunStyle.midPack => '差し',
        HorseRunStyle.closer => '追込',
      };
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

  /// 馬番（1..18）: UIでの視認性・枠割表示・並び順のキー
  final int horseNo;

  /// 馬名（正式）
  final String name;

  /// UI表示用の短縮名（空なら name を使う）
  final String shortName;

  final Frame frame;
  final CoatColor coatColor;

  /// 脚質（逃げ/先行/差し/追込）
  final HorseRunStyle runStyle;

  /// 特徴メモ（例：折り合い△、テン速い、末脚など）
  final String memo;

  /// 内外の好み（-1..+1）
  final double laneBias;

  const HorseSpec({
    required this.id,
    required this.horseNo,
    required this.name,
    this.shortName = '',
    required this.frame,
    required this.coatColor,
    this.runStyle = HorseRunStyle.stalker,
    this.memo = '',
    this.laneBias = 0.0,
  });

  /// 表示名（短縮名があれば優先）
  String get displayName => (shortName.trim().isEmpty) ? name : shortName.trim();

  HorseSpec copyWith({
    int? horseNo,
    String? name,
    String? shortName,
    Frame? frame,
    CoatColor? coatColor,
    HorseRunStyle? runStyle,
    String? memo,
    double? laneBias,
  }) {
    return HorseSpec(
      id: id,
      horseNo: horseNo ?? this.horseNo,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      frame: frame ?? this.frame,
      coatColor: coatColor ?? this.coatColor,
      runStyle: runStyle ?? this.runStyle,
      memo: memo ?? this.memo,
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

/// レース構成（ゲーム/再生の元データ）
class RaceConfig {
  final RaceSettings settings;

  // 旧：course は track_component 側の RaceCourse を使う（sample_config が作る）
  // final dynamic course;

  /// ★ dynamicやめる：保守性の要
  /// RaceCourse は描画（TrackComponent）ではなく「コース定義モデル」なので race_course.dart に置く。
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
