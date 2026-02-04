import 'horse_component.dart';
import 'race_director.dart';
import 'track_component.dart';

/// コピペで動かすためのサンプル設定集
class HorseRaceSampleConfigs {
  static List<RaceConfig> all() {
    final tokyo = RaceCourse(
      id: 'tokyo',
      name: '東京競馬場',
      ovalScale: const Vector2(1.85, 1.0),
      segments: const [
        RaceSegment(id: 'start_1c', name: 'スタート〜1角', timeEnd: 0.18, tighten: 2.2),
        RaceSegment(id: 'backstretch', name: '向こう正面', timeEnd: 0.45, tighten: 1.6),
        RaceSegment(id: '3c', name: '3角', timeEnd: 0.62, tighten: 2.4),
        RaceSegment(id: '4c', name: '4角', timeEnd: 0.76, tighten: 2.6),
        RaceSegment(id: 'stretch', name: '直線', timeEnd: 0.98, tighten: 3.2),
      ],
    );

    final nakayama = RaceCourse(
      id: 'nakayama',
      name: '中山競馬場',
      ovalScale: const Vector2(1.55, 1.0),
      segments: const [
        RaceSegment(id: 'start_1c', name: 'スタート〜1角', timeEnd: 0.22, tighten: 2.5),
        RaceSegment(id: 'backstretch', name: '向こう正面', timeEnd: 0.48, tighten: 1.7),
        RaceSegment(id: '3c', name: '3角', timeEnd: 0.67, tighten: 2.8),
        RaceSegment(id: '4c', name: '4角', timeEnd: 0.82, tighten: 2.9),
        RaceSegment(id: 'stretch', name: '直線', timeEnd: 0.98, tighten: 3.0),
      ],
    );

    // 8頭サンプル（枠番/毛色を混ぜる）
    final horses = <HorseSpec>[
      const HorseSpec(id: 'h1', name: 'シロノキセキ', frame: FrameNumber.n1, coat: CoatColor.shiroge, laneBias: -0.15),
      const HorseSpec(id: 'h2', name: 'クロカゲボーイ', frame: FrameNumber.n2, coat: CoatColor.kurokage, laneBias: 0.05),
      const HorseSpec(id: 'h3', name: 'アカノオウドウ', frame: FrameNumber.n3, coat: CoatColor.kaga, laneBias: -0.05),
      const HorseSpec(id: 'h4', name: 'アオゲノツバサ', frame: FrameNumber.n4, coat: CoatColor.aoge, laneBias: 0.18),
      const HorseSpec(id: 'h5', name: 'キイロノハヤテ', frame: FrameNumber.n5, coat: CoatColor.kurige, laneBias: 0.00),
      const HorseSpec(id: 'h6', name: 'ミドリノカゲ', frame: FrameNumber.n6, coat: CoatColor.aokage, laneBias: -0.10),
      const HorseSpec(id: 'h7', name: 'オレンジクラウン', frame: FrameNumber.n7, coat: CoatColor.tochikurige, laneBias: 0.12),
      const HorseSpec(id: 'h8', name: 'ピンクグレイ', frame: FrameNumber.n8, coat: CoatColor.ashige, laneBias: -0.02),
    ];

    // サンプル予想（区間ごとに「前→後ろ」の馬群）
    // グループ = 同じ馬群
    // 例: [[h3,h5,h1],[h7,h2,h6],[h4,h8]] は
    // 先頭集団3頭 / 中団3頭 / 後方2頭
    Map<String, List<List<String>>> predictionA() => {
          'start_1c': [
            ['h3', 'h5', 'h1'],
            ['h7', 'h2', 'h6'],
            ['h4', 'h8'],
          ],
          'backstretch': [
            ['h5', 'h7', 'h3'],
            ['h2', 'h6', 'h1'],
            ['h4', 'h8'],
          ],
          '3c': [
            ['h7', 'h5'],
            ['h3', 'h2', 'h6'],
            ['h1', 'h4', 'h8'],
          ],
          '4c': [
            ['h7', 'h3', 'h5'],
            ['h2', 'h6'],
            ['h1', 'h4', 'h8'],
          ],
          'stretch': [
            ['h7'],
            ['h3', 'h5'],
            ['h2', 'h6', 'h1'],
            ['h4', 'h8'],
          ],
        };

    Map<String, List<List<String>>> predictionB() => {
          'start_1c': [
            ['h2', 'h4', 'h7'],
            ['h6', 'h3', 'h5'],
            ['h1', 'h8'],
          ],
          'backstretch': [
            ['h4', 'h7'],
            ['h2', 'h6', 'h3'],
            ['h5', 'h1', 'h8'],
          ],
          '3c': [
            ['h7', 'h4', 'h2'],
            ['h3', 'h6'],
            ['h5', 'h1', 'h8'],
          ],
          '4c': [
            ['h7'],
            ['h4', 'h2', 'h3'],
            ['h6', 'h5'],
            ['h1', 'h8'],
          ],
          'stretch': [
            ['h7', 'h4'],
            ['h2', 'h3', 'h6'],
            ['h5', 'h1'],
            ['h8'],
          ],
        };

    return [
      RaceConfig(
        course: tokyo,
        raceName: '東京サンプルステークス',
        horses: horses,
        predictionBySegment: predictionA(),
      ),
      RaceConfig(
        course: nakayama,
        raceName: '中山サンプルカップ',
        horses: horses,
        predictionBySegment: predictionB(),
      ),
    ];
  }
}
