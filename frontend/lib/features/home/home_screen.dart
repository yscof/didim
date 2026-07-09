import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';

/// 홈 화면. docs/16-gamification.md 5장: 핵심 버튼은 항상 하나다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(weeklyChallengeProvider);
    final regions = ref.watch(regionsProvider);
    final realized = ref.watch(realizedWonProvider);
    final reserved = ref.watch(reservedWonProvider);
    final badges = ref.watch(earnedBadgesProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('나의 금융 여정',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                if (weekly != null) _WeeklyChallengeCard(challenge: weekly),
                if (weekly == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('이번 주 챌린지를 모두 마쳤어요. 다음 주에 새 챌린지가 찾아와요.'),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _CounterCard(
                        label: '지킨 돈',
                        amount: realized,
                        onTap: () => context.go('/gains/realized'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CounterCard(
                        label: '예약된 돈',
                        amount: reserved,
                        estimated: true,
                        onTap: () => context.go('/gains/reserved'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('금융 여정 지도', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: InkWell(
                    onTap: () => context.go('/map'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final region in regions)
                            _RegionProgressRow(region: region),
                          const SizedBox(height: 4),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text('전체 지도 보기 →'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('획득한 배지', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (badges.isEmpty)
                  const Text('첫 챌린지를 완료하면 첫 배지를 받아요.')
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final badge in badges)
                        Chip(
                          avatar: const Icon(Icons.emoji_events, size: 18),
                          label: Text(badge.name),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyChallengeCard extends ConsumerWidget {
  const _WeeklyChallengeCard({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(regionsProvider);
    final region = regions.firstWhere((r) => r.id == challenge.regionId);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이번 주 추천 챌린지',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Text(challenge.title,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
                '약 ${challenge.estimatedMinutes}분 · ${region.name} +${challenge.progressWeight}%'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/challenge/${challenge.id}'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('이번 주 챌린지 시작하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.label,
    required this.amount,
    required this.onTap,
    this.estimated = false,
  });

  final String label;
  final int amount;
  final VoidCallback onTap;
  final bool estimated;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(estimated ? '$label (예상)' : label,
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(won(amount),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text('내역 보기', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionProgressRow extends ConsumerWidget {
  const _RegionProgressRow({required this.region});

  final MapRegion region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = ref.watch(regionProgressProvider(region.id));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(region.name)),
          Expanded(
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text('$percent%', textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
