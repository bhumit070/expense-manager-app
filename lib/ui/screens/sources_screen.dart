import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import '../theme/icons.dart';

String sourceKindLabel(SourceKind k) => switch (k) {
  SourceKind.bank => currentL10n.sourceKindBank,
  SourceKind.card => currentL10n.debtKindCard,
  SourceKind.cash => currentL10n.sourceKindCash,
  SourceKind.wallet => currentL10n.sourceKindWallet,
};

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  Future<void> _add(BuildContext context, AppState app) async {
    final r = await showDialog<NewSource>(context: context, builder: (_) => const SourceDialog());
    if (r != null) {
      app.catalog.addSource(name: r.name, kind: r.kind, last4: r.last4, creditLimit: r.creditLimit, openingBalance: r.openingBalance, makeDefault: r.makeDefault);
      app.changed();
    }
  }

  /// Lets the user correct a source's balance to what their bank shows today.
  Future<void> _setBalance(BuildContext context, AppState app, PaymentSource s, int current) async {
    final entered = await showDialog<int>(
      context: context,
      builder: (_) => BalanceDialog(source: s, current: current),
    );
    if (entered == null) return;
    final target = s.kind == SourceKind.card ? -entered : entered;
    app.catalog.setOpeningBalance(s.id, s.openingBalance + target - current);
    app.changed();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final sources = app.catalog.sources();
    final archived = app.catalog.sources(includeArchived: true).where((s) => s.archived).toList();
    final spent = app.catalog.spentBySource(Period.of(PeriodKind.month, app.now()));
    final balances = app.catalog.balances();
    final def = app.catalog.defaultSource();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsSources, style: ts(16, weight: FontWeight.w700)),
        actions: [IconButton(key: const Key('add-source'), tooltip: context.l10n.sourceAdd, icon: const Icon(AppIcons.add), onPressed: () => _add(context, app))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(AppIcons.checkCircleFilled, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.settingsDefaultSource, style: ts(11, color: const Color(0xFFA5B4FC))),
                      Text(
                        def?.display ?? context.l10n.none,
                        style: ts(16, weight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(context.l10n.sourceDefaultHelp, style: ts(11, color: const Color(0xFFC7D2FE))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RadioGroup<int>(
              groupValue: def?.id,
              onChanged: (v) {
                app.catalog.setDefaultSource(v!);
                app.changed();
              },
              child: Column(
                children: [
                  for (final s in sources) ...[
                    ListTile(
                      key: Key('source-${s.id}'),
                      onTap: () => _setBalance(context, app, s, balances[s.id]!),
                      leading: IconBadge(sourceIcon(s.kind), color: c.brand, background: c.brandSoft, size: 40),
                      title: Text(s.display, style: ts(14, weight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key: Key('balance-${s.id}'),
                            balanceLabel(s, balances[s.id]!),
                            style: ts(12, weight: FontWeight.w600, color: balances[s.id]! < 0 ? c.spend : c.text),
                          ),
                          Text(
                            [
                              context.l10n.sourceOutIn(sourceKindLabel(s.kind), formatInr(spent[s.id] ?? 0), monthsShort[app.now().month - 1]),
                              if (s.creditLimit != null) context.l10n.sourceLimit(formatInr(s.creditLimit!)),
                            ].join(' · '),
                            style: ts(11, color: c.textMuted),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<int>(key: Key('default-${s.id}'), value: s.id),
                          if (sources.length > 1)
                            IconButton(
                              key: Key('archive-source-${s.id}'),
                              tooltip: context.l10n.catArchive(s.display),
                              icon: const Icon(AppIcons.archive),
                              onPressed: () {
                                app.catalog.archiveSource(s.id);
                                app.changed();
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const Key('archived-sources'),
                  title: Text(context.l10n.catArchivedCount(archived.length), style: ts(14, weight: FontWeight.w600)),
                  subtitle: Text(context.l10n.catArchivedHelp, style: ts(11, color: c.textMuted)),
                  children: [
                    for (final s in archived)
                      ListTile(
                        key: Key('archived-${s.id}'),
                        leading: IconBadge(sourceIcon(s.kind), color: c.textMuted, background: c.surfaceMuted, size: 40),
                        title: Text(
                          s.display,
                          style: ts(14, weight: FontWeight.w600, color: c.textMuted),
                        ),
                        subtitle: Text('${sourceKindLabel(s.kind)} · ${balanceLabel(s, balances[s.id]!)}', style: ts(11, color: c.textMuted)),
                        trailing: TextButton.icon(
                          key: Key('restore-source-${s.id}'),
                          icon: const Icon(AppIcons.unarchive, size: 18),
                          label: Text(context.l10n.restore),
                          onPressed: () {
                            app.catalog.restoreSource(s.id);
                            app.changed();
                            showSnack(context, context.l10n.catRestored(s.display));
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Balance ₹X" for accounts; "₹X outstanding" for cards.
String balanceLabel(PaymentSource s, int balance) {
  if (s.kind != SourceKind.card) return currentL10n.sourceBalance(formatInr(balance));
  return balance <= 0 ? currentL10n.sourceOutstanding(formatInr(-balance)) : currentL10n.sourceCredit(formatInr(balance));
}

typedef NewSource = ({String name, SourceKind kind, String? last4, int? creditLimit, int openingBalance, bool makeDefault});

class SourceDialog extends StatefulWidget {
  const SourceDialog({super.key});

  @override
  State<SourceDialog> createState() => _SourceDialogState();
}

class _SourceDialogState extends State<SourceDialog> {
  final _name = TextEditingController();
  final _last4 = TextEditingController();
  final _limit = TextEditingController();
  final _balance = TextEditingController();
  SourceKind _kind = SourceKind.bank;
  bool _makeDefault = false;

  @override
  void dispose() {
    _name.dispose();
    _last4.dispose();
    _limit.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    final last4 = _last4.text.trim();
    final balance = parseInr(_balance.text) ?? 0;
    Navigator.pop<NewSource>(context, (
      name: _name.text,
      kind: _kind,
      last4: last4.isEmpty ? null : last4,
      creditLimit: _kind == SourceKind.card ? parseInr(_limit.text) : null,
      openingBalance: _kind == SourceKind.card ? -balance : balance,
      makeDefault: _makeDefault,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.sourceNew),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final k in SourceKind.values) Pill(sourceKindLabel(k), selected: k == _kind, onTap: () => setState(() => _kind = k))],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('source-name'),
              controller: _name,
              decoration: InputDecoration(labelText: context.l10n.sourceNameField),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('source-last4'),
              controller: _last4,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: context.l10n.sourceLast4),
            ),
            if (_kind == SourceKind.card)
              TextField(
                key: const Key('source-limit'),
                controller: _limit,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: context.l10n.sourceCreditLimit(currencySymbol)),
              ),
            TextField(
              key: const Key('source-balance'),
              controller: _balance,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: balanceFieldLabel(_kind), helperText: context.l10n.sourceBalanceHelp(formatInr(0))),
            ),
            CheckboxListTile(
              key: const Key('source-default'),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.makeDefault),
              value: _makeDefault,
              onChanged: (v) => setState(() => _makeDefault = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(
          key: const Key('source-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: _submit,
          child: Text(context.l10n.add),
        ),
      ],
    );
  }
}

String balanceFieldLabel(SourceKind k) => k == SourceKind.card ? currentL10n.sourceOutstandingField(currencySymbol) : currentL10n.sourceBalanceField(currencySymbol);

/// Asks for what the source holds today; returns paise as the user typed it.
class BalanceDialog extends StatefulWidget {
  const BalanceDialog({super.key, required this.source, required this.current});

  final PaymentSource source;
  final int current;

  @override
  State<BalanceDialog> createState() => _BalanceDialogState();
}

class _BalanceDialogState extends State<BalanceDialog> {
  late final _amount = TextEditingController(text: _plain(widget.source.kind == SourceKind.card ? -widget.current : widget.current));

  static String _plain(int paise) => paise == 0 ? '' : (paise % paisePerRupee == 0 ? '${paise ~/ paisePerRupee}' : (paise / paisePerRupee).toStringAsFixed(2));

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.source.display),
      content: TextField(
        key: const Key('balance-amount'),
        controller: _amount,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: balanceFieldLabel(widget.source.kind), helperText: context.l10n.sourceAdjustHelp),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
        FilledButton(
          key: const Key('balance-save'),
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: () => Navigator.pop<int>(context, parseInr(_amount.text) ?? 0),
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
