# python_services/pdf_service.py

---
type: file
path: python_services/pdf_service.py
language: python
---

## 목적
Python PDF 처리 기능을 REST API로 제공하는 FastAPI 서비스입니다. Node.js 애플리케이션과 HTTP 통신을 통해 고급 PDF 처리 기능을 제공합니다.

## 주요 함수/클래스
| 이름 | 유형 | 목적 |
|------|------|------|
| `app` | FastAPI 앱 | 메인 웹 애플리케이션 인스턴스 |
| `process_pdf()` | 엔드포인트 | PDF 파일 업로드 및 처리 |
| `process_text_only()` | 엔드포인트 | 텍스트 전용 처리 (PDF 추출 없이) |
| `health_check()` | 엔드포인트 | 서비스 상태 확인 |
| `root()` | 엔드포인트 | 서비스 정보 제공 |

## 의존성
- `fastapi`: 웹 프레임워크
- `uvicorn`: ASGI 서버
- [[python_services/pdf_processor.py]]: PDF 처리 로직
- `tempfile`: 임시 파일 관리

## API 엔드포인트

### 1. PDF 처리 (`POST /process-pdf`)

**설명**: 업로드된 PDF 파일을 처리하여 텍스트 추출 및 청킹을 수행합니다.

**요청**:
```http
POST /process-pdf
Content-Type: multipart/form-data

file: PDF 파일
chunk_size: 청크 크기 (선택적, 기본 500)
language: OCR 언어 (선택적, 기본 "eng+kor")
```

**응답**:
```json
{
  "success": true,
  "extraction_method": "pymupdf",
  "page_count": 10,
  "text_length": 12500,
  "chunk_count": 25,
  "chunks": [
    {
      "content": "청크 내용",
      "index": 0,
      "token_count": 245,
      "chunk_id": "chunk_0_1715692800000"
    }
  ],
  "metadata": {
    "filename": "document.pdf",
    "images_found": 5,
    "ocr_attempted": false
  }
}
```

### 2. 텍스트 처리 (`POST /process-text`)

**설명**: 이미 추출된 텍스트를 받아서 정제 및 청킹만 수행합니다.

**요청**:
```json
{
  "text": "처리할 원본 텍스트",
  "chunk_size": 500
}
```

**응답**:
```json
{
  "cleaned_text": "정제된 텍스트",
  "chunks": [/* 청크 배열 */],
  "total_chunks": 25,
  "success": true
}
```

### 3. 헬스 체크 (`GET /health`)

**설명**: 서비스 상태를 확인합니다.

**응답**:
```json
{
  "status": "healthy",
  "service": "PDF Processing Service"
}
```

### 4. 서비스 정보 (`GET /`)

**설명**: 서비스 기본 정보와 사용 가능한 엔드포인트를 제공합니다.

**응답**:
```json
{
  "service": "PDF Processing Service",
  "version": "1.0.0",
  "endpoints": {
    "POST /process-pdf": "Upload and process PDF file",
    "POST /process-text": "Process raw text",
    "GET /health": "Health check"
  }
}
```

## 사용 방법

### 서버 실행
```bash
# 직접 실행
python pdf_service.py

# uvicorn 사용
uvicorn pdf_service:app --host 0.0.0.0 --port 8001

# 개발 모드 (자동 리로드)
uvicorn pdf_service:app --host 0.0.0.0 --port 8001 --reload
```

### cURL 예시
```bash
# PDF 처리
curl -X POST "http://localhost:8001/process-pdf" \
  -F "file=@document.pdf" \
  -F "chunk_size=1000"

# 텍스트 처리
curl -X POST "http://localhost:8001/process-text" \
  -H "Content-Type: application/json" \
  -d '{"text": "처리할 텍스트", "chunk_size": 500}'

# 헬스 체크
curl http://localhost:8001/health
```

### Python 클라이언트 예시
```python
import requests
import json

# PDF 업로드 및 처리
with open('document.pdf', 'rb') as f:
    files = {'file': f}
    data = {'chunk_size': 1000}
    response = requests.post(
        'http://localhost:8001/process-pdf',
        files=files,
        data=data
    )
    result = response.json()
    print(f"처리 완료: {result['chunk_count']}개 청크 생성")

# 텍스트만 처리
text_data = {'text': '처리할 텍스트', 'chunk_size': 500}
response = requests.post(
    'http://localhost:8001/process-text',
    json=text_data
)
result = response.json()
print(f"청크 수: {result['total_chunks']}")
```

## 에러 처리

### 일반적인 에러
- `400 Bad Request`: PDF 파일이 아닌 경우
- `500 Internal Server Error`: PDF 처리 중 오류 발생

### 에러 응답 형식
```json
{
  "detail": "Error message describing what went wrong"
}
```

## 특징

### 1. 파일 안전 처리
- 임시 파일 자동 생성 및 정리
- 업로드 파일 유효성 검사
- 메모리 효율적인 파일 처리

### 2. 유연한 파라미터
- 청크 크기 조정 가능
- OCR 언어 설정 가능
- 텍스트만 처리하는 별도 엔드포인트

### 3. 상세한 메타데이터
- 추출 방법 (PyMuPDF/OCR) 표시
- 이미지 개수 및 OCR 시도 여부
- 원본 파일명 보존

## 보안 고려사항

### 파일 검증
- PDF 파일 확장자 검사
- 파일 크기 제한 (FastAPI 기본 16MB)
- 임시 파일 자동 삭제

### 향후 개선
```python
# 파일 크기 제한
from fastapi import Request

@app.middleware("http")
async def limit_upload_size(request: Request, call_next):
    if request.url.path == "/process-pdf":
        if "content-length" in request.headers:
            if int(request.headers["content-length"]) > 100_000_000:  # 100MB
                raise HTTPException(413, "File too large")
    return await call_next(request)
```

## 모니터링

### 로깅 추가
```python
import logging

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.post("/process-pdf")
async def process_pdf(file: UploadFile = File(...)):
    logger.info(f"Processing PDF: {file.filename}")
    # ... 처리 로직
    logger.info(f"Completed processing: {result['chunk_count']} chunks")
```

### 성능 메트릭
```python
import time

# 처리 시간 측정
start_time = time.time()
# ... PDF 처리
processing_time = time.time() - start_time
logger.info(f"Processing time: {processing_time:.2f}s")
```

## Docker 통합

### Dockerfile.python에서 실행
```dockerfile
# 자동 시작 명령
CMD ["python", "pdf_service.py"]

# 또는 uvicorn 사용
CMD ["uvicorn", "pdf_service:app", "--host", "0.0.0.0", "--port", "8001"]
```

## 확장 계획

### 1. 배치 처리
```python
@app.post("/process-batch")
async def process_batch(files: List[UploadFile] = File(...)):
    results = []
    for file in files:
        result = await process_single_pdf(file)
        results.append(result)
    return {"batch_results": results}
```

### 2. 비동기 처리
```python
from fastapi import BackgroundTasks

@app.post("/process-pdf-async")
async def process_pdf_async(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...)
):
    task_id = str(uuid.uuid4())
    background_tasks.add_task(process_pdf_background, task_id, file)
    return {"task_id": task_id, "status": "processing"}
```

## 관련 파일
- [[python_services/pdf_processor.py]]: 핵심 PDF 처리 로직
- [[python_services/requirements.txt]]: Python 의존성
- [[src/modules/preprocessing/pythonPDFProcessor.js]]: Node.js 클라이언트
- [[deployment/docker.md]]: Docker 배포 가이드
- [[python-integration.md]]: Python 통합 상세 가이드
