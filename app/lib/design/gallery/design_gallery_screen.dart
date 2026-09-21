import 'package:flutter/widgets.dart';

import '../design.dart';

/// Debug-only component gallery — the runtime source for visual parity with
/// `design/S-91-components.png` (F00 `architecture.md` §7.6). It is reached
/// only through `lib/main_gallery.dart` (`flutter run -t lib/main_gallery.dart`);
/// no shipped route or screen references it.
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({this.initialScrollOffset = 0, super.key});

  /// Where the gallery starts scrolled — used by the runtime parity capture to
  /// take deterministic, repeatable screenshots of each section.
  final double initialScrollOffset;

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: widget.initialScrollOffset,
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return LoopBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(24 * s, 12 * s, 24 * s, 40 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('DESIGN GALLERY · LOOP GLASS', style: LoopText.caption(s)),
              SizedBox(height: 14 * s),
              LoopletWordmark(fontSize: 44 * s),
              _section(s, 'COLOUR ROLES'),
              const _Swatches(),
              _section(s, 'TYPE ROLES — SPACE GROTESK · MANROPE'),
              const _TypeRoles(),
              _section(s, 'TILE STATES'),
              const _TileStates(),
              _section(s, 'CONTROLS'),
              const _Controls(),
              _section(s, 'CARDS, STATS, TRACK'),
              const _Cards(),
              _section(s, 'ICONS AND STARS'),
              const _Icons(),
              _section(s, 'TURKISH GLYPHS, TABULAR FIGURES, WEIGHT AXIS'),
              const _GlyphCheck(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(double s, String title) => Padding(
    padding: EdgeInsets.only(top: 30 * s, bottom: 12 * s),
    child: Text(title, style: LoopText.caption(s)),
  );
}

class _Swatches extends StatelessWidget {
  const _Swatches();

  @override
  Widget build(BuildContext context) {
    const swatches = <(String, Color)>[
      ('Ground', LoopColors.groundTop),
      ('Glass', Color(0xFF2A345A)),
      ('Text', LoopColors.text),
      ('Muted', LoopColors.muted),
      ('Lime', LoopColors.lime),
      ('Periwinkle', LoopColors.periwinkle),
      ('Cream tile', Color(0xFFFCF7F0)),
      ('Locked', LoopColors.lockedTop),
      ('Frozen', LoopColors.frozenBottom),
      ('Slate', Color(0xFF27394B)),
    ];
    final s = LoopScale.of(context);
    return Wrap(
      spacing: 12 * s,
      runSpacing: 12 * s,
      children: <Widget>[
        for (final (name, color) in swatches)
          SizedBox(
            width: 92 * s,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 44 * s,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12 * s),
                    border: Border.all(color: LoopColors.glassEdge),
                  ),
                ),
                SizedBox(height: 5 * s),
                Text(name, style: LoopText.bodyText(s, color: LoopColors.text)),
              ],
            ),
          ),
      ],
    );
  }
}

class _TypeRoles extends StatelessWidget {
  const _TypeRoles();

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Döngü\ntamamlandı.', style: LoopText.display(s)),
        Text('Display 33 / 1.13 · 500', style: LoopText.label(s)),
        SizedBox(height: 14 * s),
        Text.rich(
          TextSpan(
            style: LoopText.headline(s),
            children: <InlineSpan>[
              const TextSpan(text: 'Sıradaki '),
              TextSpan(
                text: 'döngüyü',
                style: LoopText.headline(s).copyWith(color: LoopColors.lime),
              ),
              const TextSpan(text: ' çöz.'),
            ],
          ),
        ),
        Text('Headline 28 / 1.16 · 500', style: LoopText.label(s)),
        SizedBox(height: 14 * s),
        Text('3 · 3 · 3', style: LoopText.stat(s)),
        Text('Stat 24 · tabular', style: LoopText.label(s)),
        SizedBox(height: 14 * s),
        Text('Sonraki bölüm', style: LoopText.cta(s, color: LoopColors.text)),
        Text('CTA 16 · 500', style: LoopText.label(s)),
        SizedBox(height: 14 * s),
        Text('Hedef üç hamlede yerine oturdu.', style: LoopText.bodyText(s)),
        Text('Body 14.5 · 500 muted', style: LoopText.label(s)),
        SizedBox(height: 14 * s),
        Text('SEVİYE 05 · HEDEF DÖNGÜ', style: LoopText.caption(s)),
        Text('Label 11.5 · 600 · +0.2 em caps', style: LoopText.label(s)),
      ],
    );
  }
}

