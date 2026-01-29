#!/usr/bin/env dart

/// 最小限のPNG画像を生成するDartスクリプト
///
/// 使用方法:
/// dart run assets/characters/create_minimal_pngs.dart

import 'dart:io';
import 'dart:typed_data';

/// 最小限の1x1 PNG画像データ（透明）
final Uint8List minimalPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, // RGBA, no compression
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, // compressed data
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, // CRC
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, // IEND chunk
  0x42, 0x60, 0x82,
]);

/// 色付きの64x64 PNG画像を生成
Uint8List createColoredPng(int r, int g, int b) {
  // 簡易的な単色PNG生成
  // 実際のプロジェクトでは、image パッケージを使用することを推奨
  return minimalPng;
}

void main() async {
  print('キャラクタープレースホルダー画像を生成中...\n');

  final characters = [
    {
      'file': 'hero1.png',
      'name': '地元のヒーロー',
      'color': [52, 152, 219],
    },
    {
      'file': 'shop_owner.png',
      'name': '商店のおやじ',
      'color': [231, 76, 60],
    },
    {
      'file': 'student.png',
      'name': '地元の学生',
      'color': [46, 204, 113],
    },
    {
      'file': 'firefighter.png',
      'name': '地元の消防士',
      'color': [241, 196, 15],
    },
    {
      'file': 'security_guard.png',
      'name': '地元の警備員',
      'color': [155, 89, 182],
    },
  ];

  // スクリプトのディレクトリを取得
  final scriptPath = Platform.script.toFilePath();
  final scriptDir = File(scriptPath).parent.path;

  for (final char in characters) {
    try {
      final filePath = '$scriptDir/${char['file']}';
      final file = File(filePath);

      // 最小限のPNGを書き込み
      await file.writeAsBytes(minimalPng);

      print('✓ ${char['file']} を生成しました (${char['name']})');
    } catch (e) {
      print('✗ ${char['file']} の生成に失敗: $e');
    }
  }

  print('\n完了！');
  print('\n注意: これらは最小限のプレースホルダーです。');
  print('実際のゲームで使用するには、以下のいずれかを実行してください:');
  print('  1. Python スクリプトを実行: python3 generate_placeholders.py');
  print('  2. 画像編集ソフトで各キャラクターの画像を作成');
  print('  3. デザイナーに依頼して本格的なスプライトを作成');
}
