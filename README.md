# 디딤

Challenge-Based Learning으로 사회초년생의 첫 자산을 굴리는 AI 금융 행동 코치 앱.

디딤은 금융 지식을 많이 보여주는 앱이 아니라, 사용자가 지금 해야 할 금융 행동 하나를 정하고 끝까지 실행하도록 돕는 서비스입니다. 사회초년생 1~3년차가 첫 월급 이후 마주하는 청약, 연금, 예적금, 연말정산, 정책금융, 투자 입문 같은 의사결정을 주간 챌린지로 쪼개어 실천하게 합니다.

## 목표

- 사회초년생의 자산 격차를 줄인다.
- 금융 리터러시를 정보 암기가 아니라 실행 경험으로 높인다.
- AI를 단순 챗봇이 아니라 개인화 금융 행동 코치로 사용한다.
- 공식 자료 기반 RAG와 룰 엔진으로 금융 답변의 신뢰성과 규제 리스크를 관리한다.

## 핵심 경험

1. 사용자가 자산, 소득, 소비, 목표를 간단히 입력한다.
2. 서비스가 5단계 자산 형성 모델에서 현재 우선순위를 진단한다.
3. 매주 하나의 금융 챌린지를 추천한다.
4. 사용자는 Engage, Investigate, Act, Reflect 흐름으로 학습하고 실행한다.
5. 회고와 진척 기록을 바탕으로 다음 행동으로 이어진다.

## 저장소 구조

```text
didim/
├── docs/       # 기획, 제품, AI 안전, 마케팅, 아키텍처 문서
├── frontend/   # Flutter 모바일 앱
├── backend/    # Spring Boot API 서버
├── ai/         # FastAPI / RAG 서비스
└── shared/     # API 계약, 샘플 데이터, 이벤트 규칙
```

Codex에서는 이 `didim/` 폴더 전체를 프로젝트 루트로 열고, 작업 범위가 좁을 때는 `frontend`, `backend`, `ai` 중 어느 폴더를 수정할지 명시한다.

## 문서 구조

- [AGENTS.md](./AGENTS.md): Codex와 협업할 때 항상 참고할 프로젝트 컨텍스트
- [docs/00-project-brief.md](./docs/00-project-brief.md): 프로젝트 한 장 요약
- [docs/01-product-requirements.md](./docs/01-product-requirements.md): 제품 요구사항과 MVP 범위
- [docs/02-challenge-system.md](./docs/02-challenge-system.md): 챌린지 설계 원칙과 예시
- [docs/03-ai-rag-safety.md](./docs/03-ai-rag-safety.md): AI/RAG/안전 설계
- [docs/04-architecture.md](./docs/04-architecture.md): 시스템 아키텍처 초안
- [docs/05-go-to-market.md](./docs/05-go-to-market.md): 시장, 경쟁, BM, 마케팅
- [docs/06-research-and-metrics.md](./docs/06-research-and-metrics.md): 사용자 검증과 지표
- [docs/07-roadmap.md](./docs/07-roadmap.md): 추진 일정과 마일스톤
- [docs/08-decisions.md](./docs/08-decisions.md): 의사결정 로그
- [docs/09-open-questions.md](./docs/09-open-questions.md): 앞으로 확인할 질문
- [docs/10-mvp-scope.md](./docs/10-mvp-scope.md): MVP에 적용할 기능과 제외할 기능
- [docs/11-repo-structure.md](./docs/11-repo-structure.md): 저장소 구조와 작업 범위 기준
- [docs/12-review-feedback-actions.md](./docs/12-review-feedback-actions.md): 기획심의 종합의견 반영 액션
- [docs/13-growth-retention.md](./docs/13-growth-retention.md): 사용자 유입, 후킹, CRM, 리텐션 전략
- [docs/14-challenge-library.md](./docs/14-challenge-library.md): 챌린지 라이브러리 v1 개발 정리
