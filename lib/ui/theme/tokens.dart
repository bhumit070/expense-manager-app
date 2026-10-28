import 'package:flutter/material.dart';

import '../../data/models.dart';
import 'icons.dart';

/// Color tokens from the Penpot design system (00 · Design system).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.track,
    required this.line,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.brand,
    required this.brandSoft,
    required this.hero,
    required this.spend,
    required this.spendSoft,
    required this.invest,
    required this.investSoft,
    required this.income,
    required this.incomeSoft,
    required this.debt,
    required this.debtSoft,
    required this.positive,
  });

  final Color bg, surface, surfaceMuted, track, line, text, textMuted, textFaint, brand, brandSoft, hero;
  final Color spend, spendSoft, invest, investSoft, income, incomeSoft, debt, debtSoft, positive;

  static const light = AppColors(
    bg: Color(0xFFF5F6FA),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF1F5F9),
    track: Color(0xFFEBEDF3),
    line: Color(0xFFE8EBF2),
    text: Color(0xFF0F172A),
    textMuted: Color(0xFF64748B),
    textFaint: Color(0xFF94A3B8),
    brand: Color(0xFF4F46E5),
    brandSoft: Color(0xFFEEF2FF),
    hero: Color(0xFF1E1B4B),
    spend: Color(0xFFF43F5E),
    spendSoft: Color(0xFFFFF1F2),
    invest: Color(0xFF10B981),
    investSoft: Color(0xFFECFDF5),
    income: Color(0xFF0EA5E9),
    incomeSoft: Color(0xFFF0F9FF),
    debt: Color(0xFFF59E0B),
    debtSoft: Color(0xFFFFFBEB),
    positive: Color(0xFF059669),
  );

  static const dark = AppColors(
    bg: Color(0xFF0B0F1A),
    surface: Color(0xFF151B2B),
    surfaceMuted: Color(0xFF1F2738),
    track: Color(0xFF1A2131),
    line: Color(0xFF252D40),
    text: Color(0xFFF1F5F9),
    textMuted: Color(0xFF94A3B8),
    textFaint: Color(0xFF64748B),
    brand: Color(0xFF818CF8),
    brandSoft: Color(0xFF1F2150),
    hero: Color(0xFF1E1B4B),
    spend: Color(0xFFF43F5E),
    spendSoft: Color(0xFF3A1622),
    invest: Color(0xFF10B981),
    investSoft: Color(0xFF0F2E25),
    income: Color(0xFF0EA5E9),
    incomeSoft: Color(0xFF0C2638),
    debt: Color(0xFFF59E0B),
    debtSoft: Color(0xFF33260B),
    positive: Color(0xFF34D399),
  );

  Color typeColor(TxnType t) => switch (t) {
    TxnType.spend => spend,
    TxnType.invest => invest,
    TxnType.income => income,
    TxnType.debt => debt,
  };

  Color typeSoft(TxnType t) => switch (t) {
    TxnType.spend => spendSoft,
    TxnType.invest => investSoft,
    TxnType.income => incomeSoft,
    TxnType.debt => debtSoft,
  };

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) => t < 0.5 ? this : other!;
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

const fontFamily = 'PlusJakartaSans';

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.light ? AppColors.light : AppColors.dark;
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: c.brand, brightness: brightness, primary: c.brand, surface: c.surface),
    extensions: [c],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: c.text, displayColor: c.text),
    appBarTheme: AppBarTheme(backgroundColor: c.bg, foregroundColor: c.text, elevation: 0, scrolledUnderElevation: 0, centerTitle: true),
    dividerTheme: DividerThemeData(color: c.line, space: 1, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.brand, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.brand,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

/// Category icon keys stored in the database.
const categoryIcons = <String, IconData>{
  'food': AppIcons.food,
  'home': AppIcons.home,
  'bag': AppIcons.shopping,
  'car': AppIcons.car,
  'bolt': AppIcons.bolt,
  'heart': AppIcons.health,
  'play': AppIcons.entertainment,
  'plane': AppIcons.travel,
  'grid': AppIcons.grid,
  'bank': AppIcons.bank,
  'coins': AppIcons.savings,
  'trend': AppIcons.trendingUp,
  'gem': AppIcons.gem,
  'shield': AppIcons.shield,
  'wallet': AppIcons.wallet,
  'gift': AppIcons.gift,
};

IconData iconFor(String key) => categoryIcons[key] ?? AppIcons.grid;

IconData sourceIcon(SourceKind k) => switch (k) {
  SourceKind.bank => AppIcons.bank,
  SourceKind.card => AppIcons.creditCard,
  SourceKind.cash => AppIcons.cash,
  SourceKind.wallet => AppIcons.bolt,
};

String typeLabel(TxnType t) => switch (t) {
  TxnType.spend => 'Spend',
  TxnType.invest => 'Invest',
  TxnType.income => 'Income',
  TxnType.debt => 'Debt',
};

String investmentKindLabel(InvestmentKind k) => switch (k) {
  InvestmentKind.fd => 'Fixed deposits',
  InvestmentKind.mutualFund => 'Mutual funds',
  InvestmentKind.stock => 'Stocks',
  InvestmentKind.gold => 'Gold',
  InvestmentKind.retirement => 'Retirement (PPF/EPF/NPS)',
  InvestmentKind.other => 'Other',
};

IconData investmentIcon(InvestmentKind k) => switch (k) {
  InvestmentKind.fd => AppIcons.bank,
  InvestmentKind.mutualFund => AppIcons.savings,
  InvestmentKind.stock => AppIcons.trendingUp,
  InvestmentKind.gold => AppIcons.gem,
  InvestmentKind.retirement => AppIcons.shield,
  InvestmentKind.other => AppIcons.grid,
};
