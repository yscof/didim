/// 목 데이터. shared/challenges/mvp-core-challenges.yaml과
/// shared/gamification/journey-map.yaml의 일부를 Dart로 옮긴 것이다.
/// TODO: 백엔드 API가 생기면 이 파일을 저장소 레이어로 교체한다.
library;

import 'models.dart';

const mockRegions = [
  MapRegion(
    id: 'region-living-cost-village',
    name: '생활비 마을',
    theme: '내 돈이 어디로 나가는지 이해하고 불필요한 지출 줄이기',
    completionMessage: '생활비 마을이 완성됐어요. 이제 매달 나가는 돈을 스스로 관리할 수 있어요.',
  ),
  MapRegion(
    id: 'region-emergency-forest',
    name: '비상금 숲',
    theme: '최소한의 금융 안전망 만들기',
    completionMessage: '비상금 숲이 자라났어요. 예상치 못한 상황을 버틸 첫 번째 안전망을 만들었습니다.',
  ),
  MapRegion(
    id: 'region-benefit-harbor',
    name: '정책혜택 항구',
    theme: '받을 수 있는 혜택을 놓치지 않기',
    completionMessage: '정책혜택 항구의 등대가 켜졌어요. 받을 수 있는 혜택을 놓치지 않도록 안내해 드릴게요.',
  ),
  MapRegion(
    id: 'region-year-end-tax',
    name: '연말정산',
    theme: '13월의 월급 준비 — 연중에 예약하고 시즌에 채점받기',
    completionMessage: '연말정산 준비가 끝났어요. 내년 2월, 13월의 월급으로 돌아옵니다.',
  ),
];

