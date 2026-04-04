import 'package:flutter/material.dart';
import 'package:my_app/data/party_game_catalog.dart';
import 'package:my_app/models/party_game_definition.dart';
import 'package:my_app/services/auth_service.dart';

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

  Future<void> _onBabanukiPressed() async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) => _NicknameInputDialog(
        controller: _nicknameController,
        authService: _authService,
      ),
    );

    if (nickname == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInAnonymously();
      if (user == null) {
        if (!mounted) return;
        _showErrorDialog('認証に失敗しました。もう一度お試しください。');
        return;
      }

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/babanuki-mode-selection',
        arguments: nickname,
      );
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (!mounted) return;
      _showErrorDialog(errorMsg);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: SingleChildScrollView(
          child: Text(message, style: const TextStyle(fontSize: 14)),
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

  Future<void> _onGameSelected(PartyGameDefinition game) async {
    if (_isLoading) return;

    if (game.id == 'babanuki') {
      await _onBabanukiPressed();
      return;
    }

    if (game.id == 'head_ball') {
      await _onHeadBallPressed();
      return;
    }

    if (game.routeName != null) {
      Navigator.pushNamed(context, game.routeName!);
      return;
    }

    Navigator.pushNamed(context, '/game-idea', arguments: game);
  }

  Widget _buildGameTile(PartyGameDefinition game) {
    final availabilityColor = PartyGameCatalog.availabilityColor(game.availability);

    return Card(
      child: InkWell(
        onTap: _isLoading ? null : () => _onGameSelected(game),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: game.color.withValues(alpha: 0.15),
                    child: Icon(game.icon, color: game.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      game.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: availabilityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      PartyGameCatalog.availabilityLabel(game.availability),
                      style: TextStyle(
                        color: availabilityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(game.description, style: const TextStyle(fontSize: 13)),
              if (game.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: game.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(PartyGameCategory category) {
    final items = PartyGameCatalog.games
        .where((game) => game.category == category)
        .toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          PartyGameCatalog.categoryLabel(category),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(_buildGameTile),
      ],
    );
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  children: [
                    ListView(
                      children: [
                        const Text(
                          'みんなでゲーム会',
                          style: TextStyle(
                            fontSize: 44,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '競馬を最優先に、飲み会で遊べるゲームをホームから選択',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        _buildCategorySection(PartyGameCategory.priority),
                        _buildCategorySection(PartyGameCategory.trump),
                        _buildCategorySection(PartyGameCategory.quiz),
                        _buildCategorySection(PartyGameCategory.social),
                        _buildCategorySection(PartyGameCategory.casual),
                        const SizedBox(height: 40),
                      ],
                    ),
                    if (_isLoading)
                      const Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NicknameInputDialog extends StatefulWidget {
  const _NicknameInputDialog({required this.controller, required this.authService});

  final TextEditingController controller;
  final AuthService authService;

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
            onChanged: (_) {
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
