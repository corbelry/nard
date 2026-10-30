import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/gen/app_localizations.dart';
import '../online/account.dart';
import '../social/social_gate.dart' show AsyncBody;
import '../social/spectate.dart';
import '../theme/nard_colors.dart';
import '../theme/nard_tokens.dart';
import '../ui/competition.dart';
import '../ui/extra_tokens.dart';
import '../ui/layout.dart';
import '../ui/pressable.dart';
import 'bracket_layout.dart';
import 'tournament_models.dart';
import 'tournament_panel.dart';
import 'tournament_providers.dart';
import 'tournament_text.dart';

/// 4.3 Live knockout bracket: round chips, pan / zoom canvas, my next
/// match with the ready check. Polls the detail every 15 s.
class BracketScreen extends ConsumerStatefulWidget {
  const BracketScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<BracketScreen> createState() => _BracketScreenState();
}

class _BracketScreenState extends ConsumerState<BracketScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = pollEvery(
      const Duration(seconds: 15),
      () => ref.invalidate(tournamentDetailProvider(widget.id)),
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: AsyncBody<TournamentDetail>(
          value: ref.watch(tournamentDetailProvider(widget.id)),
          onRetry: () => ref.invalidate(tournamentDetailProvider(widget.id)),
          data: (d) => BracketView(detail: d),
        ),
      ),
    );
  }
}

/// The bracket for [detail] (public for render tests).
class BracketView extends ConsumerStatefulWidget {
  const BracketView({super.key, required this.detail});

  final TournamentDetail detail;

  @override
  ConsumerState<BracketView> createState() => _BracketViewState();
}

