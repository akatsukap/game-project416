import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/screens/start_screen.dart';
import 'package:my_app/screens/game_screen.dart';

void main() {
  group('StartScreen', () {
    testWidgets('タイトル「ババ抜き」が表示されること', (WidgetTester tester) async {
      // 要件: 1.1, 1.2
      await tester.pumpWidget(const MaterialApp(home: StartScreen()));

      // タイトルが表示されていることを確認
      expect(find.text('ババ抜き'), findsOneWidget);
    });

    testWidgets('スタートボタンが表示されること', (WidgetTester tester) async {
      // 要件: 1.3
      await tester.pumpWidget(const MaterialApp(home: StartScreen()));

      // スタートボタンが表示されていることを確認
      expect(find.text('スタート'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('スタートボタンをタップするとゲーム画面に遷移すること', (WidgetTester tester) async {
      // 要件: 1.4, 2.1
      await tester.pumpWidget(
        MaterialApp(
          home: const StartScreen(),
          routes: {'/game': (context) => const GameScreen()},
        ),
      );

      // スタートボタンをタップ
      await tester.tap(find.text('スタート'));
      await tester.pumpAndSettle();

      // ゲーム画面に遷移したことを確認
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(StartScreen), findsNothing);
    });
  });
}
