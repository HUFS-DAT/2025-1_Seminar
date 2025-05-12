from pydantic import BaseModel, Field
from typing import Optional, List, Dict

class QuizRequest(BaseModel):
    """
    API 요청(Request) 시 필요한 데이터 모델
    """
    quiz_type: str # "ox", "mcq", "short"
    topic: str
    config: Dict

class QuizOption(BaseModel):
    """
    객관식 문제에서 보기 옵션 정의
    """
    option_text: str
    is_correct: bool

class QuizResponse(BaseModel):
    """
    API 응답(Response) 시 반환할 데이터 모델
    """
    question: str # 생성된 문제
    options: Optional[List[QuizOption]] = None # 객관식일 경우 보기 목록 (OX나 단답형일 경우 None)
    answer: str # 정답

class MCQPromptConfig(BaseModel):
    difficulty: str = Field(default="medium", description="Difficulty level of the quiz")
    bloom_level: str = Field(default="application", description="Bloom's Taxonomy Level")
    distractor_count: int = Field(default=3, description="Number of incorrect options")

class OXPromptConfig(BaseModel):
    difficulty: str = Field(default="medium", description="Difficulty level of the quiz")

class ShortPromptConfig(BaseModel):
    difficulty: str = Field(default="medium", description="Difficulty level of the quiz")
    word_limit: int = Field(default=20, description="Maximum word count for the answer")



