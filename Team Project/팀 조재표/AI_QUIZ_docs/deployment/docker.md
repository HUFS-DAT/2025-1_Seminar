# Docker 배포 가이드

---
type: guide
---

## 개요
AI Quiz Backend를 Docker를 사용하여 배포하는 방법을 안내합니다. 개발 환경부터 프로덕션까지 모든 시나리오를 커버합니다.

## 🐳 Docker 구성 요소

### 서비스 목록
1. **app**: Node.js 메인 애플리케이션
2. **python-pdf**: Python PDF 처리 서비스 (선택적)
3. **mongodb**: MongoDB 데이터베이스
4. **qdrant**: 벡터 데이터베이스
5. **mongo-express**: MongoDB 관리 UI (선택적)

## 📁 파일 구조

```
backend/
├── Dockerfile              # Node.js 앱 이미지
├── Dockerfile.python       # Python 서비스 이미지
├── docker-compose.yml      # 기본 구성
├── docker-compose-with-python.yml  # Python 포함 구성
├── .dockerignore           # Docker 빌드 제외 파일
└── docker/
    ├── nginx.conf          # Nginx 설정 (프로덕션용)
    └── entrypoint.sh       # 커스텀 시작 스크립트
```

## 🚀 빠른 배포

### 1. 기본 배포 (Node.js만)
```bash
# 환경 설정
cp .env.example .env
# .env에서 OPENAI_API_KEY 설정

# 모든 서비스 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f app
```

### 2. Python 포함 배포
```bash
# Python 서비스 포함 배포
docker-compose -f docker-compose-with-python.yml up -d

# 서비스 상태 확인
docker-compose ps
```

## 🔧 상세 구성

### Node.js Dockerfile
```dockerfile
# Use Node.js LTS version
FROM node:18-alpine

# Install system dependencies for PDF processing
RUN apk add --no-cache \
    python3 py3-pip \
    poppler-utils tesseract-ocr tesseract-ocr-data-eng \
    build-base cairo-dev jpeg-dev pango-dev

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install Node.js dependencies
RUN npm ci --only=production

# Copy source code
COPY src/ ./src/

# Create directories
RUN mkdir -p uploads logs

# Set environment
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:5000/health || exit 1

# Start application
CMD ["npm", "start"]
```

### Python Dockerfile
```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    poppler-utils tesseract-ocr tesseract-ocr-kor \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY python_services/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy Python source files
COPY python_services/ ./

# Run FastAPI application
CMD ["python", "pdf_service.py"]
```

## 🌍 환경별 배포

### 개발 환경
```yaml
# docker-compose.override.yml (자동으로 적용됨)
version: '3.8'

services:
  app:
    volumes:
      - ./src:/app/src  # 소스 코드 마운트
      - ./uploads:/app/uploads
    environment:
      - NODE_ENV=development
      - LOG_LEVEL=debug
    ports:
      - "9229:9229"  # 디버그 포트
```

### 스테이징 환경
```yaml
# docker-compose.staging.yml
version: '3.8'

services:
  app:
    environment:
      - NODE_ENV=staging
      - LOG_LEVEL=info
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 512M
```

### 프로덕션 환경
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=warn
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
    restart: always
    
  # Nginx 추가
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
```

## ⚙️ 고급 설정

### 멀티 스테이지 빌드
```dockerfile
# Dockerfile.multistage
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM node:18-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY src ./src
CMD ["npm", "start"]
```

### 비밀 관리
```yaml
# docker-compose.secrets.yml
services:
  app:
    secrets:
      - openai_api_key
      - mongodb_password
    environment:
      - OPENAI_API_KEY_FILE=/run/secrets/openai_api_key

secrets:
  openai_api_key:
    file: ./secrets/openai_api_key.txt
  mongodb_password:
    file: ./secrets/mongodb_password.txt
