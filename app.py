from fastapi import FastAPI
from routers import quiz_router

app = FastAPI()

app.include_router(quiz_router.router)