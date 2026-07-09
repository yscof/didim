# 14. Challenge Library

## 목적

`didim_challenge_library_v1.md`의 챌린지 목록을 추후 개발에서 사용할 수 있게 정리한 문서다. 원본의 큰 방향은 유지하되, 앱/백엔드/AI가 공통으로 참조할 수 있도록 구조화 데이터는 [shared/challenges/challenge-library-v1.yaml](../shared/challenges/challenge-library-v1.yaml)에 둔다.

## 운영 원칙

- 행동이 없으면 독립 챌린지로 만들지 않는다.
- 실매수, 특정 종목 판단, 유망 산업 선택 유도는 격리한다.
- 학습형 콘텐츠는 챌린지의 `whyContent`, `step`, `SRS 카드`로 흡수한다.
- 확보효과는 고정 금액이 아니라 산식으로 계산한다.
- MVP는 완료율, 재방문율, 사용 편의성에 직접 기여하는 챌린지를 우선한다.

## 분류

| 구분 | 개수 | 개발 용도 |
|---|---:|---|
| 온보딩 | 2 | 첫 진입 후 진단 재미와 공유 훅 |
| MVP 코어 | 16 | MVP 챌린지 후보 풀 |
| 확장 | 32 | 베타 이후 단계별 확장 풀 |
| 흡수 | 15 | 독립 챌린지가 아니라 스텝/SRS/온보딩 문항으로 사용 |
| 격리·제외 | 8 | 규제, 신뢰성, 톤 문제로 직접 미션 부여 금지 |

원본에는 확장 라이브러리가 26개로 표기되어 있으나, 실제 항목 목록은 32개로 확인된다. 데이터 파일에는 `expansionDeclared: 26`, `expansionNormalized: 32`로 기록한다.

## MVP 코어 16개

| ID | 챌린지 | 유형 | 단계 | 시간 | 대표 |
|---|---|---|---|---:|---|
| mvp-disposable-income | 월급 하루 생존 테스트 | A | 비상금 | 7분 |  |
| mvp-emergency-fund-goal | 내 비상금 목표 정하기 | A | 비상금 | 5분 |  |
| mvp-emergency-fund-account-auto-transfer | 비상금 통장 분리 + 자동이체 | B | 비상금 | 20분 | ★ |
| mvp-net-worth-first-calc | 순자산 첫 계산 | A | 비상금 | 10분 |  |
| mvp-subscription-audit-cancel-one | 구독 전수조사 + 1개 이상 해지 | B | 소비 습관 | 10분 | ★ |
| mvp-delivery-cut-weekly | 배달 줄이기 주간 미션 | C | 소비 습관 | 주간 |  |
| mvp-no-spend-day | 무지출 데이 1회 | C | 소비 습관 | 하루 |  |
| mvp-impulse-24h-hold | 충동구매 24시간 보류 규칙 설치 | C | 소비 습관 | 3분+24h |  |
| mvp-labor-hour-price | 시급으로 환산해보기 | A | 소비 습관 | 5분 |  |
| mvp-mobile-plan-compare | 통신비 비교 + 요금제/알뜰폰 갈아타기 | B | 고정비 절감 | 15분+ | ★ |
| mvp-deposit-rate-check | 예·적금 금리 비교 점검 | B | 고정비 절감 | 10분 |  |
| mvp-money-scan-policy-benefits | 놓치는 돈 스캔 | A | 세금·정책 | 7분 | ★ |
| mvp-year-end-tax-preview | 연말정산 미리보기 | B | 세금·정책 | 15분 |  |
| mvp-credit-score-first-check | 신용점수 첫 조회 + 올리는 행동 1개 | B | 신용·안전 | 8분 |  |
| mvp-housing-subscription-open | 청약통장 만들기 | B | 청약·연금 | 20분 | ★ |
| mvp-letter-to-future-self | 1년 뒤 나에게 편지 봉인 | A | 리텐션 | 7분 |  |

## 기존 상세 MVP 6개와의 관계

이미 [shared/challenges/mvp-challenges.yaml](../shared/challenges/mvp-challenges.yaml)에 상세 시나리오가 있는 6개는 초기 구현 슬라이스로 유지한다. 새 라이브러리의 MVP 코어 16개는 후보 풀이고, 실제 첫 배포에는 그중 일부를 선택해 상세화한다.

현재 상세화된 6개:

- 비상금 목표 만들기
- 월급날 자동이체 계획 만들기
- 고정지출 한 개 줄이기
- 청약통장 상태 점검하기
- 현실적인 월 저축률 정하기
- 청년 자산 형성 정책 자격 간이 확인하기

## 상세 시나리오

MVP 코어 16개의 상세 실행 시나리오는 작성 완료 상태다.

- 구조화 데이터: [shared/challenges/mvp-core-challenges.yaml](../shared/challenges/mvp-core-challenges.yaml)
- 기획 설명(템플릿·설계 규칙): [docs/15-challenge-scenarios.md](./15-challenge-scenarios.md)

## 개발 시 사용 방식

1. `shared/challenges/challenge-library-v1.yaml`에서 후보를 선택한다.
2. MVP에 넣을 챌린지는 `shared/challenges/mvp-core-challenges.yaml` 수준으로 상세화한다.
3. 정책, 세금, 청약 관련 챌린지는 `sourceList`, `validUntil`, `sourceUpdatedAt`을 채운다.
4. 학습형 원본은 독립 미션으로 만들지 말고 `whyContent` 또는 SRS 카드로 흡수한다.
5. 격리 목록은 별도 승인이 있기 전까지 추천 엔진 후보에 넣지 않는다.
