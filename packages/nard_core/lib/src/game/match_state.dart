import '../side.dart';
import 'game_state.dart';

/// Score keeping across games: match to N points or an unlimited (money)
/// session, including the Crawford rule.
class MatchState {
  const MatchState._({
    required this.length,
    required this.whiteScore,
    required this.blackScore,
    required this.isCrawfordGame,
    required this.isPostCrawford,
    required this.gamesPlayed,
    required this.jacoby,
  });

  /// A match to [length] points; 0 means an unlimited (money) session.
  factory MatchState.start({int length = 0, bool jacoby = false}) {
    if (length < 0) throw ArgumentError('Match length must be >= 0');
    return MatchState._(
      length: length,
      whiteScore: 0,
      blackScore: 0,
      isCrawfordGame: false,
      isPostCrawford: false,
      gamesPlayed: 0,
      jacoby: length == 0 && jacoby,
    );
  }

  /// Rebuilds a match in progress (e.g. from a Match ID or a record).
  factory MatchState.resume({
    required int length,
    required int whiteScore,
    required int blackScore,
    bool isCrawfordGame = false,
    bool isPostCrawford = false,
    int gamesPlayed = 0,
    bool jacoby = false,
  }) => MatchState._(
    length: length,
    whiteScore: whiteScore,
    blackScore: blackScore,
    isCrawfordGame: isCrawfordGame,
    isPostCrawford: isPostCrawford,
    gamesPlayed: gamesPlayed,
    jacoby: length == 0 && jacoby,
  );

  final int length;
  final int whiteScore;
  final int blackScore;

  /// The current/next game is the Crawford game (no doubling).
  final bool isCrawfordGame;

  /// The Crawford game has been played.
  final bool isPostCrawford;
  final int gamesPlayed;
  final bool jacoby;

  bool get isMoney => length == 0;

  int score(Side side) => side == Side.white ? whiteScore : blackScore;

  /// Points [side] still needs to win the match.
  int away(Side side) => length - score(side);

  bool get isOver => !isMoney && (whiteScore >= length || blackScore >= length);

  Side? get winner =>
      !isOver
          ? null
          : whiteScore >= length
          ? Side.white
          : Side.black;

  /// Options for the next game.
  GameConfig gameConfig({bool cubeEnabled = true, int maxCubeValue = 64}) =>
      GameConfig(
        cubeEnabled: cubeEnabled && !isCrawfordGame,
        jacoby: jacoby,
        maxCubeValue: maxCubeValue,
      );

  /// The match after a finished game.
  MatchState withResult(GameResult result) {
    if (isOver) throw StateError('Match is already over');
    final white =
        whiteScore + (result.winner == Side.white ? result.points : 0);
    final black =
        blackScore + (result.winner == Side.black ? result.points : 0);
    var crawford = false;
    var post = isPostCrawford;
    if (!isMoney) {
      if (isCrawfordGame) {
        post = true;
      } else if (!isPostCrawford &&
          (white == length - 1 || black == length - 1) &&
          white < length &&
          black < length) {
        // MT-03: the first time a player reaches match point, the next game
        // is the Crawford game.
        crawford = true;
      }
    }
    return MatchState._(
      length: length,
      whiteScore: white,
      blackScore: black,
      isCrawfordGame: crawford,
      isPostCrawford: post,
      gamesPlayed: gamesPlayed + 1,
      jacoby: jacoby,
    );
  }

  Map<String, Object?> toJson() => {
    'length': length,
    'white': whiteScore,
    'black': blackScore,
    'crawford': isCrawfordGame,
    'postCrawford': isPostCrawford,
    'games': gamesPlayed,
    'jacoby': jacoby,
  };

  static MatchState fromJson(Map<String, Object?> json) => MatchState.resume(
    length: json['length']! as int,
    whiteScore: json['white']! as int,
    blackScore: json['black']! as int,
    isCrawfordGame: json['crawford']! as bool,
    isPostCrawford: json['postCrawford']! as bool,
    gamesPlayed: json['games']! as int,
    jacoby: json['jacoby']! as bool,
  );

  @override
  String toString() =>
      'MatchState(${isMoney ? 'money' : 'to $length'}: '
      '$whiteScore-$blackScore${isCrawfordGame ? ', Crawford' : ''})';
}
