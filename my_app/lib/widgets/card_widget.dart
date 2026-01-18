import 'package:flutter/material.dart';
import '../models/card.dart' as models;

/// カードを視覚的に表示するウィジェット
class CardWidget extends StatefulWidget {
  final models.Card card;
  final bool faceUp; // 表向きか裏向きか
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    required this.faceUp,
    this.onTap,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ホバー可能な場合のスケール
    final hoverScale = _isHovered && widget.onTap != null ? 1.15 : 1.0;

    return MouseRegion(
      onEnter: (_) {
        if (widget.onTap != null) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (widget.onTap != null) {
          setState(() => _isHovered = false);
        }
      },
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return AnimatedScale(
              scale: hoverScale * _scaleAnimation.value,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                width: 70,
                height: 105,
                decoration: BoxDecoration(
                  color: widget.faceUp ? Colors.white : Colors.blue.shade800,
                  border: Border.all(
                    color: _isHovered && widget.onTap != null
                        ? Colors.yellow
                        : (_isPressed ? Colors.amber : Colors.black87),
                    width: _isHovered && widget.onTap != null
                        ? 3
                        : (_isPressed ? 3 : 2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: _isHovered && widget.onTap != null
                          ? 12
                          : (_isPressed ? 8 : 4),
                      offset: Offset(
                        0,
                        _isHovered && widget.onTap != null
                            ? 6
                            : (_isPressed ? 4 : 2),
                      ),
                    ),
                  ],
                ),
                child: widget.faceUp
                    ? _buildFaceUpCard()
                    : _buildFaceDownCard(),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 表向きのカードを構築
  Widget _buildFaceUpCard() {
    if (widget.card.isJoker) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade300, Colors.purple.shade400],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 28),
              const SizedBox(height: 2),
              Text(
                'JOKER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // スートの色を決定
    Color suitColor = _getSuitColor();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上部：ランク
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              widget.card.rank,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: suitColor,
              ),
            ),
          ),
          // 中央：スートシンボル
          Text(
            _getSuitSymbol(),
            style: TextStyle(fontSize: 28, color: suitColor),
          ),
          // 下部：ランク（逆向き）
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              angle: 3.14159, // 180度回転
              child: Text(
                widget.card.rank,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: suitColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 裏向きのカードを構築
  Widget _buildFaceDownCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade700, Colors.blue.shade900],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_mark, color: Colors.white70, size: 40),
            const SizedBox(height: 4),
            Icon(Icons.question_mark, color: Colors.white70, size: 40),
          ],
        ),
      ),
    );
  }

  /// スートの色を取得
  Color _getSuitColor() {
    if (widget.card.suit == 'hearts' || widget.card.suit == 'diamonds') {
      return Colors.red.shade700;
    }
    return Colors.black87;
  }

  /// スートのシンボルを取得
  String _getSuitSymbol() {
    switch (widget.card.suit) {
      case 'hearts':
        return '♥';
      case 'diamonds':
        return '♦';
      case 'spades':
        return '♠';
      case 'clubs':
        return '♣';
      default:
        return '';
    }
  }
}
