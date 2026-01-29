import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'head_ball/screens/head_ball_menu_screen.dart';
import 'head_ball/screens/local_match_screen.dart';
import 'screens/game_home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/multiplayer_game_screen.dart';
import 'screens/multiplayer_result_screen.dart';
import 'screens/player_selection_screen.dart';
import 'screens/result_screen.dart';
import 'screens/start_screen.dart';

void main() async {
  // Flutterバインディングの初期化
  WidgetsFlutterBinding.ensureInitialized();

  // 画面の向きを横向き（ランドスケープ）に固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // システムUIのオーバーレイスタイルを設定（フルスクリーン表示）
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // Firebaseの初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase初期化エラーをログに出力
    debugPrint('Firebase初期化エラー: $e');
    debugPrint('');
    debugPrint('=== Firebase設定が必要です ===');
    debugPrint('1. Firebase Consoleでプロジェクトを作成');
    debugPrint('2. `flutterfire configure`コマンドを実行');
    debugPrint('3. または、FIREBASE_SETUP_INSTRUCTIONS.mdを参照');
    debugPrint('=============================');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カードゲーム集',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 初期画面をゲームホーム画面に設定
      home: const GameHomeScreen(),
      // ルーティング設定
      routes: {
        '/babanuki-mode-selection': (context) => const ModeSelectionScreen(),
        '/start': (context) => const StartScreen(),
        '/game': (context) => const GameScreen(),
        '/player-selection': (context) => const PlayerSelectionScreen(),
        '/head-ball-menu': (context) => const HeadBallMenuScreen(),
        '/head-ball-local-match': (context) => const LocalMatchScreen(),
      },
      // 引数を受け取るルート
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final winner = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(winner: winner),
          );
        } else if (settings.name == '/multiplayer-game') {
          final playerCount = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) =>
                MultiplayerGameScreen(playerCount: playerCount),
          );
        } else if (settings.name == '/multiplayer-result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MultiplayerResultScreen(
              loser: args['loser'] as int,
              playerCount: args['playerCount'] as int,
            ),
          );
        }
        return null;
      },
    );
  }
}
