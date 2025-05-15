from pydantic import BaseModel
from typing import List

class VectorSearchResult(BaseModel):
    text: str
    score: float

class AddTextRequest(BaseModel):
    text: str
