import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';

/// 완료 리액션 5단계: 완료 인정 → 금융 효과 → 지도 변화 → 배지 → 다음 챌린지
/// (docs/16-gamification.md 3장). MVP는 한 화면에 순서대로 배치한다.
/// TODO: 5~8초 애니메이션 연출은 지도 연출 수준 결정 후 추가.
class CompletionReactionScreen extends ConsumerWidget {
  const CompletionReactionScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(challengeByIdProvider(challengeId));
    if (challenge == null) {
      return const Scaffold(body: Center(child: Text('챌린지를 찾을 수 없어요.')));
    }

    final status = ref.watch(challengeProgressProvider)[challengeId] ??
        ChallengeStatus.none;
    final regions = ref.watch(regionsProvider);
    final region = regions.firstWhere((r) => r.id == challenge.regionId);
    final percent = ref.watch(regionProgressProvider(region.id));
    final badges = ref.watch(earnedBadgesProvider);
    final next = challenge.nextChallengeId == null
        ? null
        : ref.watch(challengeByIdProvider(challenge.nextChallengeId!));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 24),
                Icon(Icons.check_circle,
                    size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  '${challenge.title} ${status.label}!',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('금융 효과',
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(challenge.impactPreview),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('지도 변화',
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text('${region.name} $percent% · ${challenge.mapEffect}'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('배지',
                              style: Theme.of(context).textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final badge in badges)
                                Chip(
                                  avatar:
                                      const Icon(Icons.emoji_events, size: 18),
                                  label: Text(badge.name),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (next != null) ...[
                  Text('다음 추천 챌린지',
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text('${next.title} · 약 ${next.estimatedMinutes}분'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/challenge/${next.id}'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('다음 챌린지 확인'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton(
                  onPressed: () => context.go('/map'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('지도 구경하기'),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('홈으로'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
