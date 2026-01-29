import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/repositories/game_repository.dart';
import 'package:my_app/models/match_result.dart';
import 'package:my_app/models/player_stats.dart';

void main() {
  group('GameRepository', () {
    late GameRepository repository;

    setUp(() async {
      // SharedPreferencesのモックを初期化
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = GameRepository(prefs: prefs);
    });

    tearDown(() async {
      // テスト後にデータをクリア
      await repository.clearAll();
    });

    group('試合結果の保存と読み込み', () {
      test('試合結果を保存して読み込むことができる', () async {
        // 試合結果を作成
        final matchResult = MatchResult(
          player1CharacterId: 'char_1',
          player2CharacterId: 'char_2',
          player1Score: 3,
          player2Score: 2,
          timestamp: DateTime(2024, 1, 1, 12, 0),
          winnerId: 1,
        );

        // 保存
        final saveResult = await repository.saveMatchResult(matchResult);
        expect(saveResult, true);

        // 読み込み
        final loadedResult = await repository.loadMatchResult();
        expect(loadedResult, isNotNull);
        expect(loadedResult!.player1CharacterId, 'char_1');
        expect(loadedResult.player2CharacterId, 'char_2');
        expect(loadedResult.player1Score, 3);
        expect(loadedResult.player2Score, 2);
        expect(loadedResult.winnerId, 1);
      });

      test('データがない場合はnullを返す', () async {
        final result = await repository.loadMatchResult();
        expect(result, isNull);
      });

      test('複数の試合結果を保存して最新のものを読み込むことができる', () async {
        // 1つ目の試合結果
        final matchResult1 = MatchResult(
          player1CharacterId: 'char_1',
          player2CharacterId: 'char_2',
          player1Score: 3,
          player2Score: 2,
          timestamp: DateTime(2024, 1, 1, 12, 0),
          winnerId: 1,
        );

        // 2つ目の試合結果
        final matchResult2 = MatchResult(
          player1CharacterId: 'char_3',
          player2CharacterId: 'char_4',
          player1Score: 1,
          player2Score: 4,
          timestamp: DateTime(2024, 1, 2, 12, 0),
          winnerId: 2,
        );

        // 保存
        await repository.saveMatchResult(matchResult1);
        await repository.saveMatchResult(matchResult2);

        // 最新の試合結果を読み込み
        final loadedResult = await repository.loadMatchResult();
        expect(loadedResult, isNotNull);
        expect(loadedResult!.player1CharacterId, 'char_3');
        expect(loadedResult.player2CharacterId, 'char_4');
        expect(loadedResult.winnerId, 2);
      });

      test('すべての試合結果を読み込むことができる', () async {
        // 試合結果を作成
        final matchResult1 = MatchResult(
          player1CharacterId: 'char_1',
          player2CharacterId: 'char_2',
          player1Score: 3,
          player2Score: 2,
          timestamp: DateTime(2024, 1, 1, 12, 0),
          winnerId: 1,
        );

        final matchResult2 = MatchResult(
          player1CharacterId: 'char_3',
          player2CharacterId: 'char_4',
          player1Score: 1,
          player2Score: 4,
          timestamp: DateTime(2024, 1, 2, 12, 0),
          winnerId: 2,
        );

        // 保存
        await repository.saveMatchResult(matchResult1);
        await repository.saveMatchResult(matchResult2);

        // すべての試合結果を読み込み
        final results = await repository.loadAllMatchResults();
        expect(results.length, 2);
        expect(results[0].player1CharacterId, 'char_1');
        expect(results[1].player1CharacterId, 'char_3');
      });
    });

    group('プレイヤー統計の保存と読み込み', () {
      test('プレイヤー統計を保存して読み込むことができる', () async {
        // プレイヤー統計を作成
        final stats = PlayerStats(
          totalMatches: 10,
          wins: 6,
          losses: 3,
          draws: 1,
          totalGoals: 25,
          totalPlayTime: 900.0,
          characterUsage: {'char_1': 5, 'char_2': 5},
        );

        // 保存
        final saveResult = await repository.savePlayerStats(stats);
        expect(saveResult, true);

        // 読み込み
        final loadedStats = await repository.loadPlayerStats();
        expect(loadedStats.totalMatches, 10);
        expect(loadedStats.wins, 6);
        expect(loadedStats.losses, 3);
        expect(loadedStats.draws, 1);
        expect(loadedStats.totalGoals, 25);
        expect(loadedStats.totalPlayTime, 900.0);
        expect(loadedStats.characterUsage['char_1'], 5);
        expect(loadedStats.characterUsage['char_2'], 5);
      });

      test('データがない場合は空の統計を返す', () async {
        final stats = await repository.loadPlayerStats();
        expect(stats.totalMatches, 0);
        expect(stats.wins, 0);
        expect(stats.losses, 0);
        expect(stats.draws, 0);
        expect(stats.totalGoals, 0);
        expect(stats.totalPlayTime, 0.0);
        expect(stats.characterUsage, isEmpty);
      });

      test('統計を更新して保存できる', () async {
        // 初期統計
        final initialStats = PlayerStats.empty();
        await repository.savePlayerStats(initialStats);

        // 試合結果を反映して更新
        final updatedStats = initialStats.updateWithMatch(
          playerNumber: 1,
          playerScore: 3,
          opponentScore: 2,
          characterId: 'char_1',
          playTime: 90.0,
        );

        // 更新した統計を保存
        await repository.savePlayerStats(updatedStats);

        // 読み込み
        final loadedStats = await repository.loadPlayerStats();
        expect(loadedStats.totalMatches, 1);
        expect(loadedStats.wins, 1);
        expect(loadedStats.totalGoals, 3);
        expect(loadedStats.totalPlayTime, 90.0);
        expect(loadedStats.characterUsage['char_1'], 1);
      });
    });

    group('キャラクター選択の保存と読み込み', () {
      test('選択されたキャラクターを保存して読み込むことができる', () async {
        // キャラクターIDを保存
        final saveResult = await repository.saveSelectedCharacter('char_1');
        expect(saveResult, true);

        // 読み込み
        final loadedCharacterId = await repository.loadSelectedCharacter();
        expect(loadedCharacterId, 'char_1');
      });

      test('データがない場合はnullを返す', () async {
        final characterId = await repository.loadSelectedCharacter();
        expect(characterId, isNull);
      });

      test('キャラクター選択を更新できる', () async {
        // 最初のキャラクターを保存
        await repository.saveSelectedCharacter('char_1');

        // 別のキャラクターに更新
        await repository.saveSelectedCharacter('char_2');

        // 読み込み
        final loadedCharacterId = await repository.loadSelectedCharacter();
        expect(loadedCharacterId, 'char_2');
      });
    });

    group('データのクリア', () {
      test('すべてのデータをクリアできる', () async {
        // データを保存
        final matchResult = MatchResult(
          player1CharacterId: 'char_1',
          player2CharacterId: 'char_2',
          player1Score: 3,
          player2Score: 2,
          timestamp: DateTime(2024, 1, 1, 12, 0),
          winnerId: 1,
        );
        await repository.saveMatchResult(matchResult);

        final stats = PlayerStats(
          totalMatches: 10,
          wins: 6,
          losses: 3,
          draws: 1,
          totalGoals: 25,
          totalPlayTime: 900.0,
          characterUsage: {'char_1': 5},
        );
        await repository.savePlayerStats(stats);

        await repository.saveSelectedCharacter('char_1');

        // クリア
        final clearResult = await repository.clearAll();
        expect(clearResult, true);

        // データが削除されたことを確認
        final loadedResult = await repository.loadMatchResult();
        expect(loadedResult, isNull);

        final loadedStats = await repository.loadPlayerStats();
        expect(loadedStats.totalMatches, 0);

        final loadedCharacterId = await repository.loadSelectedCharacter();
        expect(loadedCharacterId, isNull);
      });
    });

    group('エッジケース', () {
      test('引き分けの試合結果を保存できる', () async {
        final matchResult = MatchResult(
          player1CharacterId: 'char_1',
          player2CharacterId: 'char_2',
          player1Score: 2,
          player2Score: 2,
          timestamp: DateTime(2024, 1, 1, 12, 0),
          winnerId: 0, // 引き分け
        );

        await repository.saveMatchResult(matchResult);
        final loadedResult = await repository.loadMatchResult();
        expect(loadedResult!.winnerId, 0);
      });

      test('スコアが0の試合結果を保存できる', () async {
        final matchResult = MatchResult(
          player1CharacterId: 'char_1',
          player2CharacterId: 'char_2',
          player1Score: 0,
          player2Score: 0,
          timestamp: DateTime(2024, 1, 1, 12, 0),
          winnerId: 0,
        );

        await repository.saveMatchResult(matchResult);
        final loadedResult = await repository.loadMatchResult();
        expect(loadedResult!.player1Score, 0);
        expect(loadedResult.player2Score, 0);
      });

      test('空のキャラクター使用マップを持つ統計を保存できる', () async {
        final stats = PlayerStats(
          totalMatches: 0,
          wins: 0,
          losses: 0,
          draws: 0,
          totalGoals: 0,
          totalPlayTime: 0.0,
          characterUsage: {},
        );

        await repository.savePlayerStats(stats);
        final loadedStats = await repository.loadPlayerStats();
        expect(loadedStats.characterUsage, isEmpty);
      });
    });
  });
}
