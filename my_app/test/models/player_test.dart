import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/player.dart';
import 'package:my_app/models/card.dart';

void main() {
  group('Player Model Tests', () {
    // テスト用のサンプルデータ
    final testId = 'test-player-id-123';
    final testNickname = 'TestPlayer';
    final testHand = [
      Card(suit: 'Hearts', rank: 'A', isJoker: false),
      Card(suit: 'Spades', rank: 'K', isJoker: false),
      Card(suit: 'Diamonds', rank: 'Q', isJoker: false),
    ];
    final testLastSeen = DateTime(2024, 1, 1, 12, 0, 0);

    group('シリアライゼーションテスト', () {
      test('toMap()は正しいMap形式に変換される', () {
        // Arrange
        final player = Player(
          id: testId,
          nickname: testNickname,
          hand: testHand,
          isConnected: true,
          lastSeen: testLastSeen,
        );

        // Act
        final map = player.toMap();

        // Assert
        expect(map['id'], testId);
        expect(map['nickname'], testNickname);
        expect(map['isConnected'], true);
        expect(map['lastSeen'], testLastSeen.toIso8601String());
        expect(map['hand'], isA<List>());
        expect(map['hand'].length, 3);

        // 手札の各カードが正しく変換されているか確認
        final handList = map['hand'] as List;
        expect(handList[0]['suit'], 'Hearts');
        expect(handList[0]['rank'], 'A');
        expect(handList[0]['isJoker'], false);
      });

      test('fromMap()は正しいPlayerオブジェクトを作成する', () {
        // Arrange
        final map = {
          'id': testId,
          'nickname': testNickname,
          'hand': [
            {'suit': 'Hearts', 'rank': 'A', 'isJoker': false},
            {'suit': 'Spades', 'rank': 'K', 'isJoker': false},
            {'suit': 'Diamonds', 'rank': 'Q', 'isJoker': false},
          ],
          'isConnected': true,
          'lastSeen': testLastSeen.toIso8601String(),
        };

        // Act
        final player = Player.fromMap(map);

        // Assert
        expect(player.id, testId);
        expect(player.nickname, testNickname);
        expect(player.isConnected, true);
        expect(player.lastSeen, testLastSeen);
        expect(player.hand.length, 3);
        expect(player.hand[0].suit, 'Hearts');
        expect(player.hand[0].rank, 'A');
        expect(player.hand[0].isJoker, false);
      });

      test('toMap()とfromMap()のラウンドトリップで元のデータが保持される', () {
        // Arrange
        final originalPlayer = Player(
          id: testId,
          nickname: testNickname,
          hand: testHand,
          isConnected: true,
          lastSeen: testLastSeen,
        );

        // Act
        final map = originalPlayer.toMap();
        final reconstructedPlayer = Player.fromMap(map);

        // Assert
        expect(reconstructedPlayer.id, originalPlayer.id);
        expect(reconstructedPlayer.nickname, originalPlayer.nickname);
        expect(reconstructedPlayer.isConnected, originalPlayer.isConnected);
        expect(reconstructedPlayer.lastSeen, originalPlayer.lastSeen);
        expect(reconstructedPlayer.hand.length, originalPlayer.hand.length);

        for (int i = 0; i < originalPlayer.hand.length; i++) {
          expect(reconstructedPlayer.hand[i], originalPlayer.hand[i]);
        }
      });

      test('isConnectedがnullの場合、デフォルトでtrueになる', () {
        // Arrange
        final map = {
          'id': testId,
          'nickname': testNickname,
          'hand': [],
          'lastSeen': testLastSeen.toIso8601String(),
          // isConnectedを省略
        };

        // Act
        final player = Player.fromMap(map);

        // Assert
        expect(player.isConnected, true);
      });

      test('空の手札でもシリアライゼーションが正しく動作する', () {
        // Arrange
        final player = Player(
          id: testId,
          nickname: testNickname,
          hand: [],
          isConnected: false,
          lastSeen: testLastSeen,
        );

        // Act
        final map = player.toMap();
        final reconstructedPlayer = Player.fromMap(map);

        // Assert
        expect(reconstructedPlayer.hand, isEmpty);
        expect(reconstructedPlayer.isConnected, false);
      });

      test('ジョーカーを含む手札でもシリアライゼーションが正しく動作する', () {
        // Arrange
        final handWithJoker = [
          Card(suit: 'Hearts', rank: 'A', isJoker: false),
          Card(suit: '', rank: '', isJoker: true),
        ];
        final player = Player(
          id: testId,
          nickname: testNickname,
          hand: handWithJoker,
          isConnected: true,
          lastSeen: testLastSeen,
        );

        // Act
        final map = player.toMap();
        final reconstructedPlayer = Player.fromMap(map);

        // Assert
        expect(reconstructedPlayer.hand.length, 2);
        expect(reconstructedPlayer.hand[1].isJoker, true);
      });
    });
  });
}
