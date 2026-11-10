import os
from typing import List

try:
    from pydantic_settings import BaseSettings
    class _SettingsBase(BaseSettings):
        class Config:
            env_file = ".env"
            extra = "ignore"
except ImportError:
    class _SettingsBase:
        pass

class Settings(_SettingsBase):
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    CORS_ORIGINS: List[str] = ["*"]

    # GroqCloud Configuration (Live Qwen 3.8 27B / LLaMA on Groq)
    GROQ_API_KEY: str = os.getenv("GROQ_API_KEY", "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")
    GROQ_MODEL: str = os.getenv("GROQ_MODEL", "qwen/qwen3.8-27b")

    # Cloudinary Storage Configuration (Storefront photos, CNIC & Tax PDFs)
    CLOUDINARY_CLOUD_NAME: str = os.getenv("CLOUDINARY_CLOUD_NAME", "mbecykon")
    CLOUDINARY_API_KEY: str = os.getenv("CLOUDINARY_API_KEY", "913588559286195")
    CLOUDINARY_API_SECRET: str = os.getenv("CLOUDINARY_API_SECRET", "6_8G2S1kTbpM98DOLwoLo6gxoAY")

    # Platform Defaults (Sahiwal District, Punjab, Pakistan)
    DEFAULT_REGION: str = os.getenv("DEFAULT_REGION", "sahiwal_punjab")
    COMMISSION_RATE_SERVICES_BPS: int = int(os.getenv("COMMISSION_RATE_SERVICES_BPS", "1000"))  # 10.00%
    COMMISSION_RATE_PARTS_BPS: int = int(os.getenv("COMMISSION_RATE_PARTS_BPS", "500"))        # 5.00%

settings = Settings()
