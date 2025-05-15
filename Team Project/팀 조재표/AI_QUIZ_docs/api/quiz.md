# 퀴즈 생성 API

---
type: api
---

## 개요
텍스트 청크를 기반으로 AI가 다양한 형태의 퀴즈를 생성하는 API 엔드포인트들입니다.

## 엔드포인트 목록

### 1. 문서 기반 퀴즈 생성
```http
POST /api/quiz/generate
```

**설명**: 특정 문서의 청크들을 사용하여 퀴즈를 생성합니다.

**요청**:
```json
{
  "documentId": "doc_1715692800000_abc123",
  "quizType": "multiple_choice",
  "difficulty": "medium",
  "questionCount": 5,
  "topicFocus": "machine learning"
}
```

**매개변수**:
- `documentId` (필수): 문서 ID
- `quizType` (옵션): 퀴즈 타입
  - `multiple_choice`: 객관식 (기본값)
  - `true_false`: 참/거짓
  - `short_answer`: 단답형
  - `fill_in_blank`: 빈칸 채우기
- `difficulty` (옵션): 난이도
  - `easy`: 쉬움
  - `medium`: 보통 (기본값)
  - `hard`: 어려움
- `questionCount` (옵션): 생성할 문항 수 (기본값: 5)
- `topicFocus` (옵션): 특정 주제 집중

**응답**:
```json
{
  "success": true,
  "quiz": [
    {
      "id": "quiz_1715692800000_abc123",
      "type": "multiple_choice",
      "difficulty": "medium",
      "question": "What is machine learning?",
      "options": [
        "A) A subset of artificial intelligence",
        "B) A programming language",
        "C) A database system",
        "D) A web framework"
      ],
      "correctAnswer": "A",
      "explanation": "Machine learning is indeed a subset of AI...",
      "sourceChunk": "chunk_0_1715692800000",
      "pageNumber": 1,
      "createdAt": "2025-05-14T10:30:45.123Z"
    }
  ],
  "metadata": {
    "documentId": "doc_1715692800000_abc123",
    "questionCount": 5,
    "stats": {
      "totalQuestions": 5,
      "byType": {
        "multiple_choice": 5
      },
      "byDifficulty": {
        "medium": 5
      },
      "averageQuestionLength": 85,
      "questionsWithIssues": 0
    }
  }
}
```

### 2. 검색어 기반 퀴즈 생성
```http
POST /api/quiz/generate-from-query
```

**설명**: 검색어와 유사한 청크를 찾아 퀴즈를 생성합니다.

**요청**:
```json
{
  "query": "neural networks and deep learning",
  "documentId": "doc_1715692800000_abc123",
  "quizType": "multiple_choice",
  "difficulty": "hard",
  "questionCount": 3
}
```

**매개변수**:
- `query` (필수): 검색어/주제
- `documentId` (옵션): 특정 문서 제한
- `quizType` (옵션): 퀴즈 타입
- `difficulty` (옵션): 난이도  
- `questionCount` (옵션): 생성할 문항 수

**응답**: 문서 기반 퀴즈 생성과 동일한 형식

### 3. 퀴즈 조회
```http
GET /api/quiz/:id
```

**설명**: 특정 퀴즈의 상세 정보를 조회합니다.

**매개변수**:
- `id`: 퀴즈 ID

**응답**:
```json
{
  "success": true,
  "quiz": {
    "id": "quiz_1715692800000_abc123",
    "documentId": "doc_1715692800000_abc123",
    "createdAt": "2025-05-14T10:30:45.123Z",
    "questions": [/* 문항 배열 */],
    "metadata": {/* 메타데이터 */}
  }
}
```

**상태**: 현재 미구현 (501 Not Implemented)

## 퀴즈 타입별 상세

### 객관식 (Multiple Choice)
```json
{
  "type": "multiple_choice",
  "question": "질문 내용",
  "options": ["A) 선택지1", "B) 선택지2", "C) 선택지3", "D) 선택지4"],
  "correctAnswer": "A",
  "explanation": "정답 해설"
}
```

### 참/거짓 (True/False)
```json
{
  "type": "true_false",
  "question": "참/거짓 진술문",
  "correctAnswer": true,
  "explanation": "답변 근거"
}
```

### 단답형 (Short Answer)
```json
{
  "type": "short_answer",
  "question": "질문 내용",
  "correctAnswer": "예시 답안",
  "explanation": "답안 해설"
}
```

### 빈칸 채우기 (Fill in Blank)
```json
{
  "type": "fill_in_blank",
  "question": "문장에서 _____ 부분을 채우세요",
  "correctAnswer": "빈칸에 들어갈 답",
  "explanation": "정답 근거"
}
```

## 오류 응답

### 400 Bad Request
```json
{
  "error": "Bad Request",
  "message": "Document ID is required"
}
```

### 404 Not Found  
```json
{
  "error": "Not Found",
  "message": "Document not found or has no chunks"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal Server Error", 
  "message": "Failed to generate quiz"
}
```

## 구현 상태

| 엔드포인트 | 상태 | 구현 파일 |
|-----------|------|----------|
| POST /generate | ✅ 완료 | [[src/index.js]] |
| POST /generate-from-query | ✅ 완료 | [[src/index.js]] |
| GET /:id | ❌ 미구현 | - |

## 사용 예시

### cURL
```bash
# 문서 기반 퀴즈 생성
curl -X POST http://localhost:5000/api/quiz/generate \
  -H "Content-Type: application/json" \
  -d '{
    "documentId": "doc_123",
    "quizType": "multiple_choice",
    "difficulty": "medium",
    "questionCount": 3
  }'

# 검색어 기반 퀴즈 생성
curl -X POST http://localhost:5000/api/quiz/generate-from-query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "artificial intelligence",
    "quizType": "true_false",
    "questionCount": 2
  }'
```

### JavaScript
```javascript
// 퀴즈 생성
const response = await fetch('/api/quiz/generate', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    documentId: 'doc_123',
    quizType: 'multiple_choice',
    difficulty: 'medium',
    questionCount: 5
  })
});

const result = await response.json();
console.log('생성된 퀴즈:', result.quiz);
```

## 관련 파일
- [[src/index.js]]: 메인 라우트 핸들러
- [[src/modules/quiz/quizGenerator.js]]: 퀴즈 생성 로직
- [[src/modules/quiz/llmService.js]]: LLM 서비스
- [[src/modules/embedding/embeddingService.js]]: 임베딩 서비스

## 워크플로우
[[workflows/quiz-generation.md]]: 퀴즈 생성 프로세스 상세
