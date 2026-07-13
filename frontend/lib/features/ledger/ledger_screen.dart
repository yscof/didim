import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/web_footer.dart';
import '../../data/ledger.dart';
import '../../data/models.dart';
import 'ledger_entry_sheet.dart';

/// 가계부. 이번 달 요약 + 카테고리별 지출 + 내역 리스트.
/// 기록 강제형이 아니라 챌린지 실측 입력을 뒷받침하는 가벼운 도구다.
class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(monthlyLedgerEntriesProvider);
    final expense = ref.watch(monthlyExpenseTotalProvider);
    final income = ref.watch(monthlyIncomeTotalProvider);
    final byCategory = ref.watch(monthlyExpenseByCategoryProvider);
    final month = DateTime.now().month;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('가계부')) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showLedgerEntrySheet(context),
        icon: const Icon(Icons.edit),
        label: const Text('기록하기'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
              children: [
                Text('$month월 가계부',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('직접 기록하는 가벼운 가계부예요. 무지출 데이 같은 챌린지의 실측 기록과 함께 쌓여요.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                _MonthSummaryCard(expense: expense, income: income),
                if (byCategory.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('카테고리별 지출',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final (category, amount) in byCategory.take(5))
                            _CategoryBar(
                              category: category,
                              amount: amount,
                              maxAmount: byCategory.first.$2,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text('내역', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('아직 기록이 없어요.\n오른쪽 아래 버튼으로 첫 지출이나 수입을 기록해보세요.',
                          textAlign: TextAlign.center),
                    ),
                  )
                else
                  for (final group in _groupByDay(entries)) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        '${group.first.date.month}월 ${group.first.date.day}일',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final entry in group) _EntryTile(entry: entry),
                        ],
                      ),
                    ),
                  ],
                if (!showAppBar) const WebFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 날짜(일) 단위 그룹. entries는 이미 날짜 내림차순.
  List<List<LedgerEntry>> _groupByDay(List<LedgerEntry> entries) {
    final groups = <List<LedgerEntry>>[];
    for (final entry in entries) {
      final last = groups.isEmpty ? null : groups.last.first;
      if (last != null &&
          last.date.year == entry.date.year &&
          last.date.month == entry.date.month &&
          last.date.day == entry.date.day) {
        groups.last.add(entry);
      } else {
        groups.add([entry]);
      }
    }
    return groups;
  }
}

class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({required this.expense, required this.income});

  final int expense;
  final int income;

  @override
  Widget build(BuildContext context) {
    final remaining = income - expense;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(child: _SummaryItem(label: '지출', amount: expense)),
            Expanded(child: _SummaryItem(label: '수입', amount: income)),
            Expanded(
              child: _SummaryItem(
                label: '남은 돈',
                amount: remaining,
                emphasize: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.amount,
    this.emphasize = false,
  });

  final String label;
  final int amount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          won(amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: emphasize ? FontWeight.w700 : null,
                color: amount < 0
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
        ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.maxAmount,
  });

  final LedgerCategory category;
  final int amount;
  final int maxAmount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(category.icon, size: 18),
          const SizedBox(width: 8),
          SizedBox(width: 90, child: Text(category.label)),
          Expanded(
            child: LinearProgressIndicator(
              value: maxAmount == 0 ? 0 : amount / maxAmount,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(won(amount)),
        ],
      ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = entry.kind == LedgerEntryKind.expense;
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        child: Icon(entry.category.icon, size: 18),
      ),
      title: Text(entry.memo.isEmpty ? entry.category.label : entry.memo),
      subtitle: Text(entry.category.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${isExpense ? '−' : '+'}${won(entry.amountWon)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isExpense
                      ? null
                      : Theme.of(context).colorScheme.primary,
                ),
          ),
          IconButton(
            tooltip: '삭제',
            icon: const Icon(Icons.close, size: 18),
            onPressed: () =>
                ref.read(ledgerProvider.notifier).remove(entry.id),
          ),
        ],
      ),
    );
  }
}
