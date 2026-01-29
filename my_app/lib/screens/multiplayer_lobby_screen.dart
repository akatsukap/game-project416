import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/game_room_service.dart';
import 'multiplayer_waiting_screen.dart';

/// オンラインロビー画面
/// プレイヤーがゲームルームを作成または参加できる画面
class MultiplayerLobbyScreen extends StatefulWidget {
  final String nickname;

  const MultiplayerLobbyScreen({super.key, required this.nickname});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  final AuthService _authService = AuthService();
  final GameRoomService _gameRoomService = GameRoomService();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  /// ルームを作成して待機画面に遷移
  Future<void> _createRoom() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _errorMessage = 'ユーザーが認証されていません';
          _isLoading = false;
        });
        return;
      }

      // ゲームルームを作成
      final gameRoom = await _gameRoomService.createRoom(
        user.uid,
        widget.nickname,
      );

      if (!mounted) return;

      // 待機画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MultiplayerWaitingScreen(roomCode: gameRoom.roomCode),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'ルームの作成に失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// ルームに参加して待機画面に遷移
  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim().toUpperCase();

    if (roomCode.isEmpty) {
      setState(() {
        _errorMessage = 'ルームコードを入力してください';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _errorMessage = 'ユーザーが認証されていません';
          _isLoading = false;
        });
        return;
      }

      // ルームが存在するか確認
      final gameRoom = await _gameRoomService.getRoom(roomCode);

      if (gameRoom == null) {
        setState(() {
          _errorMessage = 'ルームが見つかりません';
          _isLoading = false;
        });
        return;
      }

      // ルームに参加
      await _gameRoomService.joinRoom(roomCode, user.uid, widget.nickname);

      if (!mounted) return;

      // 待機画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiplayerWaitingScreen(roomCode: roomCode),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'ルームへの参加に失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('オンラインロビー'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // タイトル
            const Text(
              'オンラインマルチプレイヤー',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // ルームを作成ボタン
            ElevatedButton(
              onPressed: _isLoading ? null : _createRoom,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('ルームを作成'),
            ),
            const SizedBox(height: 32),

            // 区切り線
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('または'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 32),

            // ルームコード入力フィールド
            TextField(
              controller: _roomCodeController,
              decoration: const InputDecoration(
                labelText: 'ルームコード',
                hintText: '8文字のルームコードを入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // ルームに参加ボタン
            ElevatedButton(
              onPressed: _isLoading ? null : _joinRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('ルームに参加'),
            ),

            // エラーメッセージ表示
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }
}
