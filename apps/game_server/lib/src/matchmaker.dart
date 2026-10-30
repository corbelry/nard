import 'dart:async';
import 'dart:math';

import 'package:nard_protocol/nard_protocol.dart';

import 'ticket.dart';

/// A player waiting in a queue.
class QueueEntry {
  QueueEntry(this.ticket, this.request, this.joinedAt);

  final Ticket ticket;
  final QueueJoinPayload request;

  /// Milliseconds since epoch.
  final int joinedAt;

  String get key =>
      '${request.variant.name}/${request.matchLength}/${request.mode.name}';

  int get rating => ticket.rating(request.variant);
}

/// Pairs queued players (spec §7.4): one queue per (variant, length, mode);
/// ranked pairs must be within a rating band that widens from ±50 to ±400
/// while waiting; casual players get a labelled bot after [botAfter]
/// (ADR-024). In-memory, single pod; the Redis-backed queue implements the
/// same rules for several pods.
class Matchmaker {
  Matchmaker({
    required this.onMatch,
    required this.onBot,
    this.botAfter = const Duration(seconds: 30),
    this.tick = const Duration(seconds: 1),
    int Function()? now,
  }) : _now = now ?? (() => DateTime.now().millisecondsSinceEpoch);

  final void Function(QueueEntry a, QueueEntry b) onMatch;
  final void Function(QueueEntry entry) onBot;
  final Duration botAfter;
  final Duration tick;
  final int Function() _now;
  final _entries = <String, QueueEntry>{};
  Timer? _timer;

  /// Band for a player who has waited [waitedMs]: +50 every 5 s, max ±400.
  static int band(int waitedMs) => min(400, 50 + 50 * (waitedMs ~/ 5000));

  bool isQueued(String userId) => _entries.containsKey(userId);

  /// Waiting players per queue key (`variant/length/mode`), for metrics.
  Map<String, int> queueSizes() {
    final sizes = <String, int>{};
    for (final e in _entries.values) {
      sizes[e.key] = (sizes[e.key] ?? 0) + 1;
    }
    return sizes;
  }

  void start() => _timer ??= Timer.periodic(tick, (_) => match());

  void join(Ticket ticket, QueueJoinPayload request) {
    _entries[ticket.userId] = QueueEntry(ticket, request, _now());
    match();
  }

  void leave(String userId) => _entries.remove(userId);

  /// One matching pass (also run on every tick).
  void match() {
    final now = _now();
    final byKey = <String, List<QueueEntry>>{};
    for (final e in _entries.values) {
      (byKey[e.key] ??= []).add(e);
    }
    for (final group in byKey.values) {
      group.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
      final taken = <QueueEntry>{};
      for (var i = 0; i < group.length; i++) {
        final a = group[i];
        if (taken.contains(a)) continue;
        for (var j = i + 1; j < group.length; j++) {
          final b = group[j];
          if (taken.contains(b) || !_compatible(a, b, now)) continue;
          taken.addAll([a, b]);
          _entries
            ..remove(a.ticket.userId)
            ..remove(b.ticket.userId);
          onMatch(a, b);
          break;
        }
      }
      for (final e in group) {
        if (taken.contains(e) || e.request.mode != QueueMode.casual) continue;
        if (now - e.joinedAt >= botAfter.inMilliseconds) {
          _entries.remove(e.ticket.userId);
          onBot(e);
        }
      }
    }
  }

  bool _compatible(QueueEntry a, QueueEntry b, int now) {
    if (a.request.mode == QueueMode.casual) return true;
    final limit = min(band(now - a.joinedAt), band(now - b.joinedAt));
    return (a.rating - b.rating).abs() <= limit;
  }

  void dispose() => _timer?.cancel();
}
