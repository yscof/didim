# Frontend

Flutter 앱 작업 영역이다. 하나의 코드베이스로 모바일(iOS/Android)과 웹을 함께 빌드한다.

- **웹 우선 개발**: 개발·검증은 웹 타깃 기준으로 진행하고, 모바일 배포는 베타 이후 추가한다 (docs/08-decisions.md 2026-07-09).
- SEO가 필요한 마케팅 랜딩페이지는 Flutter Web으로 만들지 않고, 필요 시 별도 `web/` 영역에 만든다.

## 폴더 구조 (feature-first)

```text
lib/
├── main.dart              # 앱 진입점, 테마, SharedPreferences 주입
├── app/                   # 라우터, 웹 셸(무신사식 상단 메뉴바)
├── data/                  # 모델·목 데이터·Riverpod 상태 (shared/ 계약 기준)
└── features/
    ├── home/              # 홈 (주간 챌린지, 카운터, 스트릭, 미니맵, 배지)
    ├── challenges/        # 카테고리별 챌린지 목록
    ├── challenge/         # 챌린지 상세, 완료 게이트, 완료 리액션
    ├── map/               # 금융 여정 지도
    ├── gains/             # 지킨 돈/예약된 돈 상세 내역
    ├── ledger/            # 가계부 (자가 입력, 로컬 저장)
    ├── subscriptions/     # 디지털 월세 — 구독료 현황·절감 안내
    ├── cards/             # 카드 재테크 — 실적·해지 시점 관리
    ├── about/             # 서비스 소개 (완료 검증·보상 시스템 상세)
    └── legal/             # 면책·이용약관·개인정보처리방침 (Footer 링크)
```

## 역할

- 온보딩과 간편 진단 입력
- 자산 단계 진단 결과 화면
- 주간 챌린지 진행 화면
- 효과 계산과 성장 기록 (지킨 돈/예약된 돈, 금융 여정 지도, 배지)
- AI 코칭 대화와 회고 UI

## 기술 스택

- Flutter / Dart (프로젝트명 `didim`, org `com.didim`)
- Riverpod (상태 관리)
- Go Router (라우팅)
- 타깃 플랫폼: android, ios, web

## 실행

```bash
cd frontend
flutter run                 # 연결된 기기/시뮬레이터
flutter run -d chrome       # 웹
flutter test                # 테스트
flutter analyze             # 정적 분석
flutter build web           # 웹 배포 빌드
```

## 작업 원칙

- 금융 초보자가 바로 이해할 수 있는 문구와 흐름을 우선한다.
- 첫 챌린지 완료까지의 화면 수와 입력 부담을 줄인다.
- 홈 화면의 핵심 버튼은 항상 하나다 (docs/16-gamification.md 5장).
- 백엔드나 AI API가 아직 없으면 인터페이스 TODO를 남기고 목 데이터로 진행한다.
- 챌린지·지도·배지 데이터 계약은 `shared/` 파일을 기준으로 한다.
