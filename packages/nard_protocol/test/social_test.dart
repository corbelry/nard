import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('emotes are ids from a fixed list; no free text', () {
    expect(EmotePayload.fromJson({'id': 'good_luck'}).id, 'good_luck');
    final relayed = EmotePayload.fromJson(
      const EmotePayload('tea', from: Side.black).toJson(),
    );
    expect(relayed.from, Side.black);
    expect(
      () => EmotePayload.fromJson({'id': 'you are bad'}),
      throwsA(isA<ProtocolException>()),
    );
  });

  test('rooms and presence round-trip', () {
    final room = RoomCreatePayload.fromJson(
      const RoomCreatePayload(
        variant: Variant.longNard,
        matchLength: 3,
      ).toJson(),
    );
    expect(room.matchLength, 3);
    expect(RoomCodePayload.fromJson({'code': 'AB23CD'}).code, 'AB23CD');
    expect(
      () => RoomCodePayload.fromJson({'code': 'ab'}),
      throwsA(isA<ProtocolException>()),
    );
    expect(
      PresencePayload.fromJson(
        const PresencePayload({'u1': 'm1'}).toJson(),
      ).matches,
      {'u1': 'm1'},
    );
    expect(PresencePayload.fromJson(const {}).matches, isEmpty);
  });
}
