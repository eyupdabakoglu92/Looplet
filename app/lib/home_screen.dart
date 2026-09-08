import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'journey/journey_progress.dart';
import 'journey/journey_strings.dart';
import 'play/debug_puzzle_library.dart';
import 'play/play_session_args.dart';
import 'play/play_theme.dart';
import 'play/widgets/play_stage.dart';

/// The app's home (`/`) — F05 (`ui-design.md` "The loop, filling"). Replaces the
/// debug placeholder. LOOPLET wordmark, a 30-tick journey-progress ring with the
/// `N / 30` count at its centre, and one dominant CONTINUE CTA nested into the
/// ring's bottom gap. Not the F10 menu. App root — no back affordance.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Launch language is `tr` for the MVP (F10 owns switching).
    const lang = 'tr';
    final strings = JourneyStrings.of(lang);
    final modelAsync = ref.watch(journeyProgressModelProvider);
    final model = modelAsync.asData?.value;

    return Scaffold(
      backgroundColor: PlayTheme.stage1,
      body: PlayStage(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final ringSize = math
                      .min(
                        constraints.maxWidth * 0.62,
                        constraints.maxHeight * 0.42,
                      )
                      .clamp(180.0, 300.0)
                      .toDouble();
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const _Wordmark(),
                      SizedBox(height: ringSize * 0.14),
                      _JourneyRing(
                        size: ringSize,
                        strings: strings,
                        model: model,
                      ),
                      SizedBox(height: ringSize * 0.06),
                      _ContinueCta(lang: lang, strings: strings, model: model),
                      if (kDebugMode) ...<Widget>[
                        const SizedBox(height: 28),
                        const _DebugRow(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PlayTheme.stageGlow.withValues(alpha: 0.5),
            blurRadius: 28,
          ),
        ],
      ),
      child: const Text(
        'LOOPLET',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: 6,
          color: PlayTheme.paper,
          height: 1,
        ),
      ),
    );
  }
}

class _JourneyRing extends StatelessWidget {
  const _JourneyRing({
    required this.size,
    required this.strings,
    required this.model,
  });

  final double size;
  final JourneyStrings strings;
  final JourneyProgressModel? model;

  @override
  Widget build(BuildContext context) {
    final count = model?.progressCount ?? 0;
    final done = model?.allComplete ?? false;
    final current = done ? null : model?.continueTarget;
    final inProgress = model?.inProgressLevel != null;

    return Semantics(
      label: strings.progressSemantics(count, current),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _JourneyRingPainter(
            progressCount: count,
            currentLevel: current,
            currentInProgress: inProgress,
          ),
          child: Center(
            child: _RingCentre(strings: strings, model: model),
          ),
        ),
      ),
    );
  }
}

class _RingCentre extends StatelessWidget {
  const _RingCentre({required this.strings, required this.model});

  final JourneyStrings strings;
  final JourneyProgressModel? model;

