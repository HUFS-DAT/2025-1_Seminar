# AI Quiz Backend Project

---
type: project
name: AI Quiz Backend
updated: 2025-05-14
---

## 목적
PDF 문서에서 텍스트를 추출하고 AI를 활용하여 퀴즈를 생성하는 백엔드 시스템입니다. 머신러닝을 통한 텍스트 전처리와 임베딩, 그리고 LLM을 활용한 퀴즈 생성을 지원합니다.

## 아키텍처
### 모듈형 아키텍처 (Module-Based Architecture)
- **API 계층**: Express.js 기반 REST API
- **처리 모듈**: PDF 추출, 텍스트 처리, 임베딩, 퀴즈 생성
- **코어 레이어**: 설정 관리, 데이터베이스 연결
- **벡터 저장소**: Qdrant를 통한 임베딩 벡터 관리

### 데이터 흐름
PDF 업로드 → 텍스트 추출 → 텍스트 전처리 → 청킹 → 임베딩 → 벡터 저장소 → 퀴즈 생성

## 주요 디렉토리
- `src/api/`: API 엔드포인트 및 미들웨어
- `src/core/`: 설정 및 데이터베이스 연결 관리
- `src/modules/`: 핵심 비즈니스 로직 모듈
  - `preprocessing/`: PDF 추출 및 텍스트 처리
  - `embedding/`: 텍스트 임베딩 생성 및 벡터 DB 관리
  - `quiz/`: 퀴즈 생성 로직
- `src/utils/`: 공통 유틸리티 함수

## 기술 스택
- **언어**: JavaScript (ES6+)
- **런타임**: Node.js 18+
- **프레임워크**: Express.js
- **데이터베이스**: MongoDB (Mongoose ODM)
- **벡터 데이터베이스**: Qdrant
- **AI/ML**: 
  - OpenAI API (GPT-4)
  - OpenAI Embeddings (text-embedding-ada-002)
- **PDF 처리**: pdf-parse, PyMuPDF, Tesseract OCR

## 주요 워크플로우
1. **문서 처리 파이프라인**: PDF → 텍스트 추출 → 정제 → 청킹 → 임베딩 → 벡터 저장
2. **퀴즈 생성**: 텍스트 청크 선택 → LLM 처리 → 퀴즈 문항 생성 → 검증
3. **의미적 검색**: 사용자 쿼리 → 임베딩 → 벡터 유사도 검색 → 관련 콘텐츠 반환

## API 엔드포인트

### 문서 처리
- `POST /api/documents/upload` - PDF 파일 업로드 및 처리
- `GET /api/documents/:id` - 문서 정보 조회
- `GET /api/documents/:id/chunks` - 문서 청크 조회
- `DELETE /api/documents/:id` - 문서 삭제

### 퀴즈 생성
- `POST /api/quiz/generate` - 문서 기반 퀴즈 생성
- `POST /api/quiz/generate-from-query` - 검색 기반 퀴즈 생성
- `GET /api/quiz/:id` - 퀴즈 조회

### 검색
- `POST /api/search/semantic` - 의미적 검색
- `GET /api/search/similar/:chunkId` - 유사 청크 검색

### 시스템
- `GET /health` - 서버 상태 확인
- `GET /api/stats` - 시스템 통계

## 구현 상태

### ✅ 완료된 모듈
- **PDF 텍스트 추출** (pdfExtractor.js)
- **텍스트 전처리** (textProcessor.js, textChunker.js)
- **LLM 서비스** (llmService.js)
- **임베딩 서비스** (embeddingService.js)
- **벡터 데이터베이스** (vectorDatabaseService.js)
- **퀴즈 생성** (quizGenerator.js)
- **로깅 시스템** (logger.js)
- **메인 애플리케이션** (index.js)

### 🔧 설정 및 배포
- **환경 설정** (.env.example)
- **Docker 설정** (Dockerfile, docker-compose.yml)
- **패키지 관리** (package.json)
- **설치 스크립트** (setup.sh)

## 환경 변수
```bash
# 필수 환경 변수
OPENAI_API_KEY=your_openai_api_key

# 선택적 환경 변수
PORT=5000
MONGODB_URI=mongodb://localhost:27017/ai_quiz
NODE_ENV=development
UPLOAD_DIR=./uploads
CORS_ORIGINS=http://localhost:3000,http://localhost:3001
QDRANT_URL=http://localhost:6333
QDRANT_API_KEY=your_qdrant_api_key
QDRANT_COLLECTION=ai_quiz_docs
CHUNK_MAX_TOKENS=500
LLM_TEMPERATURE=0.7
LOG_LEVEL=info
```

## 코드 구조
[[src/index]]: Express.js 애플리케이션 메인 서버
[[src/core/config]]: 중앙 집중식 환경 설정 관리
[[src/core/database]]: MongoDB 연결 관리
[[src/modules/preprocessing/index]]: PDF 처리 및 텍스트 전처리
[[src/modules/embedding/index]]: 임베딩 생성 및 벡터 DB 관리
[[src/modules/quiz/index]]: LLM 기반 퀴즈 생성
[[src/utils/logger]]: 애플리케이션 전역 로깅 시스템

## 실행 방법

### 개발 환경
```bash
# 의존성 설치
npm install

# 환경 설정
cp .env.example .env
# .env 파일에서 OPENAI_API_KEY 설정

# 개발 서버 시작
npm run dev
```

### Docker 환경
```bash
# 모든 서비스 시작 (MongoDB, Qdrant 포함)
docker-compose up -d

# 애플리케이션 로그 확인
docker-compose logs -f app
```

## 다음 구현 예정
1. **API 계층 완성** (controllers, middleware, routes)
2. **데이터 모델 정의** (MongoDB 스키마)
3. **테스트 코드 작성** (단위 테스트, 통합 테스트)
4. **API 문서화** (OpenAPI/Swagger)
5. **성능 최적화** (캐싱, 배치 처리)
6. **모니터링 시스템** (메트릭, 로그 수집)
