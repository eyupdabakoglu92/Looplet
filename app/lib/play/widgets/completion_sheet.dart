import 'package:flutter/widgets.dart';

import '../play_strings.dart';
import '../play_theme.dart';

/// The **minimal, functional** completion panel (`ui-design.md` §7) — an F04
/// seam. Kicker + the formed word + one `MOVES` stat + a dominant Retry + a
/// quiet Close. No stars / optimal / best / "Next Level" — F04 owns that panel.
/// Crafted (raised dark surface, real type, one dominant CTA), not a placeholder.
class CompletionSheet extends StatelessWidget {
  const CompletionSheet({
    required this.strings,
    required this.word,
    required this.moves,
    required this.onRetry,
    required this.onClose,
    super.key,
  });

  final PlayStrings strings;
  final String word;
  final int moves;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 34),
      decoration: const BoxDecoration(
        color: Color(0xFF191A2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
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
          Text(
            strings.solvedKicker,
            textAlign: TextAlign.center,
            style: PlayTheme.microLabel.copyWith(
              color: PlayTheme.amber.withValues(alpha: 0.7),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            word,
            textAlign: TextAlign.center,
            style: PlayTheme.completionWord,
          ),
          const SizedBox(height: 20),
          Column(
            children: <Widget>[
              Text(strings.movesLabel, style: PlayTheme.microLabel),
              const SizedBox(height: 4),
              Text('$moves', style: PlayTheme.completionStat),
            ],
          ),
          const SizedBox(height: 26),
          _RetryCta(label: strings.retry, onPressed: onRetry),
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Container(
              alignment: Alignment.center,
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

class _RetryCta extends StatelessWidget {
  const _RetryCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
}
