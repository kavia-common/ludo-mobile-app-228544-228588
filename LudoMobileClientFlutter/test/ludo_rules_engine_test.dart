import 'package:flutter_test/flutter_test.dart';

import 'package:LudoMobileClientFlutter/domain/ludo/ludo_board.dart';
import 'package:LudoMobileClientFlutter/domain/ludo/ludo_models.dart';
import 'package:LudoMobileClientFlutter/domain/ludo/ludo_rules_engine.dart';

void main() {
  group('LudoRulesEngine', () {
    test('legal moves: from yard requires 6', () {
      final state = GameState.newLocalGame();

      final moves3 = LudoRulesEngine.legalMoves(state, 3);
      expect(moves3, isEmpty);

      final moves6 = LudoRulesEngine.legalMoves(state, 6);
      expect(moves6.length, LudoBoard.piecesPerPlayer);
      expect(moves6.every((m) => m.piece.color == LudoColor.red), isTrue);
    });

    test('capture: landing on non-safe cell captures opponent and sends to yard', () {
      // Arrange: red piece on track 1, green piece on track 4; red rolls 3 to land on 4.
      final state0 = GameState.newLocalGame();
      final red0 = const LudoPieceId(color: LudoColor.red, number: 0);
      final green0 = const LudoPieceId(color: LudoColor.green, number: 0);

      // Ensure 4 is not a safe cell with our board definition.
      expect(LudoBoard.isSafeCell(4), isFalse);

      final positions = Map<LudoPieceId, PiecePosition>.from(state0.positions);
      positions[red0] = const PiecePosition.track(1);
      positions[green0] = const PiecePosition.track(4);

      final state = state0.copyWith(
        positions: positions,
        activePlayerIndex: 0,
        diceValue: 3,
        awaitingMove: true,
      );

      final move = LudoMove(piece: red0, dice: 3);
      final next = LudoRulesEngine.applyMove(state, move);

      expect(next.positions[red0], const PiecePosition.track(4));
      expect(next.positions[green0], const PiecePosition.yard());
    });

    test('safe cells: landing on safe cell does not capture', () {
      // Arrange: safe cell 8. Red lands on 8 with an opponent already there.
      final state0 = GameState.newLocalGame();
      final red0 = const LudoPieceId(color: LudoColor.red, number: 0);
      final green0 = const LudoPieceId(color: LudoColor.green, number: 0);

      expect(LudoBoard.isSafeCell(8), isTrue);

      final positions = Map<LudoPieceId, PiecePosition>.from(state0.positions);
      positions[red0] = const PiecePosition.track(5);
      positions[green0] = const PiecePosition.track(8);

      final state = state0.copyWith(
        positions: positions,
        activePlayerIndex: 0,
        diceValue: 3,
        awaitingMove: true,
      );

      final move = const LudoMove(piece: red0, dice: 3);
      final next = LudoRulesEngine.applyMove(state, move);

      expect(next.positions[red0], const PiecePosition.track(8));
      expect(next.positions[green0], const PiecePosition.track(8));
    });

    test('extra turn on six keeps player when ending turn (consumes extra roll)', () {
      final state0 = GameState.newLocalGame().copyWith(extraRollAvailable: true);

      final samePlayer = LudoRulesEngine.endTurnIfNeeded(state0);
      expect(samePlayer.activePlayerIndex, 0);
      expect(samePlayer.extraRollAvailable, isFalse);

      final advanced = LudoRulesEngine.endTurnIfNeeded(samePlayer);
      expect(advanced.activePlayerIndex, 1);
    });

    test('win detection: all 4 pieces finished ends game', () {
      final state0 = GameState.newLocalGame();
      final positions = Map<LudoPieceId, PiecePosition>.from(state0.positions);

      for (var i = 0; i < 4; i++) {
        positions[LudoPieceId(color: LudoColor.red, number: i)] =
            const PiecePosition.homeStretch(6);
      }

      // Set up a trivial move for red that should still report win immediately.
      positions[const LudoPieceId(color: LudoColor.red, number: 0)] =
          const PiecePosition.homeStretch(5);

      final state = state0.copyWith(
        positions: positions,
        activePlayerIndex: 0,
        awaitingMove: true,
        diceValue: 1,
      );

      final next = LudoRulesEngine.applyMove(
        state,
        const LudoMove(piece: LudoPieceId(color: LudoColor.red, number: 0), dice: 1),
      );

      expect(next.isGameOver, isTrue);
      expect(next.winner, LudoColor.red);
    });
  });
}
