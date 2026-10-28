import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';
import 'debts_screen.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'investments_screen.dart';
import 'txn_form_screen.dart';
import '../theme/icons.dart';

/// Root scaffold with bottom navigation and the central add button.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final body = switch (_index) {
      0 => HomeScreen(onOpenInsights: () => _go(1), onOpenInvestments: () => _go(2), onOpenDebts: () => _go(3)),
      1 => const InsightsScreen(),
      2 => const InvestmentsScreen(),
      _ => const DebtsScreen(),
    };
    Widget tab(int i, IconData icon, String label) {
      final on = i == _index;
      return Expanded(
        child: InkWell(
          key: Key('tab-$label'),
          onTap: () => _go(i),
          // The bar has a fixed height, so its labels stop growing at 1.2× text.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: on ? c.brand : c.textMuted),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(11, weight: on ? FontWeight.w700 : FontWeight.w500, color: on ? c.brand : c.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(bottom: false, child: body),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        key: const Key('add-txn'),
        tooltip: l10n.addTransaction,
        backgroundColor: c.brand,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TxnFormScreen())),
        child: const Icon(AppIcons.add, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        color: c.surface,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            tab(0, AppIcons.home, l10n.navHome),
            tab(1, AppIcons.pieChart, l10n.navInsights),
            const SizedBox(width: 72),
            tab(2, AppIcons.trendingUp, l10n.navInvest),
            tab(3, AppIcons.people, l10n.navDebts),
          ],
        ),
      ),
    );
  }
}
