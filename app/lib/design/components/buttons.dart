import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../../reduce_motion.dart';
import '../icons.dart';
import '../tokens.dart';
import '../typography.dart';

/// Pressable wrapper shared by every button: a 98 % press scale (skipped under
/// OS reduced motion) instead of Material ink ripples; correct button
/// semantics as a *single* announced node (`enabled`, label — the visible
/// icon/text underneath carries its own implicit semantics otherwise, which
/// duplicated the announcement, F00-FE-A11Y-REWORK QA-02); and a 2 px
/// periwinkle focus ring for keyboard / Switch Control focus (ui-design §8,
/// QA-03) that also activates on Enter/Space while focused.
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.focusRadius = LoopRadii.pillFull,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  /// Corner radius of the focus ring, matched to the wrapped control's own
  /// shape (pill, round button, small text link, …).
  final double focusRadius;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final scale = (_down && !reduceMotionRequested()) ? 0.98 : 1.0;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: _enabled,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onPressed?.call(),
          ),
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _down = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _down = false) : null,
          onTapCancel: _enabled ? () => setState(() => _down = false) : null,
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 90),
            child: Container(
              // `foregroundDecoration` paints on top of the child at its own
              // size — it never changes layout, so the ring adds no size
              // shift between focused and unfocused (unlike padding/border on
              // a normal `decoration`).
              foregroundDecoration: _focused
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.focusRadius),
                      border: Border.all(
                        color: LoopColors.periwinkle,
                        width: 2,
                      ),
                    )
                  : null,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The primary action: a lime pill with a trailing icon. `glow: true` is the
/// Home variant (lime glow); the Result uses the neutral-shadow variant — the
/// one-glow rule (ui-design §10 Surface / Depth).
class LimePill extends StatelessWidget {
  const LimePill({
    required this.label,
    required this.onPressed,
    this.glow = false,
    this.icon = LoopIcon.arrowRight,
    this.height,
    this.width,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool glow;
  final LoopIcon? icon;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final h = (height ?? LoopSpacing.ctaHeight * s).clamp(44.0, 200.0);
    final pill = Container(
      width: width,
      // A minimum, not a fixed height: at large OS text sizes the label can
      // wrap to two lines, and the pill grows to fit instead of clipping it
      // (F00-FE-A11Y-REWORK QA-01). At the default 1-line size this renders
      // identically to the old fixed height — the content never needs more
      // than `h`, so the minimum is what wins.
      constraints: BoxConstraints(minHeight: h),
      padding: EdgeInsets.symmetric(horizontal: 23 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        gradient: LoopGradients.cta,
        borderRadius: BorderRadius.circular(LoopRadii.pillFull),
        boxShadow: <BoxShadow>[
          if (glow)
            BoxShadow(
              color: LoopColors.limeMid.withValues(alpha: 0.26),
              blurRadius: 50 * s,
              offset: Offset(0, 18 * s),
            )
          else
            BoxShadow(
              color: const Color(0x80020410),
              blurRadius: 32 * s,
              offset: Offset(0, 14 * s),
            ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: LoopText.cta(s),
              textAlign: TextAlign.start,
            ),
          ),
          if (icon != null)
            LoopIconView(icon!, color: LoopColors.limeInk, size: 20 * s),
        ],
      ),
    );
    return _Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      child: Opacity(opacity: onPressed == null ? 0.45 : 1, child: pill),
    );
  }
}

/// Secondary action: an outline pill.
class OutlinePill extends StatelessWidget {
  const OutlinePill({
    required this.label,
    required this.onPressed,
    this.height,
    this.width,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final h = (height ?? 48 * s).clamp(44.0, 200.0);
    return _Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      child: Opacity(
        opacity: onPressed == null ? 0.45 : 1,
        child: Container(
          width: width,
          // A minimum, not a fixed height — see LimePill (QA-01); this also
          // adds the horizontal breathing room the label never had, so a long
          // label no longer reaches the border (QA-04).
          constraints: BoxConstraints(minHeight: h),
          padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LoopRadii.pillFull),
            border: Border.all(color: LoopColors.outlineEdge),
          ),
          child: Text(
            label,
            style: LoopText.link(s, color: LoopColors.text),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Tertiary action: a muted text link. Disabled = 45 % opacity with an optional
/// suffix (e.g. `· yakında`, "coming soon").
class TextLink extends StatelessWidget {
  const TextLink({
    required this.label,
    required this.onPressed,
    this.disabledSuffix,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? disabledSuffix;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final disabled = onPressed == null;
    final text = disabled && disabledSuffix != null
        ? '$label $disabledSuffix'
        : label;
    return _Pressable(
      onPressed: onPressed,
      semanticLabel: text,
      focusRadius: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Opacity(
            opacity: disabled ? 0.45 : 1,
            child: Text(text, style: LoopText.link(s)),
          ),
        ),
      ),
    );
  }
}

/// A glass square / round button holding one icon (back, restart, settings).
/// The hit target is never below 44 pt (ui-design §13).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 44,
    this.radius = LoopRadii.roundButton,
    super.key,
  });

  final LoopIcon icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final edge = size < 44 ? 44.0 : size;
    return _Pressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      focusRadius: radius * s,
      child: Opacity(
        opacity: onPressed == null ? 0.55 : 1,
        child: Container(
          width: edge,
          height: edge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LoopColors.glassFill,
            borderRadius: BorderRadius.circular(radius * s),
            border: Border.all(color: LoopColors.glassFillEdge),
          ),
          child: LoopIconView(icon, color: LoopColors.text, size: 20 * s),
        ),
      ),
    );
  }
}

/// Undo pill: the undo icon plus the remaining quota as lime dots (max 3).
class UndoPill extends StatelessWidget {
  const UndoPill({
    required this.quota,
    required this.onPressed,
    required this.semanticLabel,
    this.total = 3,
    super.key,
  });

  final int quota;
  final int total;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return _Pressable(
      onPressed: onPressed,
      // The remaining quota is drawn only as dots (colour, not shape or
      // text); a caller-supplied label alone (e.g. "Geri al") wouldn't say
      // how many are left, so it's appended here (F00-FE-A11Y-REWORK QA-02),
      // matching the "$earned / $total …" pattern of `StarRow`.
      semanticLabel: '$semanticLabel, $quota / $total hak',
      focusRadius: 22 * s,
      child: Opacity(
        opacity: onPressed == null ? 0.55 : 1,
        child: Container(
          width: 98.5 * s,
          height: 50 * s,
          decoration: BoxDecoration(
            color: LoopColors.glassFill,
            borderRadius: BorderRadius.circular(22 * s),
            border: Border.all(color: LoopColors.glassFillEdge),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LoopIconView(LoopIcon.undo, color: LoopColors.text, size: 21 * s),
              SizedBox(width: 10 * s),
              for (var i = 0; i < total; i++) ...<Widget>[
                if (i > 0) SizedBox(width: 5 * s),
                Container(
                  width: 5.5 * s,
                  height: 5.5 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < quota
                        ? LoopColors.limeMid
                        : LoopColors.limeMid.withValues(alpha: 0.25),
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
