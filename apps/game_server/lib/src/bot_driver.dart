import 'dart:async';
import 'dart:math';

import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import 'match_room.dart';

/// Plays one seat of a [MatchRoom] with a [HeuristicBot] (casual fallback,
/// ADR-024). It reacts to the room's `game.state` like a client would.
class BotDriver {
  BotDriver({
    required this.room,
    required this.side,
    BotLevel level = BotLevel.medium,
    Random? random,
    this.thinking = const Duration(milliseconds: 900),
  }) : _random = random ?? Random(),
       _bot = HeuristicBot(level, random: random);

  final MatchRoom room;
  final Side side;
  final Duration thinking;
  final Random _random;
  final HeuristicBot _bot;
  Timer? _timer;
  int _ids = 0;

  /// Feed every message the room sends to [side].
  void receive(Envelope message) {
    if (message.type != MessageType.gameState) return;
    _timer?.cancel();
    _timer = Timer(thinking, _act);
  }

  void _send(String type, [Map<String, Object?> payload = const {}]) =>
      room.handle(
        side,
        Envelope(type: type, id: 'bot${_ids++}', ts: 0, payload: payload),
      );

  void _act() {
    if (room.isOver) return;
    final game = room.game;
    final rules = game.rules;
    switch (game.phase) {
      case GamePhase.opening:
        _send(
          MessageType.gameSeed,
          SeedPayload('bot-${_random.nextInt(1 << 32)}').toJson(),
        );
      case GamePhase.awaitingRoll when game.turn == side:
        if (game.canDouble(side) &&
            _bot.shouldDouble(rules, game.board, side)) {
          _send(MessageType.cubeOffer);
        } else {
          _send(MessageType.gameRoll);
        }
      case GamePhase.awaitingMove when game.turn == side && !game.mustPass:
        final turn = _bot.chooseTurn(rules, game.board, game.dice!);
        for (final m in turn.moves) {
          _send(
            MessageType.gameMove,
            MovePayload(m.from, m.to, die: m.die).toJson(),
          );
        }
        _send(MessageType.gameConfirmTurn);
      case GamePhase.cubeOffered when game.turn != side:
        _send(
          _bot.shouldTake(rules, game.board, side)
              ? MessageType.cubeTake
              : MessageType.cubeDrop,
        );
      default:
        break;
    }
  }

  void dispose() => _timer?.cancel();
}