class _TileStates extends StatelessWidget {
  const _TileStates();

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    final size = 60 * s;
    Widget cell(Widget tile, String label) => SizedBox(
      width: 84 * s,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: size + 10,
            child: Center(child: tile),
          ),
          SizedBox(height: 6 * s),
          Text(
            label,
            textAlign: TextAlign.center,
            style: LoopText.label(
              s,
            ).copyWith(fontSize: 11 * s, letterSpacing: 0),
          ),
        ],
      ),
    );
    return Wrap(
      spacing: 6 * s,
      runSpacing: 14 * s,
      children: <Widget>[
        cell(TileFace(letter: 'A', size: size), 'Normal'),
        cell(
          TileFace(letter: 'A', size: size, state: TileState.active),
          'Active row',
        ),
        cell(
          TileFace(letter: 'A', size: size, state: TileState.winning),
          'Winning',
        ),
        cell(
          TileFace(letter: 'A', size: size, state: TileState.locked),
          'Locked',
        ),
        cell(
          TileFace(letter: 'A', size: size, state: TileState.frozen),
          'Frozen',
        ),
        cell(
          TileFace(letter: 'A', size: size, state: TileState.inactive),
          'Inactive',
        ),
        cell(GhostSlot(size: size), 'Ghost slot'),
        cell(const RailTile(letter: 'A'), 'Rail tile'),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LimePill(label: 'Sonraki bölüm', onPressed: () {}, glow: true),
        SizedBox(height: 12 * s),
        LimePill(label: 'Sonraki bölüm (Result, no glow)', onPressed: () {}),
        SizedBox(height: 12 * s),
        OutlinePill(label: 'Secondary (outline)', onPressed: () {}),
        SizedBox(height: 4 * s),
        Wrap(
          spacing: 16 * s,
          children: <Widget>[
            TextLink(label: 'Tekrar oyna', onPressed: () {}),
            const TextLink(
              label: 'Sonraki bölüm',
              onPressed: null,
              disabledSuffix: '· yakında',
            ),
          ],
        ),
        SizedBox(height: 8 * s),
        Wrap(
          spacing: 12 * s,
          runSpacing: 12 * s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            UndoPill(quota: 3, onPressed: () {}, semanticLabel: 'Geri al'),
            GlassIconButton(
              icon: LoopIcon.restart,
              onPressed: () {},
              semanticLabel: 'Baştan',
            ),
            GlassIconButton(
              icon: LoopIcon.back,
              onPressed: () {},
              semanticLabel: 'Ana ekrana dön',
            ),
            const LoopBadge(label: 'HARİKA'),
          ],
        ),
        SizedBox(height: 12 * s),
        const Row(
          children: <Widget>[
            MovesCard(moves: 3),
            SizedBox(width: 16),
            StarRow(earned: 2, size: 24),
          ],
        ),
      ],
    );
  }
}

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const StatCard(
          cells: <StatCell>[
            StatCell(value: '3', label: 'SEN'),
            StatCell(value: '3', label: 'OPTİMAL'),
            StatCell(value: '3', label: 'EN İYİ', star: true),
          ],
        ),
        SizedBox(height: 16 * s),
        GlassCard(
          width: double.infinity,
          padding: EdgeInsets.all(18 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('YOLCULUK · 4 / 30', style: LoopText.caption(s)),
              SizedBox(height: 10 * s),
              Text.rich(
                TextSpan(
                  style: LoopText.headline(s),
                  children: <InlineSpan>[
                    const TextSpan(text: 'Sıradaki '),
                    TextSpan(
                      text: 'döngüyü',
                      style: LoopText.headline(
                        s,
                      ).copyWith(color: LoopColors.lime),
                    ),
                    const TextSpan(text: ' çöz.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18 * s),
        SizedBox(
          height: 90 * s,
          child: Stack(
            children: <Widget>[
              for (var i = 0; i < 4; i++)
                Positioned(
                  left: i * 46.0 * s,
                  top: (26 - i * 3) * s,
                  child: LoopNode(number: i + 1),
                ),
              Positioned(
                left: 4 * 46.0 * s - 6 * s,
                top: 0,
                child: const LoopNode(number: 5, current: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Icons extends StatelessWidget {
  const _Icons();

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    return Wrap(
      spacing: 16 * s,
      runSpacing: 14 * s,
      children: <Widget>[
        for (final icon in LoopIcon.values)
          LoopIconView(
            icon,
            color: LoopColors.text,
            size: 28 * s,
            filled: icon == LoopIcon.star,
          ),
        LoopIconView(
          LoopIcon.star,
          color: LoopColors.limeMid,
          size: 28 * s,
          filled: true,
        ),
        LoopIconView(
          LoopIcon.star,
          color: const Color(0x8CF4F6FF),
          size: 28 * s,
        ),
      ],
    );
  }
}

class _GlyphCheck extends StatelessWidget {
  const _GlyphCheck();

  @override
  Widget build(BuildContext context) {
    final s = LoopScale.of(context);
    TextStyle sg(double w) => LoopText.stat(s).copyWith(
      fontSize: 21 * s,
      fontVariations: <FontVariation>[FontVariation('wght', w)],
      fontWeight: FontWeight.w400,
    );
    TextStyle mr(double w) =>
        LoopText.bodyText(s, color: LoopColors.text).copyWith(
          fontSize: 17 * s,
          fontVariations: <FontVariation>[FontVariation('wght', w)],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 6 * s,
          runSpacing: 6 * s,
          children: <Widget>[
            for (final ch in 'İIŞĞÇÖÜ'.split(''))
              TileFace(letter: ch, size: 44 * s),
          ],
        ),
        SizedBox(height: 10 * s),
        Text(
          'ı ş ğ ç ö ü · HARİKA · YENİ EN İYİ · OPTİMAL · SEVİYE',
          style: LoopText.bodyText(s, color: LoopColors.text),
        ),
        SizedBox(height: 4 * s),
        Text(
          'turkishUpper: ${turkishUpper("harika · yeni en iyi · optimal · seviye · ılık")}',
          style: LoopText.bodyText(s),
        ),
        SizedBox(height: 12 * s),
        Text(
          '0 1 1 1 1\n8 8 8 8 8',
          style: LoopText.stat(s).copyWith(fontSize: 30 * s),
        ),
        SizedBox(height: 12 * s),
        Text('Space Grotesk 400  İıŞĞ 0123', style: sg(400)),
        Text('Space Grotesk 500  İıŞĞ 0123', style: sg(500)),
        Text('Space Grotesk 600  İıŞĞ 0123', style: sg(600)),
        Text('Space Grotesk 700  İıŞĞ 0123', style: sg(700)),
        SizedBox(height: 6 * s),
        Text('Manrope 400  İıŞĞÇÖÜ 0123', style: mr(400)),
        Text('Manrope 500  İıŞĞÇÖÜ 0123', style: mr(500)),
        Text('Manrope 600  İıŞĞÇÖÜ 0123', style: mr(600)),
        Text('Manrope 700  İıŞĞÇÖÜ 0123', style: mr(700)),
      ],
    );
  }
}
