import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/web_page_body.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

/// 확보효과 상세 내역. 어떤 챌린지로 얼마가 쌓였는지 보여준다.
/// track: 'realized'(지킨 돈) | 'reserved'(예약된 돈).
class GainDetailScreen extends ConsumerWidget {
  const GainDetailScreen({super.key, required this.track});

  final String track;

  bool get _isRealized => track == 'realized';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(gainEntriesProvider(track));
    // 금액 출처는 완료 시 실측 입력으로 계산된 completion.impactWon이다.
    final completions = ref.watch(challengeCompletionProvider);
    final total =
        entries.fold(0, (sum, c) => sum + completions[c.id]!.impactWon);

    return Scaffold(
      appBar: AppBar(title: Text(_isRealized ? '지킨 돈' : '예약된 돈')),
      body: WebPageBody(
        maxWidth: 520,
        padding: const EdgeInsets.all(20),
        children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_isRealized ? '지금까지 지킨 돈' : '지금까지 예약된 돈 (예상)',
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(won(total),
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        _isRealized
                            ? '실제로 아끼고 모은 금액만 더한 숫자예요.'
                            : '응답 기반 추정·연 환산 금액이라 실제와 다를 수 있어요.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _isRealized
                        ? '아직 내역이 없어요. 무지출 데이 같은 습관 챌린지를 실행하면 여기에 쌓여요.'
                        : '아직 내역이 없어요. 챌린지를 실행 완료하면 여기에 쌓여요.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                for (final challenge in entries)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(challenge.title),
                      subtitle: Text(
                          '${challenge.gainLabel.label} · ${challenge.impactInput?.formulaNote ?? '내 입력값 기반 계산'}'),
                      trailing: Text(
                        '+${won(completions[challenge.id]!.impactWon)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}
