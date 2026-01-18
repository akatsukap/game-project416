import 'package:flutter/material.dart';
import 'dart:math';
import '../models/card.dart' as models;
import '../models/game_state.dart';
import '../logic/game_logic.dart';
import '../widgets/card_widget.dart';

/// ゲーム画面
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  models.Card? _drawnCard; // 引いたカード
  List<models.Card> _removedPairs = []; // 削除されたペア
  bool _showingPairAnimation = false; // ペアアニメーション表示中

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

    // カードを配布
    final hands = GameLogic.dealCards(deck);
    var playerHand = hands['player']!;
    var cpuHand = hands['cpu']!;

    // 初期配布後にペアを削除
    playerHand = GameLogic.removePairs(playerHand);
    cpuHand = GameLogic.removePairs(cpuHand);

    // ゲーム状態を初期化
    _gameState = GameState(
      playerHand: playerHand,
      cpuHand: cpuHand,
      isPlayerTurn: true,
      status: GameStatus.playing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ババ抜き'),
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
                  // CPUの手札
                  Expanded(child: _buildCpuHand()),
                  const SizedBox(height: 20),
                  // プレイヤーの手札
                  Expanded(child: _buildPlayerHand()),
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
          colors: _gameState.isPlayerTurn
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
            _gameState.isPlayerTurn ? Icons.person : Icons.computer,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _gameState.isPlayerTurn ? 'あなたのターン' : 'CPUのターン',
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

  /// CPUの手札を構築
  Widget _buildCpuHand() {
    return Column(
      children: [
        // CPUラベルとカード枚数
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
              Icon(Icons.computer, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                'CPU',
                style: TextStyle(
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
                    colors: [Colors.blue.shade300, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_gameState.cpuHand.length}枚',
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
        const SizedBox(height: 12),
        // CPUのカード（裏向き）
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _gameState.cpuHand.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CardWidget(
                      card: card,
                      faceUp: false,
                      onTap: _gameState.isPlayerTurn
                          ? () => _onPlayerDrawCard(index)
                          : null,
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

  /// プレイヤーの手札を構築
  Widget _buildPlayerHand() {
    return Column(
      children: [
        // プレイヤーのカード（表向き）
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _gameState.playerHand.map((card) {
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
        // プレイヤーラベルとカード枚数
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
              const Text(
                'あなた',
                style: TextStyle(
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
                  '${_gameState.playerHand.length}枚',
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

  /// プレイヤーがCPUのカードを引く処理
  void _onPlayerDrawCard(int index) {
    if (!_gameState.isPlayerTurn || _gameState.status != GameStatus.playing) {
      return;
    }

    setState(() {
      // CPUの手札から選択されたカードを取得
      final drawnCard = _gameState.cpuHand[index];
      _drawnCard = drawnCard;

      // CPUの手札から削除
      final newCpuHand = List<models.Card>.from(_gameState.cpuHand);
      newCpuHand.removeAt(index);

      // プレイヤーの手札に追加
      final newPlayerHand = List<models.Card>.from(_gameState.playerHand);

      // 引いたカードとペアになるカードを探す（追加前に）
      models.Card? pairCard;
      if (!drawnCard.isJoker) {
        for (var card in newPlayerHand) {
          if (card.rank == drawnCard.rank && !card.isJoker) {
            pairCard = card;
            break;
          }
        }
      }

      newPlayerHand.add(drawnCard);

      // ペアを削除
      final playerHandAfterPairs = GameLogic.removePairs(newPlayerHand);

      // ペアが実際に削除されたかチェック
      if (pairCard != null) {
        // ペアが成立した場合、削除されたペアを記録
        _removedPairs = [drawnCard, pairCard];
      } else {
        _removedPairs = [];
      }

      // ゲーム状態を更新
      _gameState = _gameState.copyWith(
        playerHand: playerHandAfterPairs,
        cpuHand: newCpuHand,
        isPlayerTurn: false, // CPUのターンに切り替え
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

              // ゲームが終了していない場合、CPUのターンを実行
              if (_gameState.status == GameStatus.playing) {
                _onCpuTurn();
              }
            }
          });
        } else {
          // ゲームが終了していない場合、CPUのターンを実行
          if (_gameState.status == GameStatus.playing) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _onCpuTurn();
              }
            });
          }
        }
      }
    });
  }

  /// CPUのターン処理
  void _onCpuTurn() {
    if (_gameState.isPlayerTurn || _gameState.status != GameStatus.playing) {
      return;
    }

    // プレイヤーの手札が空の場合はスキップ
    if (_gameState.playerHand.isEmpty) {
      return;
    }

    // 少し待ってからCPUがカードを引く
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      setState(() {
        // ランダムにプレイヤーのカードを選択
        final random = Random();
        final randomIndex = random.nextInt(_gameState.playerHand.length);
        final drawnCard = _gameState.playerHand[randomIndex];

        // プレイヤーの手札から削除
        final newPlayerHand = List<models.Card>.from(_gameState.playerHand);
        newPlayerHand.removeAt(randomIndex);

        // CPUの手札に追加
        final newCpuHand = List<models.Card>.from(_gameState.cpuHand);

        // 引いたカードとペアになるカードを探す（追加前に）
        models.Card? pairCard;
        if (!drawnCard.isJoker) {
          for (var card in newCpuHand) {
            if (card.rank == drawnCard.rank && !card.isJoker) {
              pairCard = card;
              break;
            }
          }
        }

        newCpuHand.add(drawnCard);

        // ペアを削除
        final cpuHandAfterPairs = GameLogic.removePairs(newCpuHand);

        // ペアが実際に削除されたかチェック
        if (pairCard != null) {
          // ペアが成立した場合、削除されたペアを記録
          _removedPairs = [drawnCard, pairCard];
        } else {
          _removedPairs = [];
        }

        // ゲーム状態を更新
        _gameState = _gameState.copyWith(
          playerHand: newPlayerHand,
          cpuHand: cpuHandAfterPairs,
          isPlayerTurn: true, // プレイヤーのターンに切り替え
        );

        // ゲーム終了判定
        _checkGameOver();
      });

      // ペアが削除された場合、アニメーションを表示
      if (_removedPairs.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
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
        });
      }
    });
  }

  /// ゲーム終了判定
  void _checkGameOver() {
    if (GameLogic.isGameOver(_gameState.playerHand, _gameState.cpuHand)) {
      final winner = GameLogic.determineWinner(
        _gameState.playerHand,
        _gameState.cpuHand,
      );

      setState(() {
        _gameState = _gameState.copyWith(
          status: GameStatus.finished,
          winner: winner,
        );
      });

      // 結果画面に遷移（少し遅延させる）
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _navigateToResultScreen();
        }
      });
    }
  }

  /// 結果画面に遷移
  void _navigateToResultScreen() {
    Navigator.pushNamed(context, '/result', arguments: _gameState.winner);
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
                      Icon(Icons.celebration, size: 80, color: Colors.yellow),
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
