import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ledger.dart' show sharedPreferencesProvider;

/// 카드 재테크 관리. 카드별 실적 기준 대비 이번 달 사용액, 해지 가능 시점,
/// 연회비 일정을 자가 입력으로 관리한다 (docs/08 도구 레이어).
/// 실적 산정 기준(전월/당월, 제외 항목)은 카드사마다 달라 화면에 고지한다.

class CardEntry {
  const CardEntry({
    required this.id,
    required this.name,
    required this.monthlyTargetWon,
    required this.issuedAt,
    this.minHoldMonths,
    this.annualFeeWon,
    this.spentWon = 0,
    this.spentYearMonth = '',
  });

  final String id;
  final String name;

  /// 혜택 조건이 되는 월 실적 기준액.
  final int monthlyTargetWon;

  final DateTime issuedAt;

  /// 가입 혜택 환수 방지 등으로 유지해야 하는 개월 수. 모르면 null.
  final int? minHoldMonths;

  final int? annualFeeWon;

  /// 사용자가 마지막으로 입력한 이번 달 사용액과 그 기준 월('yyyy-MM').
  /// 달이 바뀌면 0으로 취급한다.
  final int spentWon;
  final String spentYearMonth;

  static String yearMonthOf(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// 이번 달 기준 사용액. 입력한 달이 지났으면 0.
  int effectiveSpentWon(DateTime now) =>
      spentYearMonth == yearMonthOf(now) ? spentWon : 0;

  /// 실적 달성까지 남은 금액.
  int remainingWon(DateTime now) {
    final remaining = monthlyTargetWon - effectiveSpentWon(now);
    return remaining > 0 ? remaining : 0;
  }

  /// 해지 가능일 (발급일 + 의무 유지 개월). 의무 유지 미입력이면 null.
  DateTime? get cancellableOn {
    final months = minHoldMonths;
    if (months == null) return null;
    return DateTime(issuedAt.year, issuedAt.month + months, issuedAt.day);
  }

  /// 다음 연회비 청구 예상일 (발급일 기준 매년). 연회비 미입력이면 null.
  DateTime? nextAnnualFeeDate(DateTime now) {
    if (annualFeeWon == null) return null;
    var next = DateTime(now.year, issuedAt.month, issuedAt.day);
    if (!next.isAfter(now)) {
      next = DateTime(now.year + 1, issuedAt.month, issuedAt.day);
    }
    return next;
  }

  CardEntry copyWith({int? spentWon, String? spentYearMonth}) => CardEntry(
        id: id,
        name: name,
        monthlyTargetWon: monthlyTargetWon,
        issuedAt: issuedAt,
        minHoldMonths: minHoldMonths,
        annualFeeWon: annualFeeWon,
        spentWon: spentWon ?? this.spentWon,
        spentYearMonth: spentYearMonth ?? this.spentYearMonth,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'monthlyTargetWon': monthlyTargetWon,
        'issuedAt': issuedAt.toIso8601String(),
        'minHoldMonths': minHoldMonths,
        'annualFeeWon': annualFeeWon,
        'spentWon': spentWon,
        'spentYearMonth': spentYearMonth,
      };

  static CardEntry fromJson(Map<String, dynamic> json) => CardEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        monthlyTargetWon: json['monthlyTargetWon'] as int,
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        minHoldMonths: json['minHoldMonths'] as int?,
        annualFeeWon: json['annualFeeWon'] as int?,
        spentWon: json['spentWon'] as int? ?? 0,
        spentYearMonth: json['spentYearMonth'] as String? ?? '',
      );
}

/// 카드 목록. shared_preferences(웹=localStorage)에 저장한다.
/// TODO: 백엔드 연동 시 서버 상태로 교체.
class CardsNotifier extends Notifier<List<CardEntry>> {
  static const storageKey = 'cards_v1';

  @override
  List<CardEntry> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(storageKey);
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          CardEntry.fromJson(item as Map<String, dynamic>),
      ];
    } on FormatException {
      return const [];
    }
  }

  void add({
    required String name,
    required int monthlyTargetWon,
    required DateTime issuedAt,
    int? minHoldMonths,
    int? annualFeeWon,
  }) {
    state = [
      ...state,
      CardEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        monthlyTargetWon: monthlyTargetWon,
        issuedAt: issuedAt,
        minHoldMonths: minHoldMonths,
        annualFeeWon: annualFeeWon,
      ),
    ];
    _save();
  }

  void remove(String id) {
    state = state.where((c) => c.id != id).toList();
    _save();
  }

  /// 이번 달 사용액을 갱신한다 (누적이 아니라 현재까지 총액 입력).
  void updateSpent(String id, int spentWon, {DateTime? now}) {
    final month = CardEntry.yearMonthOf(now ?? DateTime.now());
    state = [
      for (final card in state)
        if (card.id == id)
          card.copyWith(spentWon: spentWon, spentYearMonth: month)
        else
          card,
    ];
    _save();
  }

  void _save() {
    ref.read(sharedPreferencesProvider).setString(
          storageKey,
          jsonEncode([for (final c in state) c.toJson()]),
        );
  }
}

final cardsProvider =
    NotifierProvider<CardsNotifier, List<CardEntry>>(CardsNotifier.new);
