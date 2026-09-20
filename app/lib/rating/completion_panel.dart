import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../play/play_strings.dart';
import '../play/play_theme.dart';
import 'completion_result.dart';
import 'rating_strings.dart';
import '../reduce_motion.dart';

/// Vertical density of the panel. F03 `ui-design.md` §16.3 concessions when the
/// panel would exceed the 64 %-of-screen cap (large OS text scale, long
/// strings), applied in this order and no other: [compact] = gaps × 0.6 and
/// stars × 0.88; [tight] = [compact] and the `n / 3` caption dropped. Actions
/// are never clipped, scrolled or shrunk below 44 pt.
enum PanelDensity { regular, compact, tight }

/// F04's real completion panel (`architecture.md` §7, `ui-design.md` Direction A
/// "The seam becomes the panel"). Replaces F03's minimal `CompletionSheet`.
///
/// Rises over F03's dimmed + receded board and the amber seam bar, on the same
/// scrim, in the same raised dark panel family (`PlayTheme.sheet*`). The star
/// rating is the hero — a **bounded, deterministic** reveal (one-shot
/// [AnimationController], no `repeat()`), so widget tests settle. The
/// your-moves / OPTIMAL / personal-best triptych is the replay hook.
///
/// * `result != null` → the full rated panel.
/// * `result == null && ratingUnavailable` → the defensive bare completion
///   (no stars / best) — dev-only in practice (`architecture.md` §6).
class CompletionPanel extends StatefulWidget {
  const CompletionPanel({
    required this.strings,
    required this.rating,
    required this.result,
    required this.ratingUnavailable,
    required this.bareWord,
    required this.bareMoves,
    required this.onRetry,
    required this.onClose,
    this.onNextLevel,
    this.density = PanelDensity.regular,
    this.startReveal = true,
    this.spineGlow = true,
    super.key,
  });

  final PlayStrings strings;
  final RatingStrings rating;

  /// The rated completion. `null` while the rating resolves, or permanently for
  /// the no-optimal fallback (then [ratingUnavailable] is `true`).
  final CompletionResult? result;
  final bool ratingUnavailable;

  /// Shown when [result] is `null` — the formed word + move count straight from
  /// the controller.
  final String bareWord;
  final int bareMoves;

  final VoidCallback onRetry;
  final VoidCallback onClose;

  /// `null` in F04 scope — the button renders disabled with a `[PENDING — F05]`
  /// affordance. F05 supplies the Journey-advance handler.
  final VoidCallback? onNextLevel;

  /// See [PanelDensity]. Defaults to the F04 layout.
  final PanelDensity density;

  /// Whether the one-shot star reveal may run. F03 §16 holds it until the panel
  /// is at rest (the panel is built while it is still sliding in). Standalone
  /// use (tests, F04) keeps the default `true` = reveal at build time.
  final bool startReveal;

  /// Outer glow of the amber spine bar. F03 §16.3 turns it off while the docked
  /// answer row (which carries the one glow) is on screen.
  final bool spineGlow;

  @override
  State<CompletionPanel> createState() => _CompletionPanelState();
}

class _CompletionPanelState extends State<CompletionPanel>
    with TickerProviderStateMixin {
  late final AnimationController _reveal;
  late final AnimationController _underline;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _underline = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    if (widget.startReveal) _startOrSettle();
  }

  bool _revealStarted = false;

  void _startOrSettle() {
    if (_revealStarted) return;
    _revealStarted = true;
    final reduceMotion = reduceMotionRequested();
    if (reduceMotion) {
      _reveal.value = 1;
      if (_isNewBest) _underline.value = 1;
      return;
    }
    _reveal.forward();
    if (_isNewBest) _underline.forward();
  }

  bool get _isNewBest =>
      widget.result?.bestOutcome == BestOutcome.newBest &&
      widget.result?.personalBestAvailable == true;

  @override
  void didUpdateWidget(CompletionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.startReveal && widget.startReveal) _startOrSettle();
    // The personal-best read-back resolved after the reveal started. If it turned
    // into a "new best", wipe the underline in now (once).
    final becameNewBest =
        oldWidget.result?.bestOutcome != BestOutcome.newBest && _isNewBest;
    if (becameNewBest && !_underline.isAnimating && _underline.value == 0) {
      final reduceMotion = reduceMotionRequested();
      reduceMotion ? _underline.value = 1 : _underline.forward();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    _underline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final bare = result == null;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: PlayTheme.sheetSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x80000000),
            offset: Offset(0, -8),
            blurRadius: 32,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Spine(glow: widget.spineGlow),
          Padding(
            padding: EdgeInsets.fromLTRB(
              28,
              widget.density == PanelDensity.regular ? 22 : 13,
              28,
              0,
            ),
            child: bare
                ? _BareBody(
                    strings: widget.strings,
                    rating: widget.rating,
                    word: widget.bareWord,
                    moves: widget.bareMoves,
                  )
                : _RatedBody(
                    strings: widget.strings,
                    rating: widget.rating,
                    result: result,
                    reveal: _reveal,
                    underline: _underline,
                    density: widget.density,
                  ),
          ),
          _Actions(
            strings: widget.strings,
            rating: widget.rating,
            onRetry: widget.onRetry,
            onClose: widget.onClose,
            onNextLevel: widget.onNextLevel,
            isPerfect: widget.result?.isPerfect ?? false,
            density: widget.density,
          ),
        ],
      ),
    );
  }
}

