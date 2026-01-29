import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/player_stats.dart';

void main() {
  group('PlayerStats', () {
    test('PlayerStatsの初期化が正しく行われる', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5, 'shop_owner': 5},
      );

      expect(stats.totalMatches, 10);
      expect(stats.wins, 6);
      expect(stats.losses, 3);
      expect(stats.draws, 1);
      expect(stats.totalGoals, 25);
      expect(stats.totalPlayTime, 900.0);
      expect(stats.characterUsage['local_hero_1'], 5);
      expect(stats.characterUsage['shop_owner'], 5);
    });

    test('emptyファクトリーメソッドがすべて0の統計を作成する', () {
      final stats = PlayerStats.empty();

      expect(stats.totalMatches, 0);
      expect(stats.wins, 0);
      expect(stats.losses, 0);
      expect(stats.draws, 0);
      expect(stats.totalGoals, 0);
      expect(stats.totalPlayTime, 0.0);
      expect(stats.characterUsage.isEmpty, isTrue);
    });

    test('winRateが正しく計算される', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {},
      );

      expect(stats.winRate, closeTo(0.6, 0.001));
    });

    test('試合数が0の場合winRateは0.0を返す', () {
      final stats = PlayerStats.empty();
      expect(stats.winRate, 0.0);
    });

    test('toJsonメソッドが正しいJSON形式に変換する', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5, 'shop_owner': 5},
      );

      final json = stats.toJson();

      expect(json['totalMatches'], 10);
      expect(json['wins'], 6);
      expect(json['losses'], 3);
      expect(json['draws'], 1);
      expect(json['totalGoals'], 25);
      expect(json['totalPlayTime'], 900.0);
      expect(json['characterUsage']['local_hero_1'], 5);
      expect(json['characterUsage']['shop_owner'], 5);
    });

    test('fromJsonメソッドがJSONから正しくインスタンスを作成する', () {
      final json = {
        'totalMatches': 10,
        'wins': 6,
        'losses': 3,
        'draws': 1,
        'totalGoals': 25,
        'totalPlayTime': 900.0,
        'characterUsage': {'local_hero_1': 5, 'shop_owner': 5},
      };

      final stats = PlayerStats.fromJson(json);

      expect(stats.totalMatches, 10);
      expect(stats.wins, 6);
      expect(stats.losses, 3);
      expect(stats.draws, 1);
      expect(stats.totalGoals, 25);
      expect(stats.totalPlayTime, 900.0);
      expect(stats.characterUsage['local_hero_1'], 5);
      expect(stats.characterUsage['shop_owner'], 5);
    });

    test('toJsonとfromJsonのラウンドトリップが正しく動作する', () {
      final original = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5, 'shop_owner': 5},
      );

      final json = original.toJson();
      final restored = PlayerStats.fromJson(json);

      expect(restored.totalMatches, original.totalMatches);
      expect(restored.wins, original.wins);
      expect(restored.losses, original.losses);
      expect(restored.draws, original.draws);
      expect(restored.totalGoals, original.totalGoals);
      expect(restored.totalPlayTime, original.totalPlayTime);
      expect(restored.characterUsage, original.characterUsage);
    });

    test('characterUsageがnullの場合、空のマップとして処理される', () {
      final json = {
        'totalMatches': 5,
        'wins': 3,
        'losses': 2,
        'draws': 0,
        'totalGoals': 10,
        'totalPlayTime': 450.0,
        'characterUsage': null,
      };

      final stats = PlayerStats.fromJson(json);
      expect(stats.characterUsage.isEmpty, isTrue);
    });

    test('同じ値を持つPlayerStatsは等しい', () {
      final stats1 = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5},
      );

      final stats2 = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5},
      );

      expect(stats1, equals(stats2));
      expect(stats1.hashCode, equals(stats2.hashCode));
    });

    test('異なる値を持つPlayerStatsは等しくない', () {
      final stats1 = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5},
      );

      final stats2 = PlayerStats(
        totalMatches: 5,
        wins: 3,
        losses: 2,
        draws: 0,
        totalGoals: 10,
        totalPlayTime: 450.0,
        characterUsage: {'shop_owner': 5},
      );

      expect(stats1, isNot(equals(stats2)));
    });

    test('toStringメソッドが正しい文字列を返す', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {},
      );

      final result = stats.toString();
      expect(result, contains('10'));
      expect(result, contains('6'));
      expect(result, contains('3'));
      expect(result, contains('1'));
      expect(result, contains('25'));
      expect(result, contains('900'));
      expect(result, contains('60.0%'));
    });

    test('updateWithMatchで勝利時に統計が正しく更新される', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5},
      );

      final updated = stats.updateWithMatch(
        playerNumber: 1,
        playerScore: 3,
        opponentScore: 2,
        characterId: 'local_hero_1',
        playTime: 90.0,
      );

      expect(updated.totalMatches, 11);
      expect(updated.wins, 7);
      expect(updated.losses, 3);
      expect(updated.draws, 1);
      expect(updated.totalGoals, 28);
      expect(updated.totalPlayTime, 990.0);
      expect(updated.characterUsage['local_hero_1'], 6);
    });

    test('updateWithMatchで敗北時に統計が正しく更新される', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5},
      );

      final updated = stats.updateWithMatch(
        playerNumber: 1,
        playerScore: 1,
        opponentScore: 3,
        characterId: 'shop_owner',
        playTime: 90.0,
      );

      expect(updated.totalMatches, 11);
      expect(updated.wins, 6);
      expect(updated.losses, 4);
      expect(updated.draws, 1);
      expect(updated.totalGoals, 26);
      expect(updated.totalPlayTime, 990.0);
      expect(updated.characterUsage['shop_owner'], 1);
    });

    test('updateWithMatchで引き分け時に統計が正しく更新される', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5},
      );

      final updated = stats.updateWithMatch(
        playerNumber: 1,
        playerScore: 2,
        opponentScore: 2,
        characterId: 'student',
        playTime: 90.0,
      );

      expect(updated.totalMatches, 11);
      expect(updated.wins, 6);
      expect(updated.losses, 3);
      expect(updated.draws, 2);
      expect(updated.totalGoals, 27);
      expect(updated.totalPlayTime, 990.0);
      expect(updated.characterUsage['student'], 1);
    });

    test('updateWithMatchで新しいキャラクターの使用回数が正しく記録される', () {
      final stats = PlayerStats(
        totalMatches: 5,
        wins: 3,
        losses: 2,
        draws: 0,
        totalGoals: 15,
        totalPlayTime: 450.0,
        characterUsage: {'local_hero_1': 5},
      );

      final updated = stats.updateWithMatch(
        playerNumber: 1,
        playerScore: 3,
        opponentScore: 1,
        characterId: 'firefighter',
        playTime: 90.0,
      );

      expect(updated.characterUsage['local_hero_1'], 5);
      expect(updated.characterUsage['firefighter'], 1);
    });

    test('updateWithMatchで既存のキャラクター使用回数が増加する', () {
      final stats = PlayerStats(
        totalMatches: 5,
        wins: 3,
        losses: 2,
        draws: 0,
        totalGoals: 15,
        totalPlayTime: 450.0,
        characterUsage: {'local_hero_1': 5},
      );

      final updated = stats.updateWithMatch(
        playerNumber: 1,
        playerScore: 2,
        opponentScore: 1,
        characterId: 'local_hero_1',
        playTime: 90.0,
      );

      expect(updated.characterUsage['local_hero_1'], 6);
    });

    test('updateWithMatchで元の統計は変更されない（イミュータブル）', () {
      final stats = PlayerStats(
        totalMatches: 10,
        wins: 6,
        losses: 3,
        draws: 1,
        totalGoals: 25,
        totalPlayTime: 900.0,
        characterUsage: {'local_hero_1': 5},
      );

      final updated = stats.updateWithMatch(
        playerNumber: 1,
        playerScore: 3,
        opponentScore: 2,
        characterId: 'local_hero_1',
        playTime: 90.0,
      );

      // 元の統計は変更されていないことを確認
      expect(stats.totalMatches, 10);
      expect(stats.wins, 6);
      expect(stats.characterUsage['local_hero_1'], 5);

      // 新しい統計は更新されていることを確認
      expect(updated.totalMatches, 11);
      expect(updated.wins, 7);
      expect(updated.characterUsage['local_hero_1'], 6);
    });
  });
}
