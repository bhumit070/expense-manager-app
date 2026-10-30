import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../data/recurring_repo.dart';
import '../../data/templates_repo.dart';
import '../../services/location.dart';
import '../../services/receipts.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/category_picker.dart';
import '../widgets/amount_keypad.dart';
import '../widgets/common.dart';
import 'location_picker_screen.dart';
import '../theme/icons.dart';

/// Add or edit a transaction. Defaults: now, default source, "Others"
/// category, current location when permitted.
class TxnFormScreen extends StatefulWidget {
  const TxnFormScreen({super.key, this.existing, this.initialType = TxnType.spend, this.investmentId, this.debtId, this.duplicate = false, this.prefill, this.onSaved});

  final TxnView? existing;
  final TxnType initialType;
  final int? investmentId;
  final int? debtId;

  /// When true, [existing] is copied into a new transaction.
  final bool duplicate;

  /// Values for a new transaction, including its time (e.g. read from an SMS).
  final Txn? prefill;

  /// Called with the new transaction's id once it is saved (null when it
  /// became a recurring rule).
  final void Function(int? id)? onSaved;

  @override
  State<TxnFormScreen> createState() => _TxnFormScreenState();
}

class _TxnFormScreenState extends State<TxnFormScreen> {
  late TxnType _type;
  int? _categoryId;
  int? _sourceId;
  int? _investmentId;
  int? _debtId;
  late DateTime _at;
  final _amount = AmountInput();
  final _merchant = TextEditingController();
  final _note = TextEditingController();
  final _tags = TextEditingController();
  final _place = TextEditingController();
  double? _lat;
  double? _lng;
  bool _locating = false;
  bool _initialized = false;
  bool _repeat = false;
  Frequency _frequency = Frequency.monthly;
  DateTime? _repeatEnd;

  /// Receipt as saved (edit only), the current one, and files picked in this
  /// session (deleted unless they end up saved).
  String? _originalReceipt;
  String? _receipt;
  final _pickedReceipts = <String>{};
  bool _saved = false;
  late ReceiptStore _receipts;

