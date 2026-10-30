/// Abuse limits for WebSocket connections (ADR-045). Every value can be set
/// from the environment ([WsLimits.fromEnv]); 0 turns a limit off.
class WsLimits {
  const WsLimits({
    this.maxFrameBytes = 16 * 1024,
    this.authTimeout = const Duration(seconds: 10),
    this.messagesPerSecond = 20,
    this.burst = 40,
    this.maxConnectionsPerIp = 20,
    this.pingInterval = const Duration(seconds: 30),
    this.trustProxy = false,
  });

  /// `WS_MAX_FRAME_BYTES`, `WS_AUTH_TIMEOUT_SECONDS`,
  /// `WS_MESSAGES_PER_SECOND`, `WS_BURST`, `WS_MAX_CONNECTIONS_PER_IP`,
  /// `WS_PING_SECONDS` (unparsable values keep the default) and
  /// `TRUST_PROXY` (`true`/`1`).
  factory WsLimits.fromEnv(Map<String, String> env) {
    const d = WsLimits();
    int read(String key, int fallback) {
      final v = int.tryParse(env[key] ?? '');
      return v == null || v < 0 ? fallback : v;
    }

    final ping = read('WS_PING_SECONDS', d.pingInterval!.inSeconds);
    return WsLimits(
      maxFrameBytes: read('WS_MAX_FRAME_BYTES', d.maxFrameBytes),
      authTimeout: Duration(
        seconds: read('WS_AUTH_TIMEOUT_SECONDS', d.authTimeout.inSeconds),
      ),
      messagesPerSecond: read('WS_MESSAGES_PER_SECOND', d.messagesPerSecond),
      burst: read('WS_BURST', d.burst),
      maxConnectionsPerIp: read(
        'WS_MAX_CONNECTIONS_PER_IP',
        d.maxConnectionsPerIp,
      ),
      pingInterval: ping == 0 ? null : Duration(seconds: ping),
      trustProxy: const {'true', '1'}.contains(env['TRUST_PROXY']),
    );
  }

  /// Larger frames close the socket with 4009 (text is measured in UTF-16
  /// code units, binary in bytes). dart:io has already buffered the frame by
  /// then; the ingress bounds what reaches the pod.
  final int maxFrameBytes;

  /// A socket without a successful `auth` by then is closed (4008).
  final Duration authTimeout;

  /// Token bucket per connection: [messagesPerSecond] refill, [burst]
  /// capacity. A refused message gets `rate_limited` (once per run); more
  /// than [burst] refusals in a row close the socket (4008).
  final int messagesPerSecond;
  final int burst;

  /// Concurrent sockets per client address; more get HTTP 429 before the
  /// upgrade.
  final int maxConnectionsPerIp;

  /// WebSocket ping frames; a peer that stops answering is dropped. Null
  /// disables pings.
  final Duration? pingInterval;

  /// Behind a reverse proxy (the ingress): the client address is the
  /// rightmost `X-Forwarded-For` entry, the hop the proxy itself added.
  /// Never enable it when clients reach the server directly: they could
  /// then pick their own address.
  final bool trustProxy;
}

/// A token bucket on a millisecond clock.
class TokenBucket {
  TokenBucket(this.perSecond, this.capacity, int nowMs)
    : _tokens = capacity.toDouble(),
      _last = nowMs;

  final int perSecond;
  final int capacity;
  double _tokens;
  int _last;

  /// Takes one token; false when the bucket is empty.
  bool take(int nowMs) {
    if (nowMs > _last) {
      _tokens = (_tokens + (nowMs - _last) * perSecond / 1000).clamp(
        0,
        capacity.toDouble(),
      );
      _last = nowMs;
    }
    if (_tokens < 1) return false;
    _tokens -= 1;
    return true;
  }
}
