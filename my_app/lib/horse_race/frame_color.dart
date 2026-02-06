import 'package:flutter/material.dart';

/// JRA枠色（1〜8）
class FrameColor {
  static const List<Color> colors = [
    Color(0xFFFFFFFF), // 1 白
    Color(0xFF212121), // 2 黒
    Color(0xFFE53935), // 3 赤
    Color(0xFF1E88E5), // 4 青
    Color(0xFFFDD835), // 5 黄
    Color(0xFF43A047), // 6 緑
    Color(0xFFFF8F00), // 7 橙
    Color(0xFFD81B60), // 8 桃
  ];

  static Color byFrame(int frameNo) => colors[(frameNo - 1).clamp(0, 7)];
}

/// 頭数に応じた枠配分を返す（合計 = horseCount）
List<int> frameSizes(int horseCount) {
  assert(horseCount >= 2 && horseCount <= 18);

  // 2..8 は 1枠1頭で十分（見た目も自然）
  if (horseCount <= 8) {
    final sizes = List<int>.filled(8, 0);
    for (int i = 0; i < horseCount; i++) {
      sizes[i] = 1;
    }
    return sizes;
  }

  // 9..18：できるだけ均等にしつつ、余りは外枠(8→…)に寄せる
  final base = horseCount ~/ 8;
  final rem = horseCount % 8;

  final sizes = List<int>.filled(8, base);
  for (int i = 0; i < rem; i++) {
    sizes[7 - i] += 1;
  }
  return sizes;
}

/// (1..horseCount) の馬番が属する枠番(1..8)を返す
int frameOfHorseNumber({required int horseNumber, required int horseCount}) {
  assert(horseNumber >= 1 && horseNumber <= horseCount);

  final sizes = frameSizes(horseCount);
  int acc = 0;
  for (int f = 0; f < 8; f++) {
    final s = sizes[f];
    if (s == 0) continue;
    if (horseNumber <= acc + s) return f + 1;
    acc += s;
  }
  return 8;
}

/// horseCount のとき、各枠の「馬番レンジ」を返す（UIに便利）
List<(int frameNo, int startNo, int endNo)> frameRanges(int horseCount) {
  final sizes = frameSizes(horseCount);
  int cur = 1;
  final res = <(int, int, int)>[];
  for (int f = 0; f < 8; f++) {
    final s = sizes[f];
    if (s == 0) continue;
    final start = cur;
    final end = cur + s - 1;
    res.add((f + 1, start, end));
    cur = end + 1;
  }
  return res;
}
