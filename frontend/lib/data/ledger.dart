import 'dart:convert';

import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 가계부 데이터. 계좌 연동 없이 자가 입력으로 기록한다 (docs/08 결정).
/// 기록 강제형 가계부가 아니라 챌린지 실측 입력을 뒷받침하는 보조 도구다.

/// main()에서 SharedPreferences 인스턴스로 override해 주입한다.
/// 테스트에서는 SharedPreferences.setMockInitialValues 후 주입.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('main()에서 override해야 한다'),
);

enum LedgerEntryKind {
  expense('지출'),
  income('수입');

  const LedgerEntryKind(this.label);
  final String label;
}

enum LedgerCategory {
  food('식비', Icons.restaurant, LedgerEntryKind.expense),
  cafe('카페·간식', Icons.local_cafe, LedgerEntryKind.expense),
  transport('교통', Icons.directions_bus, LedgerEntryKind.expense),
  housing('주거·통신', Icons.home, LedgerEntryKind.expense),
  subscription('구독', Icons.subscriptions, LedgerEntryKind.expense),
  shopping('쇼핑', Icons.shopping_bag, LedgerEntryKind.expense),
  leisure('문화·여가', Icons.movie, LedgerEntryKind.expense),
  medical('의료', Icons.local_hospital, LedgerEntryKind.expense),
  otherExpense('기타 지출', Icons.receipt_long, LedgerEntryKind.expense),
  salary('월급', Icons.payments, LedgerEntryKind.income),
  otherIncome('기타 수입', Icons.savings, LedgerEntryKind.income);

  const LedgerCategory(this.label, this.icon, this.kind);
  final String label;
  final IconData icon;
  final LedgerEntryKind kind;

  static List<LedgerCategory> byKind(LedgerEntryKind kind) =>
      values.where((c) => c.kind == kind).toList();
}

class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.kind,
    required this.amountWon,
    required this.category,
    required this.memo,
    required this.date,
  });

  final String id;
  final LedgerEntryKind kind;
  final int amountWon;
  final LedgerCategory category;
  final String memo;
  final DateTime date;

  Map<String, Object> toJson() => {
        'id': id,
        'kind': kind.name,
        'amountWon': amountWon,
        'category': category.name,
        'memo': memo,
        'date': date.toIso8601String(),
      };

  static LedgerEntry fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: json['id'] as String,
        kind: LedgerEntryKind.values.byName(json['kind'] as String),
        amountWon: json['amountWon'] as int,
        category: LedgerCategory.values.byName(json['category'] as String),
        memo: json['memo'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}

/// 가계부 기록. shared_preferences(웹=localStorage)에 저장해 새로고침에도
/// 유지된다. TODO: 백엔드 연동 시 서버 상태로 교체.
class LedgerNotifier extends Notifier<List<LedgerEntry>> {
  static const storageKey = 'ledger_entries_v1';

  @override
  List<LedgerEntry> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(storageKey);
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          LedgerEntry.fromJson(item as Map<String, dynamic>),
      ];
    } on FormatException {
      return const [];
    }
  }

  void add({
    required LedgerEntryKind kind,
    required int amountWon,
    required LedgerCategory category,
    String memo = '',
    DateTime? date,
  }) {
    final entry = LedgerEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: kind,
      amountWon: amountWon,
      category: category,
      memo: memo,
      date: date ?? DateTime.now(),
    );
    state = [...state, entry];
    _save();
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _save();
  }

  void _save() {
    ref.read(sharedPreferencesProvider).setString(
          storageKey,
          jsonEncode([for (final e in state) e.toJson()]),
        );
  }
}

final ledgerProvider =
    NotifierProvider<LedgerNotifier, List<LedgerEntry>>(LedgerNotifier.new);

/// 이번 달 항목, 날짜 내림차순.
final monthlyLedgerEntriesProvider = Provider<List<LedgerEntry>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(ledgerProvider)
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

final monthlyExpenseTotalProvider = Provider<int>((ref) => ref
    .watch(monthlyLedgerEntriesProvider)
    .where((e) => e.kind == LedgerEntryKind.expense)
    .fold(0, (sum, e) => sum + e.amountWon));

final monthlyIncomeTotalProvider = Provider<int>((ref) => ref
    .watch(monthlyLedgerEntriesProvider)
    .where((e) => e.kind == LedgerEntryKind.income)
    .fold(0, (sum, e) => sum + e.amountWon));

/// 이번 달 카테고리별 지출 합계, 금액 큰 순.
final monthlyExpenseByCategoryProvider =
    Provider<List<(LedgerCategory, int)>>((ref) {
  final totals = <LedgerCategory, int>{};
  for (final e in ref.watch(monthlyLedgerEntriesProvider)) {
    if (e.kind != LedgerEntryKind.expense) continue;
    totals[e.category] = (totals[e.category] ?? 0) + e.amountWon;
  }
  return totals.entries.map((e) => (e.key, e.value)).toList()
    ..sort((a, b) => b.$2.compareTo(a.$2));
});