  @override
  Widget build(BuildContext context) {
    final loading = model == null;
    final count = model?.progressCount ?? 0;
    final done = model?.allComplete ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          done ? strings.allCompleteKicker : strings.progressUnit,
          style: PlayTheme.microLabel.copyWith(
            color: done
                ? PlayTheme.amber.withValues(alpha: 0.8)
                : PlayTheme.muted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        if (loading)
          const SizedBox(height: 40)
        else
          TweenAnimationBuilder<double>(
            // a single settle-tick + pulse when the count changes
            key: ValueKey<int>(count),
            tween: Tween<double>(begin: 1.06, end: 1),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '$count',
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                      color: PlayTheme.paper,
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                      height: 1,
                    ),
                  ),
                  const TextSpan(
                    text: '  / 30',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: PlayTheme.muted,
                      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _JourneyRingPainter extends CustomPainter {
  _JourneyRingPainter({
    required this.progressCount,
    required this.currentLevel,
    required this.currentInProgress,
  });

  final int progressCount;
  final int? currentLevel;
  final bool currentInProgress;

  // 300° sweep, 60° gap centred on the bottom.
  static const double _startDeg = 120; // clockwise from lower-left
  static const double _sweepDeg = 300;
  static const int _ticks = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.width * 0.5 - 10;
    final tickLen = size.width * 0.032;
    const start = _startDeg * math.pi / 180;
    const sweep = _sweepDeg * math.pi / 180;
    const step = sweep / (_ticks - 1);

    // 1) all-locked track first.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = PlayTheme.muted.withValues(alpha: 0.3);
    for (var i = 0; i < _ticks; i++) {
      final a = start + step * i;
      _tick(canvas, centre, radius, a, tickLen, trackPaint);
    }

    // 2) one continuous glow spanning the completed run.
    if (progressCount > 0) {
      final endIdx = math.min(progressCount, _ticks) - 1;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: radius),
        start,
        step * endIdx,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = tickLen + 6
          ..color = const Color(0xFFFFE9C2).withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      final donePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..color = PlayTheme.amber;
      for (var i = 0; i <= endIdx; i++) {
        final a = start + step * i;
        _tick(canvas, centre, radius, a, tickLen, donePaint);
      }
    }

    // 3) the current node.
    final cur = currentLevel;
    if (cur != null && cur >= 1 && cur <= _ticks) {
      final a = start + step * (cur - 1);
      final bright = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5
        ..color = PlayTheme.amber;
      _tick(canvas, centre, radius, a, tickLen, bright);
      final tip = Offset(
        centre.dx + (radius + tickLen * 0.5) * math.cos(a),
        centre.dy + (radius + tickLen * 0.5) * math.sin(a),
      );
      canvas.drawCircle(
        tip,
        5,
        Paint()
          ..color = PlayTheme.amber
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(tip, 4, Paint()..color = PlayTheme.amber);
      if (currentInProgress) {
        canvas.drawCircle(
          tip,
          7.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = PlayTheme.cyan,
        );
      }
    }
  }

  void _tick(Canvas canvas, Offset c, double r, double a, double len, Paint p) {
    final inner = Offset(
      c.dx + (r - len * 0.5) * math.cos(a),
      c.dy + (r - len * 0.5) * math.sin(a),
    );
    final outer = Offset(
      c.dx + (r + len * 0.5) * math.cos(a),
      c.dy + (r + len * 0.5) * math.sin(a),
    );
    canvas.drawLine(inner, outer, p);
  }

  @override
  bool shouldRepaint(_JourneyRingPainter old) =>
      old.progressCount != progressCount ||
      old.currentLevel != currentLevel ||
      old.currentInProgress != currentInProgress;
}

class _ContinueCta extends StatelessWidget {
  const _ContinueCta({
    required this.lang,
    required this.strings,
    required this.model,
  });

  final String lang;
  final JourneyStrings strings;
  final JourneyProgressModel? model;

  @override
  Widget build(BuildContext context) {
    final done = model?.allComplete ?? false;
    // All complete → replay from level 1 (progress is not reset).
    // Otherwise → the resolved current/next level (Level 1 when the model is
    // still loading or errored — a working CTA over a dead one).
    final target = done ? 1 : (model?.continueTarget ?? 1);
    final label = done ? strings.replayLabel : strings.continueLabel;
    final inProgress = !done && model?.inProgressLevel == target;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          button: true,
          label: '$label — ${strings.levelWord} $target',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(
              Routes.play,
              extra: PlaySessionArgs(
                source: PuzzleSource.journey,
                journeyLevel: target,
              ),
            ),
            child: Container(
              height: 54,
              width: 240,
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
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          strings.levelCaption(target, inProgress: inProgress),
          style: PlayTheme.helper.copyWith(
            fontSize: 13,
            color: PlayTheme.muted,
          ),
        ),
      ],
    );
  }
}

/// Dev-only shortcut to the debug smoke set (removed from release builds).
class _DebugRow extends StatelessWidget {
  const _DebugRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        const Text(
          'debug',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            color: PlayTheme.muted,
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
      ],
    );
  }
}
