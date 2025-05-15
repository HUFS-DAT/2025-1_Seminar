# 문서 관리 API

---
type: api
---

## 개요
PDF 문서의 업로드, 처리, 관리를 담당하는 API 엔드포인트들입니다.

## 엔드포인트 목록

### 1. 문서 업로드
```http
POST /api/documents/upload
```

**설명**: PDF 파일을 업로드하고 전체 처리 파이프라인을 실행합니다.

**요청**:
- Content-Type: `multipart/form-data`
- Body: `pdf` 필드에 PDF 파일

**응답**:
```json
{
  "success": true,
  "documentId": "doc_1715692800000_abc123",
  "metadata": {
    "filename": "document.pdf",
    "pageCount": 10,
    "chunkCount": 25,
    "extractionMethod": "pdf-parse",
    "processor": "nodejs"
  }
}
```

**처리 과정**:
1. PDF 파일 저장
2. 텍스트 추출 (Node.js 또는 Python)
3. 텍스트 정제 및 청킹
4. 임베딩 생성
5. 벡터 데이터베이스 저장

### 2. 문서 정보 조회
```http
GET /api/documents/:id
```

**설명**: 특정 문서의 메타데이터를 조회합니다.

**매개변수**:
- `id`: 문서 ID

**응답**:
```json
{
  "success": true,
  "document": {
    "id": "doc_1715692800000_abc123",
    "filename": "document.pdf",
    "uploadedAt": "2025-05-14T10:30:45.123Z",
    "pageCount": 10,
    "chunkCount": 25,
    "status": "processed"
  }
}
```

**상태**: 현재 미구현 (501 Not Implemented)

### 3. 문서 청크 조회
```http
GET /api/documents/:id/chunks
```

**설명**: 특정 문서의 모든 텍스트 청크를 조회합니다.

**매개변수**:
- `id`: 문서 ID
- `page` (옵션): 페이지 번호
- `limit` (옵션): 청크 개수 제한

**응답**:
```json
{
  "success": true,
  "chunks": [
    {
      "chunkId": "chunk_0_1715692800000",
      "content": "텍스트 내용...",
      "pageNumber": 1,
      "tokenCount": 245,
      "index": 0
    }
  ],
  "total": 25,
  "page": 1
}
```

**상태**: 현재 미구현 (501 Not Implemented)

### 4. 문서 삭제
```http
DELETE /api/documents/:id
```

**설명**: 문서와 관련된 모든 데이터를 삭제합니다.

**매개변수**:
- `id`: 문서 ID

**응답**:
```json
{
  "success": true,
  "message": "Document and related data deleted successfully"
}
```

**삭제 대상**:
- 벡터 데이터베이스의 청크들
- MongoDB의 메타데이터
- 업로드된 원본 파일

**상태**: 현재 미구현 (501 Not Implemented)

## 오류 응답

### 400 Bad Request
```json
{
  "error": "Bad Request",
  "message": "No file uploaded"
}
```

### 404 Not Found
```json
{
  "error": "Not Found", 
  "message": "Document not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal Server Error",
  "message": "Failed to process document"
}
```

## 구현 상태

| 엔드포인트 | 상태 | 구현 파일 |
|-----------|------|----------|
| POST /upload | ✅ 완료 | [[src/index.js]] |
| GET /:id | ❌ 미구현 | - |
| GET /:id/chunks | ❌ 미구현 | - |
| DELETE /:id | ❌ 미구현 | - |

## 사용 예시

### cURL
```bash
# 문서 업로드
curl -X POST http://localhost:5000/api/documents/upload \
  -F "pdf=@document.pdf"

# 문서 정보 조회 (미구현)
curl http://localhost:5000/api/documents/doc_123

# 문서 삭제 (미구현)
curl -X DELETE http://localhost:5000/api/documents/doc_123
```

### JavaScript
```javascript
// 문서 업로드
const formData = new FormData();
formData.append('pdf', file);

const response = await fetch('/api/documents/upload', {
  method: 'POST',
  body: formData
});

const result = await response.json();
console.log('업로드 완료:', result.documentId);
```

## 관련 파일
- [[src/index.js]]: 메인 라우트 핸들러
- [[src/modules/preprocessing/pdfExtractor.js]]: PDF 텍스트 추출
- [[src/modules/embedding/vectorDatabaseService.js]]: 벡터 저장소