  bool get _editing => widget.existing != null && !widget.duplicate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final app = AppScope.read(context);
    _receipts = app.receipts;
    final e = widget.existing?.txn ?? widget.prefill;
    _type = e?.type ?? widget.initialType;
    _at = _editing ? e!.occurredAt : widget.prefill?.occurredAt ?? app.now();
    _sourceId = e?.sourceId ?? app.catalog.defaultSource()?.id;
    _categoryId = e?.categoryId;
    _investmentId = e?.investmentId ?? widget.investmentId;
    _debtId = e?.debtId ?? widget.debtId;
    if (e != null) {
      _amount.text = plainAmount(e.amount);
      _merchant.text = e.merchant;
      _note.text = e.note;
      _tags.text = e.tags.join(' ');
      _place.text = e.place ?? '';
      _lat = e.lat;
      _lng = e.lng;
      if (_editing) _originalReceipt = _receipt = e.receipt;
    } else if (app.locationEnabled) {
      _locate(app);
    }
  }

  Future<void> _locate(AppState app) async {
    setState(() => _locating = true);
    final place = await app.location.current();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (place != null && _place.text.isEmpty) {
        _place.text = place.name;
        _lat = place.lat;
        _lng = place.lng;
      }
    });
  }

  @override
  void dispose() {
    if (!_saved) _discardPicked(keep: null);
    for (final c in [_merchant, _note, _tags, _place]) {
      c.dispose();
    }
    super.dispose();
  }

  void _discardPicked({required String? keep}) {
    for (final path in _pickedReceipts) {
      if (path != keep) _receipts.delete(path);
    }
  }

  Future<void> _pickLocation() async {
    final initial = _lat == null ? null : Place(name: _place.text, lat: _lat!, lng: _lng!);
    final picked = await Navigator.of(context).push<Place>(MaterialPageRoute(builder: (_) => LocationPickerScreen(initial: initial)));
    if (picked != null) {
      setState(() {
        _place.text = picked.name;
        _lat = picked.lat;
        _lng = picked.lng;
      });
    }
  }

  Future<void> _pickReceipt(AppState app, ReceiptSource source) async {
    final path = await app.receipts.pick(source);
    if (path == null || !mounted) return;
    setState(() {
      _pickedReceipts.add(path);
      _receipt = path;
    });
  }

  void _applyTemplate(AppState app, TxnTemplate t) {
    setState(() {
      _type = t.type;
      _amount.text = plainAmount(t.amount);
      _categoryId = t.categoryId;
      if (t.sourceId != null && app.catalog.sources().any((x) => x.id == t.sourceId)) _sourceId = t.sourceId;
      _merchant.text = t.merchant;
      _note.text = t.note;
      _tags.text = t.tags.join(' ');
    });
  }

  Future<void> _saveTemplate(AppState app) async {
    final amount = _amount.value;
    if (amount == null || amount <= 0) {
      showSnack(context, context.l10n.txnNeedAmount);
      return;
    }
    final categoryId = _categoryId ?? app.catalog.firstOf(_kind).id;
    final suggested = _merchant.text.trim().isNotEmpty ? _merchant.text.trim() : app.catalog.category(categoryId).name;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => TemplateNameDialog(initial: suggested),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    app.templates.add(TxnTemplate(name: name, type: _type, amount: amount, categoryId: categoryId, sourceId: _sourceId, merchant: _merchant.text, note: _note.text, tags: _parseTags(_tags.text)));
    app.changed();
    showSnack(context, context.l10n.txnTemplateSaved(name.trim()));
  }

  Future<void> _deleteTemplate(AppState app, TxnTemplate t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteNamed(t.name)),
        content: Text(context.l10n.txnTemplateDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.cancel)),
          FilledButton(key: const Key('confirm-delete-template'), onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.delete)),
        ],
      ),
    );
    if (ok == true) {
      app.templates.delete(t.id!);
      app.changed();
    }
  }

  Future<void> _pickRepeatEnd() async {
    final d = await showDatePicker(context: context, initialDate: occurrence(_at, _frequency, 12), firstDate: _at, lastDate: DateTime(2100));
    if (d != null) setState(() => _repeatEnd = DateTime(d.year, d.month, d.day, 23, 59));
  }

  CategoryKind get _kind => switch (_type) {
    TxnType.invest => CategoryKind.invest,
    TxnType.income => CategoryKind.income,
    _ => CategoryKind.spend,
  };

  List<String> _parseTags(String text) => text.split(RegExp(r'[\s,]+')).where((t) => t.replaceAll('#', '').isNotEmpty).map((t) => '#${t.replaceAll('#', '').toLowerCase()}').toSet().toList();

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(() => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
    if (t != null) setState(() => _at = DateTime(_at.year, _at.month, _at.day, t.hour, t.minute));
  }

  void _save() {
    final app = AppScope.read(context);
    final amount = _amount.value;
    if (amount == null || amount <= 0) {
      showSnack(context, context.l10n.txnNeedAmount);
      return;
    }
    if (_type == TxnType.debt && _debtId == null) {
      showSnack(context, context.l10n.txnNeedDebt);
      return;
    }
    final categoryId = _categoryId ?? app.catalog.firstOf(_kind).id;
    final txn = Txn(
      id: _editing ? widget.existing!.txn.id : null,
      type: _type,
      amount: amount,
      categoryId: categoryId,
      sourceId: _sourceId,
      occurredAt: _at,
      merchant: _merchant.text,
      note: _note.text,
      tags: _parseTags(_tags.text),
      place: _place.text,
      lat: _place.text.trim().isEmpty ? null : _lat,
      lng: _place.text.trim().isEmpty ? null : _lng,
      investmentId: _type == TxnType.invest ? _investmentId : null,
      debtId: _type == TxnType.debt ? _debtId : null,
      receipt: _receipt,
      recurringId: _editing ? widget.existing!.txn.recurringId : null,
    );
    int? id;
    if (_editing) {
      app.txns.update(txn);
    } else if (_repeat) {
      app.recurring.createFrom(txn, _frequency, endAt: _repeatEnd, now: app.now());
    } else {
      id = app.txns.insert(txn, now: app.now());
    }
    widget.onSaved?.call(id);
    _saved = true;
    _discardPicked(keep: _receipt);
    if (_originalReceipt != null && _originalReceipt != _receipt) app.receipts.delete(_originalReceipt!);
    app.changed();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final cats = app.catalog.categories(kind: _kind);
    final selectedCat = cats.any((x) => x.id == _categoryId) ? _categoryId : null;
    final sources = app.catalog.sources();
    final accent = c.typeColor(_type);
    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(t, style: ts(14, weight: FontWeight.w700)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? context.l10n.txnEditTitle : context.l10n.txnNewTitle, style: ts(16, weight: FontWeight.w700)),
        actions: [IconButton(key: const Key('save-template'), tooltip: context.l10n.txnSaveTemplate, icon: const Icon(AppIcons.bookmarkAdd), onPressed: () => _saveTemplate(app))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          if (!_editing && widget.existing == null) _QuickAdd(onPick: (t) => _applyTemplate(app, t), onDelete: (t) => _deleteTemplate(app, t)),
          Segmented<TxnType>(
            values: TxnType.values,
            selected: _type,
            label: typeLabel,
            activeColor: accent,
            onChanged: (t) => setState(() {
              _type = t;
              _categoryId = null;
            }),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$currencySymbol ',
                style: ts(28, weight: FontWeight.w600, color: c.textFaint),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _amount.display,
                    key: const Key('amount'),
                    style: ts(44, weight: FontWeight.w800, spacing: -1, color: _amount.text.isEmpty ? c.textFaint : c.text),
                  ),
                ),
              ),
            ],
          ),
          if (_amount.hasMath)
            Center(
              child: Text(
                '= ${formatInr(_amount.value!)}',
                key: const Key('amount-total'),
                style: ts(15, weight: FontWeight.w700, color: (_amount.value ?? 0) > 0 ? accent : c.spend),
              ),
            ),
          const SizedBox(height: 8),
          AmountKeypad(accent: accent, onKey: (k) => setState(() => _amount.press(k))),
          if (sources.isNotEmpty) ...[
            label(_type == TxnType.income ? context.l10n.txnReceivedIn : context.l10n.txnPaidFrom),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final s in sources) Pill(s.display, icon: sourceIcon(s.kind), selected: s.id == _sourceId, onTap: () => setState(() => _sourceId = s.id))],
            ),
          ],
          if (_type != TxnType.debt) ...[
            label(context.l10n.category),
            CategoryPicker(categories: cats, selectedId: selectedCat, onChanged: (id) => setState(() => _categoryId = id)),
            if (_kind == CategoryKind.spend)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(context.l10n.txnCategoryHint(app.catalog.defaultCategory().name), style: ts(12, color: c.textFaint)),
              ),
          ],
          if (_type == TxnType.invest) ...[
            label(context.l10n.txnHolding),
            DropdownButtonFormField<int?>(
              key: const Key('holding'),
              isExpanded: true,
              initialValue: _investmentId,
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(context.l10n.txnNotLinked)),
                for (final h in app.planning.holdings())
                  DropdownMenuItem<int?>(
                    value: h.investment.id,
                    child: Text(h.investment.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _investmentId = v),
            ),
          ],
          if (_type == TxnType.debt) ...[
            label(context.l10n.txnDebt),
            DropdownButtonFormField<int?>(
              key: const Key('debt'),
              isExpanded: true,
              initialValue: _debtId,
              hint: Text(context.l10n.txnChooseDebt),
              items: [
                for (final d in app.planning.debts())
                  DropdownMenuItem<int?>(
                    value: d.debt.id,
                    child: Text(d.debt.direction == DebtDirection.iOwe ? context.l10n.txnDebtYouPay(d.debt.name) : context.l10n.txnDebtYouReceive(d.debt.name), overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _debtId = v),
            ),
          ],
          label(context.l10n.details),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  key: const Key('pick-date'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.calendar),
                  title: Text(longDate(_at), style: ts(14, weight: FontWeight.w600)),
                  subtitle: Text(context.l10n.date, style: ts(11, color: c.textMuted)),
                  onTap: _pickDate,
                ),
                const Divider(),
                ListTile(
                  key: const Key('pick-time'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(AppIcons.time),
                  title: Text(timeOfDay(_at), style: ts(14, weight: FontWeight.w600)),
                  subtitle: Text(context.l10n.time, style: ts(11, color: c.textMuted)),
                  onTap: _pickTime,
                ),
                const Divider(),
                TextField(
                  key: const Key('merchant'),
                  controller: _merchant,
                  decoration: InputDecoration(labelText: context.l10n.txnMerchant, filled: false, border: InputBorder.none, enabledBorder: InputBorder.none),
                ),
                const Divider(),
                TextField(
                  key: const Key('place'),
                  controller: _place,
                  decoration: InputDecoration(
                    labelText: context.l10n.txnLocation,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(key: const Key('pick-location'), tooltip: context.l10n.pickOnMap, icon: const Icon(AppIcons.map), onPressed: _pickLocation),
                        if (_locating)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        else
                          IconButton(key: const Key('locate'), tooltip: context.l10n.useCurrentLocation, icon: const Icon(AppIcons.myLocation), onPressed: () => _locate(app)),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                TextField(
                  key: const Key('note'),
                  controller: _note,
                  maxLines: null,
                  decoration: InputDecoration(labelText: context.l10n.txnNote, filled: false, border: InputBorder.none, enabledBorder: InputBorder.none),
                ),
                const Divider(),
                TextField(
                  key: const Key('tags'),
                  controller: _tags,
                  decoration: InputDecoration(labelText: context.l10n.txnTags, filled: false, border: InputBorder.none, enabledBorder: InputBorder.none),
                ),
              ],
            ),
          ),
          label(context.l10n.receipt),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _receipt == null
                ? Row(
                    children: [
                      for (final (src, icon, text) in [
                        (ReceiptSource.camera, AppIcons.camera, context.l10n.receiptCamera),
                        (ReceiptSource.gallery, AppIcons.gallery, context.l10n.receiptGallery),
                        (ReceiptSource.pdf, AppIcons.pdf, context.l10n.receiptPdf),
                      ])
                        Expanded(
                          child: TextButton.icon(key: Key('receipt-${src.name}'), onPressed: () => _pickReceipt(app, src), icon: Icon(icon, size: 18), label: Text(text)),
                        ),
                    ],
                  )
                : ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(isPdf(_receipt!) ? AppIcons.pdf : AppIcons.image, color: c.brand),
                    title: Text(isPdf(_receipt!) ? context.l10n.receiptPdfAttached : context.l10n.receiptPhotoAttached, style: ts(14, weight: FontWeight.w600)),
                    trailing: IconButton(key: const Key('receipt-clear'), tooltip: context.l10n.receiptRemove, icon: const Icon(AppIcons.close), onPressed: () => setState(() => _receipt = null)),
                  ),
          ),
          if (_editing && widget.existing!.txn.recurringId != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(context.l10n.txnRecurringNote, style: ts(12, color: c.textMuted)),
            )
          else if (!_editing) ...[
            label(context.l10n.repeat),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  SwitchListTile(
                    key: const Key('repeat'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.txnRepeat, style: ts(14, weight: FontWeight.w600)),
                    subtitle: Text(
                      _repeat ? context.l10n.txnRepeatNext(frequencyLabel(_frequency), longDate(occurrence(_at, _frequency, 1))) : context.l10n.txnRepeatHelp,
                      style: ts(11, color: c.textMuted),
                    ),
                    value: _repeat,
                    onChanged: (v) => setState(() => _repeat = v),
                  ),
                  if (_repeat) ...[
                    Segmented<Frequency>(values: Frequency.values, selected: _frequency, label: frequencyLabel, activeColor: accent, onChanged: (f) => setState(() => _frequency = f)),
                    ListTile(
                      key: const Key('repeat-end'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(AppIcons.eventBusy),
                      title: Text(_repeatEnd == null ? context.l10n.neverEnds : context.l10n.endsOn(longDate(_repeatEnd!)), style: ts(14, weight: FontWeight.w600)),
                      trailing: _repeatEnd == null
                          ? null
                          : IconButton(key: const Key('repeat-end-clear'), tooltip: context.l10n.clearEndDate, icon: const Icon(AppIcons.close), onPressed: () => setState(() => _repeatEnd = null)),
                      onTap: _pickRepeatEnd,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(key: const Key('save-txn'), onPressed: _save, icon: const Icon(AppIcons.check), label: Text(_editing ? context.l10n.saveChanges : context.l10n.txnSave)),
        ],
      ),
    );
  }
}

