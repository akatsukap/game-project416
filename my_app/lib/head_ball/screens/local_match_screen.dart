import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../models/character_data.dart';
import '../../models/match_result.dart';
import '../../repositories/game_repository.dart';
import '../game_state.dart';
import '../head_ball_game.dart';
import '../input_controller.dart';
import '../widgets/control_panel.dart';
import '../widgets/game_hud.dart';
import 'character_select_screen.dart';
import 'match_result_screen.dart';

/// ローカル2人対戦モード画面
///
/// 2人のプレイヤーが同じデバイスで対戦するモードです。
/// 画面を左右に分割して各プレイヤーの操作エリアを提供します。
/// 要件: 8.1, 8.2, 8.3, 8.4
class LocalMatchScreen extends StatefulWidget {
  const LocalMatchScreen({super.key});

  @override
  State<LocalMatchScreen> createState() => _LocalMatchScreenState();
}

class _LocalMatchScreenState extends State<LocalMatchScreen> {
  /// ゲームインスタンス
  late final HeadBallGame _game;

  /// プレイヤー1の入力コントローラー
  InputController? _player1Controller;

  /// プレイヤー2の入力コントローラー
  InputController? _player2Controller;

  /// プレイヤー1のキャラクターデータ
  CharacterData? _player1Character;

  /// プレイヤー2のキャラクターデータ
  CharacterData? _player2Character;

  /// キャラクター選択が完了したか
  bool _isCharacterSelectionComplete = false;

  /// ゲームリポジトリ
  GameRepository? _repository;

