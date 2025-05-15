# AI Quiz Backend 학습 가이드라인

---
type: guide
---

## 🎯 목적
AI Quiz Backend 프로젝트를 체계적으로 이해하고 개발할 수 있도록 돕는 단계별 학습 경로를 제시합니다.

## 📚 학습 순서

### 1단계: 프로젝트 전체 이해 (30분)
**목표**: 프로젝트의 목적과 전체 구조 파악

1. [[project.md]] - 프로젝트 개요 및 아키텍처
2. [[README.md]] - 프로젝트 설정 및 실행 방법
3. [[map.md]] - 코드 관계도 및 데이터 흐름

**체크포인트**: 
- [ ] 프로젝트의 목적을 설명할 수 있나요?
- [ ] 주요 기술 스택을 나열할 수 있나요?
- [ ] 전체 시스템 흐름을 이해했나요?

### 2단계: 개발 환경 설정 (1시간)
**목표**: 로컬에서 프로젝트 실행하기

1. [[development/setup.md]] - 개발 환경 설정
2. [[deployment/docker.md]] - Docker를 사용한 실행

**실습 과제**:
```bash
# 1. 개발 환경 설정
npm install
cp .env.example .env
# .env에서 OPENAI_API_KEY 설정

# 2. Docker로 실행
docker-compose up -d

# 3. 헬스 체크
curl http://localhost:5000/health
```

**체크포인트**:
- [ ] 서버가 성공적으로 실행되나요?
- [ ] 헬스 체크가 정상 응답하나요?
- [ ] MongoDB와 Qdrant가 연결되나요?

### 3단계: Core 모듈 이해 (30분)
**목표**: 프로젝트의 기반 구조 이해

1. [[src/core/config.js.md]] - 설정 관리 시스템
2. [[src/core/database.js.md]] - 데이터베이스 연결
3. [[src/utils/logger.js.md]] - 로깅 시스템

**실습 과제**:
```javascript
// config 사용법 확인
import { Config } from './core/config.js';
console.log('현재 포트:', Config.PORT);

// 로거 사용법 확인
import { Logger } from './utils/logger.js';
const logger = new Logger('Test');
logger.info('테스트 로그');
```

**체크포인트**:
- [ ] 환경 변수 설정 방법을 이해했나요?
- [ ] 로깅 시스템 사용법을 알고 있나요?

### 4단계: PDF 처리 모듈 (1시간)
**목표**: PDF에서 텍스트 추출하는 과정 이해

1. [[src/modules/preprocessing/index.md]] - 전처리 모듈 개요
2. [[src/modules/preprocessing/pdfExtractor.js.md]] - PDF 텍스트 추출
3. [[src/modules/preprocessing/textProcessor.js.md]] - 텍스트 정제
4. [[src/modules/preprocessing/textChunker.js.md]] - 텍스트 청킹

**실습 과제**:
```bash
# PDF 업로드 테스트
curl -X POST http://localhost:5000/api/documents/upload \
  -F "pdf=@test.pdf"
```

**체크포인트**:
- [ ] PDF 처리 파이프라인을 설명할 수 있나요?
- [ ] 청킹이 왜 필요한지 이해했나요?

### 5단계: 임베딩 및 벡터 DB (45분)
**목표**: 벡터 임베딩과 검색 시스템 이해

1. [[src/modules/embedding/embeddingService.js.md]] - 임베딩 생성
2. [[src/modules/embedding/vectorDatabaseService.js.md]] - Qdrant 통합
3. [[workflows/pdf-processing.md]] - 전체 처리 흐름

**실습 과제**:
```bash
# 의미적 검색 테스트
curl -X POST http://localhost:5000/api/search/semantic \
  -H "Content-Type: application/json" \
  -d '{"query": "machine learning", "limit": 5}'
```

**체크포인트**:
- [ ] 임베딩이 무엇인지 설명할 수 있나요?
- [ ] 벡터 유사도 검색 원리를 이해했나요?

### 6단계: LLM 및 퀴즈 생성 (1시간)
**목표**: AI를 활용한 퀴즈 생성 이해

1. [[src/modules/quiz/llmService.js.md]] - LLM 서비스
2. [[src/modules/quiz/quizGenerator.js.md]] - 퀴즈 생성
3. [[workflows/quiz-generation.md]] - 퀴즈 생성 흐름

**실습 과제**:
```bash
# 퀴즈 생성 테스트
curl -X POST http://localhost:5000/api/quiz/generate \
  -H "Content-Type: application/json" \
  -d '{
    "documentId": "your_document_id",
    "quizType": "multiple_choice",
    "questionCount": 3
  }'
```

**체크포인트**:
- [ ] 다양한 퀴즈 타입을 설명할 수 있나요?
- [ ] 프롬프트 엔지니어링의 중요성을 이해했나요?

### 7단계: API 구조 이해 (30분)
**목표**: RESTful API 설계 이해

1. [[src/api/routes/index.md]] - 라우트 구조
2. [[api/documents.md]] - 문서 API
3. [[api/quiz.md]] - 퀴즈 API
4. [[api/search.md]] - 검색 API

