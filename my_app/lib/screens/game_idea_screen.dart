import 'package:flutter/material.dart';
import 'package:my_app/data/party_game_catalog.dart';
import 'package:my_app/models/party_game_definition.dart';

class GameIdeaScreen extends StatelessWidget {
  const GameIdeaScreen({super.key, required this.game});

  final PartyGameDefinition game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: Icon(game.icon, color: game.color),
                title: Text(game.title),
                subtitle: Text(game.description),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: PartyGameCatalog.availabilityColor(
                      game.availability,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    PartyGameCatalog.availabilityLabel(game.availability),
                    style: TextStyle(
                      color: PartyGameCatalog.availabilityColor(game.availability),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '開発メモ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'この画面は、アイデア段階のゲームをホームから選択可能にしつつ、'
              '将来的に仕様を詳細化して実装へ繋げるための共通テンプレートです。\n\n'
              'タグ: ${game.tags.join(' / ')}',
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('ホームに戻る'),
            ),
          ],
        ),
      ),
    );
  }
}
