from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.api.ai_chat import router as ai_router
from app.api.workshop_form import router as form_router
from app.api.bookings import router as bookings_router
from app.api.settlements import router as settlements_router
from app.api.media import router as media_router
from app.api.email import router as email_router

app = FastAPI(
    title="CARFIXZI Trusted Backend API",
    description=(
        "Official Python FastAPI backend for CARFIXZI - Pakistan's verified automotive marketplace. "
        "Provides grounded GroqCloud AI assistant proxy, dynamic workshop registration form schema governance, "
        "Cloudinary media uploads, and offline cash-on-service commission liability tracking."
    ),
    version="1.0.0",
)

# CORS Configuration for Flutter Web and Android Emulator
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API Routers
app.include_router(ai_router)
app.include_router(form_router)
app.include_router(bookings_router)
app.include_router(settlements_router)
app.include_router(media_router)
app.include_router(email_router)

@app.get("/", tags=["Health"])
async def root():
    return {
        "app": "CARFIXZI Trusted Backend API",
        "version": "1.0.0",
        "pilot_region": settings.DEFAULT_REGION,
        "environment": settings.ENVIRONMENT,
        "cloudinary_configured": bool(settings.CLOUDINARY_CLOUD_NAME),
        "groq_configured": bool(settings.GROQ_API_KEY),
        "status": "operational",
    }

@app.get("/health", tags=["Health"])
async def health():
    return {
        "status": "ok",
        "groq_model": settings.GROQ_MODEL,
        "cloudinary_cloud": settings.CLOUDINARY_CLOUD_NAME,
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host=settings.HOST, port=settings.PORT, reload=True)
