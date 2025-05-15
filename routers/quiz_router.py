from fastapi import APIRouter, HTTPException
from schemas.quiz_schemas import QuizRequest, QuizResponse
from services.generate_quiz import generate_quiz

router = APIRouter()

@router.post("/generate", response_model=QuizResponse)
async def create_quiz(request: QuizRequest):
    try:
        response = await generate_quiz(
            quiz_type=request.quiz_type,
            topic=request.topic,
            config=request.config
        )
        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
