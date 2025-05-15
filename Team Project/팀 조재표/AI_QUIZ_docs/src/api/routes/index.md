# api/routes

---
type: directory
path: src/api/routes/
---

## 목적
API 엔드포인트의 라우팅을 정의하는 디렉토리입니다. 각 도메인별로 라우트를 분리하여 관리합니다.

## 주요 파일
현재 구현된 파일 없음

## 구현 예정 파일
| 파일 | 역할 |
|------|------|
| [[src/api/routes/documentRoutes.js]] | 문서 관련 라우트 |
| [[src/api/routes/quizRoutes.js]] | 퀴즈 관련 라우트 |
| [[src/api/routes/searchRoutes.js]] | 검색 관련 라우트 |
| [[src/api/routes/healthRoutes.js]] | 헬스체크 라우트 |
| [[src/api/routes/index.js]] | 라우트 통합 및 설정 |

## 하위 디렉토리
없음

## 현재 라우트 정의

### 메인 애플리케이션 라우트
현재 모든 라우트가 [[src/index.js]]에 정의되어 있습니다:

```javascript
// Health check
app.get('/health', handleHealth);

// Document routes
app.post('/api/documents/upload', upload.single('pdf'), handleDocumentUpload);
app.get('/api/documents/:id', handleGetDocument);
app.get('/api/documents/:id/chunks', handleGetDocumentChunks);
app.delete('/api/documents/:id', handleDeleteDocument);

// Quiz routes
app.post('/api/quiz/generate', handleGenerateQuiz);
app.post('/api/quiz/generate-from-query', handleGenerateQuizFromQuery);
app.get('/api/quiz/:id', handleGetQuiz);

// Search routes
app.post('/api/search/semantic', handleSemanticSearch);
app.get('/api/search/similar/:chunkId', handleFindSimilar);

// Stats route
app.get('/api/stats', handleGetStats);
```

## 라우트 모듈화 계획

### 1. 문서 라우트 (documentRoutes.js)
```javascript
import express from 'express';
import { DocumentController } from '../controllers/documentController.js';
import { upload } from '../middleware/uploadMiddleware.js';
import { authenticate } from '../middleware/authMiddleware.js';

const router = express.Router();
const documentController = new DocumentController();

// 문서 업로드
router.post('/upload', 
  authenticate,
  upload.single('pdf'),
  documentController.uploadDocument
);

// 문서 조회
router.get('/:id', 
  authenticate,
  documentController.getDocument
);

// 문서 청크 조회
router.get('/:id/chunks', 
  authenticate,
  documentController.getDocumentChunks
);

// 문서 삭제
router.delete('/:id', 
  authenticate,
  documentController.deleteDocument
);

export default router;
```

### 2. 퀴즈 라우트 (quizRoutes.js)
```javascript
import express from 'express';
import { QuizController } from '../controllers/quizController.js';
import { validateRequest } from '../middleware/validationMiddleware.js';
import { quizGenerationSchema } from '../schemas/quizSchemas.js';

const router = express.Router();
const quizController = new QuizController();

// 퀴즈 생성
router.post('/generate',
  validateRequest(quizGenerationSchema),
  quizController.generateQuiz
);

// 검색 기반 퀴즈 생성
router.post('/generate-from-query',
  validateRequest(quizGenerationSchema),
  quizController.generateQuizFromQuery
);

// 퀴즈 조회
router.get('/:id',
  quizController.getQuiz
);

export default router;
```

### 3. 검색 라우트 (searchRoutes.js)
```javascript
import express from 'express';
import { SearchController } from '../controllers/searchController.js';
import { rateLimitMiddleware } from '../middleware/rateLimitMiddleware.js';

const router = express.Router();
const searchController = new SearchController();

// 의미적 검색
router.post('/semantic',
  rateLimitMiddleware.searchLimit,
  searchController.semanticSearch
);

// 유사 청크 검색
router.get('/similar/:chunkId',
  searchController.findSimilar
);

export default router;
```

### 4. 통합 라우트 (index.js)
```javascript
import express from 'express';
import documentRoutes from './documentRoutes.js';
import quizRoutes from './quizRoutes.js';
import searchRoutes from './searchRoutes.js';
import healthRoutes from './healthRoutes.js';

const router = express.Router();

// API 버전 관리
const API_VERSION = '/api/v1';

// 라우트 등록
router.use(`${API_VERSION}/documents`, documentRoutes);
router.use(`${API_VERSION}/quiz`, quizRoutes);
router.use(`${API_VERSION}/search`, searchRoutes);
router.use('/health', healthRoutes);

// API 정보 엔드포인트
router.get('/api', (req, res) => {
  res.json({
    name: 'AI Quiz Backend API',
    version: '1.0.0',
    endpoints: {
      documents: `${API_VERSION}/documents`,
      quiz: `${API_VERSION}/quiz`,
      search: `${API_VERSION}/search`,
      health: '/health'
    }
  });
});

export default router;
```

## 라우트 패턴

### REST 규칙 준수
- `GET /api/documents` - 목록 조회
- `GET /api/documents/:id` - 단일 조회
- `POST /api/documents` - 생성
- `PUT /api/documents/:id` - 전체 수정
- `PATCH /api/documents/:id` - 부분 수정
- `DELETE /api/documents/:id` - 삭제

### 중첩 리소스
- `GET /api/documents/:id/chunks` - 문서의 청크 목록
- `POST /api/quiz/:id/submit` - 퀴즈 답안 제출

### 액션 기반 라우트
- `POST /api/quiz/generate` - 퀴즈 생성
- `POST /api/search/semantic` - 의미적 검색

## 미들웨어 적용

### 전역 미들웨어
- 인증/인가 (선택적)
- CORS 처리
- 요청 로깅
- 에러 처리

### 라우트별 미들웨어
- 파일 업로드 (문서 업로드)
- Rate limiting (검색, 퀴즈 생성)
- 입력 검증 (각 POST 요청)

## API 버전 관리

### 현재 버전
- `/api/*` - 버전 없는 API (레거시)

### 미래 버전
- `/api/v1/*` - 첫 번째 안정 버전
- `/api/v2/*` - 향후 버전

## 에러 처리

### 표준 에러 응답
```javascript
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {},
  "timestamp": "2025-05-14T10:30:45.123Z"
}
```

### HTTP 상태 코드
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity
- `429` - Too Many Requests
- `500` - Internal Server Error

## 개선 사항

### 현재 문제점
1. 모든 라우트가 하나의 파일에 집중
2. 컨트롤러와 라우트가 분리되지 않음
3. 일관되지 않은 에러 처리
4. API 버전 관리 부재

### 개선 방향
1. 도메인별 라우트 파일 분리
2. 컨트롤러 계층 도입
3. 표준화된 응답 형식
4. API 문서 자동 생성 (OpenAPI/Swagger)

## 관련 파일
- [[src/index.js]]: 현재 라우트 정의
- [[src/api/controllers/index]]: 컨트롤러 계층
- [[src/api/middleware/index]]: 미들웨어 계층
- [[api/documents.md]]: 문서 API 명세
- [[api/quiz.md]]: 퀴즈 API 명세
- [[api/search.md]]: 검색 API 명세
