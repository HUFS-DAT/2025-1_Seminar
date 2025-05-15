# modules/embedding/embeddingService.js

---
type: file
path: src/modules/embedding/embeddingService.js
language: javascript
---

## 목적
텍스트를 벡터 임베딩으로 변환하고, 벡터 간 유사도 계산을 수행하는 서비스입니다. E5 모델 지원을 목표로 하지만 현재는 OpenAI 임베딩을 사용합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `EmbeddingService` | 클래스 | 임베딩 생성 및 관리 |
| `generateEmbeddings()` | 메서드 | 텍스트 청크 배열에 대한 임베딩 생성 |
| `generateQueryEmbedding()` | 메서드 | 검색 쿼리에 대한 임베딩 생성 |
| `cosineSimilarity()` | 메서드 | 두 벡터 간 코사인 유사도 계산 |
| `findSimilarChunks()` | 메서드 | 쿼리와 유사한 청크 검색 |
| `getEmbeddingStats()` | 메서드 | 임베딩 통계 정보 제공 |

## 의존성
- [[src/core/config.js]]: E5 모델 설정 및 임베딩 구성
- [[src/utils/logger.js]]: 로깅 기능
- [[src/modules/quiz/llmService.js]]: OpenAI 임베딩 생성

## 데이터 흐름
```mermaid
graph LR
    A[텍스트 청크] --> B[텍스트 전처리]
    B --> C[배치 처리]
    C --> D[임베딩 생성]
    D --> E[메타데이터 추가]
    E --> F[결과 반환]
```

## 주요 기능

### 임베딩 생성
- 텍스트 청크 배열을 배치 단위로 처리
- E5 모델 prefix 적용 (`passage:` for chunks, `query:` for queries)
- OpenAI 임베딩 fallback 지원

### 유사도 검색
- 코사인 유사도 기반 상위 K개 결과 반환
- 유사도 점수와 함께 청크 정보 제공
- 임베딩 벡터 차원 검증

### 성능 최적화
- 배치 크기 100개 단위로 처리
- 텍스트 길이 제한 (토큰 기반)
- 메모리 효율적인 배치 처리

## 코드 예시
```javascript
const embeddingService = new EmbeddingService();

// 텍스트 청크 임베딩 생성
const chunks = [
  { content: "Machine learning introduction", index: 0, ... },
  { content: "Deep learning fundamentals", index: 1, ... }
];

const embeddedChunks = await embeddingService.generateEmbeddings(chunks);

// 쿼리 임베딩 생성
const queryEmbedding = await embeddingService.generateQueryEmbedding(
  "What is machine learning?"
);

// 유사 청크 검색
const similarChunks = embeddingService.findSimilarChunks(
  queryEmbedding, 
  embeddedChunks, 
  5 // top 5 results
);

// 통계 확인
const stats = embeddingService.getEmbeddingStats(embeddedChunks);
console.log('Embedding stats:', stats);
```

## E5 모델 설정
```javascript
// Config.EMBEDDING_MODEL
{
  name: 'intfloat/e5-small-v2',
  dimensions: 384,
  maxTokens: 512,
  prefix: {
    query: 'query: ',
    passage: 'passage: '
  }
}
```

## 임베딩 결과 구조
```javascript
{
  content: "원본 텍스트",
  index: 0,
  tokenCount: 245,
  pageNumber: 1,
  chunkId: "chunk_0_1715692800000",
  embedding: [0.1, -0.2, 0.3, ...], // 벡터
  embeddingModel: "text-embedding-ada-002",
  embeddingDimensions: 1536
}
```

## 유사도 검색 결과
```javascript
[
  {
    ...chunkData,
    similarity: 0.87 // 코사인 유사도 점수
  },
  ...
]
```

## 설계 특징
- **E5 호환성**: E5 모델 prefix 규칙 준수
- **Fallback 전략**: OpenAI API 사용으로 즉시 동작 가능
- **확장성**: 향후 로컬 E5 모델 통합 준비
- **효율성**: 배치 처리로 API 호출 최소화

## 잠재적 개선사항
- 로컬 E5 모델 통합 (Hugging Face Transformers.js)
- 임베딩 캐싱 시스템
- 다양한 유사도 메트릭 지원
- 임베딩 압축 및 양자화
