# 개발 환경 설정 가이드

---
type: guide
---

## 개요
AI Quiz Backend 개발을 위한 환경 설정과 개발 워크플로우를 안내합니다.

## 📋 요구사항

### 시스템 요구사항
- **Node.js**: 18.0 이상
- **npm**: 9.0 이상  
- **Python**: 3.9 이상 (선택적)
- **Docker**: 20.10 이상 (선택적)
- **Git**: 2.0 이상

### 외부 서비스
- **OpenAI API**: 필수 (API 키 필요)
- **MongoDB**: 필수
- **Qdrant**: 벡터 데이터베이스
- **Tesseract OCR**: PDF OCR용 (선택적)

## 🚀 빠른 시작

### 1. 저장소 클론
```bash
git clone <repository-url>
cd AI_QUIZ/backend
```

### 2. 자동 설정 스크립트 실행
```bash
chmod +x setup.sh
./setup.sh
```

### 3. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일에서 OPENAI_API_KEY 설정
```

### 4. 개발 서버 시작
```bash
npm run dev
```

## 🔧 수동 설정

### Node.js 환경 설정

#### 1. 의존성 설치
```bash
npm install
```

#### 2. 필수 디렉토리 생성
```bash
mkdir -p uploads logs temp
```

#### 3. 외부 도구 설치 (Ubuntu/Debian)
```bash
# PDF 처리용
sudo apt-get update
sudo apt-get install poppler-utils tesseract-ocr tesseract-ocr-kor

# 개발 도구
sudo apt-get install curl wget git
```

#### 4. 외부 도구 설치 (macOS)
```bash
# Homebrew 사용
brew install poppler tesseract tesseract-lang
brew install curl wget git
```

### Python 환경 설정 (선택적)

#### 1. 가상환경 생성
```bash
cd python_services
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

#### 2. Python 의존성 설치
```bash
pip install -r requirements.txt
```

#### 3. 언어 모델 다운로드
```bash
python -m spacy download ko_core_news_sm
python -m nltk.downloader punkt stopwords
```

## 🐳 Docker 개발 환경

### 전체 스택 실행
```bash
# 모든 서비스 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f app

# 서비스 중지
docker-compose down
```

### Python 포함 실행
```bash
# Python 서비스 포함
docker-compose -f docker-compose-with-python.yml up -d
```

### 개별 서비스 실행
```bash
# MongoDB만 실행
docker-compose up -d mongodb

# Qdrant만 실행
docker-compose up -d qdrant
```

## 🔑 환경 변수 설정

### 필수 환경 변수
```bash
# .env 파일
OPENAI_API_KEY=sk-your-openai-api-key-here
NODE_ENV=development
PORT=5000
```

### 완전한 개발 설정
```bash
# 서버 설정
PORT=5000
NODE_ENV=development
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# 데이터베이스
MONGODB_URI=mongodb://localhost:27017/ai_quiz
QDRANT_URL=http://localhost:6333

# AI 서비스
OPENAI_API_KEY=sk-your-key
LLM_MODEL=gpt-4-turbo-preview
LLM_TEMPERATURE=0.7

# 청킹 설정
CHUNK_MAX_TOKENS=500
CHUNK_OVERLAP=50

# 로깅
LOG_LEVEL=debug

# Python 통합 (선택적)
USE_PYTHON_PDF=true
PYTHON_SERVICE_URL=http://localhost:8001
```

## 🛠 개발 도구

### VSCode 확장
```json
// .vscode/extensions.json
{
  "recommendations": [
    "ms-vscode.vscode-node-tslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "ms-python.python",
    "ms-vscode.vscode-json"
  ]
}
```

### VSCode 설정
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "python.defaultInterpreterPath": "./python_services/venv/bin/python"
}
```

### ESLint 설정
```json
// .eslintrc.json
{
  "env": {
    "es2021": true,
    "node": true
  },
  "extends": ["eslint:recommended"],
  "parserOptions": {
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "rules": {
    "indent": ["error", 2],
    "quotes": ["error", "single"],
    "semi": ["error", "always"]
  }
}
```

## 🔄 개발 워크플로우

### 1. Git 브랜치 전략
```bash
# 기능 개발
git checkout -b feature/pdf-processing-improvement
git add .
git commit -m "feat: improve PDF text extraction accuracy"
git push origin feature/pdf-processing-improvement
```

### 2. 테스트 실행
```bash
# 단위 테스트 (향후 구현)
npm test

# 통합 테스트
npm run test:integration

# API 테스트
curl http://localhost:5000/health
```

### 3. 코드 품질 체크
```bash
# 린팅
npm run lint

# 포맷팅
npm run format

# 타입 체크 (TypeScript 사용 시)
npm run type-check
```

## 🔍 디버깅

### Node.js 디버깅
```bash
# 디버그 모드로 시작
npm run dev:debug

# 특정 모듈 디버깅
DEBUG=PDFExtractor,TextProcessor npm run dev
```

### 로그 레벨 조정
```bash
# 상세 로그
LOG_LEVEL=debug npm run dev

# 에러만 표시
LOG_LEVEL=error npm run dev
```

### Python 서비스 디버깅
```bash
cd python_services
python -m debugpy --wait-for-client --listen 5678 pdf_service.py
```

## 📊 성능 프로파일링

### Node.js 프로파일링
```bash
# CPU 프로파일링
node --prof src/index.js

# 메모리 사용량 모니터링
node --inspect src/index.js
```

### 벤치마킹
```bash
# API 로드 테스트
npm install -g autocannon
autocannon -c 10 -d 30 http://localhost:5000/health
```

## 🚨 일반적인 문제 해결

### 1. 포트 충돌
```bash
# 포트 5000 사용 중 확인
lsof -i :5000
# 또는
netstat -an | grep 5000

# 다른 포트 사용
PORT=5001 npm run dev
```

### 2. 의존성 충돌
```bash
# 노드 모듈 정리
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### 3. MongoDB 연결 실패
```bash
# MongoDB 상태 확인
sudo systemctl status mongod

# Docker MongoDB 재시작
docker-compose restart mongodb
```

### 4. Python 의존성 문제
```bash
# 가상환경 재생성
rm -rf python_services/venv
cd python_services
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 📚 개발 리소스

### 문서 링크
- [[troubleshooting.md]]: 문제해결 가이드
- [[api/documents.md]]: 문서 API 레퍼런스
- [[api/quiz.md]]: 퀴즈 API 레퍼런스
- [[python-integration.md]]: Python 통합 가이드

### 유용한 명령어 모음
```bash
# 개발 서버 재시작
npm run dev

# Docker 로그 실시간 확인
docker-compose logs -f

# 데이터베이스 초기화
docker-compose down -v
docker-compose up -d

# Python 서비스만 재시작
docker-compose restart python-pdf

# 업로드 디렉토리 정리
rm -rf uploads/*
```

## 🔄 지속적 개발

### 코드 품질 유지
- **커밋 전** 항상 `npm run lint` 실행
- **새 기능** 추가 시 테스트 작성
- **API 변경** 시 문서 업데이트
- **성능 이슈** 발견 시 즉시 이슈 생성

### 개발 팁
1. **모듈별 독립 테스트**: 각 모듈은 독립적으로 테스트 가능해야 함
2. **로깅 활용**: 개발 중 상세한 로그로 디버깅
3. **환경 분리**: 개발/테스트/프로덕션 환경 명확히 구분
4. **문서 업데이트**: 코드 변경 시 관련 문서도 함께 업데이트

이 가이드를 따라 설정하면 AI Quiz Backend 개발을 위한 완벽한 환경을 구축할 수 있습니다! 🚀
