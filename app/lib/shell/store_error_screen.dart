import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../design/design.dart';
import 'shell_strings.dart';
import 'shell_wordmark.dart';
import 'splash_screen.dart';

/// Shown when the on-device store cannot be opened or a migration failed
/// (F08 AC9, F08 App Init Sequence step 1). Data is left intact at the
/// previous schema; Retry re-runs the bootstrap.
///
/// The Foundation pattern (F05 `ui-design.md` §6 / §8 `D3-20`, architecture
/// §18.3 (7)): the wordmark, one calm glass card — the caps label, the
/// periwinkle `loopBreak` glyph, the headline and a reassuring body — and one
/// lime Retry. It is the sibling of the D1 load error, with the wordmark in
/// place of the chevron: this is the app root, with no caller to go back to.
///
/// **The raw exception is never shown to the player.** It is logged with
/// `debugPrint` in every build and shown only in debug builds
/// ([showDetails], default `kDebugMode`), in a box visibly apart from the
/// player copy and excluded from semantics.
///
/// Above the 1.3× text cap the column may scroll (C-9): the whole page —
/// wordmark included — scrolls under a [ScrollBand], so text never passes
/// under the status bar and the pill is reached by scrolling.
class StoreErrorScreen extends StatefulWidget {
  const StoreErrorScreen({
    required this.message,
    required this.onRetry,
    this.showDetails,
    this.lang = 'tr',
    super.key,
  });

  /// The technical failure (log / debug only).
  final String message;
  final VoidCallback onRetry;

  /// Whether the debug details box is shown; `null` → `kDebugMode`.
  final bool? showDetails;

  final String lang;

  /// Scroll offset over which the band fades in (as on the Result).
  static const double bandFadeDistance = 24;

  @override
  State<StoreErrorScreen> createState() => _StoreErrorScreenState();
}

class _StoreErrorScreenState extends State<StoreErrorScreen> {
  final ScrollController _scroll = ScrollController();
  double _band = 0;

  @override
  void initState() {
    super.initState();
    _log();
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(StoreErrorScreen old) {
    super.didUpdateWidget(old);
    if (old.message != widget.message) _log();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _log() => debugPrint('store: bootstrap_failed — ${widget.message}');

  // The band follows the current offset, also when the content shrinks while
  // scrolled (a metrics change clamps the offset without notifying listeners).
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final v = (_scroll.position.pixels / StoreErrorScreen.bandFadeDistance)
        .clamp(0.0, 1.0);
    if (v != _band) setState(() => _band = v);
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0) _onScroll();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ShellStrings.of(widget.lang);
    final details = widget.showDetails ?? kDebugMode;
    return ShellFrame(
      scrollingWordmark: true,
      builder: (context, layout) {
        final s = layout.s;
        final capped = loopCappedTextScaler(context);
        final column = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GlassCard(
              padding: EdgeInsets.fromLTRB(26 * s, 28 * s, 26 * s, 30 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ExcludeSemantics(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 4 * s),
                            child: Text(
                              strings.storeErrorLabel,
                              style: LoopText.caption(s),
                              textScaler: capped,
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * s),
                        Opacity(
                          opacity: 0.9,
                          child: LoopIconView(
                            LoopIcon.loopBreak,
                            color: LoopColors.periwinkle,
                            size: 44 * s,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * s),
                  Text(
                    strings.storeErrorHeadline,
                    style: LoopText.headline(s),
                    textScaler: capped,
                  ),
                  SizedBox(height: 12 * s),
                  // Free text: follows the OS scale to AX5.
                  Text(
                    strings.storeErrorBody,
                    style: LoopText.bodyText(s).copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20 * s),
            LimePill(
              label: strings.retry,
              onPressed: widget.onRetry,
              icon: null,
              height: 63 * s,
            ),
            if (details) ...<Widget>[
              SizedBox(height: 20 * s),
              _DebugDetails(
                label: strings.debugDetailsLabel,
                message: widget.message,
                s: s,
              ),
            ],
          ],
        );
        final bandHeight = layout.errorBandBottom - layout.errorBandTop;
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: _onMetrics,
                child: SingleChildScrollView(
                  controller: _scroll,
                  physics: const ClampingScrollPhysics(),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          left: layout.errorColumnLeft,
                          top: layout.errorBandTop,
                          bottom: 40 * s,
                        ),
                        child: SizedBox(
                          width: 309 * s,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: bandHeight < 0 ? 0 : bandHeight,
                            ),
                            child: column,
                          ),
                        ),
                      ),
                      Positioned(
                        left: layout.wordmarkLeft,
                        top: layout.wordmarkTop,
                        child: ShellWordmark(fontSize: layout.wordmarkSize),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ScrollBand(visibility: _band),
            ),
          ],
        );
      },
    );
  }
}

/// Debug builds only: the technical message, visibly apart from the player
/// copy (a dark, outlined box with a caps label). Excluded from semantics.
class _DebugDetails extends StatelessWidget {
  const _DebugDetails({
    required this.label,
    required this.message,
    required this.s,
  });

  final String label;
  final String message;
  final double s;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 12 * s),
        decoration: BoxDecoration(
          color: const Color(0xB8050A1E), // rgba(5,10,30,.72)
          borderRadius: BorderRadius.circular(18 * s),
          border: Border.all(color: const Color(0x59AEB4CA)), // .35
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: LoopText.caption(s).copyWith(fontSize: 10 * s),
              textScaler: loopCappedTextScaler(context),
            ),
            SizedBox(height: 6 * s),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Menlo',
                fontFamilyFallback: const <String>['Courier', 'monospace'],
                fontSize: 11 * s,
                height: 1.4,
                color: const Color(0xFF8C93AE),
              ),
              // Developer detail, capped like container text: at AX5 an
              // uncapped monospace line breaks every identifier mid-word.
              textScaler: loopCappedTextScaler(context),
            ),
          ],
        ),
      ),
    );
  }
}
