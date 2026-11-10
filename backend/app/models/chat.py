from typing import List, Optional
from pydantic import BaseModel, Field

class SourceCitationModel(BaseModel):
    title: str
    type: str = "policy"
    route: Optional[str] = None

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000, description="Customer or Partner query")
    locale: str = Field(default="en", description="User language code (en or ur)")
    role: Optional[str] = Field(default="customer", description="Role of the querying user")

class ChatResponse(BaseModel):
    answer: str
    sources: List[SourceCitationModel] = []
    locale: str = "en"
    cached: bool = False

