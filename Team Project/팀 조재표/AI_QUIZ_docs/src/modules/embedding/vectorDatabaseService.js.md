# modules/embedding/vectorDatabaseService.js

---
type: file
path: src/modules/embedding/vectorDatabaseService.js
language: javascript
---

## 목적
Qdrant 벡터 데이터베이스와의 통합을 담당하는 서비스입니다. 임베딩 벡터의 저장, 검색, 관리를 수행합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `VectorDatabaseService` | 클래스 | Qdrant 클라이언트 래퍼 |
| `storeChunks()` | 메서드 | 임베딩된 청크 저장 |
| `searchSimilar()` | 메서드 | 벡터 유사도 검색 |
| `getChunksByDocument()` | 메서드 | 문서별 청크 조회 |
| `deleteDocument()` | 메서드 | 문서 및 관련 벡터 삭제 |
| `searchWithFilters()` | 메서드 | 필터 조건과 함께 검색 |
| `getCollectionStats()` | 메서드 | 컬렉션 통계 조회 |

## 의존성
- `@qdrant/js-client-rest`: Qdrant 클라이언트 라이브러리
- [[src/core/config.js]]: Qdrant 연결 설정
- [[src/utils/logger.js]]: 로깅 기능

## 데이터 흐름
```mermaid
graph LR
    A[임베딩된 청크] --> B[Qdrant 포인트 변환]
    B --> C[배치 업로드]
    C --> D[벡터 인덱싱]
    D --> E[검색 가능]
```

## 주요 기능

### 벡터 저장
- 100개 단위 배치 업로드
- 자동 컬렉션 생성
- 풍부한 메타데이터 저장

### 유사도 검색
- 코사인 유사도 기반 검색
- 점수 임계값 설정 가능
- 메타데이터 필터링 지원

### 문서 관리
- 문서 단위 청크 조회
- 문서 전체 삭제
- 페이지별 필터링

## 코드 예시
```javascript
const vectorService = new VectorDatabaseService();

// 임베딩된 청크 저장
const embeddedChunks = [/* ... */];
await vectorService.storeChunks(embeddedChunks, 'doc_123');

// 벡터 유사도 검색
const queryVector = [/* 1536-dimensional vector */];
const results = await vectorService.searchSimilar(queryVector, {
  limit: 10,
  scoreThreshold: 0.7
});

// 문서별 청크 조회
const documentChunks = await vectorService.getChunksByDocument('doc_123');

// 필터와 함께 검색
const filtered = await vectorService.searchWithFilters(queryVector, {
  documentId: 'doc_123',
  pageNumber: 5,
  minScore: 0.8
});

// 컬렉션 통계
const stats = await vectorService.getCollectionStats();
console.log('Points:', stats.pointsCount);
```

## Qdrant 컬렉션 설정
```javascript
{
  vectors: {
    size: 1536, // OpenAI 임베딩 차원
    distance: 'Cosine' // 코사인 유사도
  }
}
```

## 저장되는 데이터 구조
```javascript
// Qdrant Point
{
  id: "doc_123_0",
  vector: [0.1, -0.2, 0.3, ...],
  payload: {
    chunkId: "chunk_0_1715692800000",
    documentId: "doc_123",
    content: "텍스트 내용",
    tokenCount: 245,
    pageNumber: 1,
    index: 0,
    embeddingModel: "text-embedding-ada-002",
    createdAt: "2025-05-14T10:30:45.123Z"
  }
}
```

## 검색 결과 형식
```javascript
[
  {
    id: "doc_123_0",
    score: 0.87,
    payload: {
      chunkId: "chunk_0_1715692800000",
      content: "검색된 텍스트",
      // ... 기타 메타데이터
    },
    vector: [/* 필요시 벡터 포함 */]
  }
]
```

## 성능 최적화
- **배치 업로드**: 100개 단위로 효율적 저장
- **인덱스 최적화**: 자동 벡터 인덱싱
- **필터링**: 메타데이터 기반 사전 필터링
- **스코어 임계값**: 불필요한 결과 제거

## 에러 처리
- 연결 실패 시 graceful degradation
- 컬렉션 자동 생성
- 상세한 오류 로깅

## 확장 기능
- 필드 인덱스 생성 지원
- 배치 업데이트 기능
- 다양한 필터 조건 지원
- 백업 및 복원 (미구현)

## 잠재적 개선사항
- 연결 풀링 구현
- 재시도 로직 추가
- 벡터 압축 지원
- 실시간 인덱스 최적화
