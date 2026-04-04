import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';

void main() {
  testWidgets('ホーム画面で優先ゲームが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('みんなでゲーム会'), findsOneWidget);
    expect(find.text('最優先'), findsOneWidget);
    expect(find.text('競馬ダッシュ'), findsOneWidget);
    expect(find.text('ババ抜き'), findsOneWidget);
    expect(find.text('ヘッドボール'), findsOneWidget);
  });

  testWidgets('競馬ダッシュを押すと競馬画面へ遷移', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('競馬ダッシュ'));
    await tester.pumpAndSettle();

    expect(find.text('飲み会競馬ダッシュ'), findsOneWidget);
    expect(find.textContaining('最優先ゲーム: 競馬レース'), findsOneWidget);
  });

  testWidgets('未実装ゲームはアイデア画面に遷移できる', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ポーカー'));
    await tester.pumpAndSettle();

    expect(find.text('開発メモ'), findsOneWidget);
    expect(find.textContaining('タグ:'), findsOneWidget);
  });
}
