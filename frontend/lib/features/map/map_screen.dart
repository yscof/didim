import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';

/// 금융 여정 지도. MVP는 리스트형 지도, 오브젝트 연출은 후속 결정
/// (docs/09-open-questions.md).
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(regionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('금융 여정 지도'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final region in regions) _RegionCard(region: region),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('신용·부채 요새와 저축 평원은 베타에서 열려요. '
                            '먼저 완료한 챌린지는 열릴 때 진행도로 반영돼요.'),
                      ),
                    ],
                  ),
                ),
              ),
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
    final progress = ref.watch(challengeProgressProvider);
    final challenges = ref
        .watch(challengesProvider)
        .where((c) => c.regionId == region.id)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(region.name,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text('$percent%'),
              ],
            ),
            const SizedBox(height: 4),
            Text(region.theme, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            if (percent >= 100) ...[
              const SizedBox(height: 12),
              Text(region.completionMessage,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary)),
            ],
            const SizedBox(height: 8),
            for (final challenge in challenges)
              _ChallengeTile(
                challenge: challenge,
                status: progress[challenge.id] ?? ChallengeStatus.none,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeTile extends StatelessWidget {
  const _ChallengeTile({required this.challenge, required this.status});

  final Challenge challenge;
  final ChallengeStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      ChallengeStatus.executed => Icons.check_circle,
      ChallengeStatus.planned => Icons.radio_button_checked,
      ChallengeStatus.held => Icons.schedule,
      ChallengeStatus.none => Icons.radio_button_unchecked,
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(challenge.title),
      subtitle: Text(status == ChallengeStatus.none
          ? challenge.mapEffect
          : '${status.label} · ${challenge.mapEffect}'),
      onTap: () => context.go('/challenge/${challenge.id}'),
    );
  }
}
