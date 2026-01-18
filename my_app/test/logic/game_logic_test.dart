import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/logic/game_logic.dart';
import 'package:my_app/models/card.dart';

void main() {
  group('GameLogic - Deck Creation', () {
    test('Property 1: Deck always has 53 cards', () {
      for (int i = 0; i < 100; i++) {
        final deck = GameLogic.createDeck();
        expect(deck.length, equals(53));
        final jokers = deck.where((card) => card.isJoker).toList();
        expect(jokers.length, equals(1));
        final standardCards = deck.where((card) => !card.isJoker).toList();
        expect(standardCards.length, equals(52));
      }
    });
  });

  group('GameLogic - Card Dealing', () {
    test('Property 2: Even card distribution', () {
      for (int i = 0; i < 100; i++) {
        final deck = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck);
        final hands = GameLogic.dealCards(deck);
        final playerHand = hands['player']!;
        final cpuHand = hands['cpu']!;
        expect(playerHand.length + cpuHand.length, equals(53));
        final difference = (playerHand.length - cpuHand.length).abs();
        expect(difference, lessThanOrEqualTo(1));
      }
    });
  });

  group('GameLogic - Pair Removal', () {
    test('Property 3: No pairs after initial deal', () {
      for (int i = 0; i < 100; i++) {
        final deck = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck);
        final hands = GameLogic.dealCards(deck);
        final playerHand = GameLogic.removePairs(hands['player']!);
        final cpuHand = GameLogic.removePairs(hands['cpu']!);

        for (int j = 0; j < playerHand.length; j++) {
          for (int k = j + 1; k < playerHand.length; k++) {
            expect(playerHand[j].canPairWith(playerHand[k]), isFalse);
          }
        }

        for (int j = 0; j < cpuHand.length; j++) {
          for (int k = j + 1; k < cpuHand.length; k++) {
            expect(cpuHand[j].canPairWith(cpuHand[k]), isFalse);
          }
        }
      }
    });

    test('Property 4: Automatic pair removal', () {
      for (int i = 0; i < 100; i++) {
        final deck = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck);
        final hands = GameLogic.dealCards(deck);
        final hand = hands['player']!;
        final cleanedHand = GameLogic.removePairs(hand);

        if (hands['cpu']!.isNotEmpty) {
          final newCard = hands['cpu']!.first;
          final updatedHand = [...cleanedHand, newCard];
          final finalHand = GameLogic.removePairs(updatedHand);

          for (int j = 0; j < finalHand.length; j++) {
            for (int k = j + 1; k < finalHand.length; k++) {
              expect(finalHand[j].canPairWith(finalHand[k]), isFalse);
            }
          }
        }
      }
    });
  });

  group('GameLogic - Game Over', () {
    test('Property 8: Game over conditions', () {
      for (int i = 0; i < 100; i++) {
        final deck = GameLogic.createDeck();
        GameLogic.shuffleDeck(deck);
        final hands = GameLogic.dealCards(deck);

        expect(GameLogic.isGameOver([], hands['cpu']!), isTrue);
        expect(GameLogic.isGameOver(hands['player']!, []), isTrue);

        if (hands['player']!.isNotEmpty && hands['cpu']!.isNotEmpty) {
          final playerHand = GameLogic.removePairs(hands['player']!);
          final cpuHand = GameLogic.removePairs(hands['cpu']!);

          if (playerHand.length > 1 && cpuHand.length > 1) {
            expect(GameLogic.isGameOver(playerHand, cpuHand), isFalse);
          }
        }
      }
    });

    test('Property 9: Winner determination', () {
      for (int i = 0; i < 100; i++) {
        final joker = Card(suit: 'joker', rank: 'Joker', isJoker: true);
        final heart7 = Card(suit: 'hearts', rank: '7', isJoker: false);

        final playerWithJoker = [joker];
        final cpuWithoutJoker = [heart7];
        expect(
          GameLogic.determineWinner(playerWithJoker, cpuWithoutJoker),
          equals('cpu'),
        );

        final playerWithoutJoker = [heart7];
        final cpuWithJoker = [joker];
        expect(
          GameLogic.determineWinner(playerWithoutJoker, cpuWithJoker),
          equals('player'),
        );

        expect(GameLogic.determineWinner([], cpuWithJoker), equals('player'));
        expect(GameLogic.determineWinner(playerWithJoker, []), equals('cpu'));
      }
    });
  });
}
