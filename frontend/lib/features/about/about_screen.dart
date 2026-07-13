import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/web_page_body.dart';

/// 서비스 소개 (간략). 상세 설명은 완료 검증·보상 시스템 하위 페이지로.
/// 원고 출처: docs/17-service-overview.md
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.showAppBar = true});

  /// 웹 셸(상단 메뉴바) 안에서 열릴 때는 자체 AppBar를 숨긴다.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('서비스 소개')) : null,
      body: SafeArea(
        child: WebPageBody(
          maxWidth: 720,
          footer: !showAppBar,
          children: [
                Text('디딤',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Text('사회초년생을 위한 금융 행동 코치',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('금융 정보는 넘치지만 행동으로 이어지지 않아요. 디딤은 매주 하나의 '
                    '실제 금융 행동을 챌린지로 제안하고, 실행까지 안내합니다. '
                    '공부하라고 하지 않고, 이걸 하라고 말해주는 서비스예요.'),
                const SizedBox(height: 24),
                Text('무엇을 할 수 있나요',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const _FeatureCard(
                  icon: Icons.flag,
                  title: '챌린지 & 금융 여정 지도',
                  description: '매주 하나씩 추천되는 실행형 금융 미션. 소비 절약 · 저축·비상금 · '
                      '정책 혜택 · 연말정산 카테고리로 둘러볼 수 있고, 완료할 때마다 '
                      '나만의 금융 여정 지도가 자라나요.',
                  path: '/challenges',
                ),
                const _FeatureCard(
                  icon: Icons.edit_note,
                  title: '가계부',
                  description: '계좌 연동 없는 가벼운 자가 입력 가계부. 이번 달 지출·수입·남은 돈과 '
                      '카테고리별 지출을 한눈에. 기록을 강제하지 않아요.',
                  path: '/ledger',
                ),
                const _FeatureCard(
                  icon: Icons.subscriptions,
                  title: '디지털 월세',
                  description: '매달 나가는 구독료는 또 하나의 월세. 월 총액과 연 환산을 보여주고, '
                      '줄일 수 있는 혜택 6가지와 해지 챌린지로 연결해요.',
                  path: '/subscriptions',
                ),
                const _FeatureCard(
                  icon: Icons.credit_card,
                  title: '카드 재테크',
                  description: '카드별 실적 기준 대비 이번 달 사용액, 앞으로 얼마 더 써야 하는지, '
                      '해지 가능일 D-day와 연회비 일정까지 관리해요.',
                  path: '/cards',
                ),
                const SizedBox(height: 24),
                Text('완료를 어떻게 확인하나요',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _SummaryCard(
                  description: '단순 결과 입력도, 이미지 OCR도 아니에요. 스텝 전체 체크 → 자가체크 '
                      '질문 → 회고 필수 → 실제 수치 입력으로 이어지는 자가검증 게이트를 통과해야 '
                      '실행 완료가 확정돼요. 인증샷은 선택 보너스이고 이미지는 저장하지 않아요.',
                  buttonLabel: '완료 검증 자세히 보기',
                  onPressed: () => context.push('/about/verification'),
                ),
                const SizedBox(height: 24),
                Text('보상은 무엇인가요',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _SummaryCard(
                  description: '현금·포인트·실물 보상은 없어요. 디딤의 점수판은 사용자 본인의 진짜 돈 — '
                      '지킨 돈과 예약된 돈 카운터예요. 그 위에 여정 지도, 배지, 주간 스트릭 같은 '
                      '게이미피케이션이 쌓여요. 남과 비교하는 랭킹 대신 과거의 나와 비교해요.',
                  buttonLabel: '보상 시스템 자세히 보기',
                  onPressed: () => context.push('/about/rewards'),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('현재 개발 현황',
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        const Text('웹 버전이 배포되어 있고 데이터는 브라우저에 저장돼요. '
                            '온보딩 진단, AI 코치, 계정·서버 저장, 모바일 앱은 다음 단계로 '
                            '준비 중이에요.'),
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.path,
  });

  final IconData icon;
  final String title;
  final String description;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go(path),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 20, child: Icon(icon, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(description),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