/// Templates and frequent merchants for one-tap re-adding.
class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.onPick, required this.onDelete});

  final ValueChanged<TxnTemplate> onPick;
  final ValueChanged<TxnTemplate> onDelete;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = context.colors;
    final picks = [...app.templates.list(), ...app.templates.frequent(app.now())];
    if (picks.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.quickAdd,
            style: ts(12, weight: FontWeight.w700, color: c.textMuted, spacing: 0.4),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView(
              key: const Key('quick-add'),
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in picks)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onLongPress: t.id == null ? null : () => onDelete(t),
                      child: ActionChip(
                        key: Key(t.id == null ? 'freq-${t.name.toLowerCase()}' : 'tpl-${t.id}'),
                        avatar: Icon(t.id == null ? AppIcons.history : AppIcons.bookmark, size: 16),
                        label: Text('${t.name} · ${formatInr(t.amount)}'),
                        onPressed: () => onPick(t),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TemplateNameDialog extends StatefulWidget {
  const TemplateNameDialog({super.key, required this.initial});

  final String initial;

  @override
  State<TemplateNameDialog> createState() => _TemplateNameDialogState();
}

class _TemplateNameDialogState extends State<TemplateNameDialog> {
  late final _ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.txnSaveTemplate),
    content: TextField(
      key: const Key('template-name'),
      controller: _ctrl,
      autofocus: true,
      decoration: InputDecoration(labelText: context.l10n.settingsName),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel)),
      FilledButton(key: const Key('template-save'), onPressed: () => Navigator.pop(context, _ctrl.text), child: Text(context.l10n.save)),
    ],
  );
}
