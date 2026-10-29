import 'package:nard_ai/nard_ai.dart';
import 'package:nard_core/nard_core.dart';
import 'package:nard_protocol/nard_protocol.dart';

import '../board/board_scene.dart';
import '../data/app_settings.dart';
import '../l10n/gen/app_localizations.dart';
import '../ui/layout.dart';
import 'game_controller.dart';
import 'match_setup.dart';
import 'session.dart';

/// Primary button looks (game.md §1.3).
enum PrimaryStyle { on, wait, off }

enum PrimaryAction { none, roll, confirm, pass, nextGame }

/// Turns a [GameView] into what the game screen shows. Pure: no widgets.
class GamePresenter {
  GamePresenter(this.view, this.settings, this.l);

  final GameView view;
  final AppSettings settings;
  final AppLocalizations l;

  Session get s => view.session;
  MatchSetup get setup => s.setup;

  /// The side at the bottom of the board.
  Side get viewer {
    if (setup.hasRemote || !setup.flipBoard) return setup.localSide;
    if (s.phase == GamePhase.opening) return Side.white;
    if (s.isGameOver) return s.game.result!.winner;
    return s.turn;
  }

  /// The side whose actions the local player is taking now.
  bool get humanToMove =>
      !s.isGameOver &&
      s.phase != GamePhase.opening &&
      !s.remoteToAct &&
      s.phase != GamePhase.cubeOffered;

  bool get humanMoving =>
      humanToMove &&
      s.phase == GamePhase.awaitingMove &&
      !view.rolling &&
      !view.noMoves &&
      !view.handoff;

  String name(Side side) {
    if (setup.vsComputer) {
      return side == setup.localSide ? l.you : l.computerName;
    }
    final online = setup.online;
    if (online != null) {
      final seat = online.player(side);
      // The server's bot is always labelled (ADR-024, 20.2).
      return seat.bot
          ? l.playerBotLevel(levelName(BotLevel.medium))
          : seat.name;
    }
    final custom = side == Side.white ? setup.whiteName : setup.blackName;
    if (custom.isNotEmpty) return custom;
    return side == Side.white ? l.hotseatDefaultWhite : l.hotseatDefaultBlack;
  }

  String levelName(BotLevel level) => switch (level) {
    BotLevel.beginner => l.aiLevelBeginner,
    BotLevel.easy => l.aiLevelAmateur,
    BotLevel.medium => l.aiLevelMedium,
    BotLevel.hard => l.aiLevelStrong,
    BotLevel.expert => l.aiLevelMaster,
    BotLevel.master => l.aiLevelGrandmaster,
  };

  String variantName(Variant v) =>
      v == Variant.shortNard ? l.variantShort : l.variantLong;

  String get modeLabel =>
      setup.online?.mode == QueueMode.casual
          ? l.gameModeCasual
          : setup.matchLength <= 1
          ? l.gameModeSingle(variantName(setup.variant))
          : l.gameModeTo(variantName(setup.variant), setup.matchLength);

  int score(Side side) => s.score.score(side);

  bool get crawford => s.match.isCrawfordGame;

  List<int> get _diceFaces {
    if (s.phase == GamePhase.opening ||
        (s.openingDice != null && view.rolling)) {
      final o = s.openingDice;
      return o == null ? const [] : [o.$1, o.$2];
    }
    final d = s.dice;
    if (d == null) return const [];
    return d.isDouble ? [d.die1, d.die1, d.die1, d.die1] : [d.die1, d.die2];
  }

  List<bool> get _diceUsed {
    final d = s.dice;
    if (d == null || view.rolling) return const [];
    final faces = _diceFaces;
    final left = List<int>.of(s.remainingDice);
    final used = <bool>[];
    // Mark the unused dice from the right so used ones dim from the left.
    for (final f in faces.reversed) {
      used.insert(0, !left.remove(f));
    }
    return used;
  }