**체크포인트**:
- [ ] REST API 설계 원칙을 이해했나요?
- [ ] 각 엔드포인트의 역할을 설명할 수 있나요?

### 8단계: Python 통합 (선택적, 45분)
**목표**: Python 서비스 통합 이해

1. [[python-integration.md]] - Python 통합 가이드
2. [[python_services/pdf_processor.py.md]] - Python PDF 처리
3. [[python_services/pdf_service.py.md]] - FastAPI 서비스

**실습 과제**:
```bash
# Python 서비스 실행
cd python_services
pip install -r requirements.txt
python pdf_service.py

# Python 포함 Docker 실행
docker-compose -f docker-compose-with-python.yml up -d
```

### 9단계: 배포 및 운영 (1시간)
**목표**: 프로덕션 배포 방법 이해

1. [[deployment/docker.md]] - Docker 배포
2. [[deployment/production.md]] - 프로덕션 환경
3. [[troubleshooting.md]] - 문제해결

## 🎓 레벨별 학습 경로

### 🟢 초급자 (JavaScript/Node.js 입문자)
**예상 소요 시간**: 6-8시간

1. **필수 과정**: 1단계 → 2단계 → 3단계
2. **추천 과정**: 7단계 (API 이해)
3. **실습 중심**: 간단한 API 호출부터 시작

### 🟡 중급자 (Node.js 유경험자)
**예상 소요 시간**: 4-5시간

1. **빠른 시작**: 1단계 → 2단계
2. **핵심 과정**: 4단계 → 5단계 → 6단계
3. **심화 과정**: 8단계 (Python 통합)

### 🔴 고급자 (시스템 아키텍처 관심)
**예상 소요 시간**: 3-4시간

1. **전체 파악**: 1단계 → map.md 심화 학습
2. **기술 심화**: 5단계 → 6단계 → 8단계
3. **운영 관점**: 9단계 → 모니터링 및 스케일링

## 📝 실습 프로젝트

### 프로젝트 1: 기본 PDF 처리
```javascript
// PDF 업로드 → 텍스트 추출 → 검색 구현
1. PDF 파일 업로드
2. 추출된 텍스트 확인
3. 의미적 검색 테스트
```

### 프로젝트 2: 퀴즈 생성 시스템
```javascript
// 문서 기반 퀴즈 생성 구현
1. 문서 업로드 및 처리
2. 다양한 타입의 퀴즈 생성
3. 퀴즈 품질 평가
```

### 프로젝트 3: Python 통합
```python
# Python 처리 성능 비교
1. Node.js vs Python 처리 속도 측정
2. 한국어 문서 처리 개선
3. OCR 품질 비교
```

## 🔍 각 단계별 핵심 개념

### 텍스트 처리 관련
- **청킹 (Chunking)**: 왜 필요하고 어떻게 하는가?
- **임베딩 (Embedding)**: 텍스트를 벡터로 변환하는 이유
- **벡터 유사도**: 코사인 유사도와 검색 원리

### AI/ML 관련
- **LLM 프롬프트 엔지니어링**: 효과적인 프롬프트 작성
- **퀴즈 생성 전략**: 다양한 문항 타입별 특징
- **품질 평가**: 생성된 퀴즈의 품질 측정

### 시스템 아키텍처
- **마이크로서비스**: 모듈별 독립성과 확장성
- **벡터 데이터베이스**: Qdrant의 특징과 활용
- **하이브리드 처리**: Node.js + Python 조합의 장점

## ❓ 자주 묻는 질문

### Q1: Python 통합이 꼭 필요한가요?
**A**: 필수는 아니지만, 복잡한 PDF나 한국어 문서 처리 시 성능이 현저히 향상됩니다.

### Q2: OpenAI API 없이도 실행 가능한가요?
**A**: LLM 기능 없이는 퀴즈 생성이 불가합니다. 테스트용으로는 mock 데이터를 사용할 수 있습니다.

### Q3: 어떤 PDF가 처리하기 어려운가요?
**A**: 스캔된 이미지, 복잡한 레이아웃, 표/차트가 많은 문서가 어렵습니다.

## 🎯 학습 목표별 가이드

### 📊 이해도 체크리스트
각 단계 완료 후 다음을 확인하세요:

**기본 이해**:
- [ ] 해당 모듈의 목적을 설명할 수 있다
- [ ] 주요 함수/클래스의 역할을 안다
- [ ] 입력과 출력을 이해한다

**심화 이해**:
- [ ] 모듈 간 상호작용을 설명할 수 있다
- [ ] 에러가 발생했을 때 디버깅할 수 있다
- [ ] 성능 최적화 포인트를 안다

**실무 적용**:
- [ ] 요구사항에 맞게 커스터마이징할 수 있다
- [ ] 새로운 기능을 추가할 수 있다
- [ ] 프로덕션 배포를 수행할 수 있다

이 가이드라인을 따라 학습하면 AI Quiz Backend를 완전히 마스터할 수 있습니다! 🚀
