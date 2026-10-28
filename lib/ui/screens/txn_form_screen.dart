import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/category_picker.dart';
import '../widgets/common.dart';

/// Add or edit a transaction. Defaults: now, default source, "Others"
/// category, current location when permitted.
class TxnFormScreen extends StatefulWidget {
  const TxnFormScreen({super.key, this.existing, this.initialType = TxnType.spend, this.investmentId, this.debtId, this.duplicate = false});

  final TxnView? existing;
  final TxnType initialType;
  final int? investmentId;
  final int? debtId;

  /// When true, [existing] is copied into a new transaction.
  final bool duplicate;

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
  final _amount = TextEditingController();
  final _merchant = TextEditingController();
  final _note = TextEditingController();
  final _tags = TextEditingController();
  final _place = TextEditingController();
  double? _lat;
  double? _lng;
  bool _locating = false;
  bool _initialized = false;

  bool get _editing => widget.existing != null && !widget.duplicate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final app = AppScope.read(context);
    final e = widget.existing?.txn;
    _type = e?.type ?? widget.initialType;
    _at = _editing ? e!.occurredAt : app.now();
    _sourceId = e?.sourceId ?? app.catalog.defaultSource()?.id;
    _categoryId = e?.categoryId;
    _investmentId = e?.investmentId ?? widget.investmentId;
    _debtId = e?.debtId ?? widget.debtId;
    if (e != null) {
      _amount.text = (e.amount % 100 == 0) ? '${e.amount ~/ 100}' : (e.amount / 100).toStringAsFixed(2);
      _merchant.text = e.merchant;
      _note.text = e.note;
      _tags.text = e.tags.join(' ');
      _place.text = e.place ?? '';
      _lat = e.lat;
      _lng = e.lng;
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
    for (final c in [_amount, _merchant, _note, _tags, _place]) {
      c.dispose();
    }
    super.dispose();
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
    final amount = parseInr(_amount.text);
    if (amount == null || amount <= 0) {
      showSnack(context, 'Enter an amount greater than zero');
      return;
    }
    if (_type == TxnType.debt && _debtId == null) {
      showSnack(context, 'Pick which debt this payment belongs to');
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
    );
    _editing ? app.txns.update(txn) : app.txns.insert(txn, now: app.now());
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
        title: Text(_editing ? 'Edit transaction' : 'New transaction', style: ts(16, weight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
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
          TextField(
            key: const Key('amount'),
            controller: _amount,
            autofocus: !_editing,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: ts(44, weight: FontWeight.w800, spacing: -1),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: ts(28, weight: FontWeight.w600, color: c.textFaint),
              hintText: '0',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          if (sources.isNotEmpty) ...[
            label(_type == TxnType.income ? 'Received in' : 'Paid from'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final s in sources) Pill(s.display, icon: sourceIcon(s.kind), selected: s.id == _sourceId, onTap: () => setState(() => _sourceId = s.id))],
            ),
          ],
          if (_type != TxnType.debt) ...[
            label('Category'),
            CategoryPicker(categories: cats, selectedId: selectedCat, onChanged: (id) => setState(() => _categoryId = id)),
            if (_kind == CategoryKind.spend)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Not sure? It goes to “Others” by default.', style: ts(12, color: c.textFaint)),
              ),
          ],
          if (_type == TxnType.invest) ...[
            label('Holding (optional)'),
            DropdownButtonFormField<int?>(
              key: const Key('holding'),
              isExpanded: true,
              initialValue: _investmentId,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Not linked')),
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
            label('Debt'),
            DropdownButtonFormField<int?>(
              key: const Key('debt'),
              isExpanded: true,
              initialValue: _debtId,
              hint: const Text('Choose a debt'),
              items: [
                for (final d in app.planning.debts())
                  DropdownMenuItem<int?>(
                    value: d.debt.id,
                    child: Text('${d.debt.name} · ${d.debt.direction == DebtDirection.iOwe ? 'you pay' : 'you receive'}', overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _debtId = v),
            ),
          ],
          label('Details'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  key: const Key('pick-date'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(longDate(_at), style: ts(14, weight: FontWeight.w600)),
                  subtitle: Text('Date', style: ts(11, color: c.textMuted)),
                  onTap: _pickDate,
                ),
                const Divider(),
                ListTile(
                  key: const Key('pick-time'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(timeOfDay(_at), style: ts(14, weight: FontWeight.w600)),
                  subtitle: Text('Time', style: ts(11, color: c.textMuted)),
                  onTap: _pickTime,
                ),
                const Divider(),
                TextField(
                  key: const Key('merchant'),
                  controller: _merchant,
                  decoration: const InputDecoration(labelText: 'Merchant / payee', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none),
                ),
                const Divider(),
                TextField(
                  key: const Key('place'),
                  controller: _place,
                  decoration: InputDecoration(
                    labelText: 'Location · optional',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    suffixIcon: _locating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton(key: const Key('locate'), icon: const Icon(Icons.my_location), onPressed: () => _locate(app)),
                  ),
                ),
                const Divider(),
                TextField(
                  key: const Key('note'),
                  controller: _note,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: 'Why? Add a note (searchable)', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none),
                ),
                const Divider(),
                TextField(
                  key: const Key('tags'),
                  controller: _tags,
                  decoration: const InputDecoration(labelText: 'Tags, e.g. #work #split', filled: false, border: InputBorder.none, enabledBorder: InputBorder.none),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(key: const Key('save-txn'), onPressed: _save, icon: const Icon(Icons.check), label: Text(_editing ? 'Save changes' : 'Save transaction')),
        ],
      ),
    );
  }
}
