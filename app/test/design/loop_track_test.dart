// F05-FE-D3 — the D3 design-layer additions (F05 architecture §18.3 (3),
// §18.7 ruling 2; `ui-design.md` §6–§7, §11.1 (2)–(5)): the `LoopNode` states
// `open` / `locked` / `finish` and the `LoopTrack` geometry. The existing
// `LoopNode(number:, current:)` form is covered unchanged by components_test.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/design.dart';
import 'package:looplet_app/journey/journey_home_view.dart';
import 'package:looplet_app/journey/journey_progress.dart';

Widget host(Widget child, {double scale = 1}) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(size: Size(393, 852)),
    child: LoopScale(
      value: scale,
      child: Center(child: child),
    ),
  ),
);

const LoopNodeState d = LoopNodeState.done;
const LoopNodeState c = LoopNodeState.current;
const LoopNodeState o = LoopNodeState.open;
const LoopNodeState l = LoopNodeState.locked;
const LoopNodeState f = LoopNodeState.finish;

/// Every window the Home can show: all progress counts × every session level.
Iterable<JourneyHomeView> allViews() sync* {
  for (var done = 0; done <= 30; done++) {
    for (final session in <int?>[null, for (var n = 1; n <= done + 1; n++) n]) {
      if (session != null && session > 30) continue;
      yield JourneyHomeView.of(
        JourneyProgressModel(
          highestUnlockedLevel: (done + 1).clamp(1, 30),
          completedLevels: <int>{for (var n = 1; n <= done; n++) n},
          inProgressLevel: session,
        ),
      );
    }
  }
}

