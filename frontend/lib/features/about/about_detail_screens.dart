import 'package:flutter/material.dart';

import '../../app/web_page_body.dart';

/// 서비스 소개 상세 페이지들. 원고 출처: docs/17-service-overview.md
/// 소개 페이지에서 push로 진입하므로 항상 AppBar(뒤로가기)를 보여준다.

class AboutVerificationScreen extends StatelessWidget {
  const AboutVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('완료 검증 방식')),
      body: SafeArea(
        child: WebPageBody(
          maxWidth: 720,
          padding: const EdgeInsets.all(20),
          children: const [
                _Section(
                  title: '자가검증 게이트',
                  body: '디딤은 단순 결과 입력도, 이미지를 올려 OCR로 판독하는 방식도 쓰지 않아요. '
                      '대신 실행 완료를 누르기까지 네 단계를 통과해야 해요.',
                ),
                _StepCard(
                  number: '1',
                  title: '스텝 전체 체크',
                  body: '챌린지의 단계별 체크리스트를 모두 체크해야 완료 버튼이 활성화돼요.',
                ),
                _StepCard(
                  number: '2',
                  title: '자가체크 질문',
                  body: '챌린지별 완료 확인 질문에 답해요. 예: "자동이체를 설정했나요?"',
                ),
                _StepCard(
                  number: '3',
                  title: '회고 필수',
                  body: '한 줄이라도 회고를 써야 확정돼요. 회고는 다음 챌린지 추천의 재료가 돼요.',
                ),
                _StepCard(
                  number: '4',
                  title: '실측 입력',
                  body: '금액형 챌린지는 실제 수치(해지한 구독료, 자동이체 금액 등)를 입력해야 하고, '
                      '확보효과는 그 자리에서 입력값 × 산식으로 계산돼요. 고정 예시 금액은 쓰지 않아요.',
                ),
                _Section(
                  title: '인증샷은 선택, 보너스만',
                  body: '인증샷을 첨부하면 보너스 배지를 받지만 필수가 아니고, 금액에도 영향이 없어요. '
                      '이미지는 저장하지 않고 첨부 여부만 기록해요 (개인정보 최소 수집 원칙).',
                ),
                _Section(
                  title: '왜 이 방식인가요',
                  body: '계좌 연동이나 증빙 자동 확인은 개인정보 부담과 규제 비용이 커서 MVP에서 '
                      '제외했어요. 대신 거짓의 비용을 높이고 이득을 없애는 설계를 택했어요 — '
                      '거짓 수치를 입력하면 내 자산 기록(지킨 돈, 여정 지도)이 오염될 뿐 '
                      '얻는 것이 없어요.',
                ),
                _Section(
                  title: '검증 강도 사다리 (로드맵)',
                  body: '자가검증 게이트(현재) → 후속 확인 → AI 인증샷 판독 → 계좌 연동 순으로 '
                      '강화할 수 있게 준비되어 있어요. 만약 현금성 보상을 도입하는 날이 온다면, '
                      '상위 단계 검증이 반드시 먼저예요.',
                ),
          ],
        ),
      ),
    );
  }
}

class AboutRewardsScreen extends StatelessWidget {
  const AboutRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보상 시스템')),
      body: SafeArea(
        child: WebPageBody(
          maxWidth: 720,
          padding: const EdgeInsets.all(20),
          children: const [
                _Section(
                  title: '현금·포인트·실물 보상은 없어요',
                  body: '의도된 설계예요. 현금성·경쟁형 보상은 보상 경제가 무너지거나 규제 문제로 '
                      '실패한 사례가 많고, 무엇보다 디딤에는 필요가 없어요 — 챌린지를 완료하면 '
                      '사용자 본인의 진짜 돈이 이미 움직이니까요. 가짜 포인트는 진짜 숫자와 '
                      '경쟁할 뿐이에요.',
                ),
                _Section(
                  title: '지킨 돈 / 예약된 돈 카운터',
                  body: '지킨 돈에는 무지출·구독 해지처럼 실제로 발생한 절약만 쌓여요. '
                      '연말정산 환급 예상액 같은 추정 금액은 예약된 돈이라는 별도 트랙으로 '
                      '구분해요. 추정을 실적처럼 과장하지 않는 것이 원칙이고, 카운터를 누르면 '
                      '어떤 챌린지로 얼마가 쌓였는지 상세 내역이 나와요.',
                ),
                _Section(
                  title: '금융 여정 지도',
                  body: '챌린지를 완료할 때마다 생활비 마을, 비상금 숲, 정책혜택 항구, 연말정산 '
                      '지역에 오브젝트가 생기고 색이 채워져요 (20/40/60/80/100% 마일스톤). '
                      '내 금융 기반이 만들어지는 모습이 눈에 보이는 것 — 그게 보상이에요.',
                ),
                _Section(
                  title: '배지 = 성장 일지',
                  body: '첫 금융 행동, 자동저축 시작 같은 의미 있는 행동에만 배지를 줘요. '
                      '모든 챌린지에 주면 가치가 사라지니까요. 배지 화면은 도감이 아니라 '
                      '획득 날짜와 실제 행동이 함께 남는 성장 기록이에요.',
                ),
                _Section(
                  title: '주간 스트릭 — 벌주지 않는 꾸준함',
                  body: '매주 하나 이상 완료하면 이어져요. 사유를 기록하고 재시도를 예약한 '
                      '성실한 보류도 유지로 인정해요. 한 주를 쉬어도 기록을 초기화하지 않아요. '
                      '압박이 아니라 복귀를 돕는 게 목적이에요.',
                ),
                _Section(
                  title: '"같은 나이 상위 몇 %"는 왜 없나요',
                  body: '돈의 또래 비교는 동기부여보다 비참함을 만들기 쉬워요. 그래서 랭킹과 '
                      '리더보드는 넣지 않았어요. 디딤의 비교 대상은 남이 아니라 과거의 나예요 — '
                      '순자산 추적, 1년 뒤 나에게 쓰는 편지, 월간 여정 리포트가 그 장치예요.',
                ),
                _Section(
                  title: '검토 중인 확장',
                  body: '개인정보가 드러나지 않는 완료 카드 공유, 그리고 베타 이후에는 내 성과가 '
                      '검증 가능한 실물 기여(예: 나무 심기)로 전환되는 이타적 보상을 검토하고 '
                      '있어요. 어느 쪽이든 무작위 뽑기·현금 환전은 아니에요.',
                ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(radius: 14, child: Text(number)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(body),
      ),
    );
  }
}
