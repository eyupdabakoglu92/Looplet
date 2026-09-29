// F05-FE-D3 — the Home view-model rules (F05 architecture §18.3 (2), §18.7 C1;
// `ui-design.md` §6 window rule, `design/src/window-d3.txt` expected values).

import 'package:flutter_test/flutter_test.dart';
import 'package:looplet_app/design/components/info.dart' show LoopNodeState;
import 'package:looplet_app/journey/journey_home_view.dart';
import 'package:looplet_app/journey/journey_progress.dart';
import 'package:looplet_app/journey/journey_strings.dart';

const LoopNodeState d = LoopNodeState.done;
const LoopNodeState c = LoopNodeState.current;
const LoopNodeState o = LoopNodeState.open;
const LoopNodeState l = LoopNodeState.locked;
const LoopNodeState f = LoopNodeState.finish;

/// Levels 1…[upTo] completed (strict unlock: the next one is unlocked), plus
/// optional [extra] completed levels, and an optional session.
JourneyProgressModel m(int upTo, {int? session, Set<int> extra = const {}}) {
  final completed = <int>{for (var n = 1; n <= upTo; n++) n, ...extra};
  final highest = completed.isEmpty
      ? 1
      : (completed.reduce((a, b) => a > b ? a : b) + 1).clamp(1, 30);
  return JourneyProgressModel(
    highestUnlockedLevel: highest,
    completedLevels: completed,
    inProgressLevel: session,
  );
}

