# utils/logger.js

---
type: file
path: src/utils/logger.js
language: javascript
---

## 목적
애플리케이션 전반에서 사용되는 통합 로깅 시스템입니다. 모듈별 로거 생성, 로그 레벨 관리, 컬러 출력 등의 기능을 제공합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `Logger` | 클래스 | 모듈별 로거 인스턴스 관리 |
| `error()` | 메서드 | 에러 로그 출력 (스택 트레이스 포함) |
| `warn()` | 메서드 | 경고 로그 출력 |
| `info()` | 메서드 | 정보 로그 출력 |
| `debug()` | 메서드 | 디버그 로그 출력 |
| `success()` | 메서드 | 성공 메시지 출력 |
| `child()` | 메서드 | 컨텍스트가 추가된 하위 로거 생성 |

## 의존성
- `chalk`: 터미널 컬러 출력

## 데이터 흐름
로그 요청 → 레벨 검사 → 메시지 포맷팅 → 컬러 적용 → 콘솔 출력

## 주요 기능

### 로그 레벨 관리
- `error`: 0 (항상 출력)
- `warn`: 1
- `info`: 2 (기본값)
- `debug`: 3 (상세 디버깅)

### 컬러 코딩
- 🔴 에러: 빨간색
- 🟡 경고: 노란색
- 🔵 정보: 파란색
- ⚪ 디버그: 회색
- 🟢 성공: 초록색

### 메시지 포맷팅
```
2025-05-14T10:30:45.123Z [ModuleName] INFO: Message {"meta": "data"}
```

## 코드 예시
```javascript
import { Logger } from '../utils/logger.js';

// 모듈별 로거 생성
const logger = new Logger('MyModule');

// 기본 로깅
logger.info('Processing started');
logger.warn('Memory usage high', { usage: '85%' });
logger.error('Connection failed', error, { retry: 3 });

// 메타데이터 포함
logger.info('User logged in', { userId: 123, ip: '192.168.1.1' });

// 하위 로거 생성
const dbLogger = logger.child('Database');
dbLogger.debug('Query executed', { query: 'SELECT * FROM users' });

// 로그 레벨 설정
process.env.LOG_LEVEL = 'debug'; // 모든 로그 출력
```

## 환경 설정
```bash
# .env 파일에서 로그 레벨 설정
LOG_LEVEL=info  # error | warn | info | debug
```

## 설계 특징
- **모듈별 구분**: 각 모듈마다 고유한 로거 인스턴스
- **컨텍스트 상속**: child() 메서드로 하위 컨텍스트 생성
- **메타데이터 지원**: JSON 형태의 추가 정보 포함
- **환경 인식**: LOG_LEVEL 환경 변수로 동적 제어

## 잠재적 개선사항
- 파일 출력 지원 (winston 라이브러리 통합)
- 구조화된 로깅 (JSON 로그 포맷)
- 로그 전송 (로그 수집 시스템 연동)
- 성능 최적화 (비동기 로깅)
