import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/card.dart';
import 'dart:math';

void main() {
  group('Card Property Tests', () {
    // Feature: babanuki-game, Property 5: ランクに基づくペア判定
    // Validates: Requirements 5.2, 5.4
    test(
      'Property 5: 任意の2枚のカードについて、それらが同じランクを持つ場合にのみペアを形成し、ジョーカーはどのカードともペアを形成してはならない',
      () {
        final random = Random();
        final suits = ['hearts', 'diamonds', 'spades', 'clubs'];
        final ranks = [
          'A',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          'J',
          'Q',
          'K',
        ];

        // 100回のイテレーションでプロパティをテスト
        for (int i = 0; i < 100; i++) {
          // ランダムなカードを生成
          final suit1 = suits[random.nextInt(suits.length)];
          final suit2 = suits[random.nextInt(suits.length)];
          final rank1 = ranks[random.nextInt(ranks.length)];
          final rank2 = ranks[random.nextInt(ranks.length)];

          final card1 = Card(suit: suit1, rank: rank1, isJoker: false);
          final card2 = Card(suit: suit2, rank: rank2, isJoker: false);

          // プロパティ: 同じランクの場合のみペアを形成
          if (rank1 == rank2) {
            expect(
              card1.canPairWith(card2),
              true,
              reason: 'Cards with same rank ($rank1) should form a pair',
            );
            expect(
              card2.canPairWith(card1),
              true,
              reason: 'Pair formation should be symmetric',
            );
          } else {
            expect(
              card1.canPairWith(card2),
              false,
              reason:
                  'Cards with different ranks ($rank1, $rank2) should not form a pair',
            );
          }
        }

        // ジョーカーのテスト
        for (int i = 0; i < 100; i++) {
          final suit = suits[random.nextInt(suits.length)];
          final rank = ranks[random.nextInt(ranks.length)];

          final joker = Card(suit: 'joker', rank: 'Joker', isJoker: true);
          final normalCard = Card(suit: suit, rank: rank, isJoker: false);

          // プロパティ: ジョーカーはどのカードともペアを形成しない
          expect(
            joker.canPairWith(normalCard),
            false,
            reason: 'Joker should not pair with any normal card',
          );
          expect(
            normalCard.canPairWith(joker),
            false,
            reason: 'Normal card should not pair with joker',
          );
          expect(
            joker.canPairWith(joker),
            false,
            reason: 'Joker should not pair with another joker',
          );
        }
      },
    );
  });

  group('Card Unit Tests', () {
    test('同じランクの異なるスートのカードはペアを形成する', () {
      final card1 = Card(suit: 'hearts', rank: '7', isJoker: false);
      final card2 = Card(suit: 'diamonds', rank: '7', isJoker: false);

      expect(card1.canPairWith(card2), true);
      expect(card2.canPairWith(card1), true);
    });

    test('異なるランクのカードはペアを形成しない', () {
      final card1 = Card(suit: 'hearts', rank: '7', isJoker: false);
      final card2 = Card(suit: 'hearts', rank: '8', isJoker: false);

      expect(card1.canPairWith(card2), false);
    });

    test('ジョーカーは通常のカードとペアを形成しない', () {
      final joker = Card(suit: 'joker', rank: 'Joker', isJoker: true);
      final normalCard = Card(suit: 'hearts', rank: 'A', isJoker: false);

      expect(joker.canPairWith(normalCard), false);
      expect(normalCard.canPairWith(joker), false);
    });

    test('ジョーカー同士もペアを形成しない', () {
      final joker1 = Card(suit: 'joker', rank: 'Joker', isJoker: true);
      final joker2 = Card(suit: 'joker', rank: 'Joker', isJoker: true);

      expect(joker1.canPairWith(joker2), false);
    });
  });
}