/// The docked seam bar — a 3 pt amber rule flush with the panel top, fading to
/// transparent at both ends with a soft glow. Mirrors F03's win seam.
class _Spine extends StatelessWidget {
  const _Spine({this.glow = true});

  /// Outer glow; off while F03's docked answer row carries the one glow.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            PlayTheme.amber.withValues(alpha: 0),
            PlayTheme.amber.withValues(alpha: 0.95),
            PlayTheme.amber.withValues(alpha: 0),
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ),
        boxShadow: glow
            ? <BoxShadow>[
                BoxShadow(
                  color: PlayTheme.amber.withValues(alpha: 0.18),
                  blurRadius: 12,
                ),
              ]
            : const <BoxShadow>[],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rated body: stars → caption → word → triptych
// ---------------------------------------------------------------------------

class _RatedBody extends StatelessWidget {
  const _RatedBody({
    required this.strings,
    required this.rating,
    required this.result,
    required this.reveal,
    required this.underline,
    this.density = PanelDensity.regular,
  });

  final PlayStrings strings;
  final RatingStrings rating;
  final CompletionResult result;
  final Animation<double> reveal;
  final Animation<double> underline;
  final PanelDensity density;

  @override
  Widget build(BuildContext context) {
    // §16.3 concessions: gaps × 0.6 (compact+), stars × 0.88 (compact+),
    // caption dropped (tight). Regular = the F04 layout, unchanged.
    final f = density == PanelDensity.regular ? 1.0 : 0.6;
    final starScale = density == PanelDensity.regular ? 1.0 : 0.88;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (result.isPerfect)
          _PerfectPlate(label: rating.perfect, reveal: reveal),
        if (result.isPerfect) SizedBox(height: 10 * f),
        _StarRow(
          stars: result.stars,
          isPerfect: result.isPerfect,
          reveal: reveal,
          scale: starScale,
        ),
        SizedBox(height: 10 * f),
        Semantics(
          label: rating.starGroupSemantics(
            stars: result.stars,
            perfect: result.isPerfect,
          ),
          child: density == PanelDensity.tight
              ? const SizedBox.shrink()
              : ExcludeSemantics(
                  child: Text(
                    rating.starsCaption(result.stars),
                    style: PlayTheme.microLabel.copyWith(letterSpacing: 2),
                  ),
                ),
        ),
        SizedBox(height: 20 * f),
        Text(
          strings.solvedKicker,
          style: PlayTheme.microLabel.copyWith(
            color: PlayTheme.amber.withValues(alpha: 0.7),
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: 8 * f),
        Text(
          result.targetWord,
          textAlign: TextAlign.center,
          style: PlayTheme.completionWord.copyWith(
            fontSize: 22,
            letterSpacing: 1.5,
            color: PlayTheme.amber.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(height: 22 * f),
        _Triptych(strings: rating, result: result, underline: underline),
        SizedBox(height: 22 * f),
      ],
    );
  }
}

class _PerfectPlate extends StatelessWidget {
  const _PerfectPlate({required this.label, required this.reveal});

  final String label;
  final Animation<double> reveal;

