import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/match_result.dart';

void main() {
  group('MatchResult', () {
    test('MatchResultの初期化が正しく行われる', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 3,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 1,
      );

      expect(matchResult.player1CharacterId, 'local_hero_1');
      expect(matchResult.player2CharacterId, 'shop_owner');
      expect(matchResult.player1Score, 3);
      expect(matchResult.player2Score, 2);
      expect(matchResult.timestamp, timestamp);
      expect(matchResult.winnerId, 1);
    });

    test('toJsonメソッドが正しいJSON形式に変換する', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 3,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 1,
      );

      final json = matchResult.toJson();

      expect(json['player1CharacterId'], 'local_hero_1');
      expect(json['player2CharacterId'], 'shop_owner');
      expect(json['player1Score'], 3);
      expect(json['player2Score'], 2);
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['winnerId'], 1);
    });

    test('fromJsonメソッドがJSONから正しくインスタンスを作成する', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final json = {
        'player1CharacterId': 'local_hero_1',
        'player2CharacterId': 'shop_owner',
        'player1Score': 3,
        'player2Score': 2,
        'timestamp': timestamp.toIso8601String(),
        'winnerId': 1,
      };

      final matchResult = MatchResult.fromJson(json);

      expect(matchResult.player1CharacterId, 'local_hero_1');
      expect(matchResult.player2CharacterId, 'shop_owner');
      expect(matchResult.player1Score, 3);
      expect(matchResult.player2Score, 2);
      expect(matchResult.timestamp, timestamp);
      expect(matchResult.winnerId, 1);
    });

    test('toJsonとfromJsonのラウンドトリップが正しく動作する', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final original = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 3,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 1,
      );

      final json = original.toJson();
      final restored = MatchResult.fromJson(json);

      expect(restored.player1CharacterId, original.player1CharacterId);
      expect(restored.player2CharacterId, original.player2CharacterId);
      expect(restored.player1Score, original.player1Score);
      expect(restored.player2Score, original.player2Score);
      expect(restored.timestamp, original.timestamp);
      expect(restored.winnerId, original.winnerId);
    });

    test('同じ値を持つMatchResultは等しい', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult1 = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 3,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 1,
      );

      final matchResult2 = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 3,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 1,
      );

      expect(matchResult1, equals(matchResult2));
      expect(matchResult1.hashCode, equals(matchResult2.hashCode));
    });

    test('異なる値を持つMatchResultは等しくない', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult1 = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 3,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 1,
      );

      final matchResult2 = MatchResult(
        player1CharacterId: 'student',
        player2CharacterId: 'firefighter',
        player1Score: 1,
        player2Score: 4,
        timestamp: timestamp,
        winnerId: 2,
      );

      expect(matchResult1, isNot(equals(matchResult2)));
    });

    test('toStringメソッドが正しい文字列を返す', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 3,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 1,
      );

      final result = matchResult.toString();
      expect(result, contains('local_hero_1'));
      expect(result, contains('shop_owner'));
      expect(result, contains('3'));
      expect(result, contains('2'));
      expect(result, contains('1'));
    });

    test('引き分けの試合結果を正しく記録できる', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 2,
        player2Score: 2,
        timestamp: timestamp,
        winnerId: 0,
      );

      expect(matchResult.winnerId, 0);
      expect(matchResult.player1Score, matchResult.player2Score);
    });

    test('プレイヤー2が勝利した試合結果を正しく記録できる', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 1,
        player2Score: 3,
        timestamp: timestamp,
        winnerId: 2,
      );

      expect(matchResult.winnerId, 2);
      expect(matchResult.player2Score, greaterThan(matchResult.player1Score));
    });

    test('スコアが0の試合結果を正しく記録できる', () {
      final timestamp = DateTime(2024, 1, 15, 10, 30);
      final matchResult = MatchResult(
        player1CharacterId: 'local_hero_1',
        player2CharacterId: 'shop_owner',
        player1Score: 0,
        player2Score: 0,
        timestamp: timestamp,
        winnerId: 0,
      );

      expect(matchResult.player1Score, 0);
      expect(matchResult.player2Score, 0);
      expect(matchResult.winnerId, 0);
    });
  });
}
