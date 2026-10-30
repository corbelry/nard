import 'package:fake_async/fake_async.dart';
import 'package:game_server/src/matchmaker.dart';
import 'package:game_server/src/ticket.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

Ticket t(String id, int rating) => Ticket(
  userId: id,
  name: id,
  expiresAt: 0,
  ratings: {Variant.shortNard: rating},
);

const ranked = QueueJoinPayload(
  variant: Variant.shortNard,
  matchLength: 3,
  mode: QueueMode.ranked,
);
const casual = QueueJoinPayload(
  variant: Variant.shortNard,
  matchLength: 3,
  mode: QueueMode.casual,
);

void main() {
  test('rating band widens from ±50 to ±400', () {
    expect(Matchmaker.band(0), 50);
    expect(Matchmaker.band(4999), 50);
    expect(Matchmaker.band(5000), 100);
    expect(Matchmaker.band(60000), 400);
  });

  test('ranked players pair once their bands overlap; queues are separate', () {
    fakeAsync((async) {
      final pairs = <(String, String)>[];
      final mm = Matchmaker(
        onMatch: (a, b) => pairs.add((a.ticket.userId, b.ticket.userId)),
        onBot: (_) => fail('no bots in ranked'),
        now: () => async.elapsed.inMilliseconds,
      )..start();
      mm.join(t('a', 1500), ranked);
      mm.join(t('b', 1700), ranked);
      mm.join(t('c', 1500), casual.copyLengthForTest(5));
      expect(pairs, isEmpty);
      async.elapse(const Duration(seconds: 14));
      expect(pairs, isEmpty); // band 150 < 200
      async.elapse(const Duration(seconds: 2));
      expect(pairs, [('a', 'b')]);
      expect(mm.isQueued('c'), isTrue);
      mm.leave('c');
      expect(mm.isQueued('c'), isFalse);
      mm.dispose();
    });
  });

  test('casual players pair at once, or get a bot after 30 s (ADR-024)', () {
    fakeAsync((async) {
      final pairs = <(String, String)>[];
      final bots = <String>[];
      final mm = Matchmaker(
        onMatch: (a, b) => pairs.add((a.ticket.userId, b.ticket.userId)),
        onBot: (e) => bots.add(e.ticket.userId),
        now: () => async.elapsed.inMilliseconds,
      )..start();
      mm.join(t('a', 1000), casual);
      mm.join(t('b', 2000), casual);
      expect(pairs, [('a', 'b')]);
      mm.join(t('c', 1500), casual);
      async.elapse(const Duration(seconds: 29));
      expect(bots, isEmpty);
      async.elapse(const Duration(seconds: 2));
      expect(bots, ['c']);
      mm.dispose();
    });
  });

  test('players only meet others of the same time control (ADR-044)', () {
    fakeAsync((async) {
      final pairs = <(String, String)>[];
      final bots = <QueueEntry>[];
      final mm = Matchmaker(
        onMatch: (a, b) => pairs.add((a.ticket.userId, b.ticket.userId)),
        onBot: bots.add,
        now: () => async.elapsed.inMilliseconds,
      )..start();
      mm.join(t('a', 1500), casual.copyWith(timeControl: TimeControl.blitz));
      mm.join(t('b', 1500), casual);
      mm.join(t('c', 1500), casual.copyWith(timeControl: TimeControl.classic));
      mm.join(t('d', 1500), ranked.copyWith(timeControl: TimeControl.blitz));
      mm.join(t('e', 1500), ranked);
      expect(pairs, isEmpty);
      expect(mm.queueSizes(), {
        'shortNard/3/casual/blitz': 1,
        'shortNard/3/casual/rapid': 1,
        'shortNard/3/casual/classic': 1,
        'shortNard/3/ranked/blitz': 1,
        'shortNard/3/ranked/rapid': 1,
      });
      mm.join(t('f', 1500), ranked.copyWith(timeControl: TimeControl.blitz));
      expect(pairs, [('d', 'f')]);
      mm.join(t('g', 1500), casual.copyWith(timeControl: TimeControl.classic));
      expect(pairs.last, ('c', 'g'));
      // The bot fallback keeps the player's control.
      async.elapse(const Duration(seconds: 31));
      expect(
        {for (final e in bots) e.ticket.userId: e.request.timeControl},
        {'a': TimeControl.blitz, 'b': TimeControl.rapid},
      );
      mm.dispose();
    });
  });
}

extension on QueueJoinPayload {
  QueueJoinPayload copyLengthForTest(int length) =>
      QueueJoinPayload(variant: variant, matchLength: length, mode: mode);
}
