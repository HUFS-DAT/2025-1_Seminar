from pydantic import BaseModel

class StatusMessage(BaseModel):
    status: str
    detail: str = ""
