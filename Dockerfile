# Python 3.11 qdrant 사용 최적화인듯?
FROM python:3.11

# 작업 디렉토리 설정
WORKDIR /app

# requirements.txt 먼저 복사하고 설치 (캐시 최적화 목적)
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 프로젝트 전체 복사
COPY . .

# FastAPI 서버 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# #requirements.txt를 새로 생성해야하는 경우 사용
# FROM python:3.11

# WORKDIR /app

# COPY . .

# RUN pip install --no-cache-dir --upgrade pip && \
#     pip install --no-cache-dir fastapi uvicorn qdrant-client sentence-transformers openai python-dotenv

# CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
# #