```

## 🔍 모니터링

### 헬스 체크 설정
```javascript
// src/health.js
app.get('/health', async (req, res) => {
  const health = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    services: {
      database: await checkDatabase(),
      vectorDB: await checkQdrant(),
      python: await checkPythonService()
    }
  };
  
  const allHealthy = Object.values(health.services).every(s => s === true);
  res.status(allHealthy ? 200 : 503).json(health);
});
```

### 로그 관리
```yaml
# 로그 설정
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "5"
        tag: "{{.ImageName}}|{{.Name}}"
```

### 메트릭 수집
```yaml
# Prometheus + Grafana 추가
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

## 🚀 배포 자동화

### Docker Compose 스크립트
```bash
#!/bin/bash
# deploy.sh

set -e

# 환경 설정
ENVIRONMENT=${1:-development}
COMPOSE_FILE="docker-compose.yml"

if [ "$ENVIRONMENT" = "production" ]; then
    COMPOSE_FILE="docker-compose.prod.yml"
fi

# 이미지 빌드
echo "Building images..."
docker-compose -f $COMPOSE_FILE build

# 서비스 업데이트
echo "Updating services..."
docker-compose -f $COMPOSE_FILE up -d

# 헬스 체크
echo "Checking health..."
sleep 10
curl -f http://localhost:5000/health || exit 1

echo "Deployment completed successfully!"
```

### CI/CD 통합 (GitHub Actions)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: .
        push: true
        tags: your-repo/ai-quiz-backend:latest
    
    - name: Deploy to server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.SSH_KEY }}
        script: |
          cd /opt/ai-quiz
          docker-compose pull
          docker-compose up -d
```

## 🔧 문제해결

### 일반적인 문제들

#### 1. 포트 충돌
```bash
# 사용 중인 포트 확인
docker-compose ps
lsof -i :5000

# 다른 포트 사용
PORT=5001 docker-compose up -d
```

#### 2. 볼륨 권한 문제
```bash
# 권한 설정
sudo chown -R $(id -u):$(id -g) uploads logs

# Docker 내부 권한 설정
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 && \
    chown -R nodeuser:nodejs /app
USER nodeuser
```

#### 3. 메모리 부족
```yaml
# 리소스 제한 설정
services:
  app:
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

#### 4. 네트워크 연결 문제
```bash
# 네트워크 확인
docker network ls
docker network inspect ai-quiz-network

# 서비스 간 연결 테스트
docker exec app curl http://qdrant:6333/health
```

## 📊 성능 최적화

### 이미지 크기 최적화
```dockerfile
# Alpine Linux 사용
FROM node:18-alpine

# 불필요한 파일 제외
.dockerignore:
node_modules
.git
*.md
tests/
```

### 레이어 캐싱 최적화
```dockerfile
# 의존성 먼저 복사 (캐시 활용)
COPY package*.json ./
RUN npm ci --only=production

# 소스 코드는 나중에 복사
COPY src ./src
```

### 병렬 빌드
```bash
# 멀티 플랫폼 빌드
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --push -t your-repo/ai-quiz-backend .

# 빌드 캐시 활용
docker buildx build \
  --cache-from type=gha \
  --cache-to type=gha,mode=max .
```

## 🔐 보안 고려사항

### 컨테이너 보안
```dockerfile
# 루트 권한 사용 금지
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# 읽기 전용 파일 시스템
docker run --read-only -v /tmp:/tmp ai-quiz-backend
```

### 네트워크 보안
```yaml
# 내부 네트워크 분리
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

### 비밀 정보 관리
```bash
# Docker Secrets 사용
echo "your-api-key" | docker secret create openai_api_key -

# 환경 변수 파일 사용
docker-compose --env-file .env.prod up -d
```

## 관련 파일
- [[deployment/production.md]]: 프로덕션 배포 가이드
- [[development/setup.md]]: 개발 환경 설정
- [[troubleshooting.md]]: 문제해결 가이드

이 가이드를 따라하면 AI Quiz Backend를 안정적이고 확장 가능한 방식으로 배포할 수 있습니다! 🚀
