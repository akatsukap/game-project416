import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/screens/game_screen.dart';
import 'package:my_app/widgets/card_widget.dart';

void main() {
  group('GameScreen Widget Tests', () {
    testWidgets('ゲーム画面が正しく表示される', (WidgetTester tester) async {
      // ゲーム画面を構築
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      // アプリバーのタイトルを確認
      expect(find.text('ババ抜き'), findsOneWidget);

      // ターン表示を確認
      expect(find.text('あなたのターン'), findsOneWidget);

      // プレイヤーとCPUのラベルを確認
      expect(find.text('あなた'), findsOneWidget);
      expect(find.text('CPU'), findsOneWidget);

      // カード枚数の表示を確認（正規表現で「X枚」の形式を検索）
      expect(find.textContaining('枚'), findsAtLeastNWidgets(2));
    });

    testWidgets('プレイヤーの手札が表向きで表示される', (WidgetTester tester) async {
      // ゲーム画面を構築
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      await tester.pumpAndSettle();

      // CardWidgetが存在することを確認
      expect(find.byType(CardWidget), findsWidgets);

      // プレイヤーの手札エリアにCardWidgetが存在することを確認
      final cardWidgets = tester.widgetList<CardWidget>(
        find.byType(CardWidget),
      );

      // 少なくとも1枚のカードが表向き（faceUp: true）であることを確認
      final faceUpCards = cardWidgets.where((widget) => widget.faceUp).toList();
      expect(faceUpCards.isNotEmpty, isTrue);
    });

    testWidgets('CPUの手札が裏向きで表示される', (WidgetTester tester) async {
      // ゲーム画面を構築
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      await tester.pumpAndSettle();

      // CardWidgetが存在することを確認
      expect(find.byType(CardWidget), findsWidgets);

      // CPUの手札エリアにCardWidgetが存在することを確認
      final cardWidgets = tester.widgetList<CardWidget>(
        find.byType(CardWidget),
      );

      // 少なくとも1枚のカードが裏向き（faceUp: false）であることを確認
      final faceDownCards = cardWidgets
          .where((widget) => !widget.faceUp)
          .toList();
      expect(faceDownCards.isNotEmpty, isTrue);
    });

    testWidgets('プレイヤーのターンにCPUのカードをタップできる', (WidgetTester tester) async {
      // ゲーム画面を構築
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      await tester.pumpAndSettle();

      // 初期状態でプレイヤーのターンであることを確認
      expect(find.text('あなたのターン'), findsOneWidget);

      // CPUのカード（裏向き）を見つける
      final cardWidgets = tester.widgetList<CardWidget>(
        find.byType(CardWidget),
      );
      final faceDownCards = cardWidgets
          .where((widget) => !widget.faceUp)
          .toList();

      if (faceDownCards.isNotEmpty) {
        // 最初の裏向きカードをタップ
        final firstFaceDownCard = find.byWidget(faceDownCards.first);
        await tester.tap(firstFaceDownCard);
        await tester.pump();

        // ターンがCPUに切り替わることを確認（少し待つ）
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('CPUのターン'), findsOneWidget);
      }
    });

    testWidgets('カード枚数が正しく表示される', (WidgetTester tester) async {
      // ゲーム画面を構築
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));

      await tester.pumpAndSettle();

      // カード枚数の表示を確認
      final cardCountTexts = find.textContaining('枚');
      expect(cardCountTexts, findsAtLeastNWidgets(2));

      // 表示されているカード枚数を取得
      final texts = tester.widgetList<Text>(cardCountTexts);
      for (final text in texts) {
        final data = text.data;
        if (data != null) {
          // 「X枚」の形式であることを確認
          expect(data.contains('枚'), isTrue);
          // 数字が含まれていることを確認
          expect(RegExp(r'\d+').hasMatch(data), isTrue);
        }
      }
    });
  });
}
