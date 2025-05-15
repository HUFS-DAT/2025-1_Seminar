from pydantic import BaseModel, Field
from typing import Optional, List, Dict

class QuizRequest(BaseModel):
    quiz_type: str  # 예: "mcq", "ox", "short"
    topic: str
    config: Dict = {}

class QuizOption(BaseModel):
    option_text: str
    is_correct: bool

class QuizResponse(BaseModel):
    question: str
    options: Optional[List[QuizOption]] = None
    answer: str
