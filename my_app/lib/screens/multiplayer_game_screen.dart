import 'package:flutter/material.dart';
import 'dart:async';
import '../models/multiplayer_game_state.dart';
import '../models/player.dart';
import '../models/game_room.dart';
import '../services/game_sync_service.dart';
import '../services/auth_service.dart';
import '../logic/multiplayer_game_logic.dart';
import '../widgets/card_widget.dart';

/// オンラインマルチプレイヤーゲーム画面
class MultiplayerGameScreen extends StatefulWidget {
  final String roomCode;

  const MultiplayerGameScreen({super.key, required this.roomCode});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final GameSyncService _gameSyncService = GameSyncService();
  final AuthService _authService = AuthService();

  StreamSubscription<MultiplayerGameState?>? _gameStateSubscription;
  MultiplayerGameState? _gameState;
  String? _currentUserId;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isReconnecting = false;
  Timer? _connectionCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  /// 画面を初期化
  Future<void> _initializeScreen() async {
    try {
      // 現在のユーザーIDを取得
      final user = _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _errorMessage = '認証エラー: ユーザーが見つかりません';
          _isLoading = false;
        });
        return;
      }

      _currentUserId = user.uid;

      // ゲーム状態をリアルタイムで監視
      _gameStateSubscription = _gameSyncService
          .watchGameState(widget.roomCode)
          .listen(_onGameStateUpdate, onError: _onGameStateError);

      // 接続状態を定期的に更新
      _startConnectionCheck();
    } catch (e) {
      setState(() {
        _errorMessage = 'エラー: $e';
        _isLoading = false;
      });
    }
  }

  /// ゲーム状態の更新を処理
  void _onGameStateUpdate(MultiplayerGameState? gameState) {
    if (!mounted) return;

    if (gameState == null) {
      setState(() {
        _errorMessage = 'ゲーム状態が見つかりません';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _gameState = gameState;
      _isLoading = false;
      _isReconnecting = false;
      _errorMessage = null;
    });

    // ゲームが終了した場合、結果画面に遷移
    if (gameState.status == RoomStatus.finished && gameState.loserId != null) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _navigateToResultScreen(gameState.loserId!);
        }
      });
    }
  }

  /// ゲーム状態のエラーを処理
  void _onGameStateError(Object error) {
    if (!mounted) return;

    setState(() {
      _errorMessage = 'ゲーム状態の取得に失敗しました: $error';
      _isReconnecting = true;
    });

    // 再接続を試みる
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isReconnecting) {
        _initializeScreen();
      }
    });
  }

  /// 接続状態チェックを開始
  void _startConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 10), (
      timer,
    ) {
      if (_currentUserId != null && _gameState != null) {
        _gameSyncService.updatePlayerConnection(
          widget.roomCode,
          _currentUserId!,
          true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('オンラインゲーム - ${widget.roomCode}'),
        backgroundColor: Colors.purple.shade700,
        actions: [
          // ホームボタン
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'ホームに戻る',
            onPressed: _onHomePressed,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// ボディを構築
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    if (_gameState == null || _currentUserId == null) {
      return _buildErrorScreen();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade300, Colors.purple.shade100],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 再接続中の表示
            if (_isReconnecting) _buildReconnectingBanner(),
            // ターン表示
            _buildTurnIndicator(),
            const SizedBox(height: 12),
            // 他のプレイヤーの手札
            Expanded(child: _buildOtherPlayersHands()),
            const SizedBox(height: 12),
            // 自分の手札
            Expanded(child: _buildMyHand()),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// ローディング画面を構築
  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade300, Colors.purple.shade100],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'ゲームを読み込み中...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// エラー画面を構築
  Widget _buildErrorScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade300, Colors.purple.shade100],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade700),
              const SizedBox(height: 20),
              Text(
                _errorMessage ?? 'エラーが発生しました',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'ホームに戻る',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 再接続中のバナーを構築
  Widget _buildReconnectingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade700,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Text(
            '接続が失われました。再接続中...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// ターン表示を構築
  Widget _buildTurnIndicator() {
    final currentPlayer = _gameState!.currentPlayer;
    final isMyTurn = currentPlayer.id == _currentUserId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMyTurn
              ? [Colors.orange.shade400, Colors.orange.shade600]
              : [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMyTurn ? Icons.person : Icons.people,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            isMyTurn ? 'あなたのターン' : '${currentPlayer.nickname}のターン',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 他のプレイヤーの手札を構築
  Widget _buildOtherPlayersHands() {
    final otherPlayers = _gameState!.players.values
        .where((player) => player.id != _currentUserId)
        .toList();

    if (otherPlayers.isEmpty) {
      return const Center(
        child: Text(
          '他のプレイヤーがいません',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: otherPlayers.map((player) {
          return _buildOtherPlayerHand(player);
        }).toList(),
      ),
    );
  }

  /// 他のプレイヤーの手札を構築
  Widget _buildOtherPlayerHand(Player player) {
    final isCurrentTurn = _gameState!.currentPlayerId == player.id;
    final isMyTurn = _gameState!.currentPlayerId == _currentUserId;
    final canDrawFrom = isMyTurn && !isCurrentTurn && player.hand.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentTurn ? Colors.orange : Colors.transparent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // プレイヤー情報
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.purple.shade700, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    player.nickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!player.isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '切断中',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade300, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${player.hand.length}枚',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // カード（裏向き）
          if (player.hand.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: player.hand.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: CardWidget(
                      card: card,
                      faceUp: false,
                      onTap: canDrawFrom
                          ? () => _onDrawCard(player.id, index)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '手札なし',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 自分の手札を構築
  Widget _buildMyHand() {
    final myPlayer = _gameState!.players[_currentUserId];
    if (myPlayer == null) {
      return const Center(
        child: Text(
          'プレイヤー情報が見つかりません',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    return Column(
      children: [
        // カード（表向き）
        Expanded(
          child: Center(
            child: myPlayer.hand.isEmpty
                ? const Text(
                    '手札なし - 勝利！',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: myPlayer.hand.map((card) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CardWidget(card: card, faceUp: true),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // プレイヤー情報
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                myPlayer.nickname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${myPlayer.hand.length}枚',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// カードを引く処理
  Future<void> _onDrawCard(String fromPlayerId, int cardIndex) async {
    if (_gameState == null || _currentUserId == null) return;

    // 自分のターンでない場合は何もしない
    if (_gameState!.currentPlayerId != _currentUserId) {
      _showSnackBar('あなたのターンではありません');
      return;
    }

    try {
      // カードを引く
      final updatedState = MultiplayerGameLogic.drawCard(
        _gameState!,
        fromPlayerId,
        cardIndex,
      );

      // ゲーム状態を更新
      await _gameSyncService.updateGameState(updatedState);

      // ゲーム終了判定
      if (MultiplayerGameLogic.isGameOverMultiplayer(updatedState.players)) {
        final loserId = MultiplayerGameLogic.determineLoser(
          updatedState.players,
        );
        if (loserId != null) {
          await _gameSyncService.endGame(widget.roomCode, loserId);
        }
      }
    } catch (e) {
      _showSnackBar('カードを引くことができませんでした: $e');
    }
  }

  /// ホームボタンが押された時の処理
  void _onHomePressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ゲームを終了しますか？'),
          content: const Text('ホームに戻ると、ゲームから退出します。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('終了'),
            ),
          ],
        );
      },
    );
  }

  /// 結果画面に遷移
  void _navigateToResultScreen(String loserId) {
    Navigator.pushReplacementNamed(
      context,
      '/multiplayer_result',
      arguments: {'roomCode': widget.roomCode, 'loserId': loserId},
    );
  }

  /// スナックバーを表示
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
