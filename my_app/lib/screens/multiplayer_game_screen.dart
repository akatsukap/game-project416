import 'package:flutter/material.dart';
import '../models/card.dart' as models;
import '../models/multiplayer_game_state.dart';
import '../logic/game_logic.dart';
import '../widgets/card_widget.dart';

/// マルチプレイヤーゲーム画面
class MultiplayerGameScreen extends StatefulWidget {
  final int playerCount;

  const MultiplayerGameScreen({super.key, required this.playerCount});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  late MultiplayerGameState _gameState;
  models.Card? _drawnCard;
  List<models.Card> _removedPairs = [];
  bool _showingPairAnimation = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  /// ゲームを初期化
  void _initializeGame() {
    // デッキを作成してシャッフル
    final deck = GameLogic.createDeck();
    GameLogic.shuffleDeck(deck);

    // カードを各プレイヤーに配布
    final playerHands = <List<models.Card>>[];
    for (int i = 0; i < widget.playerCount; i++) {
      playerHands.add([]);
    }

    // カードを順番に配る
    int currentPlayer = 0;
    for (var card in deck) {
      playerHands[currentPlayer].add(card);
      currentPlayer = (currentPlayer + 1) % widget.playerCount;
    }

    // 各プレイヤーの手札からペアを削除
    for (int i = 0; i < widget.playerCount; i++) {
      playerHands[i] = GameLogic.removePairs(playerHands[i]);
    }

    // ゲーム状態を初期化
    _gameState = MultiplayerGameState(
      playerHands: playerHands,
      currentPlayerIndex: 0,
      status: GameStatus.playing,
      playerCount: widget.playerCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ババ抜き - マルチプレイ'),
        backgroundColor: Colors.green.shade700,
        actions: [
          // ホームボタン
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'ホームに戻る',
            onPressed: () {
              // 確認ダイアログを表示
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('ゲームを終了しますか？'),
                    content: const Text('ホームに戻ると、現在のゲームは終了します。'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // ダイアログを閉じる
                        },
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // ダイアログを閉じる
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst); // ホームに戻る
                        },
                        child: const Text('終了'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade300, Colors.green.shade100],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // ターン表示
                  _buildTurnIndicator(),
                  const SizedBox(height: 20),
                  // プレイヤー情報一覧
                  Expanded(child: _buildPlayersList()),
                  const SizedBox(height: 20),
                  // 次のプレイヤーの手札（カードを引く対象）
                  Expanded(child: _buildNextPlayerHand()),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // 引いたカードの表示
            if (_drawnCard != null) _buildDrawnCardOverlay(),
            // ペアアニメーションの表示
            if (_showingPairAnimation) _buildPairAnimationOverlay(),
          ],
        ),
      ),
    );
  }

  /// ターン表示を構築
  Widget _buildTurnIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
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
          const Icon(Icons.person, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            'プレイヤー${_gameState.currentPlayerIndex + 1}のターン',
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

  /// プレイヤー情報一覧を構築
  Widget _buildPlayersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.playerCount,
      itemBuilder: (context, index) {
        final isCurrentPlayer = index == _gameState.currentPlayerIndex;
        final cardCount = _gameState.playerHands[index].length;
        final isEliminated = cardCount == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentPlayer
                ? Colors.orange.shade100
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentPlayer
                  ? Colors.orange.shade400
                  : Colors.transparent,
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
          child: Row(
            children: [
              // プレイヤーアイコン
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isEliminated
                      ? Colors.grey.shade400
                      : Colors.green.shade400,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // プレイヤー情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'プレイヤー${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isEliminated
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEliminated ? '上がり' : '$cardCount枚',
                      style: TextStyle(
                        fontSize: 16,
                        color: isEliminated
                            ? Colors.grey.shade600
                            : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 次のプレイヤーの手札を構築（カードを引く対象）
  Widget _buildNextPlayerHand() {
    final nextPlayerIndex = _getNextPlayerWithCards(
      _gameState.currentPlayerIndex,
    );

    if (nextPlayerIndex == -1) {
      // ゲーム終了
      return Center(
        child: Text(
          'ゲーム終了',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      );
    }

    final nextPlayerHand = _gameState.playerHands[nextPlayerIndex];

    return Column(
      children: [
        Text(
          'プレイヤー${nextPlayerIndex + 1}からカードを引く',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: nextPlayerHand.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CardWidget(
                      card: card,
                      faceUp: false, // 裏向きで表示
                      onTap: () => _onDrawCard(index, nextPlayerIndex),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 次の手札を持っているプレイヤーのインデックスを取得
  int _getNextPlayerWithCards(int currentIndex) {
    int nextIndex = (currentIndex + 1) % widget.playerCount;
    int attempts = 0;

    while (attempts < widget.playerCount) {
      if (_gameState.playerHands[nextIndex].isNotEmpty) {
        return nextIndex;
      }
      nextIndex = (nextIndex + 1) % widget.playerCount;
      attempts++;
    }

    return -1; // 手札を持っているプレイヤーがいない
  }

  /// カードを引く処理
  void _onDrawCard(int cardIndex, int nextPlayerIndex) {
    final currentPlayerIndex = _gameState.currentPlayerIndex;

    setState(() {
      // 次のプレイヤーの手札から選択されたカードを取得
      final drawnCard = _gameState.playerHands[nextPlayerIndex][cardIndex];
      _drawnCard = drawnCard;

      // 新しい手札を作成
      final newPlayerHands = List<List<models.Card>>.from(
        _gameState.playerHands,
      );
      newPlayerHands[nextPlayerIndex] = List<models.Card>.from(
        newPlayerHands[nextPlayerIndex],
      );
      newPlayerHands[currentPlayerIndex] = List<models.Card>.from(
        newPlayerHands[currentPlayerIndex],
      );

      // カードを移動（次のプレイヤーから現在のプレイヤーへ）
      newPlayerHands[nextPlayerIndex].removeAt(cardIndex);

      // ペアになるカードを探す
      models.Card? pairCard;
      if (!drawnCard.isJoker) {
        for (var card in newPlayerHands[currentPlayerIndex]) {
          if (card.rank == drawnCard.rank && !card.isJoker) {
            pairCard = card;
            break;
          }
        }
      }

      newPlayerHands[currentPlayerIndex].add(drawnCard);

      // ペアを削除（3枚・4枚も正しく処理される）
      newPlayerHands[currentPlayerIndex] = GameLogic.removePairs(
        newPlayerHands[currentPlayerIndex],
      );

      // ペアが成立したかチェック
      if (pairCard != null) {
        _removedPairs = [drawnCard, pairCard];
      } else {
        _removedPairs = [];
      }

      // 次のターンのプレイヤーを決定
      int nextTurnPlayer = _getNextPlayerWithCards(currentPlayerIndex);
      if (nextTurnPlayer == -1) {
        nextTurnPlayer = currentPlayerIndex;
      }

      // ゲーム状態を更新
      _gameState = _gameState.copyWith(
        playerHands: newPlayerHands,
        currentPlayerIndex: nextTurnPlayer,
      );

      // ゲーム終了判定
      _checkGameOver();
    });

    // 引いたカードを表示
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _drawnCard = null;
        });

        // ペアが削除された場合、ペアアニメーションを表示
        if (_removedPairs.isNotEmpty) {
          setState(() {
            _showingPairAnimation = true;
          });

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _showingPairAnimation = false;
                _removedPairs = [];
              });
            }
          });
        }
      }
    });
  }

  /// ゲーム終了判定
  void _checkGameOver() {
    // 手札を持っているプレイヤーの数をカウント
    int playersWithCards = 0;
    int lastPlayerWithCards = -1;

    for (int i = 0; i < widget.playerCount; i++) {
      if (_gameState.playerHands[i].isNotEmpty) {
        playersWithCards++;
        lastPlayerWithCards = i;
      }
    }

    // 1人だけが手札を持っている場合、ゲーム終了
    // その1人がジョーカー1枚のみを持っている場合も終了
    if (playersWithCards == 1) {
      final lastHand = _gameState.playerHands[lastPlayerWithCards];
      if (lastHand.length == 1 && lastHand[0].isJoker) {
        setState(() {
          _gameState = _gameState.copyWith(status: GameStatus.finished);
        });

        // 結果画面に遷移
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _navigateToResultScreen(lastPlayerWithCards);
          }
        });
      }
    } else if (playersWithCards == 0) {
      // 全員上がった場合（通常は発生しない）
      setState(() {
        _gameState = _gameState.copyWith(status: GameStatus.finished);
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _navigateToResultScreen(0);
        }
      });
    }
  }

  /// 結果画面に遷移
  void _navigateToResultScreen(int loser) {
    Navigator.pushNamed(
      context,
      '/multiplayer-result',
      arguments: {'loser': loser, 'playerCount': widget.playerCount},
    );
  }

  /// 引いたカードのオーバーレイを構築
  Widget _buildDrawnCardOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '引いたカード',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Transform.scale(
                    scale: 2.0,
                    child: CardWidget(card: _drawnCard!, faceUp: true),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ペアアニメーションのオーバーレイを構築
  Widget _buildPairAnimationOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.celebration,
                        size: 80,
                        color: Colors.yellow,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ペア成立！',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _removedPairs.map((card) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Transform.scale(
                              scale: 1.5,
                              child: CardWidget(card: card, faceUp: true),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
