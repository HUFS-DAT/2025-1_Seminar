# modules/quiz/llmService.js

---
type: file
path: src/modules/quiz/llmService.js
language: javascript
---

## 목적
OpenAI API를 활용한 LLM(Large Language Model) 서비스 클래스입니다. 텍스트 생성, 임베딩 생성, 콘텐츠 조정 등의 기능을 제공합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `LLMService` | 클래스 | OpenAI API 통합 서비스 |
| `generateResponse()` | 메서드 | 텍스트 생성 (GPT 모델) |
| `generateBatchResponses()` | 메서드 | 병렬 텍스트 생성 |
| `createEmbeddings()` | 메서드 | 텍스트 임베딩 생성 |
| `moderateContent()` | 메서드 | 콘텐츠 조정 (안전성 검사) |
| `estimateTokenCount()` | 메서드 | 토큰 수 추정 |
| `splitTextByTokens()` | 메서드 | 토큰 제한에 따른 텍스트 분할 |

## 의존성
- `openai`: OpenAI API 클라이언트
- [[src/core/config.js]]: API 키 및 LLM 설정
- [[src/utils/logger.js]]: 로깅 기능

## 데이터 흐름
```mermaid
graph LR
    A[텍스트 입력] --> B[LLM 서비스]
    B --> C[OpenAI API]
    C --> D[응답 처리]
    D --> E[결과 반환]
```

## 주요 기능

### 텍스트 생성
- GPT-4 모델 기본 사용
- 온도(temperature) 및 토큰 제한 설정 가능
- 시스템/사용자 메시지 지원

### 임베딩 생성
- text-embedding-ada-002 모델 사용
- 단일 또는 배열 형태 텍스트 처리
- 1536차원 벡터 출력

### 콘텐츠 조정
- OpenAI Moderation API 활용
- 유해 콘텐츠 자동 감지
- 카테고리별 위반 사항 분석

## 코드 예시
```javascript
const llmService = new LLMService();

// 텍스트 생성
const response = await llmService.generateResponse(
  "Explain machine learning in simple terms",
  { maxTokens: 500, temperature: 0.7 }
);

// 임베딩 생성
const embeddings = await llmService.createEmbeddings([
  "Machine learning overview",
  "Neural networks basics"
]);

// 배치 처리
const responses = await llmService.generateBatchResponses([
  "What is AI?",
  "How does deep learning work?"
]);

// 콘텐츠 조정
const moderation = await llmService.moderateContent("Text to check");
if (moderation.flagged) {
  console.log('Flagged categories:', moderation.categories);
}
```

## 설정 옵션
```javascript
// Config.LLM_CONFIG
{
  model: 'gpt-4-turbo-preview',
  maxTokens: 4000,
  temperature: 0.7
}
```

## 에러 처리
- API 키 검증 및 초기화 실패 처리
- 호출 제한 및 네트워크 오류 대응
- 상세한 오류 로깅 및 메타데이터 포함

## 성능 최적화
- 배치 처리로 API 호출 효율성 향상
- 토큰 추정을 통한 비용 예측
- 디버그 로깅을 통한 사용량 모니터링

## 잠재적 문제점
- API 호출 비용 누적
- 요청 제한 (RPM/TPM) 도달 가능
- 토큰 추정의 부정확성
- 네트워크 지연으로 인한 응답 시간
