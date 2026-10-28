import 'package:expense_manager/core/dates.dart';
import 'package:expense_manager/data/models.dart';
import 'package:expense_manager/data/transactions_repo.dart';
import 'package:expense_manager/ui/theme/tokens.dart';
import 'package:expense_manager/ui/widgets/charts.dart';
import 'package:expense_manager/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import 'package:expense_manager/ui/theme/icons.dart';

Future<void> pumpBody(WidgetTester tester, Widget body, {Brightness b = Brightness.light}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(b),
      home: Scaffold(body: ListView(children: [body])),
    ),
  );
}

void main() {
  group('tokens', () {
    test('themes carry the right color extension', () {
      expect(buildTheme(Brightness.light).extension<AppColors>(), AppColors.light);
      expect(buildTheme(Brightness.dark).extension<AppColors>(), AppColors.dark);
      expect(AppColors.light.copyWith(), AppColors.light);
      expect(AppColors.light.lerp(AppColors.dark, 0.2), AppColors.light);
      expect(AppColors.light.lerp(AppColors.dark, 0.8), AppColors.dark);
    });

    test('type colors and labels cover every type', () {
      const c = AppColors.light;
      expect(TxnType.values.map(c.typeColor).toSet().length, 4);
      expect(TxnType.values.map(c.typeSoft).toSet().length, 4);
      expect(TxnType.values.map(typeLabel), ['Spend', 'Invest', 'Income', 'Debt']);
    });

    test('icon and label lookups', () {
      expect(iconFor('food'), AppIcons.food);
      expect(iconFor('unknown'), AppIcons.grid);
      expect(SourceKind.values.map(sourceIcon).toSet().length, 4);
      expect(InvestmentKind.values.map(investmentKindLabel).toSet().length, InvestmentKind.values.length);
      expect(InvestmentKind.values.map(investmentIcon).toSet().length, InvestmentKind.values.length);
    });
  });

  testWidgets('cards, headers, badges and tags render', (tester) async {
    var tapped = 0;
    await pumpBody(
      tester,
      Column(
        children: [
          AppCard(border: Colors.red, onTap: () => tapped++, child: const Text('card')),
          SectionHeader('Title', action: 'More', onAction: () => tapped++),
          const SectionHeader('Plain'),
          const CategoryBadge(Category(id: 1, name: 'Food', kind: CategoryKind.spend, icon: 'food', color: 0xFFF43F5E)),
          for (final t in TxnType.values) TypeTag(t),
          const DetailRow(label: 'Bank', value: 'HDFC'),
          StatTile(icon: AppIcons.add, label: 'L', value: 'V', caption: 'C', color: Colors.red, soft: Colors.pink, onTap: () => tapped++),
        ],
      ),
      b: Brightness.dark,
    );
    await tester.tap(find.text('card'));
    await tester.tap(find.text('More'));
    await tester.tap(find.text('V'));
    expect(tapped, 3);
    expect(find.text('SPEND'), findsOneWidget);
  });

  testWidgets('segmented, pills and empty state handle taps', (tester) async {
    String? picked;
    var pills = 0;
    var action = 0;
    await pumpBody(
      tester,
      Column(
        children: [
          Segmented<String>(values: const ['a', 'b'], selected: 'a', label: (v) => v.toUpperCase(), onChanged: (v) => picked = v),
          Segmented<String>(values: const ['x', 'y'], selected: 'x', label: (v) => v, activeColor: Colors.red, onChanged: (_) {}),
          Pill('sel', selected: true, dot: Colors.red, icon: AppIcons.add, onTap: () => pills++),
          const Pill('plain'),
          EmptyState(icon: AppIcons.add, title: 'Empty', message: 'msg', action: 'Do it', onAction: () => action++),
          const EmptyState(icon: AppIcons.add, title: 'No action', message: 'msg'),
        ],
      ),
    );
    await tester.tap(find.text('B'));
    await tester.tap(find.text('sel'));
    await tester.tap(find.text('Do it'));
    expect([picked, pills, action], ['b', 1, 1]);
  });

  testWidgets('TxnTile shows signed amounts and subtitle', (tester) async {
    final s = makeState();
    seed(s);
    final rows = s.txns.list(const TxnFilter());
    final salary = rows.firstWhere((r) => r.txn.merchant == 'Salary');
    final sip = rows.firstWhere((r) => r.txn.type == TxnType.invest && r.txn.merchant.isEmpty);
    var taps = 0;
    final noSource = TxnView(txn: sip.txn, category: sip.category, inflow: false);
    await pumpBody(
      tester,
      Column(
        children: [
          TxnTile(salary, now: kNow, onTap: () => taps++),
          TxnTile(noSource),
        ],
      ),
    );
    expect(find.text('+₹1,10,000'), findsOneWidget);
    expect(find.text('Salary · HDFC Savings · Thu, 1 Oct'), findsOneWidget);
    expect(find.text('Mutual funds / SIP'), findsWidgets);
    await tester.tap(find.text('+₹1,10,000'));
    expect(taps, 1);
  });

  testWidgets('segment bar, donut and bucket charts paint every case', (tester) async {
    Widget charts(double v) => Column(
      children: [
        SizedBox(width: 200, child: SegmentBar(segments: [(v, Colors.red), (0, Colors.blue), (2, Colors.green)])),
        DonutChart(segments: [(v, Colors.red), (1, Colors.blue)], center: const Text('c')),
        const DonutChart(segments: [(0, Colors.red)], center: Text('empty')),
        const DonutChart(segments: [(1, Colors.red), (0, Colors.blue)], center: Text('single')),
        SizedBox(
          width: 300,
          child: BucketBars(
            buckets: [
              Bucket(start: DateTime(2026), spend: 10, invest: 5),
              Bucket(start: DateTime(2026, 2), spend: 0, invest: 0),
              Bucket(start: DateTime(2026, 3), spend: 0, invest: 4),
              Bucket(start: DateTime(2026, 4), spend: 3, invest: 0),
            ],
            labels: const ['J', 'F', 'M', 'A'],
            highlight: 1,
          ),
        ),
        SizedBox(
          width: 100,
          child: BucketBars(
            buckets: [Bucket(start: DateTime(2026), spend: 0, invest: 0)],
            labels: const ['x'],
          ),
        ),
        const LegendDot('Spend', Colors.red),
      ],
    );
    await pumpBody(tester, charts(0.3));
    await pumpBody(tester, charts(0.6));
    expect(find.text('Spend'), findsOneWidget);
    expect(find.text('empty'), findsOneWidget);
  });

  testWidgets('showSnack with and without an action', (tester) async {
    var undone = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  TextButton(onPressed: () => showSnack(context, 'plain'), child: const Text('a')),
                  TextButton(
                    onPressed: () => showSnack(context, 'undoable', action: 'Undo', onAction: () => undone = true),
                    child: const Text('b'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('a'));
    await tester.pump();
    expect(find.text('plain'), findsOneWidget);
    await tester.tap(find.text('b'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(undone, isTrue);
  });

  test('period helper used by charts', () => expect(Period.of(PeriodKind.year, kNow).label, '2026'));
}
