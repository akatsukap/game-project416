import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

// Head Ball
import 'head_ball/screens/head_ball_menu_screen.dart';
import 'head_ball/screens/local_match_screen.dart';

// Screens
import 'screens/game_home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/multiplayer_game_screen.dart';
import 'screens/multiplayer_lobby_screen.dart';
import 'screens/multiplayer_result_screen.dart';
import 'screens/multiplayer_waiting_screen.dart';
import 'screens/player_selection_screen.dart';
import 'screens/result_screen.dart';
import 'screens/start_screen.dart';

// Horse race (実体は lib/horse_race/ 配下)
// import 'package:my_app/horse_race/horse_race_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 画面の向きを横向き（ランドスケープ）に固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // フルスクリーン表示
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // Firebase 初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // デバッグモード時はローカルエミュレーターを使用
    if (kDebugMode) {
      try {
        // Androidエミュレーターの場合は 10.0.2.2
        // Web/iOS/デスクトップ/コンテナなどは環境によりホストが変わる
        final String host =
            (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                ? '10.0.2.2'
                : 'localhost';

        await FirebaseAuth.instance.useAuthEmulator(host, 9099);
        FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
        debugPrint('Connected to Firebase Emulators at $host');
      } catch (e) {
        debugPrint('Failed to connect to Firebase Emulators: $e');
        // エミュレータ接続に失敗しても、アプリ自体は起動できるようにする
      }
    }
  } catch (e) {
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
      home: const GameHomeScreen(),
      routes: {
        '/babanuki-mode-selection': (context) => const ModeSelectionScreen(),
        '/start': (context) => const StartScreen(),
        '/game': (context) => const GameScreen(),
        '/player-selection': (context) => const PlayerSelectionScreen(),
        '/head-ball-menu': (context) => const HeadBallMenuScreen(),
        '/head-ball-local-match': (context) => const LocalMatchScreen(),
        // '/horse-race': (context) => HorseRaceScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final winner = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(winner: winner),
          );
        } else if (settings.name == '/multiplayer_lobby') {
          final nickname = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MultiplayerLobbyScreen(nickname: nickname),
          );
        } else if (settings.name == '/multiplayer_waiting') {
          final roomCode = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MultiplayerWaitingScreen(roomCode: roomCode),
          );
        } else if (settings.name == '/multiplayer_game') {
          final roomCode = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => MultiplayerGameScreen(roomCode: roomCode),
          );
        } else if (settings.name == '/multiplayer_result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MultiplayerResultScreen(
              roomCode: args['roomCode'] as String,
              loserId: args['loserId'] as String,
            ),
          );
        }
        return null;
      },
    );
  }
}
