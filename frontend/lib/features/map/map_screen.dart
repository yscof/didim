import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/web_page_body.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import 'region_scene.dart';

/// 금융 여정 지도. 지역별 마일스톤 이모지 장면(RegionScene)으로 진행을
/// 시각화한다. 일러스트·애니메이션 연출 수준은 후속 결정
/// (docs/09-open-questions.md).
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(regionsProvider);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('금융 여정 지도')) : null,
      body: WebPageBody(
        maxWidth: 720,
        footer: !showAppBar,
        padding: showAppBar ? const EdgeInsets.all(20) : null,
        children: [
          // 웹은 AppBar가 없으므로 페이지 제목을 본문 상단에 보여준다.
          if (!showAppBar) ...[
            Text('금융 여정 지도',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
          ],
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
    );
  }
}

class _RegionCard extends ConsumerWidget {
  const _RegionCard({required this.region});

  final MapRegion region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = ref.watch(regionProgressProvider(region.id));
    final completions = ref.watch(challengeCompletionProvider);
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
            const SizedBox(height: 10),
            RegionScene(regionId: region.id, percent: percent),
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
                status: completions[challenge.id]?.status ??
                    ChallengeStatus.none,
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
      // push라서 챌린지에서 뒤로가기하면 지도로 돌아온다.
      onTap: () => context.push('/challenge/${challenge.id}'),
    );
  }
}
