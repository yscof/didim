import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/web_page_body.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

/// 챌린지 목록. 무신사 웹의 카테고리 메뉴바처럼 상단 탭(선택 시 굵은 글씨 +
/// 검은 밑줄)으로 카테고리를 전환한다. category가 null이면 전체를 보여준다.
class ChallengeListScreen extends ConsumerWidget {
  const ChallengeListScreen({super.key, this.category, this.showAppBar = true});

  final ChallengeCategory? category;

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesByCategoryProvider(category));
    final regions = ref.watch(regionsProvider);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('챌린지')) : null,
      body: SafeArea(
        child: Column(
          children: [
            _CategoryTabBar(selected: category),
            Expanded(
              child: WebPageBody(
                footer: !showAppBar,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // 웹처럼 넓은 화면에서는 2열 그리드로 보여준다.
                      final twoColumn = constraints.maxWidth >= 720;
                      final cards = [
                        for (final challenge in challenges)
                          _ChallengeListCard(
                            challenge: challenge,
                            regionName: regions
                                .firstWhere((r) => r.id == challenge.regionId)
                                .name,
                          ),
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${category?.label ?? '전체'} 챌린지'
                            ' ${challenges.length}개',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          if (twoColumn)
                            Wrap(
                              spacing: 12,
                              children: [
                                for (final card in cards)
                                  SizedBox(
                                    // 카드 간격(12)을 뺀 2열 폭.
                                    width: (constraints.maxWidth - 12) / 2,
                                    child: card,
                                  ),
                              ],
                            )
                          else
                            ...cards,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 무신사 스타일 카테고리 탭 바: 흰 배경, 가로 스크롤, 선택 탭은
/// 검은 굵은 글씨 + 2px 검은 밑줄, 비선택 탭은 회색.
class _CategoryTabBar extends StatelessWidget {
  const _CategoryTabBar({this.selected});

  final ChallengeCategory? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _CategoryTab(
                  label: '전체',
                  selected: selected == null,
                  onTap: () => context.go('/challenges'),
                ),
                for (final category in ChallengeCategory.values)
                  _CategoryTab(
                    label: category.label,
                    selected: selected == category,
                    onTap: () =>
                        context.go('/challenges?category=${category.name}'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.black : const Color(0xFF8E8E8E),
          ),
        ),
      ),
    );
  }
}

class _ChallengeListCard extends StatelessWidget {
  const _ChallengeListCard({
    required this.challenge,
    required this.regionName,
  });

  final Challenge challenge;
  final String regionName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        // push: 뒤로가기 시 보던 카테고리 리스트로 돌아온다 (go는 홈으로 감).
        onTap: () => context.push('/challenge/${challenge.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${challenge.type.label} · 약 ${challenge.estimatedMinutes}분'
                      ' · $regionName',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (challenge.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        challenge.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8E8E8E)),
            ],
          ),
        ),
      ),
    );
  }
}
