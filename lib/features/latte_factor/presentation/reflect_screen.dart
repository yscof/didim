import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatters.dart';
import '../../../core/theme.dart';
import '../application/latte_controller.dart';
import 'widgets/challenge_stepper.dart';

/// ④ Reflect — 계산 결과를 인용한 규칙 기반 회고 + 자가 체크 + 완료.
class ReflectScreen extends ConsumerStatefulWidget {
  const ReflectScreen({super.key});

  @override
  ConsumerState<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends ConsumerState<ReflectScreen> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(latteControllerProvider);
    final controller = ref.read(latteControllerProvider.notifier);
    final input = state.input;
    final result = state.result;

    final item = input.itemName.isEmpty ? '이 소비' : input.itemName;
    final headline =
        '$item를 ${input.frequency.label} 사는 대신\n'
        '${input.years}년간 ${input.annualRatePercent.toStringAsFixed(0)}%로 굴리면\n'
        '${formatWonCompact(result.futureValue)}이 됩니다.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('회고하기'),
        leading: BackButton(onPressed: () => context.go('/act')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            const ChallengeStepper(currentStep: 3),
            const SizedBox(height: 24),

            // 규칙 기반 회고 문구
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kGrowthColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGrowthColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 12),
                  Text(
                    headline,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.45,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '그중 ${formatWonCompact(result.gain)}은 원금이 아니라 '
                    '복리로 스스로 불어난 돈이에요.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              '스스로에게 물어보기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _reflectQuestion('이 소비는 그만큼의 값어치가 있었나요?'),
            _reflectQuestion('일주일에 한 번은 줄여볼 수 있을까요?'),
            _reflectQuestion('줄인 돈을 어디에 넣어두면 좋을까요?'),
            const SizedBox(height: 20),

            CheckboxListTile(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('내 라떼 팩터를 확인하고 소비를 돌아봤어요'),
            ),
            const SizedBox(height: 12),

            if (state.completed)
              _completedBanner(context)
            else
              FilledButton(
                onPressed: _checked
                    ? () {
                        controller.complete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 챌린지 완료! 잘하셨어요.')),
                        );
                      }
                    : null,
                child: const Text('챌린지 완료'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _reflectQuestion(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('· ', style: TextStyle(fontSize: 15)),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
            ),
          ],
        ),
      );

  Widget _completedBanner(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kSeedColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Text('✅ 챌린지 완료', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text(
                '이번 주 첫 금융 행동을 실천했어요.\n다음 주엔 새로운 챌린지로 만나요!',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            ref.read(latteControllerProvider.notifier).reset();
            context.go('/engage');
          },
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          child: const Text('처음부터 다시 하기'),
        ),
      ],
    );
  }
}