  BoardScene scene() {
    final mover = humanMoving ? s.turn : null;
    final selected = mover == null ? null : s.selected;
    final targets =
        selected != null && settings.showLegalMoves
            ? s.targetsFrom(selected)
            : const <int>{};
    final rejected = s.rejectedMove;
    final markers = s.pending.isEmpty && s.phase != GamePhase.opening;
    return BoardScene(
      rules: s.rules,
      viewer: viewer,
      board: s.board,
      dice: _diceFaces,
      diceUsed: _diceUsed,
      diceOwner: s.phase == GamePhase.opening ? null : s.turn,
      rolling: view.rolling,
      cubeValue: s.game.cube.value,
      cubeOwner: s.game.cube.owner,
      cubeVisible: s.game.config.cubeEnabled,
      cubeOffered: s.phase == GamePhase.cubeOffered,
      mover: mover,
      selected: selected,
      targets: targets,
      illegalTarget:
          s.rejection == MoveRejection.sixBlock && rejected != null
              ? rejected.$2
              : null,
      lastMoves: markers ? s.lastTurn : const [],
      lastMover: markers && s.lastTurn.isNotEmpty ? s.turn.opponent : null,
      mustEnter: mover != null && s.board.barCount(mover) > 0,
      colorBlind: settings.colorBlind,
      largePips: settings.largePips,
    );
  }

  String _diceText() {
    final d = s.dice;
    return d == null ? '' : l.bannerDice(d.die1, d.die2);
  }

  ({String title, String? sub, BannerTone tone}) banner() {
    if (s.isGameOver) {
      final r = s.game.result!;
      return (
        title: l.bannerGameOver,
        sub: _kindName(r.kind),
        tone: BannerTone.ok,
      );
    }
    if (s.phase == GamePhase.opening) {
      final o = s.openingDice;
      final tie = o != null && o.$1 == o.$2 && !view.rolling;
      return (
        title: tie ? l.bannerOpeningTie : l.bannerOpening,
        sub: null,
        tone: BannerTone.brass,
      );
    }
    if (view.rolling) {
      return (title: l.bannerRolling, sub: null, tone: BannerTone.brass);
    }
    if (view.noMoves) {
      return (title: l.bannerNoMoves, sub: noMovesReason, tone: BannerTone.dim);
    }
    if (s.phase == GamePhase.cubeOffered) {
      final responderIsBot = s.remoteToAct;
      return (
        title: responderIsBot ? l.bannerCubeWaiting : l.bannerCubeOffer,
        sub: null,
        tone: BannerTone.brass,
      );
    }
    if (s.remoteToAct) {
      return (
        title: l.bannerOpponentThinking,
        sub: s.dice == null ? null : _diceText(),
        tone: BannerTone.dim,
      );
    }
    if (s.rejection != null && s.phase == GamePhase.awaitingMove) {
      return (
        title: l.bannerIllegalMove,
        sub: _diceText(),
        tone: BannerTone.danger,
      );
    }
    final title =
        setup.hasRemote ? l.bannerYourTurn : l.bannerTurnOf(name(s.turn));
    String? sub;
    if (s.phase == GamePhase.awaitingMove) {
      if (setup.variant == Variant.longNard &&
          s.pending.any((m) => m.from == LongNardRules.head)) {
        sub = l.bannerHeadRuleHint;
      } else if (s.remainingDice.isNotEmpty && !s.canConfirm) {
        sub = l.bannerLegalMoveCount(
          {for (final m in s.nextMoves) (m.from, m.to)}.length,
        );
      }
    } else if (crawford) {
      sub =
          s.match.away(s.turn.opponent) == 1
              ? l.bannerOpponentNeedsOne
              : l.bannerYouNeedOne;
    }
    return (title: title, sub: sub, tone: BannerTone.brass);
  }

  String get noMovesReason =>
      s.board.barCount(s.turn) > 0
          ? l.noMovesReasonBar
          : l.noMovesReasonBlocked;

  String _kindName(WinKind kind) => switch (kind) {
    WinKind.single => l.resignSingle,
    WinKind.gammon => l.resignMars,
    WinKind.backgammon => l.resignKoks,
  };

