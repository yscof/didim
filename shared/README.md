# Shared

앱, 백엔드, AI 서비스가 함께 참고할 계약과 샘플 데이터를 두는 작업 영역이다.

## 후보 파일

- API 계약 초안
- 챌린지 JSON 샘플
- 이벤트 이름 규칙
- 공통 용어집
- 테스트용 사용자 프로필

## 현재 파일

- [challenges/challenge-library-v1.yaml](./challenges/challenge-library-v1.yaml): 온보딩, MVP 코어, 확장, 흡수, 격리·제외 챌린지 전체 카탈로그
- [challenges/mvp-challenges.yaml](./challenges/mvp-challenges.yaml): MVP 챌린지 샘플과 완료 상태 구조
- [events.md](./events.md): 완료율, 재방문율, 추천 근거 측정을 위한 이벤트 이름 초안
- [crm-triggers.yaml](./crm-triggers.yaml): AARRR/CRM 기반 리텐션 트리거 초안

## 작업 원칙

- 한쪽 구현에만 숨어 있는 계약을 만들지 않는다.
- 앱과 서버가 함께 쓰는 필드명은 가능하면 camelCase로 맞춘다.
- 변경이 생기면 관련 문서와 샘플을 함께 갱신한다.