const mockChallenges = [
  Challenge(
    id: 'mvp-disposable-income',
    title: '월급 하루 생존 테스트',
    subtitle: '진짜 가용액 계산',
    type: ChallengeType.instant,
    estimatedMinutes: 7,
    coachHook: '월급이 들어온 날, 이미 나가기로 정해진 돈을 다 빼면 얼마가 남을까요? '
        '7분이면 내 진짜 월급을 알 수 있어요.',
    whyContent: '통장에 찍히는 월급과 실제로 쓸 수 있는 돈은 다르다. '
        '고정지출을 뺀 가처분액을 알아야 저축 목표도 소비 기준도 세울 수 있다.',
    steps: [
      '월 실수령액을 입력한다.',
      '고정지출을 카테고리별로 입력한다 (주거·통신·구독·교통·보험·대출 상환).',
      '진짜 가처분액을 확인한다.',
      '하루 가용액(가처분액 ÷ 30)을 확인한다.',
    ],
    completionCheckQuestions: ['내 진짜 가처분액을 확인했나요?'],
    reflectionQuestions: ['예상보다 컸나요, 작았나요?'],
    gainLabel: GainLabel.discovery,
    impactPreview: '내 진짜 가처분액과 하루 가용액을 알게 됐어요. 이 숫자가 모든 챌린지의 기준이 돼요.',
    categories: [ChallengeCategory.spending],
    regionId: 'region-living-cost-village',
    mapEffect: '마을 길이 정돈되고 밝아짐',
    progressWeight: 15,
    nextChallengeId: 'mvp-subscription-audit-cancel-one',
  ),
  Challenge(
    id: 'mvp-subscription-audit-cancel-one',
    title: '구독 전수조사 + 1개 이상 해지',
    type: ChallengeType.action,
    estimatedMinutes: 10,
    coachHook: '한 달에 몇 개 구독료가 나가는지 정확히 알고 계세요? '
        '10분 전수조사로 안 쓰는 구독 하나만 잘라도 1년치가 돌아와요.',
    whyContent: '구독은 가장 잊기 쉬운 고정지출이다. 한 번 전수조사하면 매달 반복되는 절감 효과가 생긴다.',
    steps: [
      '최근 한 달 카드·계좌 내역에서 정기 결제를 찾는다.',
      '앱스토어(구글·애플) 구독 관리 화면을 확인한다.',
      '구독 목록을 만들고 최근 한 달 사용 여부를 체크한다.',
      '안 쓰는 구독 1개 이상을 해지하고 금액을 기록한다.',
    ],
    completionCheckQuestions: [
      '구독 전체 목록을 확인했나요?',
      '해지했거나 해지할 구독을 정했나요?',
    ],
    reflectionQuestions: ['잊고 있던 구독이 있었나요?'],
    gainLabel: GainLabel.annualized,
    impactPreview: '해지한 구독료만큼 매달 반복 절약돼요. 1년 기준 효과는 완료할 때 계산해 드려요 (연 환산 · 예상).',
    impactInput: ImpactInputSpec(
      label: '해지한 구독의 월 요금 합계',
      multiplier: 12,
      formulaNote: '월 요금 × 12개월',
    ),
    categories: [ChallengeCategory.spending],
    regionId: 'region-living-cost-village',
    mapEffect: '상점 거리가 정리되고 간판이 켜짐',
    progressWeight: 20,
    nextChallengeId: 'mvp-emergency-fund-goal',
  ),
  Challenge(
    id: 'mvp-no-spend-day',
    title: '무지출 데이 1회',
    type: ChallengeType.habit,
    estimatedMinutes: 3,
    coachHook: '딱 하루만 지갑을 닫아봐요. 자동결제는 예외니까 생각보다 어렵지 않아요.',
    whyContent: '무지출 데이는 금액보다 지출을 선택할 수 있다는 감각을 만드는 훈련이다.',
    steps: [
      '무지출 데이 날짜를 정한다 (약속 없는 날 권장).',
      '당일 아침 시작 체크인을 한다.',
      '하루를 지출 없이 보낸다 (자동결제 예외).',
      '하루 끝 결산 체크인을 한다.',
    ],
    completionCheckQuestions: ['오늘 하루 지출 없이 보냈나요?'],
    reflectionQuestions: ['가장 참기 어려웠던 순간은 언제였나요?'],
    gainLabel: GainLabel.realized,
    impactPreview: '오늘 하루 평균 일지출만큼 지켜요. 지킨 금액은 완료할 때 계산해 드려요 (실발생).',
    impactInput: ImpactInputSpec(
      label: '오늘 지킨 평균 일지출',
      multiplier: 1,
      formulaNote: '하루 지출을 그대로 지킨 금액',
    ),
    categories: [ChallengeCategory.spending],
    regionId: 'region-living-cost-village',
    mapEffect: '가로등이 하나 켜짐',
    progressWeight: 10,
  ),
  Challenge(
    id: 'mvp-emergency-fund-goal',
    title: '내 비상금 목표 정하기',
    type: ChallengeType.instant,
    estimatedMinutes: 5,
    coachHook: '비상금은 많을수록 좋은 돈이 아니라 내 상황에 맞는 만큼이면 되는 돈이에요. '
        '내 기준을 5분 만에 정해봐요.',
    whyContent: '기준이 있어야 얼마나 모았는지가 보인다. 수입이 일정하면 짧게, 불규칙하면 길게 잡는다.',
    steps: [
      '월 필수 생활비를 확인한다.',
      '고용 형태를 선택한다 (정규직 3개월 / 계약직·프리랜서 6개월 권장).',
      '추천 개월 수를 확인하고 필요하면 조정한다.',
      '목표액을 확정하고 저장한다.',
    ],
    completionCheckQuestions: ['목표 비상금 금액을 확정했나요?'],
    reflectionQuestions: ['지금 모아둔 돈으로 몇 개월을 버틸 수 있나요?'],
    gainLabel: GainLabel.estimated,
    impactPreview: '내 비상금 목표가 생겼어요. 이제 얼마나 모았는지가 보여요.',
    categories: [ChallengeCategory.saving],
    regionId: 'region-emergency-forest',
    mapEffect: '씨앗이 심어짐',
    progressWeight: 25,
    nextChallengeId: 'mvp-emergency-fund-account-auto-transfer',
  ),
  Challenge(
    id: 'mvp-emergency-fund-account-auto-transfer',
    title: '비상금 통장 분리 + 자동이체',
    type: ChallengeType.action,
    estimatedMinutes: 20,
    coachHook: '비상금이 생활비 통장에 섞여 있으면 반드시 쓰게 돼요. '
        '오늘 20분으로 안 보이는 금고를 만들어봐요.',
    whyContent: '저축은 의지보다 구조가 중요하다. 통장을 분리하고 월급 직후 자동이체를 걸면 '
        '의지 없이도 비상금이 쌓인다.',
    steps: [
      '비상금 전용으로 쓸 통장을 고르거나 새로 만들 은행을 정한다.',
      '통장에 별명을 붙인다 (예: 3개월 버티는 돈).',
      '자동이체 날짜를 월급일 다음 날로 정한다.',
      '자동이체 금액을 정한다.',
      '은행 앱에서 자동이체를 설정한다.',
    ],
    completionCheckQuestions: [
      '비상금 통장을 분리했나요?',
      '자동이체를 설정했나요, 아니면 설정할 날짜를 정했나요?',
    ],
    reflectionQuestions: ['이 금액을 매달 유지할 수 있을 것 같나요?'],
    gainLabel: GainLabel.annualized,
    impactPreview: '매달 자동이체한 만큼 1년 뒤 비상금이 쌓여요. 금액은 완료할 때 계산해 드려요 (연 환산 · 예상).',
    impactInput: ImpactInputSpec(
      label: '월 자동이체 금액',
      multiplier: 12,
      formulaNote: '월 이체액 × 12개월',
    ),
    categories: [ChallengeCategory.saving],
    regionId: 'region-emergency-forest',
    mapEffect: '첫 번째 나무가 자람',
    progressWeight: 45,
    nextChallengeId: 'mvp-money-scan-policy-benefits',
  ),
  Challenge(
    id: 'mvp-money-scan-policy-benefits',
    title: '놓치는 돈 스캔',
    subtitle: '숨은 지원금·감면 확인',
    type: ChallengeType.instant,
    estimatedMinutes: 7,
    coachHook: '신청 안 하면 아무도 챙겨주지 않는 돈이 있어요. '
        '문항 몇 개만 답하면, 내가 놓치고 있을 지원금과 감면을 훑어드릴게요.',
    whyContent: '청년 대상 지원금과 감면은 종류가 많고 흩어져 있어 존재 자체를 모르는 경우가 많다. '
        '결과는 응답 기반 추정이며 최종 자격은 공식 페이지에서 확인한다.',
    steps: [
      '자격 문항에 답한다 (나이, 고용 형태, 소득 구간, 주거 등).',
      '해당 가능 항목 리스트를 확인한다.',
      '항목별 예상 금액과 합산 찾은 돈을 확인한다.',
      '가장 금액이 큰 항목 1개의 다음 행동을 예약한다.',
    ],
    completionCheckQuestions: [
      '스캔 결과를 확인했나요?',
      '다음 행동으로 예약할 항목을 골랐나요?',
    ],
    reflectionQuestions: ['처음 알게 된 항목이 있었나요?'],
    gainLabel: GainLabel.estimated,
    impactPreview: '놓치고 있던 지원금·감면을 찾아요 (추정 · 2026년 기준). 공식 페이지에서 최종 확인하세요.',
    impactInput: ImpactInputSpec(
      label: '스캔 결과 합산 금액',
      multiplier: 1,
      formulaNote: '응답 기반 추정 합계',
    ),
    categories: [ChallengeCategory.benefit],
    regionId: 'region-benefit-harbor',
    mapEffect: '항구에 배가 들어옴',
    progressWeight: 45,
    nextChallengeId: 'mvp-year-end-tax-preview',
  ),
  Challenge(
    id: 'mvp-year-end-tax-preview',
    title: '13월의 월급 예약하기',
    subtitle: '연말정산, 지금 예약하면 더 돌려받아요',
    type: ChallengeType.action,
    estimatedMinutes: 15,
    coachHook: '연말정산이 연말에 하는 것이 아니라는 거 아세요? 1월에 서류 내는 건 채점일 뿐이고, '
        '점수는 지금부터 12월까지 쌓여요.',
    whyContent: '연말정산의 승부는 연중이다. 연금저축 납입, 월세 서류, 카드 비율은 12월에 알면 늦다. '
        '환급은 공돈이 아니라 내가 낸 세금을 돌려받는 것이다.',
    steps: [
      '스캔 문항 6개에 답한다 (고용 형태 / 회사 규모 / 나이 / 주거 / 무주택 여부 / 이미 하는 것).',
      '내 환급 지도를 확인한다 (항목별 예상 금액).',
      '이번 주 첫 행동 1개를 고른다.',
      '실행 가이드를 따라 실행한다.',
    ],
    completionCheckQuestions: [
      '스캔 결과(환급 지도)를 확인했나요?',
      '이번 주 첫 행동 1개를 실행했거나 실행 날짜를 정했나요?',
    ],
    reflectionQuestions: [
      '가장 아까웠던 건 뭐였어요? (90% 감면 존재 / 월세 환급 / 12월엔 늦다 / 딱히 없음)',
    ],
    gainLabel: GainLabel.estimated,
    impactPreview: '지금 챙기면 내년 2월 환급이 늘어나요 (추정 · 2026년 기준). 내 환급 지도로 금액을 확인해요.',
    impactInput: ImpactInputSpec(
      label: '환급 지도 예상 합계',
      multiplier: 1,
      formulaNote: '응답 기반 추정 합계',
    ),
    categories: [ChallengeCategory.yearEndTax],
    regionId: 'region-year-end-tax',
    mapEffect: '환급 지도가 펼쳐짐',
    progressWeight: 30,
    nextChallengeId: 'tax-smb-income-tax-relief',
  ),
  Challenge(
    id: 'mvp-housing-subscription-open',
    title: '청약통장 만들기',
    subtitle: '자격·혜택 확인 후 개설 안내',
    type: ChallengeType.action,
    estimatedMinutes: 20,
    coachHook: '청약통장은 집 살 사람만 만드는 게 아니에요. 무주택 직장인이라면 '
        '납입액의 40%를 소득공제 받는 절세 통장이기도 해요.',
    whyContent: '청약통장은 가입 기간이 길수록 유리한 경우가 많아 일찍 만드는 것 자체가 자산이다. '
        '조건이 되면 연말정산 소득공제 혜택도 함께 받는다.',
    steps: [
      '청약통장 보유 여부를 확인한다 (보유 시 납입 상태 점검).',
      '자격·혜택을 확인한다 (무주택 세대주 여부, 총급여, 소득공제 조건).',
      '월 납입액을 정한다 (인정 납입액 기준 안내).',
      '은행 앱에서 주택청약종합저축을 개설한다.',
    ],
    completionCheckQuestions: [
      '청약통장을 개설했나요, 아니면 개설할 은행과 납입액을 정했나요?',
      '소득공제 대상 여부를 확인했나요?',
    ],
    reflectionQuestions: ['오늘 새롭게 알게 된 점은 무엇인가요?'],
    gainLabel: GainLabel.annualized,
    impactPreview: '납입액의 40%를 소득공제 받아요 (해당자 · 연 환산 · 추정). 줄어드는 세금은 완료할 때 계산해 드려요.',
    impactInput: ImpactInputSpec(
      label: '월 납입액',
      multiplier: 0.72,
      formulaNote: '연 납입 40% 공제 × 세율 15% 근사',
    ),
    // 소득공제 혜택이 있어 연말정산 카테고리에도 함께 노출한다.
    categories: [ChallengeCategory.benefit, ChallengeCategory.yearEndTax],
    regionId: 'region-benefit-harbor',
    mapEffect: '등대가 켜지고 새 항로가 열림',
    progressWeight: 55,
  ),

  // ── 연말정산 카테고리 (M-13 후속 미션, didim_challenge_spec_tax.md §4·§7) ──
  Challenge(
    id: 'tax-smb-income-tax-relief',
    title: '중소기업 취업자 소득세 감면 신청',
    type: ChallengeType.action,
    estimatedMinutes: 10,
    coachHook: '중소기업에 다니면 소득세의 90%를 안 내도 되는 제도가 있어요. '
        '신청서 한 장이면 되는데, 몰라서 매달 그냥 내는 사람이 태반이에요.',
    whyContent: '만 15~34세 중소기업 재직자는 소득세 90% 감면(연 한도 200만 원, 최대 5년)을 '
        '받을 수 있다. 감면율이 가장 크고 실행이 가장 쉬운데 인지도가 가장 낮다. '
        '세부 요건은 회사·홈택스에서 최종 확인한다.',
    steps: [
      '대상인지 확인한다 (만 15~34세 + 중소기업 재직, 일부 업종 제외).',
      '국세청 양식 감면 신청서를 작성한다.',
      '회사(인사·경리)에 제출한다.',
      '다음 급여명세서에서 반영을 확인한다.',
    ],
    // tax-* 완료 질문은 yaml 미정의라 didim_challenge_spec_tax.md 후속 미션
    // 기준으로 신규 작성했다.
    completionCheckQuestions: [
      '감면 대상(만 15~34세 + 중소기업 재직)인지 확인했나요?',
      '감면 신청서를 회사에 제출했나요?',
    ],
    reflectionQuestions: ['신청 과정에서 막힌 부분이 있었나요?'],
    gainLabel: GainLabel.estimated,
    impactPreview: '소득세의 90%를 감면받아요 (추정 · 2026년 기준). 아끼는 금액은 완료할 때 계산해 드려요.',
    impactInput: ImpactInputSpec(
      label: '급여명세서의 월 소득세',
      multiplier: 10.8,
      formulaNote: '12개월 × 90% 감면',
    ),
    categories: [ChallengeCategory.yearEndTax],
    regionId: 'region-year-end-tax',
    mapEffect: '13월의 금고가 열림',
    progressWeight: 25,
    nextChallengeId: 'tax-rent-deduction-docs',
  ),
  Challenge(
    id: 'tax-rent-deduction-docs',
    title: '월세 공제 서류 3종 모으기',
    type: ChallengeType.action,
    estimatedMinutes: 15,
    coachHook: '월세 내는 무주택 직장인이라면, 서류 3장으로 낸 월세의 15~17%를 돌려받을 수 있어요. '
        '집주인 동의는 필요 없어요.',
    whyContent: '월세 세액공제는 무주택 + 총급여 요건 + 전입신고만 충족하면 된다. '
        '1월 제출 시즌에 서류가 없어서 놓치는 경우가 가장 많다.',
    steps: [
      '임대차계약서 사본을 준비한다.',
      '월세 이체 내역을 내려받는다.',
      '전입신고 여부를 확인한다.',
      '폴더에 모아둔다 (1월 연말정산 때 제출).',
    ],
    completionCheckQuestions: [
      '임대차계약서 사본과 월세 이체 내역을 준비했나요?',
      '전입신고 여부를 확인했나요?',
    ],
    reflectionQuestions: ['서류 중 가장 구하기 어려웠던 것은 무엇이었나요?'],
    gainLabel: GainLabel.estimated,
    impactPreview: '낸 월세의 15~17%를 돌려받아요 (추정 · 2026년 기준). 환급액은 완료할 때 계산해 드려요.',
    impactInput: ImpactInputSpec(
      label: '월세',
      multiplier: 2.04,
      formulaNote: '12개월 × 세액공제 17%',
    ),
    categories: [ChallengeCategory.yearEndTax],
    regionId: 'region-year-end-tax',
    mapEffect: '서류 보관함이 채워짐',
    progressWeight: 20,
    nextChallengeId: 'tax-pension-savings-first-month',
  ),
  Challenge(
    id: 'tax-pension-savings-first-month',
    title: '연금저축 첫 달 설정',
    type: ChallengeType.action,
    estimatedMinutes: 10,
    coachHook: '연금저축은 12월에 몰아 넣는 것보다 지금 시작하면 월 부담이 절반이에요. '
        '가입할지 말지는 천천히 정해도 돼요.',
    whyContent: '연금저축 납입액은 세액공제(총급여 5,500만 이하 16.5%) 대상이다. '
        '특정 상품 추천은 하지 않으며, 계좌 개설 여부는 자율이다.',
    steps: [
      '세액공제 개념 카드를 확인한다.',
      '월 부담액을 계산해본다 (지금 시작 vs 12월 시작 비교).',
      '개설한다면 첫 자동이체 날짜를 정한다 (개설은 자율).',
    ],
    completionCheckQuestions: [
      '월 부담액을 계산해봤나요?',
      '개설 여부와 첫 자동이체 날짜를 정했나요?',
    ],
    reflectionQuestions: ['지금 시작과 12월 시작, 비교해보니 어땠나요?'],
    gainLabel: GainLabel.estimated,
    impactPreview: '연말까지 납입한 금액의 16.5%를 세액공제 받아요 (추정 · 2026년 기준).',
    impactInput: ImpactInputSpec(
      label: '월 납입액',
      multiplier: 0.99,
      formulaNote: '연말까지 6개월 × 세액공제 16.5%',
    ),
    categories: [ChallengeCategory.yearEndTax, ChallengeCategory.saving],
    regionId: 'region-year-end-tax',
    mapEffect: '연금 나무가 심어짐',
    progressWeight: 15,
    nextChallengeId: 'tax-card-25-line',
  ),
  Challenge(
    id: 'tax-card-25-line',
    title: '카드 25% 라인 계산',
    type: ChallengeType.instant,
    estimatedMinutes: 5,
    coachHook: '카드 공제는 총급여의 25%를 넘게 쓴 금액부터 시작돼요. '
        '내 25% 라인을 알면 하반기 카드 전략이 달라져요.',
    whyContent: '25% 라인 도달 전에는 혜택 좋은 신용카드, 도달 후에는 공제율 높은 '
        '체크카드·현금영수증(30%)이 유리하다. 모든 근로소득자에게 적용된다.',
    steps: [
      '내 총급여를 확인한다.',
      '총급여 x 25% 라인을 계산한다.',
      '지금까지 카드 사용액과 비교한다.',
      '하반기 전략을 정한다 (라인 전 신용카드 / 라인 후 체크카드).',
    ],
    completionCheckQuestions: [
      '내 25% 라인을 계산했나요?',
      '하반기 카드 전략을 정했나요?',
    ],
    reflectionQuestions: ['지금까지 사용액은 라인 기준 어디쯤이었나요?'],
    gainLabel: GainLabel.discovery,
    impactPreview: '내 25% 라인을 알았어요. 이제 하반기 카드 사용 전략이 생겼어요.',
    categories: [ChallengeCategory.yearEndTax],
    regionId: 'region-year-end-tax',
    mapEffect: '거리에 이정표가 세워짐',
    progressWeight: 10,
  ),
];

const mockBadges = [
  DidimBadge(
    id: 'badge-first-action',
    name: '첫 금융 행동',
    description: '디딤에서 첫 번째 금융 행동을 완료했어요.',
  ),
  DidimBadge(
    id: 'badge-auto-saving-start',
    name: '자동저축 시작',
    description: '첫 번째 자동이체를 설정했어요.',
  ),
  DidimBadge(
    id: 'badge-benefit-explorer',
    name: '혜택 탐험가',
    description: '내가 받을 수 있는 혜택을 처음 확인했어요.',
  ),
  DidimBadge(
    id: 'badge-verified-action',
    name: '기록으로 남긴 실행',
    description: '실행 완료를 인증샷과 함께 기록했어요.',
  ),
];
