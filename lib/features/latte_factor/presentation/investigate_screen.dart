import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/challenge_stepper.dart';

/// ② Investigate — 라떼 팩터와 복리 개념을 짧게 학습한다.
class InvestigateScreen extends StatelessWidget {
  const InvestigateScreen({super.key});

  static const _cards = [
    (
      icon: '☕',
      title: '라떼 팩터란?',
      body: '매일 쓰는 작은 돈이 쌓여 만드는 큰 지출을 뜻해요. '
          '하루 커피 한 잔 값도 1년, 10년이 모이면 무시할 수 없는 금액이 됩니다.',
    ),
    (
      icon: '📈',
      title: '복리의 힘',
      body: '아낀 돈을 투자하면 원금에 이자가 붙고, 그 이자에 다시 이자가 붙어요. '
          '시간이 길어질수록 눈덩이처럼 불어나는 것이 복리입니다.',
    ),
    (
      icon: '🎯',
      title: '기회비용 인식하기',
      body: '"이 소비를 안 했다면?"을 숫자로 보면 선택이 달라져요. '
          '무조건 아끼자는 게 아니라, 내 소비의 값어치를 알고 결정하자는 거예요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('잠깐, 알아두기'),
        leading: BackButton(onPressed: () => context.go('/engage')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const ChallengeStepper(currentStep: 1),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _cards.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final card = _cards[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card.icon, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    card.body,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.55,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/act'),
                child: const Text('내 라떼 팩터 계산하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
