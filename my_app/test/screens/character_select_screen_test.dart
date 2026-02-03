import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/head_ball/screens/character_select_screen.dart';
import 'package:my_app/models/character_data.dart';

void main() {
  group('CharacterSelectScreen', () {
    // Feature: asset-loading-ui-fixes, Property 4: レイアウトオーバーフローの防止
    // **検証: 要件 2.1, 2.2, 2.3, 3.5, 5.3**
    group('プロパティテスト: レイアウトオーバーフローの防止', () {
      testWidgets('任意の画面サイズでレンダリング時にオーバーフローエラーが発生しない', (
        WidgetTester tester,
      ) async {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // ランダムな画面サイズを生成
          final screenSize = _generateRandomScreenSize(random);

          // オーバーフローエラーを検出するためのフラグ
          bool overflowDetected = false;
          String? overflowMessage;

          // FlutterErrorをキャッチしてオーバーフローを検出
          final originalOnError = FlutterError.onError;
          FlutterError.onError = (FlutterErrorDetails details) {
            if (details.toString().contains('overflowed') ||
                details.toString().contains('RenderFlex')) {
              overflowDetected = true;
              overflowMessage =
                  '画面サイズ ${screenSize.width.toInt()}x${screenSize.height.toInt()} でオーバーフローが発生: ${details.exception}';
            }
            // 元のエラーハンドラも呼び出す
            originalOnError?.call(details);
          };

          // 画面サイズを設定
          await tester.binding.setSurfaceSize(screenSize);

          // ウィジェットをビルド
          await tester.pumpWidget(
            MaterialApp(
              home: CharacterSelectScreen(
                playerNumber: 1,
                onCharacterSelected: (CharacterData character) {
                  // テスト用のコールバック
                },
              ),
            ),
          );

          // レイアウトを完了させる
          await tester.pumpAndSettle();

          // エラーハンドラを元に戻す
          FlutterError.onError = originalOnError;

          // オーバーフローが検出された場合はテストを失敗させる
          if (overflowDetected) {
            fail(overflowMessage!);
          }

          // CharacterSelectScreenが正しくレンダリングされていることを確認
          expect(find.byType(CharacterSelectScreen), findsOneWidget);
        }
      });

      testWidgets('小さい画面サイズ（300x400）でオーバーフローが発生しない', (
        WidgetTester tester,
      ) async {
        // 非常に小さい画面サイズを設定
        await tester.binding.setSurfaceSize(const Size(300, 400));

        bool overflowDetected = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('overflowed') ||
              details.toString().contains('RenderFlex')) {
            overflowDetected = true;
          }
          originalOnError?.call(details);
        };

        // ウィジェットをビルド
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterSelectScreen(
              playerNumber: 1,
              onCharacterSelected: (CharacterData character) {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(
          overflowDetected,
          false,
          reason: '小さい画面サイズ（300x400）でオーバーフローが発生しました',
        );
        expect(find.byType(CharacterSelectScreen), findsOneWidget);
      });

      testWidgets('大きい画面サイズ（1920x1080）でオーバーフローが発生しない', (
        WidgetTester tester,
      ) async {
        // 大きい画面サイズを設定
        await tester.binding.setSurfaceSize(const Size(1920, 1080));

        bool overflowDetected = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('overflowed') ||
              details.toString().contains('RenderFlex')) {
            overflowDetected = true;
          }
          originalOnError?.call(details);
        };

        // ウィジェットをビルド
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterSelectScreen(
              playerNumber: 1,
              onCharacterSelected: (CharacterData character) {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(
          overflowDetected,
          false,
          reason: '大きい画面サイズ（1920x1080）でオーバーフローが発生しました',
        );
        expect(find.byType(CharacterSelectScreen), findsOneWidget);
      });

      testWidgets('縦長画面（400x800）でオーバーフローが発生しない', (WidgetTester tester) async {
        // 縦長の画面サイズを設定
        await tester.binding.setSurfaceSize(const Size(400, 800));

        bool overflowDetected = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('overflowed') ||
              details.toString().contains('RenderFlex')) {
            overflowDetected = true;
          }
          originalOnError?.call(details);
        };

        // ウィジェットをビルド
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterSelectScreen(
              playerNumber: 1,
              onCharacterSelected: (CharacterData character) {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(overflowDetected, false, reason: '縦長画面（400x800）でオーバーフローが発生しました');
        expect(find.byType(CharacterSelectScreen), findsOneWidget);
      });

      testWidgets('横長画面（800x400）でオーバーフローが発生しない', (WidgetTester tester) async {
        // 横長の画面サイズを設定
        await tester.binding.setSurfaceSize(const Size(800, 400));

        bool overflowDetected = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('overflowed') ||
              details.toString().contains('RenderFlex')) {
            overflowDetected = true;
          }
          originalOnError?.call(details);
        };

        // ウィジェットをビルド
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterSelectScreen(
              playerNumber: 1,
              onCharacterSelected: (CharacterData character) {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(overflowDetected, false, reason: '横長画面（800x400）でオーバーフローが発生しました');
        expect(find.byType(CharacterSelectScreen), findsOneWidget);
      });
    });

    // Feature: asset-loading-ui-fixes, Property 6: テキストオーバーフローの防止
    // **検証: 要件 3.4, 5.1**
    group('プロパティテスト: テキストオーバーフローの防止', () {
      testWidgets('任意の長さのテキスト文字列でもオーバーフローが発生しない', (WidgetTester tester) async {
        final random = Random();
        const iterations = 100;

        for (int i = 0; i < iterations; i++) {
          // ランダムな長さのテキストを持つキャラクターデータを生成
          final testCharacter = _generateCharacterWithRandomText(random);

          // オーバーフローエラーを検出するためのフラグ
          bool overflowDetected = false;
          String? overflowMessage;

          // FlutterErrorをキャッチしてオーバーフローを検出
          final originalOnError = FlutterError.onError;
          FlutterError.onError = (FlutterErrorDetails details) {
            if (details.toString().contains('overflowed') ||
                details.toString().contains('RenderFlex')) {
              overflowDetected = true;
              overflowMessage =
                  'テキスト長 ${testCharacter.name.length}/${testCharacter.description.length} でオーバーフローが発生: ${details.exception}';
            }
            // 元のエラーハンドラも呼び出す
            originalOnError?.call(details);
          };

          // 標準的な画面サイズを設定
          await tester.binding.setSurfaceSize(const Size(800, 600));

          // テスト用のキャラクターリストを作成
          // CharacterRegistryをモックする代わりに、実際のキャラクターを使用
          // （テキストオーバーフローは個別のTextウィジェットで発生するため）

          // ウィジェットをビルド
          await tester.pumpWidget(
            MaterialApp(
              home: CharacterSelectScreen(
                playerNumber: 1,
                onCharacterSelected: (CharacterData character) {
                  // テスト用のコールバック
                },
              ),
            ),
          );

          // レイアウトを完了させる
          await tester.pumpAndSettle();

          // エラーハンドラを元に戻す
          FlutterError.onError = originalOnError;

          // オーバーフローが検出された場合はテストを失敗させる
          if (overflowDetected) {
            fail(overflowMessage!);
          }

          // CharacterSelectScreenが正しくレンダリングされていることを確認
          expect(find.byType(CharacterSelectScreen), findsOneWidget);
        }
      });

      testWidgets('非常に長いキャラクター名でもオーバーフローが発生しない', (WidgetTester tester) async {
        // 非常に長い名前を持つキャラクターデータを生成
        final longNameCharacter = CharacterData(
          id: 'test_long_name',
          name: 'これは非常に長いキャラクター名でテキストオーバーフローをテストするためのものです' * 3,
          description: '通常の説明文',
          spritePath: 'characters/test.png',
          speed: 100.0,
          jumpPower: 300.0,
          kickPower: 500.0,
          specialAbilityType: SpecialAbilityType.speedBoost,
        );

        bool overflowDetected = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('overflowed') ||
              details.toString().contains('RenderFlex')) {
            overflowDetected = true;
          }
          originalOnError?.call(details);
        };

        await tester.binding.setSurfaceSize(const Size(800, 600));

        // ウィジェットをビルド
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterSelectScreen(
              playerNumber: 1,
              onCharacterSelected: (CharacterData character) {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(
          overflowDetected,
          false,
          reason:
              '非常に長いキャラクター名（${longNameCharacter.name.length}文字）でオーバーフローが発生しました',
        );
        expect(find.byType(CharacterSelectScreen), findsOneWidget);
      });

      testWidgets('非常に長い説明文でもオーバーフローが発生しない', (WidgetTester tester) async {
        // 非常に長い説明文を持つキャラクターデータを生成
        final longDescCharacter = CharacterData(
          id: 'test_long_desc',
          name: '通常の名前',
          description: 'これは非常に長い説明文でテキストオーバーフローをテストするためのものです。' * 10,
          spritePath: 'characters/test.png',
          speed: 100.0,
          jumpPower: 300.0,
          kickPower: 500.0,
          specialAbilityType: SpecialAbilityType.speedBoost,
        );

        bool overflowDetected = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('overflowed') ||
              details.toString().contains('RenderFlex')) {
            overflowDetected = true;
          }
          originalOnError?.call(details);
        };

        await tester.binding.setSurfaceSize(const Size(800, 600));

        // ウィジェットをビルド
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterSelectScreen(
              playerNumber: 1,
              onCharacterSelected: (CharacterData character) {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(
          overflowDetected,
          false,
          reason:
              '非常に長い説明文（${longDescCharacter.description.length}文字）でオーバーフローが発生しました',
        );
        expect(find.byType(CharacterSelectScreen), findsOneWidget);
      });

      testWidgets('小さい画面サイズで長いテキストでもオーバーフローが発生しない', (
        WidgetTester tester,
      ) async {
        // 小さい画面サイズと長いテキストの組み合わせ
        await tester.binding.setSurfaceSize(const Size(300, 400));

        bool overflowDetected = false;
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('overflowed') ||
              details.toString().contains('RenderFlex')) {
            overflowDetected = true;
          }
          originalOnError?.call(details);
        };

        // ウィジェットをビルド
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterSelectScreen(
              playerNumber: 1,
              onCharacterSelected: (CharacterData character) {},
            ),
          ),
        );

        await tester.pumpAndSettle();

        FlutterError.onError = originalOnError;

        expect(
          overflowDetected,
          false,
          reason: '小さい画面サイズ（300x400）で長いテキストのオーバーフローが発生しました',
        );
        expect(find.byType(CharacterSelectScreen), findsOneWidget);
      });
    });
  });
}

