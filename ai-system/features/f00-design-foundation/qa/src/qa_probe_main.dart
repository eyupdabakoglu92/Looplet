// QA probe for F00-QA-VISUAL — NOT part of the repository. Lives in the QA scratch dir and is built with
//   flutter build ios --simulator --debug -t <this file>
// It imports the delivered design layer as a package and (1) draws the edge cases the gallery does not
// (two-digit nodes, long labels, star/undo/moves ranges, Turkish capitals at three tile sizes, 3-line text),
// (2) dumps the runtime semantics tree and RenderBox sizes to the log (QAPROBE lines), (3) in `press` mode
// holds a synthetic pointer-down on a LimePill to observe the pressed scale under the real OS Reduce Motion
// setting, (4) hosts the real DesignGalleryApp in `gallery` mode to dump ITS semantics tree.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/main_gallery.dart' show DesignGalleryApp;
import 'package:looplet_app/reduce_motion.dart';

int _overflowCount = 0;

String _mode() {
  try {
    final f = File('${Directory.systemTemp.path}/probe_mode');
    if (f.existsSync()) return f.readAsStringSync().trim();
  } on FileSystemException {
    // default below
  }
  return 'edge';
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed')) _overflowCount++;
    final full = details.toString().replaceAll('\n', ' ⏎ ');
    debugPrint('QAPROBE flutter-error: ${text.split('\n').first}');
    final info = (details.informationCollector?.call() ?? const <DiagnosticsNode>[])
        .map((n) => n.toStringDeep().replaceAll('\n', ' ⏎ '))
        .join(' ⏎ ');
    debugPrint('QAPROBE flutter-error-widget: ${info.length > 600 ? info.substring(0, 600) : info}');
    previous?.call(details);
  };
  final mode = _mode();
  debugPrint('QAPROBE start mode=$mode');
  runApp(mode == 'gallery' ? const DesignGalleryApp() : ProbeApp(mode: mode));
  Timer(const Duration(seconds: 3), () => _report(mode));
  if (mode == 'press') {
    Timer(const Duration(seconds: 4), _pressDown);
    Timer(const Duration(seconds: 14), _pressUp);
  }
}

