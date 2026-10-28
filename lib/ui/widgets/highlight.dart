import 'package:flutter/material.dart';

import '../../data/transactions_repo.dart';

/// [text] with every occurrence of the search words emphasised.
class HighlightedText extends StatelessWidget {
  const HighlightedText(this.text, {super.key, required this.query, required this.style, required this.highlight, this.maxLines = 1});

  final String text;
  final String query;
  final TextStyle style;
  final Color highlight;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final (start, end) in matchRanges(text, query)) {
      if (start > last) spans.add(TextSpan(text: text.substring(last, start)));
      spans.add(
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(backgroundColor: highlight, fontWeight: FontWeight.w800),
        ),
      );
      last = end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Sorted, non-overlapping [start, end) ranges where any search word occurs.
List<(int, int)> matchRanges(String text, String query) {
  final lower = text.toLowerCase();
  final hits = <(int, int)>[];
  for (final w in searchWords(query)) {
    for (var i = lower.indexOf(w); i >= 0; i = lower.indexOf(w, i + w.length)) {
      hits.add((i, i + w.length));
    }
  }
  hits.sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <(int, int)>[];
  for (final h in hits) {
    if (merged.isNotEmpty && h.$1 <= merged.last.$2) {
      final prev = merged.removeLast();
      merged.add((prev.$1, h.$2 > prev.$2 ? h.$2 : prev.$2));
    } else {
      merged.add(h);
    }
  }
  return merged;
}
