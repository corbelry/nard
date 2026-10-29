import 'package:nard_core/nard_core.dart';

/// What the game screen can ask of a match, offline or online.
abstract interface class GameActions {
  void tapSlot(int? slot);
  void drop(int from, int? to);
  void roll();
  void undo();
  void confirm();
  void pass();
  void offerDouble();
  void takeDouble();
  void dropDouble();
  void resign(WinKind kind);
  void nextGame();
  void ready();
  void undoLastTurn();

  /// Plays the same setup again (offline) or queues again (online).
  void rematch();
  void leave();
}
