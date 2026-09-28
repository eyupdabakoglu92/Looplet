import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsService;

import '../../design/design.dart';
import '../../rating/rating_strings.dart';
import '../../rating/result_model.dart';
import '../../reduce_motion.dart';
import '../play_layout.dart';
import '../play_strings.dart';
import '../win_timeline.dart';
import 'lime_glow.dart';

/// The result's look on one frame — its entrance, rest, or the retry exit.
/// Opacities are 0…1; `*Rise` and [drop] are offsets below the rest position
/// in reference units (× s).
@immutable
class ResultMotion {
  const ResultMotion({
    this.back = 1,
    this.head = 1,
    this.sub = 1,
    this.stats = 1,
    this.cta = 1,
    this.headRise = 0,
    this.subRise = 0,
    this.statsRise = 0,
    this.ctaRise = 0,
    this.radial = 1,
    this.answer = 1,
    this.exit = 1,
    this.drop = 0,
    this.starRevealMs,
  });

  /// The win entrance at [ms] after T0 ([WinTimeline]).
  factory ResultMotion.win(WinTimeline tl, double ms) {
    final back = tl.band(ResultBand.back, ms);
    final head = tl.band(ResultBand.head, ms);
    final sub = tl.band(ResultBand.sub, ms);
    final stats = tl.band(ResultBand.stats, ms);
    final cta = tl.band(ResultBand.cta, ms);
    return ResultMotion(
      back: back.opacity,
      head: head.opacity,
      sub: sub.opacity,
      stats: stats.opacity,
      cta: cta.opacity,
      headRise: head.rise,
      subRise: sub.rise,
      statsRise: stats.rise,
      ctaRise: cta.rise,
      radial: tl.radial(ms),
      answer: tl.resultRow(ms),
      starRevealMs: tl.starRevealMs(ms),
    );
  }

  /// The retry exit at [ms] after the tap ([RetryTimeline]): everything fades
  /// out and drops; the answer row has left as the flight (regular) or fades
  /// with the rest (reduced).
  factory ResultMotion.retry(RetryTimeline rt, double ms) {
    final out = rt.resultOut(ms);
    return ResultMotion(
      exit: out.opacity,
      drop: out.rise,
      answer: rt.reduceMotion ? 1 : 0,
    );
  }

  /// At rest, stars filled.
  static const ResultMotion rest = ResultMotion();

  final double back;
  final double head;
  final double sub;
  final double stats;
  final double cta;
  final double headRise;
  final double subRise;
  final double statsRise;
  final double ctaRise;
  final double radial;

  /// The result's own answer row (hidden while the travelling copy flies).
  final double answer;

  /// Multiplies every opacity (the retry exit).
  final double exit;

  /// Added to every offset (the retry exit's drop).
  final double drop;

  /// See [StarRow.revealMs]; `null` = static (filled).
  final double? starRevealMs;
}

/// The full-screen result (F03 `ui-design.md` §16.6–§16.8, architecture §20.3
/// (4)–(9)): an in-screen state of `/play`, no board behind it, no Close.
///
/// One column (x 24·s, 309·s wide) laid out on the S-04 anchors, scaled by
/// width (`s = W / 358`) with the extra height `e = H − 717·s` spread as in
/// S-04: the reserved badge row, the capped two-line display headline, the
/// free subtitle, the answer tiles with their lime radial, the stars, the
/// stats card, one lime pill and one quiet link. The back button is fixed
/// outside the column. Up to the 1.3× text cap it fits without scrolling;
/// above it the column scrolls (`ClampingScrollPhysics`) under a fixed band
/// and always starts at offset 0.
///
/// [slotKey] marks the laid-out answer row, so the win glide and the retry
/// flight can measure it. Input and semantics are live only when
/// [interactive] (at rest).
class ResultView extends StatefulWidget {
  const ResultView({
    required this.model,
    required this.letters,
    required this.strings,
    required this.rating,
    required this.layout,
    required this.motion,
    required this.slotKey,
    required this.interactive,
    required this.onBack,
    required this.onRetry,
    this.onNext,
    super.key,
  });

  final ResultModel model;

  /// The answer tiles' letters (the row that won, as the board spelled it).
  final List<String> letters;
  final PlayStrings strings;
  final RatingStrings rating;
  final PlayLayout layout;
  final ResultMotion motion;
  final GlobalKey slotKey;
  final bool interactive;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final VoidCallback? onNext;

  /// A late `YENİ EN İYİ` fades into its reserved row (§20.7 C1).
  static const Duration badgeFade = Duration(milliseconds: 160);

  /// Scroll distance over which the band fades in.
  static const double bandFadeDistance = 12;

  /// The column's reference geometry (× s), `ui-design.md` §16.6.
  static const double columnLeftRef = 24;
  static const double columnWidthRef = 309;
  static const double backTopRef = 54;
  static const double badgeRowRef = 42;
  static const double tilesGapRef = 6.5;
  static const double starSizeRef = 19;
  static const double radialHeightRef = 240;

