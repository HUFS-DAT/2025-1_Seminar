# database.js

---
type: file
path: src/core/database.js
language: javascript
---

## 목적
MongoDB 데이터베이스 연결을 관리하고, 연결 상태를 모니터링하며, 안전한 종료를 처리하는 데이터베이스 매니저 클래스입니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `Database` | 클래스 | 데이터베이스 연결 관리 |
| `connect()` | 정적 메서드 | MongoDB 연결 수행 |
| `disconnect()` | 정적 메서드 | MongoDB 연결 해제 |
| `getConnectionStatus()` | 정적 메서드 | 현재 연결 상태 반환 |

## 의존성
- `mongoose`: MongoDB ODM 라이브러리
- [[src/core/config.js]]: MongoDB URI 설정

## 데이터 흐름
애플리케이션 시작 → Database.connect() → MongoDB 연결 → 연결 상태 모니터링

## 주요 기능

### 연결 관리
- 환경에 따른 유연한 연결 처리 (개발 환경에서는 연결 실패 시에도 계속 진행)
- 연결 옵션 설정 (`useNewUrlParser`, `useUnifiedTopology`)

### 에러 처리
- 개발 환경과 프로덕션 환경의 다른 에러 처리 전략
- MongoDB URI가 없을 때 graceful degradation

### 이벤트 모니터링
- 연결, 에러, 연결 해제 이벤트 로깅
- 프로세스 종료 시 안전한 연결 해제 (SIGINT 핸들링)

## 코드 예시
```javascript
import { Database } from '../core/database.js';

// 애플리케이션 시작 시
try {
  await Database.connect();
  console.log('Database ready');
} catch (error) {
  console.error('Database connection failed');
}

// 연결 상태 확인
if (Database.getConnectionStatus()) {
  console.log('Database is connected');
}

// 애플리케이션 종료 시 (자동 처리됨)
process.on('SIGINT', () => {
  // Database.disconnect() 자동 호출
});
```

## 설계 특징
- **Graceful Degradation**: 데이터베이스 연결 실패 시에도 애플리케이션 계속 실행
- **Environment-aware**: 개발과 프로덕션 환경의 다른 에러 처리
- **Event-driven**: Mongoose 이벤트 기반 상태 모니터링
- **Process Safety**: 프로세스 종료 시 안전한 정리

## 잠재적 문제점
- MongoDB URI가 없을 때 null을 반환하지만, 호출하는 쪽에서 null 체크가 필요
- 재연결 로직이 없어 연결이 끊어지면 수동으로 재시작 필요
- 연결 풀 설정이 없어 고부하 상황에서 성능 이슈 가능
