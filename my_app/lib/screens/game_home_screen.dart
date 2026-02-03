import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';

/// ゲームホーム画面（ニックネーム入力画面）
///
/// 複数のゲームを選択できる画面（将来的な拡張用）
class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key});

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// 開始ボタンが押されたときの処理（ババ抜き用）
  Future<void> _onBabanukiPressed() async {
    // ニックネーム入力ダイアログを表示
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) => _NicknameInputDialog(
        controller: _nicknameController,
        authService: _authService,
      ),
    );

    // キャンセルされた場合は何もしない
    if (nickname == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase匿名認証を実行
      final user = await _authService.signInAnonymously();

      if (user == null) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('エラー'),
              content: const Text('認証に失敗しました。もう一度お試しください。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 認証成功後、モード選択画面に遷移
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/babanuki-mode-selection',
          arguments: nickname,
        );
      }
    } catch (e) {
      // エラーメッセージを整形
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }

      setState(() {
        _isLoading = false;
      });

      // エラーダイアログを表示
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('エラー'),
            content: SingleChildScrollView(
              child: Text(errorMsg, style: const TextStyle(fontSize: 14)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ヘッドボール開始（ローディング表示の統一用）
  Future<void> _onHeadBallPressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      Navigator.pushNamed(context, '/head-ball-menu');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade400,
              Colors.purple.shade600,
              Colors.deepPurple.shade700,
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
                  // アプリアイコン
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.games,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // アプリタイトル
                  Text(
                    'カードゲーム集',
                    style: TextStyle(
                      fontSize: 48,
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
                  const SizedBox(height: 8),
                  Text(
                    'Card Game Collection',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // ニックネーム入力カード
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 説明テキスト
                        Text(
                          'ゲームを選択してください',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // ババ抜きボタン
                        ElevatedButton(
                          onPressed: _isLoading ? null : _onBabanukiPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.style),
                                    SizedBox(width: 8),
                                    Text(
                                      'ババ抜き',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 16),

                        // ヘッドボールボタン（child 重複を解消）
                        ElevatedButton(
                          onPressed: _isLoading ? null : _onHeadBallPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sports_soccer),
                                    SizedBox(width: 8),
                                    Text(
                                      'ヘッドボール',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ニックネーム入力ダイアログ
class _NicknameInputDialog extends StatefulWidget {
  final TextEditingController controller;
  final AuthService authService;

  const _NicknameInputDialog({
    required this.controller,
    required this.authService,
  });

  @override
  State<_NicknameInputDialog> createState() => _NicknameInputDialogState();
}

class _NicknameInputDialogState extends State<_NicknameInputDialog> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ニックネーム入力'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('3文字以上20文字以内で入力してください'),
          const SizedBox(height: 16),
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: 'ニックネーム',
              hintText: '例: プレイヤー1',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
            maxLength: 20,
            onChanged: (value) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            final nickname = widget.controller.text.trim();
            if (nickname.isEmpty) {
              setState(() {
                _errorMessage = 'ニックネームを入力してください';
              });
              return;
            }
            if (!widget.authService.validateNickname(nickname)) {
              setState(() {
                _errorMessage = 'ニックネームは3文字以上20文字以内で入力してください';
              });
              return;
            }
            Navigator.of(context).pop(nickname);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