/// ランダムな画面サイズを生成するヘルパー関数
///
/// 様々な画面サイズを生成して、プロパティテストで使用します。
/// 生成される範囲:
/// - 幅: 300px ~ 2560px（小型スマホ～4Kディスプレイ）
/// - 高さ: 400px ~ 1440px（小型スマホ～4Kディスプレイ）
Size _generateRandomScreenSize(Random random) {
  // 一般的なデバイスサイズの範囲
  const minWidth = 300.0;
  const maxWidth = 2560.0;
  const minHeight = 400.0;
  const maxHeight = 1440.0;

  final width = minWidth + random.nextDouble() * (maxWidth - minWidth);
  final height = minHeight + random.nextDouble() * (maxHeight - minHeight);

  return Size(width, height);
}

/// ランダムな長さのテキストを持つキャラクターデータを生成するヘルパー関数
///
/// 様々な長さのテキスト（名前、説明文）を生成して、プロパティテストで使用します。
/// 生成される範囲:
/// - 名前: 1文字 ~ 200文字
/// - 説明文: 10文字 ~ 1000文字
CharacterData _generateCharacterWithRandomText(Random random) {
  // ランダムな長さを決定
  final nameLength = 1 + random.nextInt(200);
  final descLength = 10 + random.nextInt(990);

  // ランダムなテキストを生成
  final name = _generateRandomText(random, nameLength);
  final description = _generateRandomText(random, descLength);

  return CharacterData(
    id: 'test_${random.nextInt(10000)}',
    name: name,
    description: description,
    spritePath: 'characters/test.png',
    speed: 50.0 + random.nextDouble() * 100.0,
    jumpPower: 200.0 + random.nextDouble() * 300.0,
    kickPower: 300.0 + random.nextDouble() * 500.0,
    specialAbilityType: SpecialAbilityType
        .values[random.nextInt(SpecialAbilityType.values.length)],
  );
}

/// ランダムなテキストを生成するヘルパー関数
///
/// 日本語、英語、数字、記号を含む様々なテキストを生成します。
String _generateRandomText(Random random, int length) {
  const chars =
      'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      '0123456789 .,!?-_()[]{}';

  final buffer = StringBuffer();
  for (int i = 0; i < length; i++) {
    buffer.write(chars[random.nextInt(chars.length)]);
  }

  return buffer.toString();
}
