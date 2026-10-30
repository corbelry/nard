import '../dice.dart';
import '../move.dart';
import '../rules/rule_set.dart';
import '../side.dart';

/// Everything that can happen in a game. A game is fully described by its
/// rule set, configuration and the ordered list of actions, which is what a
/// `GameRecord` stores and what the server validates.
sealed class GameAction {
  const GameAction();

  String get type;

  Map<String, Object?> toJson();

  static GameAction fromJson(Map<String, Object?> json) {
    Side side(String key) => Side.values.byName(json[key]! as String);
    WinKind kind() => WinKind.values.byName(json['kind']! as String);
    return switch (json['type']) {
      'opening' => OpeningRoll(json['white']! as int, json['black']! as int),
      'roll' => RollDice(
        side('by'),
        DiceRoll(json['d1']! as int, json['d2']! as int),
      ),
      'turn' => PlayTurn(side('by'), [
        for (final m in (json['moves']! as List).cast<Map<String, Object?>>())
          Move(
            m['from']! as int,
            m['to']! as int,
            m['die']! as int,
            hit: m['hit'] as bool? ?? false,
          ),
      ]),
      'double' => OfferDouble(side('by')),
      'take' => TakeDouble(side('by')),
      'drop' => DropDouble(side('by')),
      'resign' => OfferResignation(side('by'), kind()),
      'acceptResign' => AcceptResignation(side('by')),
      'rejectResign' => RejectResignation(side('by')),
      'forfeit' => Forfeit(side('loser'), kind()),
      final t => throw FormatException('Unknown action type: $t'),
    };
  }
}

/// Each side throws one die to decide who starts. Ties are re-thrown.
final class OpeningRoll extends GameAction {
  OpeningRoll(this.white, this.black) {
    if (!DiceRoll.isValidDie(white) || !DiceRoll.isValidDie(black)) {
      throw ArgumentError('Dice must be in 1..6');
    }
  }

  final int white;
  final int black;

  @override
  String get type => 'opening';

  @override
  Map<String, Object?> toJson() => {
    'type': type,
    'white': white,
    'black': black,
  };
}

/// An action taken by a specific side.
sealed class SideAction extends GameAction {
  const SideAction(this.by);

  final Side by;
}

final class RollDice extends SideAction {
  const RollDice(super.by, this.roll);

  final DiceRoll roll;

  @override
  String get type => 'roll';

  @override
  Map<String, Object?> toJson() => {
    'type': type,
    'by': by.name,
    'd1': roll.die1,
    'd2': roll.die2,
  };
}

final class PlayTurn extends SideAction {
  PlayTurn(super.by, List<Move> moves) : moves = List.unmodifiable(moves);

  final List<Move> moves;

  @override
  String get type => 'turn';

  @override
  Map<String, Object?> toJson() => {
    'type': type,
    'by': by.name,
    'moves': [
      for (final m in moves)
        {'from': m.from, 'to': m.to, 'die': m.die, if (m.hit) 'hit': true},
    ],
  };
}

final class OfferDouble extends SideAction {
  const OfferDouble(super.by);

  @override
  String get type => 'double';

  @override
  Map<String, Object?> toJson() => {'type': type, 'by': by.name};
}

final class TakeDouble extends SideAction {
  const TakeDouble(super.by);

  @override
  String get type => 'take';

  @override
  Map<String, Object?> toJson() => {'type': type, 'by': by.name};
}

final class DropDouble extends SideAction {
  const DropDouble(super.by);

  @override
  String get type => 'drop';

  @override
  Map<String, Object?> toJson() => {'type': type, 'by': by.name};
}

final class OfferResignation extends SideAction {
  const OfferResignation(super.by, this.kind);

  final WinKind kind;

  @override
  String get type => 'resign';

  @override
  Map<String, Object?> toJson() => {
    'type': type,
    'by': by.name,
    'kind': kind.name,
  };
}

final class AcceptResignation extends SideAction {
  const AcceptResignation(super.by);

  @override
  String get type => 'acceptResign';

  @override
  Map<String, Object?> toJson() => {'type': type, 'by': by.name};
}

final class RejectResignation extends SideAction {
  const RejectResignation(super.by);

  @override
  String get type => 'rejectResign';

  @override
  Map<String, Object?> toJson() => {'type': type, 'by': by.name};
}

/// Server-imposed loss (timeout, abandonment). Not a player choice.
final class Forfeit extends GameAction {
  const Forfeit(this.loser, this.kind);

  final Side loser;
  final WinKind kind;

  @override
  String get type => 'forfeit';

  @override
  Map<String, Object?> toJson() => {
    'type': type,
    'loser': loser.name,
    'kind': kind.name,
  };
}
