/// Protocol version; bumped on any breaking change to message shapes.
const int protocolVersion = 1;

/// Message types (spec §7.2, docs/PROTOCOL.md).
abstract final class MessageType {
  static const hello = 'hello';
  static const auth = 'auth';
  static const queueJoin = 'queue.join';
  static const queueLeave = 'queue.leave';
  static const matchFound = 'match.found';
  static const gameState = 'game.state';
  static const gameSeed = 'game.seed';
  static const gameRoll = 'game.roll';
  static const gameMove = 'game.move';
  static const gameUndo = 'game.undo';
  static const gameConfirmTurn = 'game.confirmTurn';
  static const cubeOffer = 'cube.offer';
  static const cubeTake = 'cube.take';
  static const cubeDrop = 'cube.drop';
  static const gameResign = 'game.resign';
  static const gameTimeout = 'game.timeout';
  static const chatEmote = 'chat.emote';
  static const spectateJoin = 'spectate.join';
  static const ping = 'ping';
  static const pong = 'pong';
  static const error = 'error';

  static const all = {
    hello,
    auth,
    queueJoin,
    queueLeave,
    matchFound,
    gameState,
    gameSeed,
    gameRoll,
    gameMove,
    gameUndo,
    gameConfirmTurn,
    cubeOffer,
    cubeTake,
    cubeDrop,
    gameResign,
    gameTimeout,
    chatEmote,
    spectateJoin,
    ping,
    pong,
    error,
  };
}

/// Every WebSocket frame: `{ v, type, id, ts, payload }`.
class Envelope {
  const Envelope({
    required this.type,
    required this.id,
    required this.ts,
    this.payload = const {},
    this.version = protocolVersion,
  });

  final String type;

  /// Client-generated id, echoed in replies for correlation.
  final String id;

  /// Milliseconds since epoch (sender clock).
  final int ts;
  final Map<String, Object?> payload;
  final int version;

  Map<String, Object?> toJson() => {
    'v': version,
    'type': type,
    'id': id,
    'ts': ts,
    'payload': payload,
  };

  /// Parses and validates a decoded JSON frame.
  static Envelope fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('Envelope must be a JSON object');
    }
    final type = json['type'];
    final id = json['id'];
    final ts = json['ts'];
    final payload = json['payload'] ?? const <String, Object?>{};
    final version = json['v'] ?? protocolVersion;
    if (type is! String || !MessageType.all.contains(type)) {
      throw FormatException('Unknown message type: $type');
    }
    if (id is! String || id.isEmpty || id.length > 64) {
      throw const FormatException('Invalid id');
    }
    if (ts is! int) throw const FormatException('Invalid ts');
    if (payload is! Map<String, Object?>) {
      throw const FormatException('Payload must be an object');
    }
    if (version is! int) throw const FormatException('Invalid version');
    return Envelope(
      type: type,
      id: id,
      ts: ts,
      payload: payload,
      version: version,
    );
  }
}
