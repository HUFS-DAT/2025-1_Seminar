from fastapi import APIRouter, HTTPException
from schemas import QuizRequest, QuizResponse
from services import generate_quiz

router = APIRouter()

@router.post("/generate-quiz", response_model=QuizResponse)
async def create_quiz(request: QuizRequest):
    """
    퀴즈 생성 요청을 받아 OpenAI API를 통해 퀴즈를 생성하고 반환합니다.
    """
    try:
        response = await generate_quiz(request.quiz_type, request.topic, request.config)
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))