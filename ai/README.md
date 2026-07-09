# AI

FastAPI 기반 AI/RAG 서비스를 두는 작업 영역이다.

## 역할

- 자연어 입력 구조화
- 공식 자료 기반 RAG 검색
- 진단 근거 설명
- 챌린지 개인화 보조
- 금융 개념 설명과 회고 코칭

## 기술 방향

- Python
- FastAPI
- Pydantic
- LangChain 또는 LlamaIndex
- OpenAI 또는 Anthropic SDK

## 작업 원칙

- 진단 결론은 룰 엔진 우선, LLM은 설명과 코칭을 담당한다.
- 정책, 세금, 금융상품 정보는 출처와 기준일을 함께 다룬다.
- 불확실한 정보는 단정하지 않고 확인 필요 상태로 응답한다.

