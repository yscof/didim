import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';

/// 웹 전용 홈. 모바일 홈(HomeScreen)을 그대로 띄우면 좁은 세로 화면이
/// 어색하게 떠 보여서, 넓은 화면을 활용하는 대시보드형 레이아웃을 쓴다.
/// 화면이 좁으면(모바일 브라우저) 한 열로 접힌다.
class WebHomeScreen extends ConsumerWidget {
  const WebHomeScreen({super.key});

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
            constraints: const BoxConstraints(maxWidth: 960),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final counters = [
                  _CounterCard(
                    label: '지킨 돈',
                    amount: realized,
                    onTap: () => context.push('/gains/realized'),
                  ),
                  const SizedBox(height: 12, width: 12),
                  _CounterCard(
                    label: '예약된 돈',
                    amount: reserved,
                    estimated: true,
                    onTap: () => context.push('/gains/reserved'),
                  ),
                ];

                return ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 28),
                  children: [
                    Text(
                      '나의 금융 여정',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    if (wide)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                                flex: 3, child: _WeeklyHero(challenge: weekly)),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Expanded(child: counters[0]),
                                  const SizedBox(height: 12),
                                  Expanded(child: counters[2]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _WeeklyHero(challenge: weekly),
                      const SizedBox(height: 12),
                      ...counters,
                    ],
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Text('금융 여정 지도',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/map'),
                          child: const Text('전체 지도 보기 →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (wide)
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final region in regions)
                            SizedBox(
                              // 패딩(48)과 카드 사이 간격(16)을 뺀 2열 폭.
                              width: (constraints.maxWidth - 48 - 16) / 2,
                              child: _RegionCard(region: region),
                            ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          for (final region in regions)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RegionCard(region: region),
                            ),
                        ],
                      ),
                    const SizedBox(height: 28),
                    Text('획득한 배지',
                        style: Theme.of(context).textTheme.titleMedium),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyHero extends ConsumerWidget {
  const _WeeklyHero({required this.challenge});

  final Challenge? challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = challenge;
    if (weekly == null) {
      return const Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('이번 주 챌린지를 모두 마쳤어요. 다음 주에 새 챌린지가 찾아와요.'),
        ),
      );
    }

    final regions = ref.watch(regionsProvider);
    final region = regions.firstWhere((r) => r.id == weekly.regionId);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('이번 주 추천 챌린지',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(weekly.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('약 ${weekly.estimatedMinutes}분 · ${region.name} '
              '+${weekly.progressWeight}%'),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => context.push('/challenge/${weekly.id}'),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text('이번 주 챌린지 시작하기'),
              ),
            ),
          ),
        ],
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
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(estimated ? '$label (예상)' : label,
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                won(amount),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text('내역 보기', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionCard extends ConsumerWidget {
  const _RegionCard({required this.region});

  final MapRegion region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = ref.watch(regionProgressProvider(region.id));

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/map'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                region.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                region.theme,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$percent%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
