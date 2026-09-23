import 'package:flutter/widgets.dart';

import 'tokens.dart';
import 'typography.dart';

/// The `Looplet` wordmark (design-foundation §18 decision 5): capital `L` only,
/// the last three letters `let` in lime. Text-set in Space Grotesk 500; the
/// final drawn logo asset is a later phase. Capped with [loopCappedTextScaler]
/// (F00-FE-A11Y-REWORK QA-01) — without it, "Looplet" is long enough that at
/// the largest OS accessibility sizes it wraps mid-word ("Loo" / "plet")
/// wherever the wordmark sits in a width-constrained header.
class LoopletWordmark extends StatelessWidget {
  const LoopletWordmark({this.fontSize = 25, super.key});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final base = LoopText.wordmark(fontSize);
    return Semantics(
      label: 'Looplet',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'Loop', style: base),
            TextSpan(
              text: 'let',
              style: base.copyWith(color: LoopColors.lime),
            ),
          ],
        ),
        textScaler: loopCappedTextScaler(context),
      ),
    );
  }
}
