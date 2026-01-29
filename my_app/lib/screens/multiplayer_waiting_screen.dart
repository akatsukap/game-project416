import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/multiplayer_game_logic.dart';
import '../models/game_room.dart';
import '../models/player.dart';
import '../services/auth_service.dart';
import '../services/game_room_service.dart';
import '../services/game_sync_service.dart';
import 'multiplayer_game_screen.dart';

/// 待機画面
/// ゲーム開始前にプレイヤーが集まるのを待つ画面
class MultiplayerWaitingScreen extends StatefulWidget {
  final String roomCode;

  const MultiplayerWaitingScreen({super.key, required this.roomCode});

  @override
  State<MultiplayerWaitingScreen> createState() =>
      _MultiplayerWaitingScreenState();
}

class _MultiplayerWaitingScreenState extends State<MultiplayerWaitingScreen> {
  final AuthService _authService = AuthService();
  final GameRoomService _gameRoomService = GameRoomService();
  final GameSyncService _gameSyncService = GameSyncService();

  StreamSubscription<GameRoom?>? _roomSubscription;
  GameRoom? _currentRoom;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startWatchingRoom();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  /// ゲームルームをリアルタイムで監視
  void _startWatchingRoom() {
    _roomSubscription = _gameRoomService
        .watchRoom(widget.roomCode)
        .listen(
          (gameRoom) {
            if (!mounted) return;

            if (gameRoom == null) {
              // ルームが削除された場合、前の画面に戻る
              Navigator.pop(context);
              return;
            }

            setState(() {
              _currentRoom = gameRoom;
            });

            // ゲームが開始された場合、ゲーム画面に遷移
            if (gameRoom.status == RoomStatus.playing) {
              _navigateToGameScreen();
            }
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _errorMessage = 'ルームの監視中にエラーが発生しました: $error';
            });
          },
        );
  }

  /// ゲーム画面に遷移
  void _navigateToGameScreen() {
    // 既に遷移中の場合は何もしない
    if (_isLoading) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MultiplayerGameScreen(roomCode: widget.roomCode),
      ),
    );
  }

  /// ルームコードをクリップボードにコピー
  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ルームコードをコピーしました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// ゲームを開始
  Future<void> _startGame() async {
    if (_currentRoom == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // プレイヤー情報を取得
      final players = await _gameRoomService.getPlayers(widget.roomCode);

      // デッキを作成してシャッフル
      final deck = MultiplayerGameLogic.createDeck();
      MultiplayerGameLogic.shuffleDeck(deck);

      // カードを配布
      final hands = MultiplayerGameLogic.dealCardsMultiplayer(
        deck,
        _currentRoom!.playerIds,
      );

      // プレイヤーの手札を更新
      final updatedPlayers = <String, Player>{};
      players.forEach((playerId, player) {
        updatedPlayers[playerId] = player.copyWith(hand: hands[playerId] ?? []);
      });

      // ターン順序をランダムに決定
      final turnOrder = MultiplayerGameLogic.randomizeTurnOrder(
        _currentRoom!.playerIds,
      );

      // ルームステータスを「進行中」に更新
      await _gameRoomService.updateRoomStatus(
        widget.roomCode,
        RoomStatus.playing,
      );

      // ゲーム状態を初期化
      await _gameSyncService.initializeGame(
        widget.roomCode,
        _currentRoom!.playerIds,
        updatedPlayers,
        turnOrder,
      );

      // ゲーム画面への遷移は、watchRoomのリスナーで自動的に行われる
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'ゲームの開始に失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// ルームから退出
  Future<void> _leaveRoom() async {
    final user = _authService.getCurrentUser();
    if (user == null) return;

    // 確認ダイアログを表示
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出確認'),
        content: const Text('本当にルームから退出しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    try {
      await _gameRoomService.leaveRoom(widget.roomCode, user.uid);

      if (!mounted) return;
      // 前の画面に戻る
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('退出に失敗しました: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 現在のユーザーがホストかどうかを判定
  bool _isHost() {
    final user = _authService.getCurrentUser();
    if (user == null || _currentRoom == null) return false;
    return _currentRoom!.hostId == user.uid;
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('待機中'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // 戻るボタンを非表示
        actions: [
          // 退出ボタン
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _isLoading ? null : _leaveRoom,
            tooltip: '退出',
          ),
        ],
      ),
      body: _currentRoom == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ルームコード表示
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'ルームコード',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.roomCode,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: _copyRoomCode,
                                tooltip: 'コピー',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 参加人数表示
                  Text(
                    '参加人数: ${_currentRoom!.playerIds.length}/${_currentRoom!.maxPlayers}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // 参加プレイヤーリスト
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: StreamBuilder<GameRoom?>(
                        stream: _gameRoomService.watchRoom(widget.roomCode),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final room = snapshot.data!;
                          final playerIds = room.playerIds;

                          return ListView.builder(
                            itemCount: playerIds.length,
                            itemBuilder: (context, index) {
                              final playerId = playerIds[index];
                              final isHost = playerId == room.hostId;
                              final isCurrentUser = playerId == user?.uid;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isHost
                                      ? Colors.amber
                                      : Colors.blue,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: FutureBuilder<String>(
                                  future: _getPlayerNickname(playerId),
                                  builder: (context, nicknameSnapshot) {
                                    final nickname =
                                        nicknameSnapshot.data ?? '読み込み中...';
                                    return Text(
                                      nickname,
                                      style: TextStyle(
                                        fontWeight: isCurrentUser
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    );
                                  },
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isHost)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'ホスト',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (isCurrentUser && !isHost)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'あなた',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ホストの場合：ゲーム開始ボタン
                  // ゲストの場合：待機メッセージ
                  if (_isHost())
                    ElevatedButton(
                      onPressed: _isLoading || !_currentRoom!.canStart
                          ? null
                          : _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _currentRoom!.canStart
                                  ? 'ゲーム開始'
                                  : 'プレイヤーを待っています (最低2人必要)',
                            ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hourglass_empty, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'ホストがゲームを開始するのを待っています',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                  // エラーメッセージ表示
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 退出ボタン
                  OutlinedButton(
                    onPressed: _isLoading ? null : _leaveRoom,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: const Text('退出'),
                  ),
                ],
              ),
            ),
    );
  }

  /// プレイヤーのニックネームを取得
  Future<String> _getPlayerNickname(String playerId) async {
    try {
      final players = await _gameRoomService.getPlayers(widget.roomCode);
      final player = players[playerId];
      return player?.nickname ?? 'プレイヤー ${playerId.substring(0, 8)}';
    } catch (e) {
      return '不明';
    }
  }
}
