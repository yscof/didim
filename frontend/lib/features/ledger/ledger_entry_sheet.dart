import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ledger.dart';

/// 가계부 기록 입력 시트. 지출/수입 토글 → 금액 → 카테고리 → 메모(선택) → 날짜.
Future<void> showLedgerEntrySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const _LedgerEntryForm(),
    ),
  );
}

class _LedgerEntryForm extends ConsumerStatefulWidget {
  const _LedgerEntryForm();

  @override
  ConsumerState<_LedgerEntryForm> createState() => _LedgerEntryFormState();
}

class _LedgerEntryFormState extends ConsumerState<_LedgerEntryForm> {
  var _kind = LedgerEntryKind.expense;
  LedgerCategory? _category = LedgerCategory.food;
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  var _date = DateTime.now();

  int get _amount => int.tryParse(_amountController.text) ?? 0;

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(ledgerProvider.notifier).add(
          kind: _kind,
          amountWon: _amount,
          category: _category!,
          memo: _memoController.text.trim(),
          date: _date,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = LedgerCategory.byKind(_kind);
    final canSave = _amount > 0 && _category != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('기록하기', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SegmentedButton<LedgerEntryKind>(
            segments: [
              for (final kind in LedgerEntryKind.values)
                ButtonSegment(value: kind, label: Text(kind.label)),
            ],
            selected: {_kind},
            onSelectionChanged: (selection) => setState(() {
              _kind = selection.first;
              _category = LedgerCategory.byKind(_kind).first;
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('ledger-amount-input'),
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '금액',
              suffixText: '원',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final category in categories)
                ChoiceChip(
                  avatar: Icon(category.icon, size: 16),
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('ledger-memo-input'),
            controller: _memoController,
            decoration: const InputDecoration(
              labelText: '메모 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('날짜: ${_date.month}월 ${_date.day}일'),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: const Text('변경'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canSave ? _save : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('저장'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
