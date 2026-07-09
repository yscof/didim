# 11. Repo Structure

## 결정

디딤은 하나의 Git 저장소 안에서 기획 문서, Flutter 앱, Spring Boot 백엔드, FastAPI AI 서비스를 함께 관리한다.

```text
didim/
├── .git/
├── docs/
├── frontend/
├── backend/
├── ai/
├── shared/
├── AGENTS.md
└── README.md
```

## 폴더별 역할

- `docs/`: 제품, 기획, 마케팅, AI 안전, 아키텍처, 의사결정 문서
- `frontend/`: Flutter 앱 (android, ios, web 타깃)
- `backend/`: Spring Boot API 서버
- `ai/`: FastAPI 기반 AI/RAG 서비스
- `shared/`: API 계약, 샘플 데이터, 이벤트 규칙, 공통 용어

## Codex 작업 기준

Codex에서는 `didim/` 전체를 프로젝트 루트로 연다. 작업 범위가 특정 영역이면 지시에서 폴더를 명확히 제한한다.

예:

```text
frontend 폴더만 작업해줘. backend와 ai는 수정하지 말고 필요한 API는 shared에 TODO로 남겨줘.
```

## 왜 이 구조인가

- Git 히스토리를 하나로 유지하면서 제품 맥락과 구현을 함께 관리할 수 있다.
- 앱, 백엔드, AI 서비스의 경계가 명확하다.
- MVP 단계에서 API와 데이터 계약을 빠르게 조율할 수 있다.
- Desktop이나 홈 폴더 전체를 프로젝트로 여는 위험을 피할 수 있다.

## 아직 하지 않는 것

- Flutter 프로젝트는 2026-07-09 `frontend/`에 생성했다. Spring/FastAPI 프로젝트 생성은 다음 구현 단계에서 진행한다.
- 마케팅 랜딩용 `web/` 영역은 SEO가 필요해지는 시점에 만든다.
- 글로벌 Codex 설정인 `~/.codex/config.toml`은 프로젝트 파일이 아니므로 여기에서 관리하지 않는다.
- 하위 폴더를 별도 Git 저장소로 분리하지 않는다.

