import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import 'common.dart';
import '../theme/tokens.dart';

/// Ring chart with a centered label.
class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.segments, required this.center, this.size = 150, this.stroke = 20, this.semanticLabel});

  final List<(double, Color)> segments;

  /// What the ring shows, read by screen readers (e.g. "Spent ₹1,200, invested ₹500").
  final String? semanticLabel;
  final Widget center;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(segments, stroke, context.colors.line),
        child: Center(child: center),
      ),
    ),
  );
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments, this.stroke, this.track);

  final List<(double, Color)> segments;
  final double stroke;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    final total = segments.fold<double>(0, (a, s) => a + s.$1);
    if (total <= 0) return;
    var start = -math.pi / 2;
    const gap = 0.06;
    for (final (v, color) in segments) {
      final sweep = v / total * math.pi * 2;
      if (sweep <= 0) continue;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      final s = segments.where((e) => e.$1 > 0).length > 1 ? math.max(sweep - gap, 0.001) : sweep;
      canvas.drawArc(rect, start + (sweep - s) / 2, s, false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.segments != segments || old.track != track;
}

/// Stacked spend/invest bars with labels, one per bucket.
class BucketBars extends StatelessWidget {
  const BucketBars({super.key, required this.buckets, required this.labels, this.highlight, this.height = 130});

  final List<Bucket> buckets;
  final List<String> labels;
  final int? highlight;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final max = buckets.fold<int>(0, (m, b) => math.max(m, b.spend + b.invest));
    return SizedBox(
      height: height + 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < buckets.length; i++)
            Expanded(
              child: Semantics(
                // One readable summary per bar instead of unlabeled shapes.
                label: context.l10n.chartBarLabel(labels[i], formatInr(buckets[i].spend), formatInr(buckets[i].invest)),
                excludeSemantics: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _Stack(spend: buckets[i].spend, invest: buckets[i].invest, max: max, height: height, spendColor: c.spend, investColor: c.invest, dim: highlight != null && i > highlight!),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      maxLines: 1,
                      style: ts(10, weight: i == highlight ? FontWeight.w700 : FontWeight.w500, color: i == highlight ? c.text : c.textMuted),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.spend, required this.invest, required this.max, required this.height, required this.spendColor, required this.investColor, required this.dim});

  final int spend, invest, max;
  final double height;
  final Color spendColor, investColor;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    double h(int v) => max == 0 ? 0 : height * v / max;
    return Opacity(
      opacity: dim ? 0.35 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (invest > 0)
            Container(
              height: h(invest),
              decoration: BoxDecoration(color: investColor, borderRadius: BorderRadius.circular(6)),
            ),
          if (invest > 0 && spend > 0) const SizedBox(height: 2),
          if (spend > 0)
            Container(
              height: h(spend),
              decoration: BoxDecoration(color: spendColor, borderRadius: BorderRadius.circular(6)),
            ),
          if (spend == 0 && invest == 0)
            Container(
              height: 3,
              decoration: BoxDecoration(color: context.colors.line, borderRadius: BorderRadius.circular(2)),
            ),
        ],
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  const LegendDot(this.label, this.color, {super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ts(11, color: context.colors.textMuted),
        ),
      ),
    ],
  );
}