// ---------------------------------------------------------------------------------------------- reporting
void _report(String mode) {
  final dispatcher = WidgetsBinding.instance.platformDispatcher;
  final view = dispatcher.views.first;
  final f = dispatcher.accessibilityFeatures;
  debugPrint(
    'QAPROBE env mode=$mode logical=${view.physicalSize.width / view.devicePixelRatio}x'
    '${view.physicalSize.height / view.devicePixelRatio} dpr=${view.devicePixelRatio} '
    'textScale=${dispatcher.textScaleFactor} reduceMotion=${f.reduceMotion} '
    'disableAnimations=${f.disableAnimations} boldText=${f.boldText} '
    'reduceMotionRequested=${reduceMotionRequested()} overflows=$_overflowCount',
  );
  SemanticsNode? root;
  for (final rv in RendererBinding.instance.renderViews) {
    root = rv.owner?.semanticsOwner?.rootSemanticsNode ?? root;
  }
  debugPrint('QAPROBE semantics-root=${root != null}');
  var count = 0;
  void walk(SemanticsNode n, int depth) {
    final d = n.getSemanticsData();
    final hasInfo = d.label.isNotEmpty ||
        d.hasFlag(ui.SemanticsFlag.isButton) ||
        d.hasFlag(ui.SemanticsFlag.isImage) ||
        d.hasAction(ui.SemanticsAction.tap);
    if (hasInfo) {
      count++;
      final r = n.rect;
      debugPrint(
        'QAPROBE sem d=$depth size=${r.width.toStringAsFixed(1)}x${r.height.toStringAsFixed(1)} '
        'button=${d.hasFlag(ui.SemanticsFlag.isButton)} enabled=${d.hasFlag(ui.SemanticsFlag.isEnabled)} '
        'hasEnabled=${d.hasFlag(ui.SemanticsFlag.hasEnabledState)} image=${d.hasFlag(ui.SemanticsFlag.isImage)} '
        'tap=${d.hasAction(ui.SemanticsAction.tap)} label="${d.label.replaceAll('\n', ' | ')}"',
      );
    }
    n.visitChildren((c) {
      walk(c, depth + 1);
      return true;
    });
  }

  if (root != null) walk(root, 0);
  debugPrint('QAPROBE sem-count=$count');
  const watched = <String>{
    'LimePill', 'OutlinePill', 'TextLink', 'GlassIconButton', 'UndoPill', 'MovesCard', 'LoopNode',
    'StarRow', 'StatCard', 'TileFace', 'LoopBadge', 'GhostSlot', 'RailTile', 'LoopletWordmark',
  };
  void visit(Element e) {
    final t = e.widget.runtimeType.toString();
    if (watched.contains(t)) {
      final ro = e.renderObject;
      if (ro is RenderBox && ro.hasSize) {
        final p = ro.localToGlobal(Offset.zero);
        debugPrint(
          'QAPROBE box $t ${ro.size.width.toStringAsFixed(1)}x${ro.size.height.toStringAsFixed(1)} '
          'at ${p.dx.toStringAsFixed(1)},${p.dy.toStringAsFixed(1)}',
        );
      }
    }
    e.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  debugPrint('QAPROBE report-end overflows=$_overflowCount');
}

// ---------------------------------------------------------------------------------------------- press mode
final GlobalKey _pressKey = GlobalKey();

Offset? _pressCentre() {
  final ro = _pressKey.currentContext?.findRenderObject();
  if (ro is! RenderBox) return null;
  return ro.localToGlobal(ro.size.center(Offset.zero));
}

void _pressDown() {
  final c = _pressCentre();
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  if (c == null) return debugPrint('QAPROBE press: no target');
  GestureBinding.instance.handlePointerEvent(
    PointerDownEvent(pointer: 77, position: c, kind: PointerDeviceKind.touch, viewId: view.viewId),
  );
  debugPrint('QAPROBE press down at ${c.dx},${c.dy} reduceMotionRequested=${reduceMotionRequested()}');
}

void _pressUp() {
  final c = _pressCentre();
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  if (c == null) return;
  GestureBinding.instance.handlePointerEvent(
    PointerUpEvent(pointer: 77, position: c, kind: PointerDeviceKind.touch, viewId: view.viewId),
  );
  debugPrint('QAPROBE press up');
}

// ---------------------------------------------------------------------------------------------- UI
class ProbeApp extends StatelessWidget {
  const ProbeApp({required this.mode, super.key});
  final String mode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: LoopColors.groundBottom),
      home: Scaffold(
        body: LoopBackdrop(
          child: SafeArea(
            child: mode == 'press' || mode == 'nopress' ? _PressScreen(mode: mode) : const _EdgeScreen(),
          ),
        ),
      ),
    );
  }
}

class _PressScreen extends StatelessWidget {
  const _PressScreen({required this.mode});
  final String mode;
  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24 * s),
      child: Center(
        child: KeyedSubtree(
          key: _pressKey,
          child: LimePill(label: 'Sonraki bölüm', onPressed: () {}),
        ),
      ),
    );
  }
}

double _probeOffset() {
  try {
    final f = File('${Directory.systemTemp.path}/probe_offset');
    if (f.existsSync()) return double.tryParse(f.readAsStringSync().trim()) ?? 0;
  } on FileSystemException {
    // top
  }
  return 0;
}

class _EdgeScreen extends StatelessWidget {
  const _EdgeScreen();

