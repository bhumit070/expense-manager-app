import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../theme/tokens.dart';
import 'highlight.dart';
import '../theme/icons.dart';

TextStyle ts(double size, {FontWeight weight = FontWeight.w500, Color? color, double? height, double? spacing}) =>
    TextStyle(fontFamily: fontFamily, fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.onTap, this.border});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: color ?? c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: border == null ? BorderSide.none : BorderSide(color: border!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: ts(17, weight: FontWeight.w700)),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: ts(13, weight: FontWeight.w600, color: context.colors.brand),
              ),
            ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, required this.color, required this.background, this.size = 40});

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size / 2.8)),
    alignment: Alignment.center,
    child: Icon(icon, size: size / 2, color: color),
  );
}

/// Badge for a category using its stored color.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge(this.category, {super.key, this.size = 40});

  final Category category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return IconBadge(iconFor(category.icon), color: color, background: color.withValues(alpha: 0.14), size: size);
  }
}

class TypeTag extends StatelessWidget {
  const TypeTag(this.type, {super.key});

  final TxnType type;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: c.typeSoft(type), borderRadius: BorderRadius.circular(8)),
      child: Text(
        typeLabel(type).toUpperCase(),
        style: ts(9, weight: FontWeight.w800, color: c.typeColor(type), spacing: 0.4),
      ),
    );
  }
}

/// Horizontal bar made of colored segments over a track.
class SegmentBar extends StatelessWidget {
  const SegmentBar({super.key, required this.segments, this.height = 8, this.track});

  /// (fraction 0..1, color) pairs.
  final List<(double, Color)> segments;
  final double height;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: CustomPaint(painter: _SegmentPainter(segments, track ?? context.colors.line), size: Size.infinite),
      ),
    );
  }
}

class _SegmentPainter extends CustomPainter {
  _SegmentPainter(this.segments, this.track);

  final List<(double, Color)> segments;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = track);
    var x = 0.0;
    for (final (f, color) in segments) {
      final w = size.width * f.clamp(0.0, 1.0);
      if (w <= 0) continue;
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, (x + w).clamp(0, size.width) - x, size.height), Radius.circular(size.height / 2));
      canvas.drawRRect(r, Paint()..color = color);
      x += w;
    }
  }

  @override
  bool shouldRepaint(_SegmentPainter old) => old.segments != segments || old.track != track;
}

/// iOS-style segmented control.
class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.values, required this.selected, required this.label, required this.onChanged, this.activeColor});

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.track, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: v == selected ? (activeColor ?? c.surface) : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                  child: Text(
                    label(v),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(13, weight: v == selected ? FontWeight.w700 : FontWeight.w500, color: v == selected ? (activeColor != null ? Colors.white : c.text) : c.textMuted),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.selected = false, this.onTap, this.dot, this.icon});

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? c.brandSoft : c.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? c.brand : c.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[Icon(AppIcons.check, size: 14, color: c.brand), const SizedBox(width: 4)],
              if (icon != null) ...[Icon(icon, size: 14, color: selected ? c.brand : c.textMuted), const SizedBox(width: 6)],
              if (dot != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: ts(12, weight: FontWeight.w600, color: selected ? c.brand : c.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action, this.onAction});

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          IconBadge(icon, color: c.brand, background: c.brandSoft, size: 56),
          const SizedBox(height: 12),
          Text(
            title,
            style: ts(16, weight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: ts(13, color: c.textMuted),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 12), TextButton(onPressed: onAction, child: Text(action!))],
        ],
      ),
    );
  }
}

/// A transaction row used in lists.
class TxnTile extends StatelessWidget {
  const TxnTile(this.view, {super.key, this.onTap, this.now, this.highlight, this.snippet, this.highlightAmount = false});

  final TxnView view;
  final VoidCallback? onTap;
  final DateTime? now;

  /// Search query whose words are emphasised in the title and [snippet].
  final String? highlight;

  /// Extra matched line (note, tags or place) shown under the title.
  final String? snippet;

  /// Emphasises the amount (it matched the search).
  final bool highlightAmount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = view.txn;
    final sub = [view.category.name, if (view.source != null) view.source!.name, if (now != null) relativeDay(t.occurredAt, now!)].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CategoryBadge(view.category, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (highlight == null)
                    Text(
                      t.titleOr(view.category.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(14, weight: FontWeight.w600),
                    )
                  else
                    HighlightedText(
                      t.titleOr(view.category.name),
                      query: highlight!,
                      style: ts(14, weight: FontWeight.w600, color: c.text),
                      highlight: c.brandSoft,
                    ),
                  if (snippet != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: HighlightedText(
                        snippet!,
                        query: highlight ?? '',
                        style: ts(12, color: c.textMuted),
                        highlight: c.brandSoft,
                        maxLines: 2,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      TypeTag(t.type),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(12, color: c.textMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: highlightAmount ? const EdgeInsets.symmetric(horizontal: 4) : EdgeInsets.zero,
              color: highlightAmount ? c.brandSoft : null,
              child: Text(
                formatInr(view.signedAmount, signed: true),
                style: ts(14, weight: FontWeight.w700, color: view.inflow ? c.positive : c.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stat card: icon, label, value, caption.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.label, required this.value, required this.caption, required this.color, required this.soft, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final Color color;
  final Color soft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon, color: color, background: soft, size: 32),
          const SizedBox(height: 10),
          Text(label, style: ts(11, color: c.textMuted)),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(value, style: ts(16, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ts(11, weight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// Labeled field row inside a details card.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: ts(13, color: context.colors.textMuted)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: ts(13, weight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

void showSnack(BuildContext context, String message, {String? action, VoidCallback? onAction}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: action == null ? null : SnackBarAction(label: action, onPressed: onAction!),
      ),
    );
}
