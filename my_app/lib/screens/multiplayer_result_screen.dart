import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/game_room_service.dart';
import '../services/auth_service.dart';

/// オンラインマルチプレイヤー結果画面
///
/// ゲーム終了時に勝敗メッセージと全プレイヤーの最終順位を表示
class MultiplayerResultScreen extends StatefulWidget {
  final String roomCode;
  final String loserId;

  const MultiplayerResultScreen({
    super.key,
    required this.roomCode,
    required this.loserId,
  });

  @override
  State<MultiplayerResultScreen> createState() =>
      _MultiplayerResultScreenState();
}

class _MultiplayerResultScreenState extends State<MultiplayerResultScreen> {
  final GameRoomService _gameRoomService = GameRoomService();
  final AuthService _authService = AuthService();

  Map<String, Player>? _players;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  /// プレイヤー情報を読み込む
  Future<void> _loadPlayers() async {
    try {
      final players = await _gameRoomService.getPlayers(widget.roomCode);
      if (!mounted) return;

      setState(() {
        _players = players;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'プレイヤー情報の読み込みに失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  /// 現在のユーザーが勝者かどうかを判定
  bool _isWinner() {
    final user = _authService.getCurrentUser();
    if (user == null) return false;
    return user.uid != widget.loserId;
  }

  /// プレイヤーを順位順にソート（勝者が先、敗者が最後）
  List<MapEntry<String, Player>> _getSortedPlayers() {
    if (_players == null) return [];

    final playerEntries = _players!.entries.toList();

    // 敗者を最後に、それ以外は手札枚数順（少ない順）
    playerEntries.sort((a, b) {
      if (a.key == widget.loserId) return 1;
      if (b.key == widget.loserId) return -1;
      return a.value.hand.length.compareTo(b.value.hand.length);
    });

    return playerEntries;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null || _players == null) {
      return _buildErrorScreen();
    }

    final isWinner = _isWinner();
    final resultMessage = isWinner ? '勝ちました！' : '負けました...';
    final resultColor = isWinner ? Colors.orange : Colors.blue;
    final resultIcon = isWinner
        ? Icons.emoji_events
        : Icons.sentiment_dissatisfied;
    final resultEmoji = isWinner ? '🎉' : '😢';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              resultColor.shade400,
              resultColor.shade600,
              resultColor.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 結果表示エリア
              Expanded(
                flex: 2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 結果アイコン（アニメーション付き）
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                resultIcon,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // 絵文字
                      Text(resultEmoji, style: const TextStyle(fontSize: 50)),
                      const SizedBox(height: 16),
                      // 勝敗メッセージ
                      Text(
                        resultMessage,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 最終順位表示エリア
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // タイトル
                      Text(
                        '最終順位',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: resultColor.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 2),
                      const SizedBox(height: 8),
                      // プレイヤーリスト
                      Expanded(
                        child: ListView.builder(
                          itemCount: _players!.length,
                          itemBuilder: (context, index) {
                            final sortedPlayers = _getSortedPlayers();
                            final entry = sortedPlayers[index];
                            final playerId = entry.key;
                            final player = entry.value;
                            final isLoser = playerId == widget.loserId;
                            final currentUser = _authService.getCurrentUser();
                            final isCurrentUser = playerId == currentUser?.uid;

                            return _buildPlayerRankItem(
                              rank: index + 1,
                              player: player,
                              isLoser: isLoser,
                              isCurrentUser: isCurrentUser,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ボタンエリア
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: _onBackToLobby,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: resultColor.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, size: 28),
                      SizedBox(width: 12),
                      Text('ロビーに戻る'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// プレイヤーの順位アイテムを構築
  Widget _buildPlayerRankItem({
    required int rank,
    required Player player,
    required bool isLoser,
    required bool isCurrentUser,
  }) {
    // 順位に応じたメダルアイコンと色
    IconData? medalIcon;
    Color? medalColor;
    if (rank == 1 && !isLoser) {
      medalIcon = Icons.emoji_events;
      medalColor = Colors.amber;
    } else if (rank == 2 && !isLoser) {
      medalIcon = Icons.emoji_events;
      medalColor = Colors.grey.shade400;
    } else if (rank == 3 && !isLoser) {
      medalIcon = Icons.emoji_events;
      medalColor = Colors.brown.shade400;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.blue.shade50
            : (isLoser ? Colors.red.shade50 : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? Colors.blue.shade300
              : (isLoser ? Colors.red.shade300 : Colors.grey.shade300),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // 順位またはメダル
          SizedBox(
            width: 50,
            child: medalIcon != null
                ? Icon(medalIcon, color: medalColor, size: 36)
                : Text(
                    '$rank位',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLoser
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 12),
          // プレイヤー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.nickname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLoser ? Colors.red.shade700 : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCurrentUser)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'あなた',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isLoser ? 'ジョーカーを持っていました' : '手札: ${player.hand.length}枚',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // 勝敗アイコン
          if (isLoser)
            Icon(Icons.close, color: Colors.red.shade700, size: 32)
          else
            Icon(Icons.check, color: Colors.green.shade700, size: 32),
        ],
      ),
    );
  }

  /// ローディング画面を構築
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
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
                '結果を読み込み中...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// エラー画面を構築
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade300, Colors.red.shade100],
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
                  onPressed: _onBackToLobby,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'ロビーに戻る',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ロビーに戻る
  void _onBackToLobby() {
    // オンラインロビー画面まで戻る
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == '/multiplayer_lobby' ||
          route.settings.name == '/mode_selection' ||
          route.isFirst,
    );
  }
}
