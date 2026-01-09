import 'package:flutter_test/flutter_test.dart';

import 'package:LudoMobileClientFlutter/domain/ludo/ai/ai_models.dart';
import 'package:LudoMobileClientFlutter/domain/ludo/ai/ludo_ai.dart';
import 'package:LudoMobileClientFlutter/domain/ludo/ludo_board.dart';
import 'package:LudoMobileClientFlutter/domain/ludo/ludo_models.dart';
import 'package:LudoMobileClientFlutter/domain/ludo/ludo_rules_engine.dart';

void main() {
  group('Ludo AI', () {
    test('Easy: selected move is always null or one of legalMoves', () {
      final state0 = GameState.newLocalGame();

      // Make a deterministic scenario: initial position, roll 6 => 4 legal moves.
      final dice = 6;
      final legal = LudoRulesEngine.legalMoves(state0, dice);
      expect(legal, isNotEmpty);

      final ai = LudoAiStrategies.forDifficulty(AiDifficulty.easy, seed: 1);
      final selected = ai.selectMove(state: state0, dice: dice, legalMoves: legal);

      expect(selected, isNotNull);
      expect(legal.contains(selected), isTrue);
    });

    test('Medium: prefers capture when capture is available', () {
      // Arrange a capture opportunity for red:
      // red0 on track 1, green0 on track 4 (non-safe), dice=3 -> red lands on 4 and captures.
      final state0 = GameState.newLocalGame();
      final red0 = const LudoPieceId(color: LudoColor.red, number: 0);
      final red1 = const LudoPieceId(color: LudoColor.red, number: 1);
      final green0 = const LudoPieceId(color: LudoColor.green, number: 0);

      expect(LudoBoard.isSafeCell(4), isFalse);

      final positions = Map<LudoPieceId, PiecePosition>.from(state0.positions);
      positions[red0] = const PiecePosition.track(1);
      positions[red1] = const PiecePosition.track(10);
      positions[green0] = const PiecePosition.track(4);

      final state = state0.copyWith(
        positions: positions,
        activePlayerIndex: 0,
        diceValue: 3,
        awaitingMove: true,
      );

      final legal = LudoRulesEngine.legalMoves(state, 3);
      expect(legal, isNotEmpty);

      // Confirm there exists a capturing move in legal.
      final capturingMove = legal.firstWhere(
        (m) => m.piece == red0,
        orElse: () => const LudoMove(piece: LudoPieceId(color: LudoColor.red, number: 99), dice: 3),
      );
      expect(capturingMove.piece, red0);

      final ai = LudoAiStrategies.forDifficulty(AiDifficulty.medium, seed: 7);
      final selected = ai.selectMove(state: state, dice: 3, legalMoves: legal);

      expect(selected, isNotNull);
      expect(legal.contains(selected), isTrue);

      // Medium heuristic should select the capture move in this simple setup.
      expect(selected, capturingMove);
    });

    test('Medium: never returns an illegal move (stress over multiple random seeds)', () {
      final state0 = GameState.newLocalGame();
      final dice = 6;
      final legal = LudoRulesEngine.legalMoves(state0, dice);
      expect(legal, isNotEmpty);

      for (var seed = 0; seed < 25; seed++) {
        final ai = LudoAiStrategies.forDifficulty(AiDifficulty.medium, seed: seed);
        final selected = ai.selectMove(state: state0, dice: dice, legalMoves: legal);
        expect(selected, isNotNull);
        expect(legal.contains(selected), isTrue);
      }
    });
  });
}