  static const Interval _window = Interval(
    0.60,
    0.82,
    curve: Curves.easeOutBack,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, child) {
        final t = _window.transform(reveal.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.8 + 0.2 * t.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: PlayTheme.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PlayTheme.amber.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: PlayTheme.microLabel.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 3,
            color: PlayTheme.amber,
          ),
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.stars,
    required this.isPerfect,
    required this.reveal,
    this.scale = 1.0,
  });

  final int stars;
  final bool isPerfect;
  final Animation<double> reveal;

  /// §16.3 density: 1.0 regular, 0.88 compact/tight.
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reveal,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (var i = 0; i < 3; i++) ...<Widget>[
              if (i > 0) SizedBox(width: 18 * scale),
              _Star(
                earned: i < stars,
                strike: _strikeFor(i),
                perfectPulse: isPerfect ? _perfectPulse : 0,
                scale: scale,
              ),
            ],
          ],
        );
      },
    );
  }

  /// Per-star strike progress on the 800 ms reveal: star 0 ≈ 80–340 ms,
  /// star 1 ≈ 210–470 ms, star 2 ≈ 340–600 ms.
  double _strikeFor(int i) {
    final start = 0.10 + i * 0.16;
    final end = start + 0.24;
    final v = ((reveal.value - start) / (end - start)).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(v).clamp(0.0, 1.0);
  }

  /// A single synchronised glow pulse across all three stars once they are up
  /// (≈ 600–760 ms), for the Perfect "lands last" beat.
  double get _perfectPulse {
    final v = ((reveal.value - 0.72) / 0.2).clamp(0.0, 1.0);
    return math.sin(math.pi * v);
  }
}

/// A drawn faceted star — **not** `Icons.star`. `earned` stars strike from a
/// recessed socket to a raised amber medal; unearned stars stay sockets.
class _Star extends StatelessWidget {
  const _Star({
    required this.earned,
    required this.strike,
    required this.perfectPulse,
    this.scale = 1.0,
  });

  final bool earned;
  final double strike;
  final double perfectPulse;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final t = earned ? strike : 0.0;
    final pulse = earned ? perfectPulse : 0.0;
    return SizedBox(
      width: 46 * scale,
      height: 46 * scale,
      child: CustomPaint(
        painter: _StarPainter(struck: t, pulse: pulse),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.struck, required this.pulse});

  final double struck;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseR = size.width * 0.46;
    final scale =
        0.9 + 0.1 * struck + math.sin(math.pi * struck) * 0.1 + pulse * 0.06;
    final outerR = baseR * scale;
    final path = _starPath(center, outerR, outerR * 0.42);

    // Recessed socket (always painted; the struck fill sits on top).
    canvas.drawPath(path, Paint()..color = PlayTheme.plate);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF07070E),
    );

    if (struck <= 0.001) {
      return;
    }

    // Outer bloom — one soft amber halo behind the struck star.
    canvas.drawPath(
      _starPath(center, outerR * 1.15, outerR * 0.5),
      Paint()
        ..color = const Color(
          0xFFFFE9C2,
        ).withValues(alpha: 0.14 * struck + 0.12 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * struck + 6),
    );

    // Struck fill — amber medal. Fade the whole fill in with `struck` via a
    // layer (a shader Paint ignores `.color`, so alpha can't ride the fill).
    final fill = Paint()
      ..shader = const RadialGradient(
        colors: <Color>[PlayTheme.amber, PlayTheme.amberLo],
      ).createShader(Rect.fromCircle(center: center, radius: outerR));
    final faded = struck < 1;
    if (faded) {
      canvas.saveLayer(
        Rect.fromCircle(center: center, radius: outerR * 1.4),
        Paint()..color = Colors.white.withValues(alpha: struck.clamp(0.0, 1.0)),
      );
    }
    canvas.drawPath(path, fill);
    if (faded) {
      canvas.restore();
    }

    // Faceted centre + a top highlight edge.
    canvas.drawLine(
      Offset(center.dx, center.dy - outerR * 0.5),
      Offset(center.dx, center.dy + outerR * 0.5),
      Paint()
        ..strokeWidth = 1
        ..color = PlayTheme.inkAmber.withValues(alpha: 0.15 * struck),
    );
    canvas.drawPath(
      _starPath(center, outerR, outerR * 0.42),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.55 * struck),
    );
  }

  Path _starPath(Offset c, double outer, double inner) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.struck != struck || old.pulse != pulse;
}