  @override
  void initState() {
    super.initState();
    _game = HeadBallGame();

    // キャラクター選択を開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCharacterSelection();
    });
  }

  /// キャラクター選択を開始
  Future<void> _startCharacterSelection() async {
    // プレイヤー1のキャラクター選択
    final player1Character = await Navigator.push<CharacterData>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterSelectScreen(
          playerNumber: 1,
          onCharacterSelected: (character) {
            Navigator.pop(context, character);
          },
        ),
      ),
    );

    // キャンセルされた場合は前の画面に戻る
    if (player1Character == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    // プレイヤー2のキャラクター選択
    final player2Character = await Navigator.push<CharacterData>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterSelectScreen(
          playerNumber: 2,
          onCharacterSelected: (character) {
            Navigator.pop(context, character);
          },
        ),
      ),
    );

    // キャンセルされた場合は前の画面に戻る
    if (player2Character == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    // キャラクターを設定
    setState(() {
      _player1Character = player1Character;
      _player2Character = player2Character;
    });

    // ゲームを初期化
    await _initializeGame();
  }

  /// ゲームを初期化
  Future<void> _initializeGame() async {
    try {
      // ゲームリポジトリを初期化
      _repository = await GameRepository.create();

      // プレイヤーキャラクターを初期化
      await _game.initializePlayers(
        character1Data: _player1Character!,
        character2Data: _player2Character!,
      );

      // 入力コントローラーを作成
      _player1Controller = InputController(
        playerNumber: 1,
        player: _game.player1!,
      );
      _player2Controller = InputController(
        playerNumber: 2,
        player: _game.player2!,
      );

      // ゲームに入力コントローラーを追加
      await _game.world.add(_player1Controller!);
      await _game.world.add(_player2Controller!);

      // プレイヤーが完全にマウントされるまで少し待機
      // これにより、物理ボディが確実に初期化される
      await Future.delayed(const Duration(milliseconds: 100));

      // 試合を開始
      _game.startMatch();

      setState(() {
        _isCharacterSelectionComplete = true;
      });

      // ゲーム終了を監視
      _monitorGameEnd();
    } catch (e) {
      debugPrint('ゲームの初期化に失敗しました: $e');
      // エラーが発生した場合はメニューに戻る
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ゲームの初期化に失敗しました')));
      }
    }
  }

  /// ゲーム終了を監視
  void _monitorGameEnd() {
    // 定期的にゲーム状態をチェック
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return false;

      // ゲームが終了したら結果画面に遷移
      if (_game.state == GameState.finished) {
        await _showMatchResult();
        return false;
      }

      return true;
    });
  }

  /// 試合結果を表示
  Future<void> _showMatchResult() async {
    // 試合結果を作成
    final matchResult = MatchResult(
      player1CharacterId: _player1Character!.id,
      player2CharacterId: _player2Character!.id,
      player1Score: _game.player1Score,
      player2Score: _game.player2Score,
      timestamp: DateTime.now(),
      winnerId: _game.winnerId,
    );

    // 試合結果を保存
    if (_repository != null) {
      try {
        await _repository!.saveMatchResult(matchResult);
      } catch (e) {
        debugPrint('試合結果の保存に失敗しました: $e');
      }
    }

    // 結果画面に遷移
    if (mounted) {
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => MatchResultScreen(matchResult: matchResult),
        ),
      );

      // 結果画面から戻った場合の処理
      if (mounted) {
        if (result == 'replay') {
          // 再試合の場合は、ゲームをリセットして再開
          _game.resumeEngine(); // エンジンを再開
          _game.startMatch(); // 試合を開始
          _monitorGameEnd(); // ゲーム終了を再監視
        } else {
          // メニューに戻る
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // キャラクター選択中はローディング画面を表示
    if (!_isCharacterSelectionComplete) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // ゲーム画面
          GameWidget(
            game: _game,
            overlayBuilderMap: {
              'hud': (context, game) {
                return GameHUD(
                  player1Score: _game.player1Score,
                  player2Score: _game.player2Score,
                  remainingTime: _game.remainingTime,
                  onPausePressed: () {
                    _game.pauseMatch();
                    _showPauseMenu();
                  },
                );
              },
            },
            initialActiveOverlays: const ['hud'],
          ),
          // プレイヤー1の操作パネル（画面左下）
          ControlPanel(
            playerNumber: 1,
            onLeftPressed: () => _player1Controller?.isLeftPressed = true,
            onLeftReleased: () => _player1Controller?.isLeftPressed = false,
            onRightPressed: () => _player1Controller?.isRightPressed = true,
            onRightReleased: () => _player1Controller?.isRightPressed = false,
            onJumpPressed: () => _player1Controller?.isJumpPressed = true,
            onJumpReleased: () => _player1Controller?.isJumpPressed = false,
            onKickPressed: () => _player1Controller?.isKickPressed = true,
            onKickReleased: () => _player1Controller?.isKickPressed = false,
            onSpecialPressed: () => _player1Controller?.isSpecialPressed = true,
            onSpecialReleased: () =>
                _player1Controller?.isSpecialPressed = false,
          ),
          // プレイヤー2の操作パネル（画面右下）
          ControlPanel(
            playerNumber: 2,
            onLeftPressed: () => _player2Controller?.isLeftPressed = true,
            onLeftReleased: () => _player2Controller?.isLeftPressed = false,
            onRightPressed: () => _player2Controller?.isRightPressed = true,
            onRightReleased: () => _player2Controller?.isRightPressed = false,
            onJumpPressed: () => _player2Controller?.isJumpPressed = true,
            onJumpReleased: () => _player2Controller?.isJumpPressed = false,
            onKickPressed: () => _player2Controller?.isKickPressed = true,
            onKickReleased: () => _player2Controller?.isKickPressed = false,
            onSpecialPressed: () => _player2Controller?.isSpecialPressed = true,
            onSpecialReleased: () =>
                _player2Controller?.isSpecialPressed = false,
          ),
        ],
      ),
    );
  }

  /// 一時停止メニューを表示
  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('一時停止'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'スコア: ${_game.player1Score} - ${_game.player2Score}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '残り時間: ${_game.remainingTime.toInt()}秒',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _game.resumeMatch();
            },
            child: const Text('再開'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _game.startMatch();
            },
            child: const Text('リスタート'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('メニューに戻る'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ゲームエンジンが実行中の場合のみ一時停止
    if (_game.state == GameState.playing) {
      _game.pauseEngine();
    }
    super.dispose();
  }
}
