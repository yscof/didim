# Backend

Spring Boot API 서버를 두는 작업 영역이다.

## 역할

- 사용자 프로필과 자가 입력 금융 정보 관리
- 자산 단계 진단 결과 저장
- 챌린지 배정, 진행 상태, 완료 기록 관리
- 회고와 이벤트 로그 저장
- 모바일 앱과 AI 서비스 사이의 안정적인 API 제공

## 기술 방향

- Java 17
- Spring Boot 3.x
- PostgreSQL 또는 Supabase
- JPA/Hibernate
- Spring Security

## 작업 원칙

- MVP에서는 계좌 연동 없이 자가 입력 데이터를 기준으로 한다.
- 금융상품 추천이나 가입 대행으로 오해될 수 있는 API는 만들지 않는다.
- AI 서비스가 실패해도 기본 챌린지 추천과 진행 상태 저장은 유지되게 설계한다.

