import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// ゲームホーム画面（ニックネーム入力画面）
///
/// プレイヤーがニックネームを入力してゲームに参加する画面
/// Firebase匿名認証を使用してプレイヤーを登録し、モード選択画面に遷移する
class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key});

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// ニックネームを検証
  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ニックネームを入力してください';
    }

    if (!_authService.validateNickname(value)) {
      return 'ニックネームは3文字以上20文字以内で入力してください';
    }

    return null;
  }

  /// 開始ボタンが押されたときの処理
  Future<void> _onStartPressed() async {
    // 入力検証
    final validationError = _validateNickname(_nicknameController.text);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Firebase匿名認証を実行
      final user = await _authService.signInAnonymously();

      if (user == null) {
        setState(() {
          _errorMessage = '認証に失敗しました。もう一度お試しください。';
          _isLoading = false;
        });
        return;
      }

      // 認証成功後、モード選択画面に遷移
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/babanuki-mode-selection',
          arguments: _nicknameController.text.trim(),
        );
      }
    } catch (e) {
      // エラーメッセージを整形
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }

      setState(() {
        _errorMessage = errorMsg;
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
                          'ニックネームを入力してください',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '3文字以上20文字以内',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // ニックネーム入力フィールド
                        TextField(
                          controller: _nicknameController,
                          decoration: InputDecoration(
                            labelText: 'ニックネーム',
                            hintText: '例: プレイヤー1',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.purple.shade700,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.purple.shade700,
                                width: 2,
                              ),
                            ),
                            errorText: _errorMessage,
                          ),
                          maxLength: 20,
                          enabled: !_isLoading,
                          onChanged: (value) {
                            // 入力中はエラーメッセージをクリア
                            if (_errorMessage != null) {
                              setState(() {
                                _errorMessage = null;
                              });
                            }
                          },
                          onSubmitted: (_) => _onStartPressed(),
                        ),
                        const SizedBox(height: 24),
                        // 開始ボタン
                        ElevatedButton(
                          onPressed: _isLoading ? null : _onStartPressed,
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
                                    Text(
                                      '開始',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward),
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
