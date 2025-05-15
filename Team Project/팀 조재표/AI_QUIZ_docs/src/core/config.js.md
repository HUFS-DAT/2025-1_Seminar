# config.js

---
type: file
path: src/core/config.js
language: javascript
---

## 목적
애플리케이션의 모든 환경 변수와 설정값을 중앙 집중식으로 관리하는 설정 클래스입니다. 각 모듈에서 필요한 설정을 일관성 있게 접근할 수 있도록 합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `Config` | 클래스 | 정적 메서드로 모든 설정값 제공 |
| `validate()` | 정적 메서드 | 필수 환경 변수 유효성 검사 |

## 의존성
- `process.env`: 환경 변수 접근

## 데이터 흐름
환경 변수 → Config 클래스 → 각 모듈의 설정 접근

## 주요 설정 그룹

### 서버 설정
- `PORT`: 서버 포트 (기본값: 5000)
- `NODE_ENV`: 실행 환경
- `CORS_ORIGINS`: CORS 허용 도메인

### 데이터베이스 설정
- `MONGODB_URI`: MongoDB 연결 문자열
- `QDRANT_CONFIG`: Qdrant 벡터 데이터베이스 설정

### AI/ML 설정
- `OPENAI_API_KEY`: OpenAI API 키 (필수)
- `EMBEDDING_MODEL`: E5 임베딩 모델 설정
- `LLM_CONFIG`: LLM 모델 설정
- `CHUNK_CONFIG`: 텍스트 청킹 설정

## 코드 예시
```javascript
// 기본 사용법
import { Config } from '../core/config.js';

// 단순 설정값 접근
const port = Config.PORT;

// 객체 설정 접근
const embeddingConfig = Config.EMBEDDING_MODEL;
console.log(embeddingConfig.dimensions); // 384

// 설정 유효성 검사
Config.validate(); // 필수 환경 변수 확인
```

## 설계 특징
- **정적 메서드 패턴**: 인스턴스 생성 없이 설정 접근
- **기본값 제공**: 환경 변수가 없을 때 안전한 기본값 사용
- **타입 변환**: 문자열 환경 변수를 적절한 타입으로 변환
- **설정 그룹화**: 관련 설정들을 객체로 묶어 관리

## 잠재적 문제점
- 환경 변수가 설정되지 않은 경우 `undefined` 반환 가능
- `validate()` 메서드는 OPENAI_API_KEY만 검사함 (다른 필수 값들도 추가 고려 필요)
