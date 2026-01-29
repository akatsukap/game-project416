import 'package:flutter/material.dart';

/// 操作パネル
///
/// プレイヤーの操作ボタン（左、右、ジャンプ、キック、特殊能力）を表示するウィジェット
class ControlPanel extends StatelessWidget {
  /// プレイヤー番号（1 or 2）
  final int playerNumber;

  /// 左移動ボタンが押されたときのコールバック
  final VoidCallback? onLeftPressed;

  /// 左移動ボタンが離されたときのコールバック
  final VoidCallback? onLeftReleased;

  /// 右移動ボタンが押されたときのコールバック
  final VoidCallback? onRightPressed;

  /// 右移動ボタンが離されたときのコールバック
  final VoidCallback? onRightReleased;

  /// ジャンプボタンが押されたときのコールバック
  final VoidCallback? onJumpPressed;

  /// ジャンプボタンが離されたときのコールバック
  final VoidCallback? onJumpReleased;

  /// キックボタンが押されたときのコールバック
  final VoidCallback? onKickPressed;

  /// キックボタンが離されたときのコールバック
  final VoidCallback? onKickReleased;

  /// 特殊能力ボタンが押されたときのコールバック
  final VoidCallback? onSpecialPressed;

  /// 特殊能力ボタンが離されたときのコールバック
  final VoidCallback? onSpecialReleased;

  /// 特殊能力がクールダウン中かどうか
  final bool isSpecialOnCooldown;

  const ControlPanel({
    super.key,
    required this.playerNumber,
    this.onLeftPressed,
    this.onLeftReleased,
    this.onRightPressed,
    this.onRightReleased,
    this.onJumpPressed,
    this.onJumpReleased,
    this.onKickPressed,
    this.onKickReleased,
    this.onSpecialPressed,
    this.onSpecialReleased,
    this.isSpecialOnCooldown = false,
  });

  @override
  Widget build(BuildContext context) {
    // プレイヤー1は左側、プレイヤー2は右側に配置
    final isLeftSide = playerNumber == 1;

    return Positioned(
      bottom: 20,
      left: isLeftSide ? 20 : null,
      right: isLeftSide ? null : 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上段：特殊能力ボタン
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildSpecialButton()],
            ),
            const SizedBox(height: 12),
            // 中段：ジャンプとキックボタン
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  icon: Icons.arrow_upward,
                  label: 'ジャンプ',
                  color: Colors.green,
                  onPressed: onJumpPressed,
                  onReleased: onJumpReleased,
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.sports_soccer,
                  label: 'キック',
                  color: Colors.orange,
                  onPressed: onKickPressed,
                  onReleased: onKickReleased,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 下段：左右移動ボタン
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDirectionButton(
                  icon: Icons.arrow_back,
                  onPressed: onLeftPressed,
                  onReleased: onLeftReleased,
                ),
                const SizedBox(width: 12),
                _buildDirectionButton(
                  icon: Icons.arrow_forward,
                  onPressed: onRightPressed,
                  onReleased: onRightReleased,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 方向ボタンを構築（長押し対応）
  Widget _buildDirectionButton({
    required IconData icon,
    VoidCallback? onPressed,
    VoidCallback? onReleased,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed?.call(),
      onTapUp: (_) => onReleased?.call(),
      onTapCancel: () => onReleased?.call(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  /// アクションボタンを構築（タップ）
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
    VoidCallback? onReleased,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed?.call(),
      onTapUp: (_) => onReleased?.call(),
      onTapCancel: () => onReleased?.call(),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 特殊能力ボタンを構築
  Widget _buildSpecialButton() {
    return GestureDetector(
      onTapDown: isSpecialOnCooldown ? null : (_) => onSpecialPressed?.call(),
      onTapUp: isSpecialOnCooldown ? null : (_) => onSpecialReleased?.call(),
      onTapCancel: isSpecialOnCooldown ? null : () => onSpecialReleased?.call(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSpecialOnCooldown
              ? Colors.grey.withValues(alpha: 0.5)
              : Colors.purple.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_on,
              color: isSpecialOnCooldown
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.yellow,
              size: 36,
            ),
            const SizedBox(height: 4),
            Text(
              '特殊能力',
              style: TextStyle(
                color: isSpecialOnCooldown
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
