# 검색 API

---
type: api
---

## 개요
벡터 임베딩을 활용한 의미적 검색과 유사도 기반 청크 검색을 제공하는 API 엔드포인트들입니다.

## 엔드포인트 목록

### 1. 의미적 검색
```http
POST /api/search/semantic
```

**설명**: 자연어 쿼리를 벡터로 변환하여 유사한 텍스트 청크를 검색합니다.

**요청**:
```json
{
  "query": "machine learning algorithms",
  "documentId": "doc_1715692800000_abc123",
  "limit": 10,
  "scoreThreshold": 0.7
}
```

**매개변수**:
- `query` (필수): 검색할 자연어 텍스트
- `documentId` (옵션): 특정 문서로 검색 범위 제한
- `limit` (옵션): 반환할 최대 결과 수 (기본값: 10)
- `scoreThreshold` (옵션): 최소 유사도 점수 (기본값: 0.7)

**응답**:
```json
{
  "success": true,
  "results": [
    {
      "id": "doc_123_0",
      "score": 0.87,
      "payload": {
        "chunkId": "chunk_0_1715692800000",
        "documentId": "doc_123",
        "content": "Machine learning is a subset of AI...",
        "tokenCount": 245,
        "pageNumber": 1,
        "index": 0,
        "embeddingModel": "text-embedding-ada-002",
        "createdAt": "2025-05-14T10:30:45.123Z"
      }
    }
  ],
  "metadata": {
    "query": "machine learning algorithms",
    "resultCount": 5,
    "documentId": "doc_123"
  }
}
```

### 2. 유사 청크 검색
```http
GET /api/search/similar/:chunkId
```

**설명**: 특정 청크와 유사한 다른 청크들을 찾습니다.

**매개변수**:
- `chunkId`: 기준이 되는 청크 ID
- `limit` (쿼리 파라미터): 반환할 결과 수 (기본값: 5)
- `scoreThreshold` (쿼리 파라미터): 최소 유사도 점수

**요청 예시**:
```http
GET /api/search/similar/chunk_0_1715692800000?limit=5&scoreThreshold=0.8
```

**응답**:
```json
{
  "success": true,
  "baseChunk": {
    "chunkId": "chunk_0_1715692800000",
    "content": "Machine learning overview..."
  },
  "similarChunks": [
    {
      "chunkId": "chunk_5_1715692800000",
      "content": "Deep learning algorithms...",
      "similarity": 0.82,
      "documentId": "doc_123",
      "pageNumber": 3
    }
  ],
  "metadata": {
    "baseChunkId": "chunk_0_1715692800000",
    "resultCount": 3
  }
}
```

**상태**: 현재 미구현 (501 Not Implemented)

## 고급 검색 옵션

### 필터링 검색
의미적 검색에서 추가적인 필터 조건을 적용할 수 있습니다.

**요청**:
```json
{
  "query": "neural networks",
  "filters": {
    "documentId": "doc_123",
    "pageNumber": 5,
    "minTokenCount": 100
  },
  "limit": 5,
  "scoreThreshold": 0.75
}
```

### 하이브리드 검색 (향후 구현 예정)
벡터 검색과 키워드 검색을 결합한 하이브리드 접근법:

```json
{
  "query": "machine learning",
  "keywords": ["algorithm", "neural", "training"],
  "hybridWeight": 0.7,
  "limit": 10
}
```

## 검색 프로세스

### 의미적 검색 처리 과정
1. 쿼리 텍스트를 임베딩 벡터로 변환
2. 벡터 데이터베이스에서 유사도 검색 수행
3. 점수 임계값 적용하여 필터링
4. 메타데이터와 함께 결과 반환

```mermaid
graph LR
    A[검색 쿼리] --> B[임베딩 생성]
    B --> C[벡터 유사도 검색]
    C --> D[점수 필터링]
    D --> E[결과 반환]
```

## 오류 응답

### 400 Bad Request
```json
{
  "error": "Bad Request",
  "message": "Search query is required"
}
```

### 404 Not Found
```json
{
  "error": "Not Found",
  "message": "Chunk not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal Server Error",
  "message": "Failed to perform semantic search"
}
```

## 구현 상태

| 엔드포인트 | 상태 | 구현 파일 |
|-----------|------|----------|
| POST /semantic | ✅ 완료 | [[src/index.js]] |
| GET /similar/:chunkId | ❌ 미구현 | - |

## 사용 예시

### cURL
```bash
# 의미적 검색
curl -X POST http://localhost:5000/api/search/semantic \
  -H "Content-Type: application/json" \
  -d '{
    "query": "artificial intelligence",
    "limit": 5,
    "scoreThreshold": 0.8
  }'

# 유사 청크 검색 (미구현)
curl http://localhost:5000/api/search/similar/chunk_123?limit=3
```

### JavaScript
```javascript
// 의미적 검색
const searchResults = await fetch('/api/search/semantic', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    query: 'machine learning algorithms',
    documentId: 'doc_123',
    limit: 10
  })
});

const results = await searchResults.json();
console.log('검색 결과:', results.results);

// 결과 활용
results.results.forEach(result => {
  console.log(`점수: ${result.score}`);
  console.log(`내용: ${result.payload.content}`);
});
```

## 성능 고려사항

### 최적화 방법
- **벡터 인덱싱**: Qdrant의 HNSW 인덱스 활용
- **배치 검색**: 여러 쿼리를 동시에 처리
- **캐싱**: 자주 검색되는 쿼리 결과 캐싱
- **필터링**: 메타데이터 필터링으로 검색 범위 축소

### 검색 품질 향상
- **쿼리 확장**: 동의어, 관련어 추가
- **리랭킹**: 추가적인 모델로 결과 재정렬
- **개인화**: 사용자 피드백 반영

## 관련 파일
- [[src/index.js]]: 메인 라우트 핸들러
- [[src/modules/embedding/embeddingService.js]]: 임베딩 생성 및 유사도 계산
- [[src/modules/embedding/vectorDatabaseService.js]]: 벡터 DB 검색
- [[src/core/config.js]]: 임베딩 모델 설정

## 벡터 유사도 이해
- **코사인 유사도**: -1 ~ 1 범위, 1에 가까울수록 유사
- **임계값 설정**: 0.7 이상 권장 (높은 관련성)
- **차원 수**: OpenAI ada-002 모델은 1536차원
