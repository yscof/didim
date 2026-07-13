import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/subscriptions.dart';

/// 구독 등록 시트. 이름(프리셋 칩 지원) → 월 요금 → 결제일(선택).
Future<void> showSubscriptionEntrySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const _SubscriptionEntryForm(),
    ),
  );
}

class _SubscriptionEntryForm extends ConsumerStatefulWidget {
  const _SubscriptionEntryForm();

  @override
  ConsumerState<_SubscriptionEntryForm> createState() =>
      _SubscriptionEntryFormState();
}

class _SubscriptionEntryFormState
    extends ConsumerState<_SubscriptionEntryForm> {
  final _nameController = TextEditingController();
  final _feeController = TextEditingController();
  final _dayController = TextEditingController();

  int get _fee => int.tryParse(_feeController.text) ?? 0;

  int? get _billingDay {
    final day = int.tryParse(_dayController.text);
    if (day == null || day < 1 || day > 31) return null;
    return day;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _feeController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(subscriptionsProvider.notifier).add(
          name: _nameController.text.trim(),
          monthlyFeeWon: _fee,
          billingDay: _billingDay,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty && _fee > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('구독 추가', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            key: const Key('subscription-name-input'),
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '서비스 이름',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          // 입력 편의용 프리셋. 요금은 직접 입력한다 (추천·가입 유도 아님).
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final preset in subscriptionNamePresets)
                ActionChip(
                  label: Text(preset),
                  onPressed: () =>
                      setState(() => _nameController.text = preset),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('subscription-fee-input'),
            controller: _feeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '월 요금',
              suffixText: '원',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('subscription-day-input'),
            controller: _dayController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '매월 결제일 (선택)',
              hintText: '예: 15',
              suffixText: '일',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
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