  /// Top of the column (the reserved badge row): 54·s + 0.16 e.
  static double columnTop(PlayLayout layout) =>
      backTopRef * layout.s + 0.16 * layout.extra;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _contentKey = GlobalKey(debugLabel: 'result.content');
  late final AnimationController _badgeIn = AnimationController(
    vsync: this,
    duration: ResultView.badgeFade,
  );
  double _band = 0;
  double? _radialTop;
  bool _announced = false;

  @override
  void initState() {
    super.initState();
    _badgeIn.value = widget.model.badge == ResultBadge.none ? 0 : 1;
    _scroll.addListener(_onScroll);
    if (widget.interactive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _announce();
      });
    }
  }

  @override
  void didUpdateWidget(ResultView old) {
    super.didUpdateWidget(old);
    final was = old.model.badge;
    final now = widget.model.badge;
    if (was == ResultBadge.none && now != ResultBadge.none) {
      // The rating read-back resolved into a badge. Once the badge row has
      // entered, it fades in inside its reserved row (no layout shift).
      if (widget.motion.head > 0 && !reduceMotionRequested()) {
        _badgeIn.forward(from: 0);
      } else {
        _badgeIn.value = 1;
      }
      if (_announced) _say(_badgeSpoken(now));
    } else if (now == ResultBadge.none) {
      _badgeIn.value = 0;
    }
    if (!old.interactive && widget.interactive) _announce();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _badgeIn.dispose();
    super.dispose();
  }

  /// The band follows the current offset (architecture §20.9 (1)). Called on
  /// every scroll and on every scroll-metrics change: when the content shrinks
  /// (e.g. the OS text size drops while scrolled), the position clamps its
  /// offset without notifying listeners, and only a
  /// [ScrollMetricsNotification] reports it.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final v = (_scroll.position.pixels / ResultView.bandFadeDistance).clamp(
      0.0,
      1.0,
    );
    if (v != _band) setState(() => _band = v);
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0) _onScroll();
    return false;
  }

  /// At rest, once: "Döngü tamamlandı. Hedef üç hamlede yerine oturdu.", then
  /// the badge when shown (`ui-design.md` §16.11 Semantics).
  void _announce() {
    if (_announced) return;
    _announced = true;
    final strings = widget.strings;
    final badge = widget.model.badge;
    final parts = <String>[
      strings.resultHeadlineSpoken,
      strings.subtitleFor(widget.model.playerMoves),
      if (badge != ResultBadge.none) _badgeSpoken(badge),
    ];
    _say(parts.join(' '));
  }

  void _say(String message) {
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    SemanticsService.announce(message, direction);
  }

  String _badgeSpoken(ResultBadge badge) => switch (badge) {
    ResultBadge.perfect => widget.rating.perfectSpoken,
    ResultBadge.newBest => widget.rating.newBestSpoken,
    ResultBadge.none => '',
  };

  /// Places the radial on the laid-out answer row (content-local), so it
  /// paints behind the whole column and scrolls with the row.
  void _measureRadial() {
    if (!mounted) return;
    final slot = widget.slotKey.currentContext?.findRenderObject();
    final content = _contentKey.currentContext?.findRenderObject();
    if (slot is! RenderBox || content is! RenderBox) return;
    if (!slot.hasSize || !content.hasSize) return;
    final s = widget.layout.s;
    final centre = slot
        .localToGlobal(Offset(0, slot.size.height / 2), ancestor: content)
        .dy;
    final top = centre - ResultView.radialHeightRef / 2 * s;
    if (_radialTop == null || (top - _radialTop!).abs() > 0.1) {
      setState(() => _radialTop = top);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureRadial());
    final layout = widget.layout;
    final s = layout.s;
    final e = layout.extra;
    final m = widget.motion;
    final model = widget.model;
    final strings = widget.strings;
    final rating = widget.rating;
    final capped = loopCappedTextScaler(context);
    const even = TextHeightBehavior(
      leadingDistribution: TextLeadingDistribution.even,
    );
    final colX = layout.left + ResultView.columnLeftRef * s;
    final colW = ResultView.columnWidthRef * s;
    final bottom = MediaQuery.paddingOf(context).bottom + 24 * s;

    Widget band(double opacity, double rise, Widget child) => Opacity(
      opacity: (opacity * m.exit).clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (rise + m.drop) * s),
        child: child,
      ),
    );

    // --- verdict: badge row (reserved), headline, subtitle -----------------
    final badgeLabel = switch (model.badge) {
      ResultBadge.perfect => rating.perfect,
      ResultBadge.newBest => rating.newBest,
      ResultBadge.none => null,
    };
    final badgeRow = SizedBox(
      height: ResultView.badgeRowRef * s,
      child: badgeLabel == null
          ? null
          : Center(
              child: FadeTransition(
                opacity: _badgeIn,
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: Semantics(
                    label: _badgeSpoken(model.badge),
                    excludeSemantics: true,
                    child: LoopBadge(label: badgeLabel),
                  ),
                ),
              ),
            ),
    );
    final headline = Semantics(
      header: true,
      label: strings.resultHeadlineSpoken,
      excludeSemantics: true,
      child: Text(
        strings.resultHeadline,
        style: LoopText.display(s),
        textAlign: TextAlign.center,
        textScaler: capped,
        textHeightBehavior: even,
      ),
    );
    final subtitle = Text(
      strings.subtitleFor(model.playerMoves),
      style: LoopText.bodyText(s).copyWith(height: 1.3),
      textAlign: TextAlign.center,
      textHeightBehavior: even,
    );

    // --- the object: the answer row, then the stars --------------------------
    final letters = widget.letters;
    final answer = Semantics(
      label: '${strings.answerWord}: ${model.word}',
      excludeSemantics: true,
      child: SizedBox(
        key: widget.slotKey,
        height: TileFace.answerHeightRef * s,
        child: Opacity(
          opacity: (m.answer * m.exit).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, m.drop * s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (var i = 0; i < letters.length; i++) ...<Widget>[
                  if (i > 0) SizedBox(width: ResultView.tilesGapRef * s),
                  TileFace.answer(letter: letters[i], scale: s),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    final Widget stars = model.rated
        ? Center(
            child: Semantics(
              label: rating.starGroupSemantics(
                stars: model.stars,
                perfect: model.perfect,
              ),
              excludeSemantics: true,
              child: StarRow(
                earned: model.stars,
                size: ResultView.starSizeRef,
                starWord: rating.starWord,
                revealMs: m.starRevealMs,
              ),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(minHeight: ResultView.starSizeRef * s),
            child: Text(
              rating.noRating,
              style: LoopText.bodyText(
                s,
              ).copyWith(fontSize: 13 * s, height: 1.3),
              textAlign: TextAlign.center,
              textHeightBehavior: even,
            ),
          );

    // --- numbers and choice ----------------------------------------------------
    String num(int? n) => n == null ? '—' : '$n';
    final stats = Semantics(
      label: rating.statsSemantics(
        you: model.playerMoves,
        optimal: model.optimal,
        best: model.best,
        bestIsPerfect: model.bestIsPerfect,
      ),
      excludeSemantics: true,
      child: StatCard(
        cells: <StatCell>[
          StatCell(value: '${model.playerMoves}', label: rating.you),
          StatCell(value: num(model.optimal), label: rating.optimal),
          StatCell(
            value: num(model.best),
            label: rating.best,
            star: model.bestIsPerfect,
          ),
        ],
      ),
    );
    final nextLabel = model.next == ResultNext.terminal
        ? strings.finishJourney
        : strings.nextLevel;
    final onNext = widget.onNext ?? () {};
    final primary = LimePill(
      label: model.nextIsPrimary ? nextLabel : strings.playAgain,
      onPressed: model.nextIsPrimary ? onNext : widget.onRetry,
    );
    final Widget link;
    if (model.nextIsPrimary) {
      link = TextLink(label: strings.playAgain, onPressed: widget.onRetry);
    } else if (model.nextDisabled) {
      link = Semantics(
        label: strings.nextLevelSoonSpoken,
        button: true,
        enabled: false,
        excludeSemantics: true,
        child: TextLink(
          label: strings.nextLevel,
          onPressed: null,
          disabledSuffix: strings.soonSuffix,
        ),
      );
    } else {
      link = TextLink(label: nextLabel, onPressed: onNext);
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        band(m.head, m.headRise, badgeRow),
        SizedBox(height: 16 * s + 0.08 * e),
        band(m.head, m.headRise, headline),
        SizedBox(height: 14.25 * s),
        band(m.sub, m.subRise, subtitle),
        SizedBox(height: 38.3 * s + 0.16 * e),
        answer,
        SizedBox(height: 32 * s),
        band(m.stats, m.statsRise, stars),
        SizedBox(height: 24.5 * s),
        band(m.stats, m.statsRise, stats),
        SizedBox(height: 18.5 * s),
        band(m.cta, m.ctaRise, primary),
        SizedBox(height: 27.25 * s - 22),
        band(m.cta, m.ctaRise, SizedBox(width: double.infinity, child: link)),
      ],
    );

    final radialTop = _radialTop;
    final content = Stack(
      key: _contentKey,
      clipBehavior: Clip.none,
      children: <Widget>[
        if (radialTop != null)
          Positioned(
            left: -colX,
            width: layout.screen.width,
            top: radialTop,
            height: ResultView.radialHeightRef * s,
            child: Opacity(
              opacity: (m.radial * m.exit).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, m.drop * s),
                child: const LimeGlow.result(),
              ),
            ),
          ),
        column,
      ],
    );

    return IgnorePointer(
      ignoring: !widget.interactive,
      child: ExcludeSemantics(
        excluding: !widget.interactive,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: _onMetrics,
                child: SingleChildScrollView(
                  controller: _scroll,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: colX,
                    right: layout.screen.width - colX - colW,
                    top: ResultView.columnTop(layout),
                    bottom: bottom,
                  ),
                  child: content,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ScrollBand(visibility: _band),
            ),
            Positioned(
              left: colX,
              top: ResultView.backTopRef * s,
              child: Opacity(
                opacity: (m.back * m.exit).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, m.drop * s),
                  child: GlassIconButton(
                    icon: LoopIcon.back,
                    onPressed: widget.onBack,
                    semanticLabel: strings.backHome,
                    radius: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
