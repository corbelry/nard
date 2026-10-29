import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:nard_protocol/nard_protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum SocketStatus { connecting, online, offline }

/// WebSocket to the game server with ticket auth, keep-alive pings and
/// automatic reconnects (a fresh ticket per attempt). Messages are
/// re-delivered through [messages]; the server resends `game.state` after
/// every reconnect, so nothing is replayed client-side.
class GameSocket {
  GameSocket({
    required this.url,
    required this.ticket,
    WebSocketChannel Function(Uri)? connect,
    this.ping = const Duration(seconds: 20),
  }) : _connect = connect ?? WebSocketChannel.connect;

  final String url;

  /// Fetches a new ticket from the API.
  final Future<String> Function() ticket;
  final WebSocketChannel Function(Uri) _connect;
  final Duration ping;

  final _messages = StreamController<Envelope>.broadcast();
  final _status = StreamController<SocketStatus>.broadcast();
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _retry;
  int _attempt = 0;
  int _ids = 0;
  bool _closed = false;
  SocketStatus _current = SocketStatus.offline;

  Stream<Envelope> get messages => _messages.stream;
  Stream<SocketStatus> get status => _status.stream;
  SocketStatus get current => _current;

  void _setStatus(SocketStatus s) {
    _current = s;
    _status.add(s);
  }

  Future<void> open() async {
    _closed = false;
    _setStatus(SocketStatus.connecting);
    try {
      final t = await ticket();
      final ch = _channel = _connect(Uri.parse(url));
      await ch.ready;
      ch.stream.listen(
        (frame) {
          if (frame is! String) return;
          try {
            final msg = Envelope.fromJson(jsonDecode(frame));
            if (msg.type == MessageType.hello) {
              _attempt = 0;
              _setStatus(SocketStatus.online);
            }
            _messages.add(msg);
          } on FormatException {
            // Ignore malformed frames.
          }
        },
        onDone: _lost,
        onError: (Object _) => _lost(),
      );
      send(MessageType.auth, AuthPayload(t).toJson());
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(ping, (_) => send(MessageType.ping));
    } on Object {
      _lost();
    }
  }

  void _lost() {
    _pingTimer?.cancel();
    _channel = null;
    if (_closed) return;
    _setStatus(SocketStatus.offline);
    // 1, 2, 4 … 15 s with jitter.
    final delay = min(15000, 1000 * (1 << min(_attempt++, 4)));
    _retry?.cancel();
    _retry = Timer(Duration(milliseconds: delay + Random().nextInt(500)), open);
  }

  /// Sends an intent; returns its id (errors echo it).
  String send(String type, [Map<String, Object?> payload = const {}]) {
    final id = 'c${_ids++}';
    _channel?.sink.add(
      jsonEncode(
        Envelope(
          type: type,
          id: id,
          ts: DateTime.now().millisecondsSinceEpoch,
          payload: payload,
        ).toJson(),
      ),
    );
    return id;
  }

  Future<void> close() async {
    _closed = true;
    _retry?.cancel();
    _pingTimer?.cancel();
    await _channel?.sink.close();
    _setStatus(SocketStatus.offline);
  }

  Future<void> dispose() async {
    await close();
    await _messages.close();
    await _status.close();
  }
}
