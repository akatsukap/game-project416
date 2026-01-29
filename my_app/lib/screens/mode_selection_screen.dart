import 'package:flutter/material.dart';
import 'multiplayer_lobby_screen.dart';

/// モード選択画面
///
/// ローカルプレイとオンラインプレイを選択する画面
/// 要件2: モード選択機能を実装
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ニックネームを引数から取得（GameHomeScreenから渡される）
    final nickname = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          tooltip: 'ホームに戻る',
          onPressed: () {
            Navigator.of(context).pop(); // ゲームホーム画面に戻る
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
              Colors.teal.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // カードアイコン
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.style,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // ゲームタイトル
                  Text(
                    'ババ抜き',
                    style: TextStyle(
                      fontSize: 56,
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
                  const SizedBox(height: 16),
                  Text(
                    'Old Maid Card Game',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 2,
                    ),
                  ),
                  if (nickname != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'ようこそ、$nickname さん！',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                  // モード選択の説明
                  Text(
                    'プレイモードを選択してください',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ローカルプレイボタン（要件2.2, 2.4）
                  _buildModeButton(
                    context,
                    'ローカルプレイ',
                    'この端末で2〜6人でプレイ',
                    Icons.people,
                    Colors.blue,
                    () {
                      // 要件2.4: 既存のローカルゲーム画面に遷移
                      Navigator.pushNamed(context, '/player-selection');
                    },
                  ),
                  const SizedBox(height: 24),
                  // オンラインプレイボタン（要件2.3, 2.5）
                  _buildModeButton(
                    context,
                    'オンラインプレイ',
                    'インターネット経由で友達と対戦',
                    Icons.wifi,
                    Colors.orange,
                    () {
                      // 要件2.5: オンラインロビー画面に遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiplayerLobbyScreen(
                            nickname: nickname ?? 'プレイヤー',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// モードボタンを構築
  ///
  /// [title] ボタンのタイトル
  /// [subtitle] ボタンのサブタイトル（説明）
  /// [icon] ボタンのアイコン
  /// [color] ボタンのテーマカラー
  /// [onPressed] ボタンが押されたときのコールバック
  Widget _buildModeButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            // アイコン
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            // テキスト
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // 矢印アイコン
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