class _BracketViewState extends ConsumerState<BracketView>
    with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Animation<Matrix4>? _tween;
  int _viewed = 1;
  bool _placed = false;
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() {
      final t = _tween;
      if (t != null) _transform.value = t.value;
    });
    final t = widget.detail.tournament;
    _viewed = max(1, t.currentRound);
    if (t.stillIn || t.live) {
      ref.read(tournamentSocketProvider.notifier).connect();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _transform.dispose();
    super.dispose();
  }

  String? get _me => ref.read(accountProvider).value?.id;

  double get _scale => _transform.value.getMaxScaleOnAxis();

  void _animateTo(Matrix4 target) {
    if (MediaQuery.of(context).disableAnimations) {
      _transform.value = target;
      return;
    }
    _tween = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _anim, curve: NardMotion.standard));
    _anim.forward(from: 0);
  }

  /// Puts [round]'s column at the left edge (keeping the scale).
  void _showRound(BracketLayout layout, int round, {Rect? focus}) {
    setState(() => _viewed = round);
    final s = _scale;
    final x = BracketLayout.cardX(round) - BracketLayout.firstX;
    final rect = focus ?? layout.columns[round - 1].first.rect;
    final y =
        max(0.0, rect.center.dy * s - _viewport.height / 2)
            .clamp(0.0, max(0.0, layout.size.height * s - _viewport.height))
            .toDouble();
    _animateTo(
      Matrix4.identity()
        ..translate(-x * s, -y)
        ..scale(s),
    );
  }

  void _zoom(double factor) {
    final s = (_scale * factor).clamp(.5, 1.6);
    final center = Offset(_viewport.width / 2, _viewport.height / 2);
    final scene = _transform.toScene(center);
    _animateTo(
      Matrix4.identity()
        ..translate(center.dx - scene.dx * s, center.dy - scene.dy * s)
        ..scale(s),
    );
  }

  void _tapMatch(BracketMatch m) {
    final id = m.matchId;
    if (id == null) return;
    final white = m.white;
    final black = m.black;
    if (m.status == PairingStatus.ready && white != null && black != null) {
      ref
          .read(spectatorProvider.notifier)
          .watch(id, whiteName: white.name, blackName: black.name);
      unawaited(context.push('/spectate'));
    } else if (m.status == PairingStatus.finished && m.involves(_me)) {
      unawaited(context.push('/analysis/match/$id'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    final d = widget.detail;
    final t = d.tournament;
    final me = ref.watch(accountProvider).value?.id;
    final layout = BracketLayout.of(d, me: me);
    final next = d.nextMatch;
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScreenHeader(
          title: t.nameFor(locale),
          bare: true,
          trailing:
              t.live
                  ? TournamentStatusLabel(
                    text: l.tourLive,
                    color: c.dangerText,
                    dot: true,
                  )
                  : null,
        ),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            children: [
              for (var r = 1; r <= layout.rounds; r++) ...[
                if (r > 1) const SizedBox(width: 6),
                _RoundChip(
                  label: stageLabel(l, layout.stages[r - 1]),
                  viewed: r == _viewed,
                  finished:
                      r < t.currentRound ||
                      t.status == TournamentStatus.finished,
                  onTap: () => _showRound(layout, r),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              _viewport = box.biggest;
              if (!_placed) {
                _placed = true;
                final mine = layout.myCell(me, nextMatchId: next?.matchId);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  final round = mine?.round ?? min(_viewed, layout.rounds);
                  _transform.value = Matrix4.identity();
                  _showRound(layout, round, focus: mine?.rect);
                });
              }
              return ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DotGridPainter(color: c.bracketDot),
                      ),
                    ),
                    InteractiveViewer(
                      transformationController: _transform,
                      constrained: false,
                      minScale: .5,
                      maxScale: 1.6,
                      boundaryMargin: const EdgeInsets.all(80),
                      child: SizedBox(
                        width: layout.size.width,
                        height: layout.size.height,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ConnectorPainter(
                                  connectors: layout.connectors,
                                  line: c.bracketLine,
                                  mine: c.accentHi,
                                ),
                              ),
                            ),
                            for (final column in layout.columns)
                              for (final cell in column)
                                Positioned.fromRect(
                                  rect: cell.rect,
                                  child: _MatchCard(
                                    match: cell.match,
                                    me: me,
                                    next:
                                        next != null &&
                                        cell.match?.matchId == next.matchId,
                                    onTap:
                                        cell.match == null
                                            ? null
                                            : () => _tapMatch(cell.match!),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: _ZoomButtons(
                        onIn: () => _zoom(1.25),
                        onOut: () => _zoom(1 / 1.25),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        TournamentPanel(detail: d),
      ],
    );
  }
}

class _RoundChip extends StatelessWidget {
  const _RoundChip({
    required this.label,
    required this.viewed,
    required this.finished,
    required this.onTap,
  });

  final String label;
  final bool viewed;
  final bool finished;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      minSize: 28,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: viewed ? NardPalette.ivory100 : null,
          borderRadius: BorderRadius.circular(NardRadius.s),
          border:
              viewed ? null : Border.all(color: c.accent.withValues(alpha: .2)),
        ),
        child: Text(
          label,
          style: NardType.caption.copyWith(
            fontWeight: viewed ? FontWeight.w600 : FontWeight.w400,
            color:
                viewed
                    ? NardPalette.walnut900
                    : finished
                    ? c.text.withValues(alpha: .6)
                    : c.text,
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.me,
    required this.next,
    this.onTap,
  });

  final BracketMatch? match;
  final String? me;
  final bool next;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.nard;
    final m = match;
    final mine = m?.involves(me) ?? false;
    final live = m?.status == PairingStatus.ready;
    Widget row(UserLite? user, int? score, bool winner, bool top) {
      final decided = m?.decided ?? false;
      final strong = !decided || winner;
      final name = user?.name ?? (decided ? '—' : '');
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: NardType.caption.copyWith(
                    fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                    color:
                        user == null
                            ? c.text.withValues(alpha: .4)
                            : strong
                            ? c.text
                            : c.text.withValues(alpha: .5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (live && top)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.dangerText,
                    ),
                  ),
                ),
              Text(
                score == null ? '–' : '$score',
                style: NardType.caption.copyWith(
                  fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                  color: strong ? c.text : c.text.withValues(alpha: .5),
                  fontFeatures: tabular,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final score = m?.score;
    return Pressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: mine ? c.accentHi : c.accent.withValues(alpha: .2),
            width: mine ? 1.5 : 1,
          ),
          boxShadow:
              next
                  ? [
                    BoxShadow(
                      color: c.accentHi.withValues(alpha: .25),
                      blurRadius: 20,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            row(m?.white, score?.$1, m?.result == 'white', true),
            Container(height: 1, color: c.accent.withValues(alpha: .12)),
            row(m?.black, score?.$2, m?.result == 'black', false),
          ],
        ),
      ),
    );
  }
}

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons({required this.onIn, required this.onOut});

  final VoidCallback onIn;
  final VoidCallback onOut;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.nard;
    Widget cell(IconData icon, String label, VoidCallback onTap) => Pressable(
      onTap: onTap,
      semanticLabel: label,
      minSize: 42,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(icon, size: 20, color: c.text),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: BorderRadius.circular(NardRadius.m),
        border: Border.all(color: c.accent.withValues(alpha: .24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cell(LucideIcons.plus, l.zoomIn, onIn),
          Container(
            width: 42,
            height: 1,
            color: c.accent.withValues(alpha: .2),
          ),
          cell(LucideIcons.minus, l.zoomOut, onOut),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = 8.0; y < size.height; y += 16) {
      for (var x = 8.0; x < size.width; x += 16) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.connectors,
    required this.line,
    required this.mine,
  });

  final List<BracketConnector> connectors;
  final Color line;
  final Color mine;

  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connectors) {
      final paint =
          Paint()
            ..color = conn.mine ? mine : line
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(conn.points.first.dx, conn.points.first.dy);
      for (final p in conn.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) => old.connectors != connectors;
}
