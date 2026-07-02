import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/challenge_stepper.dart';

/// ① Engage — 챌린지를 소개하고 도전을 수락하게 한다.
class EngageScreen extends StatelessWidget {
  const EngageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('이번 주 챌린지')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const ChallengeStepper(currentStep: 0),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '☕ 소비 습관 · 약 5분',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '나의 라떼 팩터\n찾아보기',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.25),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '매일 무심코 쓰는 작은 돈, 라떼 한 잔.\n'
                      '그 돈을 아껴서 투자했다면 얼마가 됐을까요?\n\n'
                      '이번 챌린지에서 내 습관적 소비의 '
                      '진짜 기회비용을 눈으로 확인해봐요.',
                      style: TextStyle(fontSize: 16, height: 1.6, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => context.go('/investigate'),
                child: const Text('도전하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