// ---------------------------------------------------------------------------
// Triptych: SEN / OPTİMAL / EN İYİ
// ---------------------------------------------------------------------------

class _Triptych extends StatelessWidget {
  const _Triptych({
    required this.strings,
    required this.result,
    required this.underline,
  });

  final RatingStrings strings;
  final CompletionResult result;
  final Animation<double> underline;

  @override
  Widget build(BuildContext context) {
    final bestText = result.personalBestAvailable
        ? '${result.personalBestMoves}'
        : '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: PlayTheme.sheetRecess,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 30,
            child: _StatCell(
              value: '${result.playerMoves}',
              label: strings.you,
            ),
          ),
          SizedBox(
            width: 34,
            child: _GapConnective(
              isPerfect: result.isPerfect,
              over: result.movesOverOptimal,
            ),
          ),
          Expanded(
            flex: 36,
            child: _StatCell(
              value: '${result.optimalMoves}',
              label: strings.optimal,
              emphasized: true,
            ),
          ),
          const _CellDivider(),
          Expanded(
            flex: 30,
            child: _BestCell(
              strings: strings,
              value: bestText,
              outcome: result.personalBestAvailable ? result.bestOutcome : null,
              bestIsPerfect: result.bestIsPerfect,
              underline: underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.emphasized = false,
  });

