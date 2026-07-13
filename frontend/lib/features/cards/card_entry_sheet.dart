import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cards.dart';

/// 카드 등록 시트. 이름 → 월 실적 기준 → 발급일 → 의무 유지(선택) → 연회비(선택).
Future<void> showCardEntrySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const _CardEntryForm(),
    ),
  );
}

class _CardEntryForm extends ConsumerStatefulWidget {
  const _CardEntryForm();

  @override
  ConsumerState<_CardEntryForm> createState() => _CardEntryFormState();
}

class _CardEntryFormState extends ConsumerState<_CardEntryForm> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _holdMonthsController = TextEditingController();
  final _annualFeeController = TextEditingController();
  var _issuedAt = DateTime.now();

  int get _target => int.tryParse(_targetController.text) ?? 0;

  int? _optionalInt(TextEditingController controller) {
    final value = int.tryParse(controller.text);
    return (value == null || value <= 0) ? null : value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _holdMonthsController.dispose();
    _annualFeeController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(cardsProvider.notifier).add(
          name: _nameController.text.trim(),
          monthlyTargetWon: _target,
          issuedAt: _issuedAt,
          minHoldMonths: _optionalInt(_holdMonthsController),
          annualFeeWon: _optionalInt(_annualFeeController),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty && _target > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('카드 추가', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            key: const Key('card-name-input'),
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '카드 이름',
              hintText: '예: 통신비 할인 카드',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('card-target-input'),
            controller: _targetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '월 실적 기준액',
              hintText: '혜택 조건이 되는 금액',
              suffixText: '원',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('발급일: ${_issuedAt.year}년 ${_issuedAt.month}월 ${_issuedAt.day}일'),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _issuedAt,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _issuedAt = picked);
                },
                child: const Text('변경'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('card-hold-months-input'),
            controller: _holdMonthsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '의무 유지 개월 (선택)',
              hintText: '가입 혜택 조건에 있다면 입력. 예: 6',
              suffixText: '개월',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('card-annual-fee-input'),
            controller: _annualFeeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '연회비 (선택)',
              suffixText: '원',
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
