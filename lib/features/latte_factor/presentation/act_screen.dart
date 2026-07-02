import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatters.dart';
import '../../../core/theme.dart';
import '../application/latte_controller.dart';
import '../domain/latte_input.dart';
import 'widgets/challenge_stepper.dart';
import 'widgets/comparison_chart.dart';
import 'widgets/stat_tile.dart';

/// ③ Act — 습관적 소비를 입력하고 30년 복리 기회비용을 실시간 계산한다.
class ActScreen extends ConsumerStatefulWidget {
  const ActScreen({super.key});

  @override
  ConsumerState<ActScreen> createState() => _ActScreenState();
}

class _ActScreenState extends ConsumerState<ActScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;

  static const _rates = [3.0, 5.0, 7.0, 10.0];

  @override
  void initState() {
    super.initState();
    final input = ref.read(latteControllerProvider).input;
    _nameCtrl = TextEditingController(text: input.itemName);
    _amountCtrl = TextEditingController(
      text: input.amountPerOccurrence.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(latteControllerProvider.notifier);
    final state = ref.watch(latteControllerProvider);
    final input = state.input;
    final result = state.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 라떼 팩터'),
        leading: BackButton(onPressed: () => context.go('/investigate')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            const ChallengeStepper(currentStep: 2),
            const SizedBox(height: 24),

            // ── 입력 영역 ──────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('무엇에 쓰나요?'),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: '예: 아메리카노',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: controller.setItemName,
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('한 번에 얼마인가요? (원)'),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '예: 4500',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) =>
                          controller.setAmount(double.tryParse(v) ?? 0),
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('얼마나 자주?'),
                    SegmentedButton<Frequency>(
                      segments: Frequency.values
                          .map((f) => ButtonSegment(
                                value: f,
                                label: Text(f.label),
                              ))
                          .toList(),
                      selected: {input.frequency},
                      onSelectionChanged: (s) =>
                          controller.setFrequency(s.first),
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('기간: ${input.years}년'),
                    Slider(
                      value: input.years.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: '${input.years}년',
                      onChanged: (v) => controller.setYears(v.round()),
                    ),
                    _fieldLabel('연 수익률: ${input.annualRatePercent.toStringAsFixed(0)}%'),
                    Wrap(
                      spacing: 8,
                      children: _rates.map((r) {
                        return ChoiceChip(
                          label: Text('${r.toStringAsFixed(0)}%'),
                          selected: input.annualRatePercent == r,
                          onSelected: (_) => controller.setRate(r),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 결과 영역 ──────────────────────────────
            Text(
              '${input.itemName.isEmpty ? '이 소비' : input.itemName}를 '
              '${input.frequency.label} 사면,\n'
              '${input.years}년간 월 ${formatWon(result.monthlyContribution)} 꼴이에요.',
              style: const TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            StatTile(
              label: '이 돈을 그냥 썼다면 (원금)',
              value: formatWon(result.principal),
              accentColor: kPrincipalColor,
            ),
            const SizedBox(height: 12),
            StatTile(
              label: '${input.annualRatePercent.toStringAsFixed(0)}%로 ${input.years}년 굴렸다면',
              value: formatWon(result.futureValue),
              caption: '복리 수익 +${formatWon(result.gain)}',
              accentColor: kGrowthColor,
              emphasize: true,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: ComparisonChart(
                  principal: result.principal,
                  futureValue: result.futureValue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/reflect'),
              child: const Text('회고하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      );
}
