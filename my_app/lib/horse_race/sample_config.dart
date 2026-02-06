import 'package:flutter/material.dart';

enum GateColor {
  white,
  black,
  red,
  blue,
  yellow,
  green,
  orange,
  pink,
}

extension GateColorExt on GateColor {
  Color toColor() {
    switch (this) {
      case GateColor.white:
        return Colors.white;
      case GateColor.black:
        return Colors.black;
      case GateColor.red:
        return Colors.red;
      case GateColor.blue:
        return Colors.blue;
      case GateColor.yellow:
        return Colors.yellow;
      case GateColor.green:
        return Colors.green;
      case GateColor.orange:
        return Colors.orange;
      case GateColor.pink:
        return Colors.pink;
    }
  }

  String label() {
    switch (this) {
      case GateColor.white:
        return '白';
      case GateColor.black:
        return '黒';
      case GateColor.red:
        return '赤';
      case GateColor.blue:
        return '青';
      case GateColor.yellow:
        return '黄';
      case GateColor.green:
        return '緑';
      case GateColor.orange:
        return '橙';
      case GateColor.pink:
        return '桃';
    }
  }
}

enum CoatColor {
  bay,
  darkBay,
  brown,
  black,
  chestnut,
  darkChestnut,
  grey,
  white,
}

extension CoatColorExt on CoatColor {
  String label() {
    switch (this) {
      case CoatColor.bay:
        return '鹿毛';
      case CoatColor.darkBay:
        return '黒鹿毛';
      case CoatColor.brown:
        return '青鹿毛';
      case CoatColor.black:
        return '青毛';
      case CoatColor.chestnut:
        return '栗毛';
      case CoatColor.darkChestnut:
        return '栃栗毛';
      case CoatColor.grey:
        return '芦毛';
      case CoatColor.white:
        return '白毛';
    }
  }
}

class HorseSpec {
  final String id;
  final String name;
  final int gateNumber; // 1-8
  final GateColor gateColor;
  final CoatColor coatColor;

  const HorseSpec({
    required this.id,
    required this.name,
    required this.gateNumber,
    required this.gateColor,
    required this.coatColor,
  });
}

enum RaceCourse {
  tokyo,
  nakayama,
  kyoto,
  hanshin,
}

extension RaceCourseExt on RaceCourse {
  String label() {
    switch (this) {
      case RaceCourse.tokyo:
        return '東京';
      case RaceCourse.nakayama:
        return '中山';
      case RaceCourse.kyoto:
        return '京都';
      case RaceCourse.hanshin:
        return '阪神';
    }
  }
}

class RaceConfig {
  final String raceName;
  final RaceCourse course;
  final List<HorseSpec> horses;
  final Map<String, List<List<String>>> predictionBySegment;

  const RaceConfig({
    required this.raceName,
    required this.course,
    required this.horses,
    required this.predictionBySegment,
  });
}

class HorseRaceSampleConfigs {
  static List<RaceConfig> all() {
    const horses = <HorseSpec>[
      HorseSpec(
        id: 'h1',
        name: 'サンプルホース1',
        gateNumber: 1,
        gateColor: GateColor.white,
        coatColor: CoatColor.bay,
      ),
      HorseSpec(
        id: 'h2',
        name: 'サンプルホース2',
        gateNumber: 2,
        gateColor: GateColor.black,
        coatColor: CoatColor.black,
      ),
    ];

    return const [
      RaceConfig(
        raceName: 'サンプルレース',
        course: RaceCourse.tokyo,
        horses: horses,
        predictionBySegment: {
          'スタート': [
            ['h1', 'h2']
          ],
          '直線': [
            ['h2'],
            ['h1']
          ],
        },
      ),
    ];
  }
}