  final String value;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: PlayTheme.completionStat.copyWith(
                fontSize: emphasized ? 32 : 27,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: PlayTheme.microLabel.copyWith(
                color: emphasized
                    ? PlayTheme.amber.withValues(alpha: 0.7)
                    : PlayTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GapConnective extends StatelessWidget {
  const _GapConnective({required this.isPerfect, required this.over});

  final bool isPerfect;
  final int over;

  @override
  Widget build(BuildContext context) {
    final text = isPerfect ? '=' : '+$over';
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: PlayTheme.completionStat.copyWith(
          fontSize: 18,
          color: PlayTheme.amber,
        ),
      ),
    );
  }
}

class _CellDivider extends StatelessWidget {
  const _CellDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class _BestCell extends StatelessWidget {
  const _BestCell({
    required this.strings,
    required this.value,
    required this.outcome,
    required this.bestIsPerfect,
    required this.underline,
  });

  final RatingStrings strings;
  final String value;
  final BestOutcome? outcome;
  final bool bestIsPerfect;
  final Animation<double> underline;

  @override
  Widget build(BuildContext context) {
    final isNewBest = outcome == BestOutcome.newBest;
    final tag = switch (outcome) {
      BestOutcome.firstClear => strings.firstRecord,
      BestOutcome.newBest => strings.newBest,
      BestOutcome.noImprovement => strings.betterKept,
      BestOutcome.matchedBest || null => null,
    };
    final semanticsLabel = <String>[
      '${strings.best}: $value',
      if (bestIsPerfect) strings.starsSemanticsPerfect,
      if (tag != null) tag,
    ].join(', ');

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            if (tag != null && isNewBest)
              Text(
                tag,
                style: PlayTheme.microLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: PlayTheme.amber,
                ),
              ),
            if (tag != null && isNewBest) const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (isNewBest)
                  const Padding(
                    padding: EdgeInsets.only(right: 3),
                    child: Text(
                      '▲',
                      style: TextStyle(fontSize: 10, color: PlayTheme.amber),
                    ),
                  ),
                Text(
                  value,
                  style: PlayTheme.completionStat.copyWith(fontSize: 27),
                ),
                if (bestIsPerfect)
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      '★',
                      style: TextStyle(
                        fontSize: 11,
                        color: PlayTheme.amber.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
              ],
            ),
            if (isNewBest)
              AnimatedBuilder(
                animation: underline,
                builder: (context, _) => Container(
                  margin: const EdgeInsets.only(top: 3),
                  height: 2,
                  width: 26 * underline.value,
                  color: PlayTheme.amber,
                ),
              )
            else
              const SizedBox(height: 5),
            const SizedBox(height: 2),
            Text(strings.best, style: PlayTheme.microLabel),
            if (tag != null && !isNewBest)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  tag,
                  style: PlayTheme.microLabel.copyWith(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: PlayTheme.muted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bare body (no-optimal fallback)
// ---------------------------------------------------------------------------

class _BareBody extends StatelessWidget {
  const _BareBody({
    required this.strings,
    required this.rating,
    required this.word,
    required this.moves,
  });

  final PlayStrings strings;
  final RatingStrings rating;
  final String word;
  final int moves;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 8),
        Text(
          strings.solvedKicker,
          style: PlayTheme.microLabel.copyWith(
            color: PlayTheme.amber.withValues(alpha: 0.7),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          word,
          textAlign: TextAlign.center,
          style: PlayTheme.completionWord,
        ),
        const SizedBox(height: 20),
        _StatCell(value: '$moves', label: rating.you),
        const SizedBox(height: 14),
        Text(rating.ratingUnavailable, style: PlayTheme.helper),
        const SizedBox(height: 22),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

class _Actions extends StatelessWidget {
  const _Actions({
    required this.strings,
    required this.rating,
    required this.onRetry,
    required this.onClose,
    required this.onNextLevel,
    required this.isPerfect,
    this.density = PanelDensity.regular,
  });

  /// §16.3: gaps × 0.6 for compact/tight; controls keep their 44 pt+ boxes.
  final PanelDensity density;

  final PlayStrings strings;
  final RatingStrings rating;
  final VoidCallback onRetry;
  final VoidCallback onClose;
  final VoidCallback? onNextLevel;

  /// `stars == 3` — drives the per-outcome CTA weighting (`ui-design.md §7.4`,
  /// `f05 architecture.md §16`).
  final bool isPerfect;

  @override
  Widget build(BuildContext context) {
    // Exactly one amber pill per panel. `Next Level` becomes the primary only
    // when it is BOTH the natural next action (Perfect) AND actually wired
    // (F05 supplies a handler; the debug entry does not).
    final canNext = onNextLevel != null;
    final nextIsPrimary = isPerfect && canNext;

    final primary = nextIsPrimary
        ? _CtaPill(
            label: rating.nextLevel,
            onPressed: onNextLevel,
            primary: true,
          )
        : _CtaPill(label: strings.retry, onPressed: onRetry, primary: true);
    final secondary = nextIsPrimary
        ? _CtaPill(label: strings.retry, onPressed: onRetry, primary: false)
        : _CtaPill(
            label: rating.nextLevel,
            onPressed: onNextLevel,
            primary: false,
            disabledSuffix: canNext ? null : rating.soon,
          );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        28,
        0,
        28,
        (density == PanelDensity.regular ? 18 : 12) +
            MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          primary,
          SizedBox(height: density == PanelDensity.regular ? 10 : 6),
          secondary,
          SizedBox(height: density == PanelDensity.regular ? 4 : 2),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Container(
              alignment: Alignment.center,
              // ≥ 44 pt tap target (ui-design §16.5 rule 5; was 42 pt).
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                strings.close,
                style: PlayTheme.helper.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One completion-panel CTA. `primary` → the amber filled pill (`Retry`'s F04
/// treatment); otherwise a quiet ghost pill. A `null` `onPressed` on a
/// non-primary pill renders it disabled with an optional `disabledSuffix`
/// (`· yakında`) — the debug-entry path (F05 always supplies a handler).
class _CtaPill extends StatelessWidget {
  const _CtaPill({
    required this.label,
    required this.onPressed,
    required this.primary,
    this.disabledSuffix,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final String? disabledSuffix;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    if (primary) {
      return Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[PlayTheme.amber, PlayTheme.amberLo],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x4DFFB020),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: PlayTheme.inkAmber,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled || disabledSuffix == null
          ? label
          : '$label — $disabledSuffix',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: PlayTheme.muted.withValues(alpha: enabled ? 0.6 : 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: PlayTheme.microLabel.copyWith(
                  fontSize: 12,
                  color: PlayTheme.muted.withValues(alpha: enabled ? 1 : 0.45),
                ),
              ),
              if (!enabled && disabledSuffix != null) ...<Widget>[
                Text(
                  '  ·  ',
                  style: PlayTheme.microLabel.copyWith(
                    color: PlayTheme.muted.withValues(alpha: 0.45),
                  ),
                ),
                Text(
                  disabledSuffix!,
                  style: PlayTheme.helper.copyWith(
                    fontSize: 11,
                    color: PlayTheme.muted.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
