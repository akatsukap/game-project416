import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/screens/result_screen.dart';
import 'package:my_app/screens/start_screen.dart';

void main() {
  group('ResultScreen', () {
    testWidgets('プレイヤーが勝った場合、「勝ちました」が表示されること', (WidgetTester tester) async {
      // 要件: 9.1, 9.3
      await tester.pumpWidget(
        const MaterialApp(home: ResultScreen(winner: 'player')),
      );

      // 勝敗メッセージが表示されていることを確認
      expect(find.text('勝ちました！'), findsOneWidget);
    });

    testWidgets('CPUが勝った場合、「負けました」が表示されること', (WidgetTester tester) async {
      // 要件: 9.1, 9.2
      await tester.pumpWidget(
        const MaterialApp(home: ResultScreen(winner: 'cpu')),
      );

      // 勝敗メッセージが表示されていることを確認
      expect(find.text('負けました...'), findsOneWidget);
    });

    testWidgets('「もう一度プレイ」ボタンが表示されること', (WidgetTester tester) async {
      // 要件: 9.4, 10.1
      await tester.pumpWidget(
        const MaterialApp(home: ResultScreen(winner: 'player')),
      );

      // もう一度プレイボタンが表示されていることを確認
      expect(find.text('もう一度プレイ'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('「もう一度プレイ」ボタンをタップするとスタート画面に戻ること', (WidgetTester tester) async {
      // 要件: 10.2
      await tester.pumpWidget(
        MaterialApp(
          home: const StartScreen(),
          routes: {
            '/game': (context) =>
                const Scaffold(body: Center(child: Text('Game Screen'))),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/result') {
              final winner = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => ResultScreen(winner: winner),
              );
            }
            return null;
          },
        ),
      );

      // スタート画面からゲーム画面に遷移
      await tester.tap(find.text('スタート'));
      await tester.pumpAndSettle();

      // ゲーム画面から結果画面に遷移
      final context = tester.element(find.text('Game Screen'));
      Navigator.pushNamed(context, '/result', arguments: 'player');
      await tester.pumpAndSettle();

      // 結果画面が表示されていることを確認
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(find.text('勝ちました！'), findsOneWidget);

      // もう一度プレイボタンをタップ
      await tester.tap(find.text('もう一度プレイ'));
      await tester.pumpAndSettle();

      // スタート画面に戻ったことを確認
      expect(find.byType(StartScreen), findsOneWidget);
      expect(find.byType(ResultScreen), findsNothing);
    });
  });
}
