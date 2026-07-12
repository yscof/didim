import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_state.dart';
import '../../data/mock_challenges.dart';
import '../../data/models.dart';

/// 주간 스트릭 카드. 압박이 아니라 복귀를 돕는 문구만 쓴다
/// (docs/16-gamification.md 6장: 끊겨도 초기화하지 않는다).
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(weeklyStreakProvider);

    final String title;
    final String message;
    if (streak.thisWeekKept) {
      title = '🔥 ${streak.totalWeeks}주 연속 금융 루틴';
      message = streak.thisWeekHeldOnly
          ? '이번 주는 성실한 보류로 리듬을 지켰어요.'
          : '이번 주 루틴을 지켰어요. 다음 주에도 이어가요.';
    } else if (streak.pastWeeks > 0) {
      title = '🔥 ${streak.pastWeeks}주 연속 금융 루틴';
      message = '이번 주 챌린지를 완료하면 ${streak.pastWeeks + 1}주 연속이 돼요.';
    } else {
      title = '금융 루틴 시작하기';
      message = '이번 주 챌린지를 완료하면 여정을 다시 이어갈 수 있어요.';
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(message, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final entry in mockStreakHistory) ...[
                  _WeekDot(
                    label: entry.weekLabel,
                    emoji: switch (entry.status) {
                      WeeklyStreakStatus.completed => '✅',
                      WeeklyStreakStatus.heldKept => '⏳',
                      WeeklyStreakStatus.missed => '💤',
                    },
                  ),
                  const SizedBox(width: 14),
                ],
                _WeekDot(
                  label: '이번 주',
                  emoji: !streak.thisWeekKept
                      ? '🎯'
                      : streak.thisWeekHeldOnly
                          ? '⏳'
                          : '✅',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.label, required this.emoji});

  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
