import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

const _palette = [0xFFF43F5E, 0xFF8B5CF6, 0xFFEC4899, 0xFFF59E0B, 0xFF10B981, 0xFF0EA5E9, 0xFF6366F1, 0xFF64748B];

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _add(BuildContext context, AppState app) async {
    final r = await showDialog<NewCategory>(context: context, builder: (_) => const CategoryDialog());
    if (r != null) {
      app.catalog.addCategory(name: r.name, kind: r.kind, icon: r.icon, color: r.color);
      app.changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    Widget section(CategoryKind kind, String title, String explainer) {
      final list = app.catalog.categories(kind: kind);
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
            child: ReorderableListView(
              key: Key('reorder-${kind.name}'),
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
                  ListTile(
                    key: ValueKey(list[i].id),
                    leading: CategoryBadge(list[i], size: 38),
                    title: Text(list[i].name, style: ts(14, weight: FontWeight.w600)),
                    subtitle: list[i].isDefault ? Text('Default — used when nothing is picked', style: ts(11, color: c.textMuted)) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!list[i].isDefault)
                          IconButton(
                            key: Key('archive-${list[i].id}'),
                            icon: const Icon(Icons.archive_outlined),
                            onPressed: () {
                              app.catalog.archiveCategory(list[i].id);
                              app.changed();
                            },
                          ),
                        ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: ts(16, weight: FontWeight.w700)),
        actions: [IconButton(key: const Key('add-category'), icon: const Icon(Icons.add), onPressed: () => _add(context, app))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          section(CategoryKind.spend, 'Spend', 'Money that’s gone — food, rent, bills.'),
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
  const CategoryDialog({super.key});

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _name = TextEditingController();
  CategoryKind _kind = CategoryKind.spend;
  String _icon = 'grid';
  int _color = _palette.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New category'),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final e in categoryIcons.entries)
                  IconButton(
                    key: Key('icon-${e.key}'),
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
                      child: _color == p ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
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