void main() {
  group('LoopNode — the D3 states (never colour-only)', () {
    testWidgets('sizes: done / open / locked 38, current / finish 58 in a 76 '
        'halo', (tester) async {
      for (final (state, edge) in <(LoopNodeState, double)>[
        (d, 38),
        (o, 38),
        (l, 38),
        (c, 76),
        (f, 76),
      ]) {
        await tester.pumpWidget(host(LoopNode(number: 3, state: state)));
        expect(tester.getSize(find.byType(LoopNode)), Size(edge, edge));
        expect(LoopNode.extentFor(state, 1), edge);
      }
    });

    testWidgets('each state is announced with its state (§18.7 ruling 2)', (
      tester,
    ) async {
      for (final (state, word) in <(LoopNodeState, String)>[
        (d, 'tamamlandı'),
        (c, 'geçerli seviye'),
        (o, 'açık'),
        (l, 'kilitli'),
        (f, 'tamamlandı'),
      ]) {
        await tester.pumpWidget(host(LoopNode(number: 7, state: state)));
        expect(tester.getSemantics(find.byType(LoopNode)).label, '7, $word');
      }
    });

    testWidgets('greyscale-distinct: open = solid edge, locked = dashed edge '
        '(≥ 3 : 1 alphas), finish = lime with a lime halo', (tester) async {
      await tester.pumpWidget(host(const LoopNode(number: 13, state: o)));
      final open = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(LoopNode),
              matching: find.byType(Container),
            )
            .first,
      );
      final openDeco = open.decoration! as BoxDecoration;
      expect(openDeco.gradient, isNull);
      expect((openDeco.border! as Border).top.color.a, closeTo(0.62, 0.01));
      expect(
        tester.widget<Text>(find.text('13')).style!.color,
        LoopColors.text,
      );

      await tester.pumpWidget(host(const LoopNode(number: 4, state: l)));
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byType(LoopNode),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter!
              as DashedRRectPainter;
      expect(painter.color.a, closeTo(0.62, 0.01));
      expect(
        tester.widget<Text>(find.text('4')).style!.color,
        LoopColors.muted,
      );

      await tester.pumpWidget(host(const LoopNode(number: 30, state: f)));
      final boxes = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(LoopNode),
              matching: find.byType(Container),
            ),
          )
          .map((w) => w.decoration as BoxDecoration?)
          .whereType<BoxDecoration>()
          .toList();
      expect(boxes.first.color, const Color(0x1CDDFA6B)); // lime halo
      expect(boxes.last.gradient, LoopGradients.nodeDone);
    });
  });

  group('LoopTrack geometry (§11.1 (2)–(5))', () {
    test('every window: no node overlaps another node or a halo, nothing '
        'leaves the card, the current node is in the window', () {
      var checked = 0;
      for (final view in allViews()) {
        final states = view.windowStates;
        final centres = LoopTrackGeometry.centres(states);
        final rects = <Rect>[
          for (var i = 0; i < states.length; i++)
            Rect.fromCenter(
              center: centres[i],
              width: LoopNode.extentFor(states[i], 1),
              height: LoopNode.extentFor(states[i], 1),
            ),
        ];
        for (final r in rects) {
          expect(r.left, greaterThanOrEqualTo(0));
          expect(r.right, lessThanOrEqualTo(LoopTrackGeometry.cardWidth));
          expect(r.top, greaterThanOrEqualTo(0));
          expect(r.bottom, lessThanOrEqualTo(LoopTrackGeometry.blockHeight));
        }
        for (var i = 1; i < rects.length; i++) {
          // Adjacent boxes (halo included for the large states) never meet.
          expect(
            rects[i].left - rects[i - 1].right,
            greaterThanOrEqualTo(7 - 1e-9),
          );
        }
        if (view.currentLevel != null) {
          expect(states, contains(c));
        }
        checked++;
      }
      expect(checked, greaterThan(400));
    });

    test('the line rises: each centre is at or above the previous one', () {
      for (final states in <List<LoopNodeState>>[
        <LoopNodeState>[c, l, l, l, l],
        <LoopNodeState>[d, d, d, d, c],
        <LoopNodeState>[d, d, c, d, d],
        <LoopNodeState>[d, d, d, d, f],
      ]) {
        final centres = LoopTrackGeometry.centres(states);
        for (var i = 1; i < centres.length; i++) {
          expect(centres[i].dy, lessThanOrEqualTo(centres[i - 1].dy));
        }
      }
    });

    test('lead-in iff the window starts after level 1; tail only when '
        'levels follow and there is room', () {
      const newPlayer = LoopTrack(
        firstLevel: 1,
        states: <LoopNodeState>[c, l, l, l, l],
      );
      expect(newPlayer.hasLeadIn, isFalse);
      // 6–30 follow, but the chain ends 47 pt from the edge (< 48): no tail,
      // as in `D3-01`.
      expect(newPlayer.hasTail, isFalse);

      const frontier12 = LoopTrack(
        firstLevel: 9,
        states: <LoopNodeState>[d, d, d, d, c],
      );
      expect(frontier12.hasLeadIn, isTrue);
      expect(frontier12.hasTail, isFalse); // the current node leaves no room

      const replay = LoopTrack(
        firstLevel: 5,
        states: <LoopNodeState>[d, d, c, d, d],
      );
      expect(replay.hasLeadIn, isTrue);
      expect(replay.hasTail, isFalse); // 40 pt of room (`D3-05`)

      // Only an all-small chain leaves ≥ 48 pt (54): the rule still holds.
      const allSmall = LoopTrack(
        firstLevel: 3,
        states: <LoopNodeState>[d, d, o, l, l],
      );
      expect(allSmall.hasTail, isTrue);

      const terminal = LoopTrack(
        firstLevel: 26,
        states: <LoopNodeState>[d, d, d, d, f],
      );
      expect(terminal.hasLeadIn, isTrue);
      expect(terminal.hasTail, isFalse); // nothing follows 30
    });

    testWidgets('display-only and out of the semantics tree; the nodes sit '
        'on their centres', (tester) async {
      const s = 393 / 358;
      await tester.pumpWidget(
        host(
          const LoopTrack(
            firstLevel: 5,
            states: <LoopNodeState>[d, d, c, d, d],
          ),
          scale: s,
        ),
      );
      expect(find.byType(GestureDetector), findsNothing);
      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel(RegExp('seviye|tamamlandı')), findsNothing);
      semantics.dispose();

      final origin = tester.getTopLeft(find.byType(LoopTrack));
      final centres = LoopTrackGeometry.centres(<LoopNodeState>[d, d, c, d, d]);
      for (var i = 0; i < 5; i++) {
        final node = find.byWidgetPredicate(
          (w) => w is LoopNode && w.number == 5 + i,
        );
        final centre = tester.getCenter(node) - origin;
        expect(centre.dx, closeTo(centres[i].dx * s, 0.01));
        expect(centre.dy, closeTo(centres[i].dy * s, 0.01));
      }
    });
  });
}
