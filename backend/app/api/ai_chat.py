from fastapi import APIRouter, HTTPException, Request
from app.models.chat import ChatRequest, ChatResponse
from app.services.groq_service import groq_service

router = APIRouter(prefix="/v1/ai", tags=["AI Assistant"])

@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest, raw_req: Request):
    """
    POST /v1/ai/chat
    Answers user inquiries grounded strictly in verified CARFIXZI pilot policies.
    """
    try:
        answer, sources = await groq_service.answer_query(
            user_message=request.message,
            locale=request.locale
        )
        return ChatResponse(
            answer=answer,
            sources=sources,
            locale=request.locale,
            cached=False
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI inference error: {str(e)}")

