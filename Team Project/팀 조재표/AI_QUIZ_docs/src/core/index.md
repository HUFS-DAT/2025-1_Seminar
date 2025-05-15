# core

---
type: directory
path: src/core/
---

## 목적
애플리케이션의 핵심 설정과 기본 구조를 관리하는 디렉토리입니다. 환경 변수 관리, 데이터베이스 연결, 기본 구성 등을 담당합니다.

## 주요 파일
| 파일 | 역할 |
|------|------|
| [[src/core/config.js]] | 중앙 집중식 환경 설정 관리 |
| [[src/core/database.js]] | MongoDB 연결 및 관리 |

## 하위 디렉토리
없음

## 관계
- `config.js`는 모든 모듈에서 환경 변수와 설정값을 가져오는 단일 진입점
- `database.js`는 애플리케이션 전체의 MongoDB 연결을 관리
- 다른 모듈들은 이 core 모듈의 설정을 의존성으로 주입받음

## 설계 패턴
- **Singleton Pattern**: 설정과 데이터베이스 연결의 단일 인스턴스 보장
- **Configuration Object Pattern**: 설정값들을 객체로 그룹화하여 관리
- **Graceful Shutdown**: 프로세스 종료 시 안전한 연결 해제
