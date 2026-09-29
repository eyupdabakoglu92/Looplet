import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'design/design.dart';
import 'journey/journey_home_view.dart';
import 'journey/journey_progress.dart';
import 'journey/journey_strings.dart';
import 'play/debug_puzzle_library.dart';
import 'play/play_session_args.dart';
import 'reduce_motion.dart';
import 'shell/splash_screen.dart';

/// The app's home (`/`) — F05, Design Adoption Phase D3 (`ui-design.md` §4–§12,
/// architecture §18.3 / §18.7): the Loop Glass composition of `S-06b`. The
/// `Looplet` wordmark; a glass card with `YOLCULUK · N / 30`, a two-line
/// headline with one lime word and the loop track; one lime "Devam et" pill
/// with its glow; the caption of where it leads. App root — no back
/// affordance, no top bar. Not the F10 menu (no future-scope item).
///
/// Before the Journey model loads, Home is the splash frame (the wordmark
/// only — no empty card, no spinner). When the model arrives the content
/// enters once per app process (C3); never on a return from `/play` (Home
/// stays mounted) and never when the model updates. No idle motion.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({this.showDebugRow = kDebugMode, super.key});

  /// The dev-only smoke-puzzle launchers (C2). Debug builds only.
  final bool showDebugRow;

  /// The entrance (ui-design §5): card 0–240, CTA 60–300, caption 120–340 ms.
  static const Duration entranceDuration = Duration(milliseconds: 340);

  static bool _entrancePlayed = false;

  /// Lets the next Home play its entrance again (tests only).
  @visibleForTesting
  static void resetEntranceForTest() => _entrancePlayed = false;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Launch language is `tr` for the MVP (F10 owns switching).
  static const String _lang = 'tr';

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: HomeScreen.entranceDuration,
  );
  bool _entranceArmed = false;

  final GlobalKey _captionKey = GlobalKey(debugLabel: 'home.caption');
  final GlobalKey _debugRowKey = GlobalKey(debugLabel: 'home.debugRow');
  final GlobalKey _stackKey = GlobalKey(debugLabel: 'home.stack');
  bool _debugRowFits = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entrance.dispose();
    super.dispose();
  }

  // Defensive: Reduce Motion switched on (or its flag arriving) mid-entrance
  // puts the content at rest at once.
  @override
  void didChangeAccessibilityFeatures() {
    if (reduceMotionRequested() && _entrance.isAnimating) _entrance.value = 1;
  }

  /// Arms the entrance at the first frame that has the model (C3).
  void _armEntrance() {
    if (_entranceArmed) return;
    _entranceArmed = true;
    if (HomeScreen._entrancePlayed || reduceMotionRequested()) {
      _entrance.value = 1;
    } else {
      _entrance.forward(from: 0);
    }
    HomeScreen._entrancePlayed = true;
  }

  /// C2: the debug row sits at the bottom and is shown only while it clears
  /// the caption; measured after layout, so it never overflows.
  void _checkDebugRow() {
    final row = _debugRowKey.currentContext?.findRenderObject() as RenderBox?;
    final caption =
        _captionKey.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (row == null || caption == null || stack == null || !mounted) return;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final rowTop = stack.size.height - bottomInset - 8 - row.size.height;
    final captionBottom = caption
        .localToGlobal(Offset(0, caption.size.height), ancestor: stack)
        .dy;
    final fits = rowTop >= captionBottom + 12;
    if (fits != _debugRowFits) setState(() => _debugRowFits = fits);
  }

  @override
  Widget build(BuildContext context) {
    final strings = JourneyStrings.of(_lang);
    final modelAsync = ref.watch(journeyProgressModelProvider);
    var model = modelAsync.asData?.value;
    if (model == null && modelAsync.hasError) {
      // Keep a working CTA over a dead one: a failing read-model falls back
      // to the new-player view (level 1), as the shipped home did.
      debugPrint('journey: home_model_failed — ${modelAsync.error}');
      model = const JourneyProgressModel(
        highestUnlockedLevel: 1,
        completedLevels: <int>{},
        inProgressLevel: null,
      );
    }
    if (model != null) _armEntrance();
    final view = model == null ? null : JourneyHomeView.of(model);

    if (widget.showDebugRow) {
      // Re-measured after every layout-relevant change: this State depends on
      // the text scale and the screen size, so a live OS text-size change
      // rebuilds it and the check runs again (C2).
      MediaQuery.textScalerOf(context);
      MediaQuery.sizeOf(context);
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkDebugRow());
    }

    return ShellFrame(
      builder: (context, layout) {
        if (view == null) return const SizedBox.shrink(); // = the splash frame
        return Stack(
          key: _stackKey,
          children: <Widget>[
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: layout.homeColumnLeft,
                  top: layout.homeColumnTop,
                  bottom: 24 * layout.s,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: layout.homeColumnWidth,
                    child: _HomeColumn(
                      view: view,
                      strings: strings,
                      entrance: _entrance,
                      captionKey: _captionKey,
                      onCta: () => context.push(
                        Routes.play,
                        extra: PlaySessionArgs(
                          source: PuzzleSource.journey,
                          journeyLevel: view.ctaTarget,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showDebugRow)
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.paddingOf(context).bottom + 8,
                child: Offstage(
                  offstage: !_debugRowFits,
                  child: KeyedSubtree(
                    key: _debugRowKey,
                    child: const _DebugRow(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Card → CTA → caption, one flow column so free text can grow with the OS
/// scale without overlap (ui-design §6).
class _HomeColumn extends StatelessWidget {
  const _HomeColumn({
    required this.view,
    required this.strings,
    required this.entrance,
    required this.captionKey,
    required this.onCta,
  });

  final JourneyHomeView view;
  final JourneyStrings strings;
  final Animation<double> entrance;
  final Key captionKey;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Enter(
          animation: entrance,
          from: 0,
          to: 240,
          rise: 10 * s,
          child: Padding(
            padding: EdgeInsets.only(left: 0.5 * s),
            child: _JourneyCard(view: view, strings: strings),
          ),
        ),
        SizedBox(height: 22 * s),
        _Enter(
          animation: entrance,
          from: 60,
          to: 300,
          rise: 10 * s,
          child: Semantics(
            button: true,
            label: view.ctaSemantics(strings),
            onTap: onCta,
            excludeSemantics: true,
            child: LimePill(
              label: view.ctaLabel(strings),
              onPressed: onCta,
              glow: true,
              width: 309 * s,
              height: 63 * s,
            ),
          ),
        ),
        SizedBox(height: 17 * s),
        _Enter(
          animation: entrance,
          from: 120,
          to: 340,
          rise: 10 * s,
          // The CTA already announces its target; the caption is not read
          // twice. Free text: follows the OS scale; no-break joins let it
          // break only before "·".
          child: ExcludeSemantics(
            child: SizedBox(
              width: 309 * s,
              child: Text(
                view.caption(strings),
                key: captionKey,
                textAlign: TextAlign.center,
                style: LoopText.bodyText(
                  s,
                ).copyWith(fontSize: 14 * s, height: 1.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Journey card: the label, the headline and the loop track over the two
/// decorative swirl arcs of `S-06b`, clipped to the card (ui-design §5–§7).
/// 300·s tall at 1.0× (31 + 11 + 15 + 65 + 12 + 166); it grows only when the
/// capped label or headline does.
class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.view, required this.strings});

  final JourneyHomeView view;
  final JourneyStrings strings;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final capped = loopCappedTextScaler(context);
    final headline = view.headlineText(strings);
    final headStyle = LoopText.headline(s);
    return GlassCard(
      width: LoopTrackGeometry.cardWidth * s,
      minHeight: 300 * s,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LoopRadii.card * s - 1),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 300 * s,
              child: const ExcludeSemantics(
                child: CustomPaint(painter: _SwirlPainter()),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 31·s from the card's outer top: the glass card's 1 px edge
                // insets its child by 1 px on each side (`BoxDecoration`
                // padding), so 2 px come off here to keep the card 300·s tall.
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    24.5 * s,
                    31 * s - 2,
                    24.5 * s,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // The progress, announced once (§18.3 (5)).
                      Semantics(
                        container: true,
                        label: view.progressSemantics(strings),
                        child: ExcludeSemantics(
                          child: Text(
                            strings.journeyLabel(view.progressCount),
                            style: LoopText.caption(s).copyWith(
                              fontSize: 11 * s,
                              letterSpacing: 0.2 * 11 * s,
                              height: 1,
                            ),
                            textScaler: capped,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                      SizedBox(height: 15 * s),
                      Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(text: headline.before),
                            TextSpan(
                              text: headline.emphasis,
                              style: const TextStyle(color: LoopColors.lime),
                            ),
                            TextSpan(text: headline.after),
                          ],
                        ),
                        style: headStyle,
                        textScaler: capped,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * s),
                LoopTrack(
                  firstLevel: view.windowStart,
                  states: view.windowStates,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The two decorative swirl arcs of `S-06b` (ui-design §5 Surface), in the
/// card's 308 × 300 reference box, anchored to its bottom. No semantics.
class _SwirlPainter extends CustomPainter {
  const _SwirlPainter();

  static const Color _sage = Color(0x24BECDAA); // rgba(190,205,170,.14)
  static const Color _peri = Color(0x427884E1); // rgba(120,132,225,.26)

  void _ellipse(
    Canvas canvas,
    Offset centre,
    double rx,
    double ry,
    double degrees,
    Color color,
    double width,
  ) {
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..rotate(degrees * 3.141592653589793 / 180)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = color,
      )
      ..restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 308, size.height / 300);
    _ellipse(canvas, const Offset(60, 210), 170, 64, -9, _sage, 20);
    _ellipse(canvas, const Offset(240, 230), 150, 80, -14, _peri, 24);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SwirlPainter oldDelegate) => false;
}

/// One entrance element: opacity 0 → 1 with a rise, ease-out
/// `cubic-bezier(.22,.61,.36,1)`, in the [from]–[to] ms window of the
/// 340 ms entrance (ui-design §5).
class _Enter extends StatelessWidget {
  const _Enter({
    required this.animation,
    required this.from,
    required this.to,
    required this.rise,
    required this.child,
  });

  final Animation<double> animation;
  final int from;
  final int to;
  final double rise;
  final Widget child;

  static const Curve _ease = Cubic(0.22, 0.61, 0.36, 1);

  @override
  Widget build(BuildContext context) {
    const total = 340;
    final window = Interval(from / total, to / total, curve: _ease);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = window.transform(animation.value);
        if (t >= 1) return child!; // at rest: no Opacity layer
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, rise * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Dev-only shortcut to the debug smoke set and the debug sync screen (C2:
/// `kDebugMode` only, outside the content column; Material buttons allowed
/// because players never see it).
class _DebugRow extends StatelessWidget {
  const _DebugRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        const Text(
          'debug',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            color: LoopColors.muted,
          ),
        ),
        for (final id in DebugPuzzleLibrary.ids)
          OutlinedButton(
            onPressed: () => context.push(
              Routes.play,
              extra: PlaySessionArgs(
                source: PuzzleSource.journey,
                debugPuzzleId: id,
              ),
            ),
            child: Text(id.replaceFirst('smoke-tr-', 'L')),
          ),
        // F08 Activation A3: the fake daily-result trigger.
        OutlinedButton(
          onPressed: () => context.push(Routes.debugSync),
          child: const Text('sync'),
        ),
      ],
    );
  }
}
