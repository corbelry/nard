import 'package:game_server/src/ticket.dart';
import 'package:nard_core/nard_core.dart';
import 'package:test/test.dart';

void main() {
  const t = Ticket(
    userId: 'u1',
    name: 'Elvin',
    country: 'AZ',
    ratings: {Variant.shortNard: 1620},
    cosmetics: {'board': 'board.caspian'},
    expiresAt: 1000,
  );

  test('signed tickets verify until they expire', () {
    final token = Ticket.sign(t, 'secret');
    final back = Ticket.verify(token, 'secret', nowSeconds: 999)!;
    expect(back.userId, 'u1');
    expect(back.country, 'AZ');
    expect(back.rating(Variant.shortNard), 1620);
    expect(back.rating(Variant.longNard), 1500);
    expect(back.cosmetics, {'board': 'board.caspian'});
    expect(Ticket.verify(token, 'secret', nowSeconds: 1001), isNull);
  });

  test('tampered, foreign or malformed tickets are rejected', () {
    final token = Ticket.sign(t, 'secret');
    expect(Ticket.verify(token, 'other', nowSeconds: 0), isNull);
    final forged = Ticket.sign(
      const Ticket(userId: 'admin', name: 'x', expiresAt: 1000),
      'other',
    );
    expect(Ticket.verify(forged, 'secret', nowSeconds: 0), isNull);
    expect(Ticket.verify('abc', 'secret', nowSeconds: 0), isNull);
    expect(Ticket.verify('a.b.c', 'secret', nowSeconds: 0), isNull);
    final body = token.split('.').first;
    expect(Ticket.verify('$body.x', 'secret', nowSeconds: 0), isNull);
  });

  test('muted and queue cooldown flags round-trip (ADR-042)', () {
    final token = Ticket.sign(
      const Ticket(
        userId: 'u2',
        name: 'Nigar',
        expiresAt: 1000,
        muted: true,
        queueCooldownUntil: 900,
      ),
      'secret',
    );
    final back = Ticket.verify(token, 'secret', nowSeconds: 0)!;
    expect(back.muted, isTrue);
    expect(back.queueCooldownUntil, 900);
    expect(back.inQueueCooldown(899), isTrue);
    expect(back.inQueueCooldown(900), isFalse);
    final plain =
        Ticket.verify(Ticket.sign(t, 'secret'), 'secret', nowSeconds: 0)!;
    expect(plain.muted, isFalse);
    expect(plain.inQueueCooldown(0), isFalse);
    expect(plain.toJson().containsKey('muted'), isFalse);
  });
}
