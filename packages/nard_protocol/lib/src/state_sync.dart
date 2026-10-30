import 'messages.dart';

/// Turns a stream of `game.state` frames of one match into full states
/// (ADR-048). Full frames replace the state; deltas are applied to it.
/// A delta that does not fit (lost frame, new socket) is never guessed at:
/// [accept] reports the gap once through `onGap` — the caller sends
/// `game.sync` — and ignores deltas until the next full frame.
class GameStateSync {
  GameStatePayload? _current;
  bool _resyncing = false;

  /// The latest full state.
  GameStatePayload? get current => _current;

  /// A gap was seen and no full frame has arrived since.
  bool get resyncing => _resyncing;

  /// Forgets the state (new match or watched game).
  void reset() {
    _current = null;
    _resyncing = false;
  }

  /// The full state after [frame], or null when [frame] is stale (its seq
  /// is not newer than the current one of the same match) or is a delta
  /// that cannot be applied.
  GameStatePayload? accept(GameStateFrame frame, {void Function()? onGap}) {
    final current = _current;
    if (current != null &&
        frame.matchId == current.matchId &&
        frame.seq <= current.seq) {
      return null;
    }
    switch (frame) {
      case GameStatePayload():
        _resyncing = false;
        return _current = frame;
      case GameStateDelta():
        if (_resyncing) return null;
        try {
          if (current == null) throw const StateGapException('No base state');
          return _current = frame.applyTo(current);
        } on StateGapException {
          _resyncing = true;
          onGap?.call();
          return null;
        }
    }
  }
}