  Widget _h(double s, String t) => Padding(
        padding: EdgeInsets.only(top: 18 * s, bottom: 8 * s),
        child: Text(t, style: LoopText.caption(s)),
      );

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final w = MediaQuery.sizeOf(context).width - 48 * s;
    return SingleChildScrollView(
      controller: ScrollController(initialScrollOffset: _probeOffset()),
      padding: EdgeInsets.fromLTRB(24 * s, 8 * s, 24 * s, 40 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _h(s, 'LOOP NODES 1 · 9 · 10 · 29 · 30 · CURRENT 12 · 30'),
          Wrap(
            spacing: 8 * s,
            runSpacing: 8 * s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const <Widget>[
              LoopNode(number: 1), LoopNode(number: 9), LoopNode(number: 10), LoopNode(number: 29),
              LoopNode(number: 30), LoopNode(number: 12, current: true), LoopNode(number: 30, current: true),
            ],
          ),
          _h(s, 'LONG LABELS'),
          SizedBox(width: w, child: LimePill(label: 'Sonraki bölümü başlat ve yeni döngüye devam et', onPressed: () {})),
          SizedBox(height: 10 * s),
          SizedBox(width: w, child: OutlinePill(label: 'İkincil eylem: yeniden oyna ve en iyi sonucu geliştir', onPressed: () {})),
          SizedBox(height: 6 * s),
          TextLink(label: 'Sonraki bölüme geç ve kaldığın yerden devam et', onPressed: null, disabledSuffix: '· yakında'),
          _h(s, 'MOVES 0 · 9 · 42 · 100 · BADGES'),
          Wrap(
            spacing: 10 * s,
            runSpacing: 10 * s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const <Widget>[
              MovesCard(moves: 0), MovesCard(moves: 9), MovesCard(moves: 42), MovesCard(moves: 100),
              LoopBadge(label: 'HARİKA'), LoopBadge(label: 'YENİ EN İYİ'),
            ],
          ),
          _h(s, 'STARS 0 1 2 3 · UNDO QUOTA 0 1 2 3'),
          Wrap(
            spacing: 16 * s,
            runSpacing: 10 * s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              const StarRow(earned: 0), const StarRow(earned: 1), const StarRow(earned: 2), const StarRow(earned: 3),
              for (var q = 0; q <= 3; q++) UndoPill(quota: q, onPressed: q == 0 ? null : () {}, semanticLabel: 'Geri al, $q hak'),
            ],
          ),
          _h(s, 'STATS WITH 3-DIGIT VALUES'),
          const StatCard(
            cells: <StatCell>[
              StatCell(value: '128', label: 'SEN'),
              StatCell(value: '12', label: 'OPTİMAL'),
              StatCell(value: '9', label: 'EN İYİ', star: true),
            ],
          ),
          _h(s, 'TILES İ Ğ Ş Ç Ö Ü AT 44 · 57.6 · 66 (× s)'),
          Wrap(
            spacing: 6 * s,
            runSpacing: 6 * s,
            children: <Widget>[
              for (final size in const [44.0, 57.6, 66.0])
                for (final ch in const ['İ', 'Ğ', 'Ş', 'Ç', 'Ö', 'Ü', 'W', 'M'])
                  TileFace(letter: ch, size: size * s, state: ch == 'W' ? TileState.locked : (ch == 'M' ? TileState.frozen : TileState.normal)),
            ],
          ),
          _h(s, 'GLASS CARD, 3-LINE HEADLINE'),
          GlassCard(
            width: w,
            padding: EdgeInsets.all(18 * s),
            child: Text.rich(
              TextSpan(
                style: LoopText.headline(s),
                children: <InlineSpan>[
                  const TextSpan(text: 'Sıradaki '),
                  TextSpan(text: 'döngüyü', style: LoopText.headline(s).copyWith(color: LoopColors.lime)),
                  const TextSpan(text: ' çöz. Hedef üç hamlede yerine oturdu, yolculuk devam ediyor.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          Row(
            children: <Widget>[
              GlassIconButton(icon: LoopIcon.back, onPressed: () {}, semanticLabel: 'Ana ekrana dön'),
              SizedBox(width: 10 * s),
              GlassIconButton(icon: LoopIcon.restart, onPressed: () {}, semanticLabel: 'Yeniden başlat'),
              SizedBox(width: 10 * s),
              const LoopletWordmark(fontSize: 25),
            ],
          ),
        ],
      ),
    );
  }
}
