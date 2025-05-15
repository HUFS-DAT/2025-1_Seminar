#docker compose up --build -d
#docker에서 새로 pip하면 필요
#pip freeze > requirements.txt
#도커 종료 - 다시 실행하려면 오래걸림, 파일 수정하면 다시 켜야함
#docker compose down 
#docker ps -a 실행중인 도커
#docker logs fastapi-app 로그, 에러확인
#http://localhost:8000/docs 실행하고 조금 기다려야 열림
from fastapi import FastAPI
from routers.quiz_router import router as quiz_router
from routers.vector_router import router as vector_router

app = FastAPI()
app.include_router(quiz_router, prefix="/quiz")
app.include_router(vector_router, prefix="/vector")