  /// Result line of the finished game, e.g. "Mars · +2 xal".
  String resultLine() {
    final r = s.game.result!;
    return switch (r.reason) {
      GameEndReason.doubleDropped => l.resultDropped(r.points),
      GameEndReason.resignation => l.resultResigned(r.points),
      _ => switch (r.kind) {
        WinKind.single => l.resultSingle(r.points),
        WinKind.gammon => l.resultMars(r.points),
        WinKind.backgammon => l.resultKoks(r.points),
      },
    };
  }

  ({String label, String? sub, PrimaryStyle style, PrimaryAction action})
  primary() {
    if (s.isGameOver) {
      return s.isMatchOver
          ? (
            label: l.actionNextGame,
            sub: null,
            style: PrimaryStyle.off,
            action: PrimaryAction.none,
          )
          : (
            label: l.actionNextGame,
            sub: null,
            style: PrimaryStyle.on,
            action: PrimaryAction.nextGame,
          );
    }
    if (view.noMoves && !s.remoteToAct) {
      return (
        label: l.actionPass,
        sub: null,
        style: PrimaryStyle.wait,
        action: PrimaryAction.pass,
      );
    }
    if (humanMoving) {
      final total = s.game.planner.maxDiceUsed;
      return (
        label: l.actionConfirm,
        sub: l.actionMovesProgress(s.pending.length, total),
        style: s.canConfirm ? PrimaryStyle.on : PrimaryStyle.wait,
        action: s.canConfirm ? PrimaryAction.confirm : PrimaryAction.none,
      );
    }
    final canRoll =
        humanToMove &&
        s.phase == GamePhase.awaitingRoll &&
        !view.rolling &&
        !view.handoff;
    return (
      label: l.actionRoll,
      sub: null,
      style: canRoll ? PrimaryStyle.on : PrimaryStyle.off,
      action: canRoll ? PrimaryAction.roll : PrimaryAction.none,
    );
  }

  bool get canUndo => humanMoving && s.canUndo;

  bool get showDouble => s.game.config.cubeEnabled;

  bool get canDouble =>
      humanToMove && !view.rolling && !view.handoff && s.canDouble;

  /// The local player must answer a double (sheet 6.2).
  bool get mustAnswerDouble =>
      s.phase == GamePhase.cubeOffered && !s.remoteToAct && !s.isGameOver;

  /// Title and body for the illegal-move toast.
  ({String title, String? body})? rejectionText() {
    final r = s.rejection;
    if (r == null || s.phase != GamePhase.awaitingMove) return null;
    final long = setup.variant == Variant.longNard;
    final mv = s.rejectedMove;
    return switch (r) {
      MoveRejection.headRule => (title: l.ruleHeadTitle, body: l.ruleHeadBody),
      MoveRejection.sixBlock => (
        title: l.ruleSixBlockTitle,
        body: l.ruleSixBlockBody(
          mv == null ? '' : '${mv.$1}',
          mv == null ? '' : '${mv.$2}',
        ),
      ),
      MoveRejection.pointClosed => (
        title: l.rulePointClosedTitle,
        body: long ? l.rulePointClosedLong : l.rulePointClosedShort,
      ),
      MoveRejection.mustEnterFromBar => (
        title: l.ruleBarTitle,
        body: l.ruleBarBody,
      ),
      MoveRejection.mustUseBothDice => (
        title: l.ruleBothDiceTitle,
        body: l.ruleBothDiceBody,
      ),
      MoveRejection.mustUseLargerDie => (
        title: l.ruleLargerDieTitle,
        body: l.ruleLargerDieBody,
      ),
      MoveRejection.bearOffNotAllowed => (
        title: l.ruleBearOffTitle,
        body: l.ruleBearOffBody,
      ),
      MoveRejection.bearOffHigherDie => (
        title: l.ruleBearOffHigherTitle,
        body: l.ruleBearOffHigherBody,
      ),
      MoveRejection.noMatchingDie => (
        title: l.ruleNoDieTitle,
        body: l.ruleNoDieBody,
      ),
      MoveRejection.noChecker => (title: l.ruleNoCheckerTitle, body: null),
      MoveRejection.turnComplete => (
        title: l.ruleTurnCompleteTitle,
        body: l.ruleTurnCompleteBody,
      ),
    };
  }
}
