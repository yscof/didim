import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models.dart';
import '../../data/subscriptions.dart';
import 'subscription_entry_sheet.dart';

/// 디지털 월세(구독료) 관리. 현황 → 줄일 수 있는 혜택 → 줄이는 방법 순서로
/// 보여준다.
class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final monthly = ref.watch(digitalRentMonthlyProvider);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('디지털 월세')) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSubscriptionEntrySheet(context),
        icon: const Icon(Icons.add),
        label: const Text('구독 추가'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
              children: [
                Text('디지털 월세',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('매달 나가는 구독료는 또 하나의 월세예요. 현황을 보고, 줄일 수 있는 만큼 줄여봐요.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                _SummaryCard(
                    monthly: monthly, count: subscriptions.length),
                const SizedBox(height: 20),
                Text('내 구독', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (subscriptions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('아직 등록한 구독이 없어요.\n오른쪽 아래 버튼으로 쓰고 있는 구독을 등록해보세요.',
                          textAlign: TextAlign.center),
                    ),
                  )
                else
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final subscription in subscriptions)
                          _SubscriptionTile(subscription: subscription),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Text('줄일 수 있는 혜택',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('조건은 서비스마다 달라요. 최종 조건은 각 서비스의 공식 안내에서 확인하세요.',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                for (final tip in subscriptionTips)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(tip.description),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('줄이는 방법',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        const Text('가장 확실한 방법은 안 쓰는 구독을 끊는 거예요. '
                            '10분 전수조사 챌린지로 잊고 있던 구독까지 찾아서 정리해보세요. '
                            '해지한 만큼이 그대로 연 환산 절감액이 돼요.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context
                              .push('/challenge/mvp-subscription-audit-cancel-one'),
                          child: const Text('구독 전수조사 챌린지 하러 가기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.monthly, required this.count});

  final int monthly;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이번 달 디지털 월세',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(won(monthly),
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('구독 $count개 · 연 환산 ${won(monthly * 12)}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionTile extends ConsumerWidget {
  const _SubscriptionTile({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 18,
        child: Icon(Icons.subscriptions, size: 18),
      ),
      title: Text(subscription.name),
      subtitle: Text(subscription.billingDay == null
          ? '결제일 미입력'
          : '매월 ${subscription.billingDay}일 결제'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('월 ${won(subscription.monthlyFeeWon)}',
              style: Theme.of(context).textTheme.titleSmall),
          IconButton(
            tooltip: '삭제',
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => ref
                .read(subscriptionsProvider.notifier)
                .remove(subscription.id),
          ),
        ],
      ),
    );
  }
}
