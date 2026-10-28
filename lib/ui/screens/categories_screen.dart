import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../theme/icons.dart';

const _palette = [0xFFF43F5E, 0xFF8B5CF6, 0xFFEC4899, 0xFFF59E0B, 0xFF10B981, 0xFF0EA5E9, 0xFF6366F1, 0xFF64748B];

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _add(BuildContext context, AppState app, {Category? parent}) async {
    final r = await showDialog<NewCategory>(
      context: context,
      builder: (_) => CategoryDialog(parent: parent),
    );
    if (r != null) {
      app.catalog.addCategory(name: r.name, kind: r.kind, icon: r.icon, color: r.color, parentId: parent?.id);
      app.changed();
    }
  }

  /// Asks where to move [cat]: under another top-level category of the same
  /// kind, or (for a sub-category) back to the top level.
  Future<void> _move(BuildContext context, AppState app, Category cat) async {
    final targets = app.catalog.parents(cat.kind).where((p) => p.id != cat.id && p.id != cat.parentId).toList();
    final picked = await showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Move ${cat.name}'),
        children: [
          if (cat.isChild) SimpleDialogOption(key: const Key('move-top'), onPressed: () => Navigator.pop(context, 0), child: const Text('Top level')),
          for (final p in targets) SimpleDialogOption(key: Key('move-to-${p.id}'), onPressed: () => Navigator.pop(context, p.id), child: Text('Under ${p.name}')),
        ],
      ),
    );
    if (picked == null || !context.mounted) return;
    if (app.catalog.setParent(cat.id, picked == 0 ? null : picked)) {
      app.changed();
    } else {
      showSnack(context, 'Only categories without sub-categories can be moved under another');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;

    Widget tile(Category cat, int index, {required bool canMove}) {
      return ListTile(
        key: cat.isChild ? ValueKey(cat.id) : Key('cat-tile-${cat.id}'),
        contentPadding: EdgeInsets.only(left: cat.isChild ? 40 : 16, right: 8),
        leading: CategoryBadge(cat, size: cat.isChild ? 32 : 38),
        title: Text(cat.name, style: ts(cat.isChild ? 13 : 14, weight: FontWeight.w600)),
        subtitle: cat.isDefault ? Text('Default — used when nothing is picked', style: ts(11, color: c.textMuted)) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              key: Key('cat-menu-${cat.id}'),
              icon: const Icon(AppIcons.more),
              onSelected: (v) => v == 'sub' ? _add(context, app, parent: cat) : _move(context, app, cat),
              itemBuilder: (_) => [
                if (!cat.isChild) const PopupMenuItem(value: 'sub', child: Text('Add sub-category')),
                if (canMove) PopupMenuItem(value: 'move', child: Text(cat.isChild ? 'Move…' : 'Move under…')),
              ],
            ),
            if (!cat.isDefault)
              IconButton(
                key: Key('archive-${cat.id}'),
                tooltip: 'Archive ${cat.name}',
                icon: const Icon(AppIcons.archive),
                onPressed: () {
                  app.catalog.archiveCategory(cat.id);
                  app.changed();
                },
              ),
            ReorderableDragStartListener(index: index, child: const Icon(AppIcons.dragHandle)),
          ],
        ),
      );
    }

    /// Reorderable list of siblings; [onReorder] persists the new order.
    Widget siblings(String key, List<Category> list, {required List<Category> all}) {
      return ReorderableListView(
        key: Key(key),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        onReorderItem: (from, to) {
          final ids = list.map((e) => e.id).toList();
          ids.insert(to, ids.removeAt(from));
          app.catalog.reorderCategories(ids);
          app.changed();
        },
        children: [
          for (var i = 0; i < list.length; i++)
            if (list[i].isChild)
              tile(list[i], i, canMove: true)
            else
              Column(
                key: ValueKey(list[i].id),
                children: [
                  tile(list[i], i, canMove: !list[i].isDefault && !all.any((x) => x.parentId == list[i].id) && all.where((x) => !x.isChild).length > 1),
                  if (all.any((x) => x.parentId == list[i].id)) siblings('reorder-sub-${list[i].id}', all.where((x) => x.parentId == list[i].id).toList(), all: all),
                ],
              ),
        ],
      );
    }

    Widget section(CategoryKind kind, String title, String explainer) {
      final all = app.catalog.categories(kind: kind);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 2),
            child: Text(
              title.toUpperCase(),
              style: ts(13, weight: FontWeight.w700, color: c.textMuted, spacing: 0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(explainer, style: ts(12, color: c.textFaint)),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: siblings('reorder-${kind.name}', all.where((x) => !x.isChild).toList(), all: all),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: ts(16, weight: FontWeight.w700)),
        actions: [IconButton(key: const Key('add-category'), tooltip: 'Add category', icon: const Icon(AppIcons.add), onPressed: () => _add(context, app))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          section(CategoryKind.spend, 'Spend', 'Money that’s gone — food, rent, bills. Tap ⋮ to add sub-categories.'),
          section(CategoryKind.invest, 'Investment', 'Money out that still grows your net worth.'),
          section(CategoryKind.income, 'Income', 'Money coming in.'),
        ],
      ),
    );
  }
}

typedef NewCategory = ({String name, CategoryKind kind, String icon, int color});

/// Dialog that owns its own text controller (disposed with the dialog).
class CategoryDialog extends StatefulWidget {
  const CategoryDialog({super.key, this.parent});

  /// When set, the new category is a sub-category of [parent] (same kind).
  final Category? parent;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _name = TextEditingController();
  late CategoryKind _kind = widget.parent?.kind ?? CategoryKind.spend;
  late String _icon = widget.parent?.icon ?? 'grid';
  late int _color = widget.parent?.color ?? _palette.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parent == null ? 'New category' : 'New sub-category in ${widget.parent!.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('cat-name'),
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            if (widget.parent == null) ...[
              const SizedBox(height: 12),
              Segmented<CategoryKind>(
                values: CategoryKind.values,
                selected: _kind,
                label: (k) => switch (k) {
                  CategoryKind.spend => 'Spend',
                  CategoryKind.invest => 'Invest',
                  CategoryKind.income => 'Income',
                },
                onChanged: (k) => setState(() => _kind = k),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final e in categoryIcons.entries)
                  IconButton(
                    key: Key('icon-${e.key}'),
                    tooltip: e.key,
                    isSelected: _icon == e.key,
                    onPressed: () => setState(() => _icon = e.key),
                    icon: Icon(e.value, color: _icon == e.key ? Color(_color) : null),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in _palette)
                  GestureDetector(
                    key: Key('color-$p'),
                    onTap: () => setState(() => _color = p),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(p),
                      child: _color == p ? const Icon(AppIcons.check, size: 14, color: Colors.white) : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          key: const Key('cat-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: () => Navigator.pop<NewCategory>(context, _name.text.trim().isEmpty ? null : (name: _name.text, kind: _kind, icon: _icon, color: _color)),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
