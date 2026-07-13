import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/web_page_body.dart';
import '../../data/cards.dart';
import '../../data/models.dart';
import 'card_entry_sheet.dart';

String _monthDay(DateTime date) => '${date.month}월 ${date.day}일';

/// 카드 재테크. 카드별 이번 달 실적 현황(얼마 썼고 얼마 더 써야 하는지)과
/// 해지 가능 시점, 연회비 일정을 관리한다.
class CardScreen extends ConsumerWidget {
  const CardScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider);
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysLeft = endOfMonth.day - now.day;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('카드 재테크')) : null,
      // FAB는 모바일 패턴이라 웹에서는 제목 옆 버튼으로 대체한다.
      floatingActionButton: showAppBar
          ? FloatingActionButton.extended(
              onPressed: () => showCardEntrySheet(context),
              icon: const Icon(Icons.add_card),
              label: const Text('카드 추가'),
            )
          : null,
      body: SafeArea(
        child: WebPageBody(
          footer: !showAppBar,
          padding: showAppBar
              ? const EdgeInsets.fromLTRB(20, 20, 20, 88)
              : null,
          children: [
                if (showAppBar)
                  Text('카드 재테크',
                      style: Theme.of(context).textTheme.headlineSmall)
                else
                  Row(
                    children: [
                      Expanded(
                        child: Text('카드 재테크',
                            style:
                                Theme.of(context).textTheme.headlineSmall),
                      ),
                      FilledButton.icon(
                        onPressed: () => showCardEntrySheet(context),
                        icon: const Icon(Icons.add_card, size: 18),
                        label: const Text('카드 추가'),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                    '실적 기준을 채우면 혜택, 조건을 다 챙겼으면 해지 시점까지. '
                    '이번 달 실적 마감까지 D-$daysLeft이에요.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                if (cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                          showAppBar
                              ? '아직 등록한 카드가 없어요.\n오른쪽 아래 버튼으로 관리할 카드를 등록해보세요.'
                              : '아직 등록한 카드가 없어요.\n위의 카드 추가 버튼으로 관리할 카드를 등록해보세요.',
                          textAlign: TextAlign.center),
                    ),
                  )
                else
                  for (final card in cards) _CardStatusCard(card: card),
                const SizedBox(height: 8),
                Text('실적 산정 기준(전월/당월 기준, 제외 항목)은 카드사마다 달라요. '
                    '정확한 조건은 카드사 앱에서 확인하세요.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('연말정산까지 함께 챙기기',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text('카드 소득공제는 총급여의 25%를 넘게 쓴 금액부터 시작돼요. '
                            '내 25% 라인을 알면 신용카드와 체크카드를 언제 나눠 쓸지 전략이 생겨요.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () =>
                              context.push('/challenge/tax-card-25-line'),
                          child: const Text('카드 25% 라인 계산 챌린지 하러 가기'),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _CardStatusCard extends ConsumerWidget {
  const _CardStatusCard({required this.card});

  final CardEntry card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final spent = card.effectiveSpentWon(now);
    final remaining = card.remainingWon(now);
    final achieved = remaining == 0;
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysLeft = endOfMonth.day - now.day;
    final cancellable = card.cancellableOn;
    final feeDate = card.nextAnnualFeeDate(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(card.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  tooltip: '삭제',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () =>
                      ref.read(cardsProvider.notifier).remove(card.id),
                ),
              ],
            ),
            Text('이번 달 ${won(spent)} / 기준 ${won(card.monthlyTargetWon)}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: card.monthlyTargetWon == 0
                  ? 0
                  : (spent / card.monthlyTargetWon).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              achieved
                  ? '이번 달 실적 달성! 혜택 조건을 채웠어요.'
                  : '앞으로 ${won(remaining)} 더 쓰면 실적 달성이에요 (월말까지 D-$daysLeft).',
              style: TextStyle(
                color: achieved ? Theme.of(context).colorScheme.primary : null,
                fontWeight: achieved ? FontWeight.w700 : null,
              ),
            ),
            if (cancellable != null) ...[
              const SizedBox(height: 4),
              Text(
                now.isBefore(cancellable)
                    ? '해지 가능일까지 D-${cancellable.difference(now).inDays + 1} (${_monthDay(cancellable)})'
                    : '해지 가능 시점이 지났어요. 혜택과 연회비를 비교해 유지 여부를 정하세요.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (feeDate != null) ...[
              const SizedBox(height: 4),
              Text(
                '다음 연회비 ${_monthDay(feeDate)} 예상 · ${won(card.annualFeeWon!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _showSpentDialog(context, ref),
              child: const Text('이번 달 사용액 입력'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSpentDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${card.name} 이번 달 사용액'),
        content: TextField(
          key: const Key('card-spent-input'),
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: '지금까지 쓴 금액 (누적)',
            suffixText: '원',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(controller.text) ?? 0;
              ref.read(cardsProvider.notifier).updateSpent(card.id, amount);
              Navigator.of(context).pop();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
