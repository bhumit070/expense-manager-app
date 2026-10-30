import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../theme/tokens.dart';
import 'common.dart';

/// "Parent › Child" for sub-categories, the plain name otherwise.
String categoryLabel(Category c, Iterable<Category> all) {
  if (!c.isChild) return c.name;
  final parent = all.where((p) => p.id == c.parentId).firstOrNull;
  return parent == null ? c.name : '${parent.name} › ${c.name}';
}

/// Category grid for the transaction form: top-level categories as tiles and,
/// when the picked one has sub-categories, a row of chips to narrow it down.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({super.key, required this.categories, required this.selectedId, required this.onChanged});

  /// Categories of one kind in tree order.
  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = categories.where((x) => x.id == selectedId).firstOrNull;
    final activeParent = selected == null ? null : (selected.isChild ? selected.parentId : selected.id);
    final parents = categories.where((x) => !x.isChild || !categories.any((p) => p.id == x.parentId)).toList();
    final subs = activeParent == null ? const <Category>[] : categories.where((x) => x.parentId == activeParent).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            for (final cat in parents)
              GestureDetector(
                key: Key('cat-${cat.id}'),
                onTap: () => onChanged(cat.id),
                child: Container(
                  width: 78,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: activeParent == cat.id ? c.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: activeParent == cat.id ? Color(cat.color) : Colors.transparent, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      CategoryBadge(cat, size: 44),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ts(11, weight: FontWeight.w600, color: activeParent == cat.id ? c.text : c.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (subs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              key: const Key('sub-categories'),
              spacing: 8,
              runSpacing: 8,
              children: [
                Pill(context.l10n.allOf(categories.firstWhere((x) => x.id == activeParent).name), selected: selectedId == activeParent, onTap: () => onChanged(activeParent!)),
                for (final s in subs) Pill(s.name, key: Key('sub-${s.id}'), dot: Color(s.color), selected: selectedId == s.id, onTap: () => onChanged(s.id)),
              ],
            ),
          ),
      ],
    );
  }
}