void main() {
  const tr = JourneyStrings.of;

  group('window-d3.txt — every rendered state', () {
    final rows = <String, (JourneyProgressModel, int, List<LoopNodeState>)>{
      'new': (m(0), 1, <LoopNodeState>[c, l, l, l, l]),
      'new_ip': (m(0, session: 1), 1, <LoopNodeState>[c, l, l, l, l]),
      'mid': (m(4), 1, <LoopNodeState>[d, d, d, d, c]),
      'ip': (m(4, session: 5), 1, <LoopNodeState>[d, d, d, d, c]),
      'w12': (m(12, session: 13), 9, <LoopNodeState>[d, d, d, d, c]),
      'w25': (m(25), 22, <LoopNodeState>[d, d, d, d, c]),
      'replay': (m(12, session: 7), 5, <LoopNodeState>[d, d, c, d, d]),
      'term': (m(30), 26, <LoopNodeState>[d, d, d, d, f]),
      'termReplay': (m(30, session: 12), 10, <LoopNodeState>[d, d, c, d, d]),
    };
    for (final row in rows.entries) {
      test(row.key, () {
        final v = JourneyHomeView.of(row.value.$1);
        expect(v.windowStart, row.value.$2);
        expect(v.windowStates, row.value.$3);
      });
    }
  });

  group('window rule — edge cases (§18.7 C1 list)', () {
    test('frontier at 1–5: the window stays 1–5', () {
      for (var n = 1; n <= 5; n++) {
        final v = JourneyHomeView.of(m(n - 1));
        expect(v.windowStart, 1, reason: 'frontier $n');
        expect(v.windowStates[n - 1], c);
      }
    });

    test('frontier at 26–30: the window is current − 4, capped at 26', () {
      for (var n = 26; n <= 30; n++) {
        final v = JourneyHomeView.of(m(n - 1));
        expect(v.windowStart, n - 4 > 26 ? 26 : n - 4, reason: 'frontier $n');
        expect(v.windowStates[n - v.windowStart], c);
      }
    });

    test('replay at 1 and 2 (12 done): the window starts at 1', () {
      final one = JourneyHomeView.of(m(12, session: 1));
      expect(one.windowStart, 1);
      expect(one.windowStates, <LoopNodeState>[c, d, d, d, d]);
      final two = JourneyHomeView.of(m(12, session: 2));
      expect(two.windowStart, 1);
      expect(two.windowStates, <LoopNodeState>[d, c, d, d, d]);
    });

    test('replay of the highest completed level (12 of 12): the frontier '
        'window 8–12 under the replay headline', () {
      final v = JourneyHomeView.of(m(12, session: 12));
      expect(v.windowStart, 8);
      expect(v.windowStates, <LoopNodeState>[d, d, d, d, c]);
      expect(v.headline, JourneyHeadline.replay);
    });

    test('a replay window reaching the frontier shows it as open', () {
      final v = JourneyHomeView.of(m(12, session: 11));
      expect(v.windowStart, 9);
      expect(v.windowStates, <LoopNodeState>[d, d, c, d, o]);
    });

    test('replay at 29 and 30 after 30 / 30: window 26–30, no finish node', () {
      final at29 = JourneyHomeView.of(m(30, session: 29));
      expect(at29.windowStart, 26);
      expect(at29.windowStates, <LoopNodeState>[d, d, d, c, d]);
      final at30 = JourneyHomeView.of(m(30, session: 30));
      expect(at30.windowStart, 26);
      expect(at30.windowStates, <LoopNodeState>[d, d, d, d, c]);
    });

    test('the current node is always inside the window (every state)', () {
      for (var done = 0; done <= 30; done++) {
        for (final session in <int?>[null, for (var n = 1; n <= 30; n++) n]) {
          if (session != null && session > done + 1) continue;
          final v = JourneyHomeView.of(m(done, session: session));
          expect(v.windowStart, inInclusiveRange(1, 26));
          if (v.currentLevel != null) {
            expect(
              v.currentLevel! - v.windowStart,
              inInclusiveRange(0, 4),
              reason: 'done $done, session $session',
            );
          }
        }
      }
    });
  });

  group('C1 copy rule and the §18.3 (2) CTA', () {
    String head(JourneyProgressModel model) =>
        JourneyHomeView.of(model).headlineText(tr('tr')).plain;

    test('headline per situation', () {
      expect(head(m(0)), 'İlk\ndöngüyü çöz.');
      expect(head(m(0, session: 1)), 'Sıradaki\ndöngüyü çöz.');
      expect(head(m(4)), 'Sıradaki\ndöngüyü çöz.');
      expect(head(m(4, session: 5)), 'Sıradaki\ndöngüyü çöz.');
      expect(head(m(12, session: 7)), 'Yarım kalan\ndöngüne dön.');
      expect(head(m(30)), 'Tüm döngüler\ntamam.');
      expect(head(m(30, session: 12)), 'Tüm döngüler\ntamam.');
    });

    test('CTA, caption and semantics — terminal ⇔ continueTarget == null', () {
      final strings = tr('tr');
      final n1 = JourneyHomeView.of(m(30, session: 12));
      expect(n1.terminal, isFalse);
      expect(n1.ctaTarget, 12);
      expect(n1.ctaLabel(strings), 'Devam et');
      expect(n1.caption(strings), 'Seviye 12 · sürüyor');
      expect(n1.ctaSemantics(strings), 'Devam et, Seviye 12, sürüyor');
      expect(
        n1.progressSemantics(strings),
        '30 / 30 seviye tamamlandı — Seviye 12',
      );

      final done = JourneyHomeView.of(m(30));
      expect(done.terminal, isTrue);
      expect(done.ctaTarget, 1);
      expect(done.ctaLabel(strings), 'Tekrar oyna');
      expect(done.caption(strings), 'Seviye 1');
      expect(done.ctaSemantics(strings), 'Tekrar oyna, Seviye 1');
      expect(done.progressSemantics(strings), '30 / 30 seviye tamamlandı');

      final mid = JourneyHomeView.of(m(4));
      expect(mid.ctaLabel(strings), 'Devam et');
      expect(mid.caption(strings), 'Seviye 5');
      expect(mid.ctaSemantics(strings), 'Devam et, Seviye 5');
    });
  });
}
