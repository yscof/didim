import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';

/// 챌린지 상세. S2 템플릿의 훅 → 스텝 체크리스트 → 완료 확인
/// (docs/15-challenge-scenarios.md).
class ChallengeDetailScreen extends ConsumerStatefulWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  final _checkedSteps = <int>{};

  void _complete(ChallengeStatus status) {
    ref
        .read(challengeProgressProvider.notifier)
        .setStatus(widget.challengeId, status);
    if (status == ChallengeStatus.held) {
      // TODO: 보류 사유 선택과 재시도 예약 (holdReasonOptions)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보류했어요. 다음 주에 다시 이어갈 수 있어요.')),
      );
      context.pop();
    } else {
      context.go('/challenge/${widget.challengeId}/reaction');
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = ref.watch(challengeByIdProvider(widget.challengeId));
    if (challenge == null) {
      return const Scaffold(body: Center(child: Text('챌린지를 찾을 수 없어요.')));
    }

    return Scaffold(
      // 뒤로가기는 기본 pop을 쓴다. 중첩 라우트라 딥링크로 진입해도
      // 상위 스택(홈)이 함께 만들어져 항상 pop이 가능하다.
      appBar: AppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(challenge.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              if (challenge.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(challenge.subtitle!),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('약 ${challenge.estimatedMinutes}분')),
                  Chip(label: Text(challenge.type.label)),
                  Chip(label: Text('확보효과: ${challenge.gainLabel.label}')),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('코치', style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(challenge.coachHook),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('왜 필요한가요?',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(challenge.whyContent),
              const SizedBox(height: 16),
              Text('이렇게 하면 돼요',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final (index, step) in challenge.steps.indexed)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedSteps.contains(index),
                  onChanged: (checked) => setState(() {
                    checked == true
                        ? _checkedSteps.add(index)
                        : _checkedSteps.remove(index);
                  }),
                  title: Text(step),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _complete(ChallengeStatus.executed),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('실행까지 했어요'),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _complete(ChallengeStatus.planned),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('계획까지 세웠어요'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _complete(ChallengeStatus.held),
                child: const Text('이번 주는 보류할게요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
