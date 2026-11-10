from typing import Optional
from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from app.services.cloudinary_service import cloudinary_service

router = APIRouter(prefix="/v1/media", tags=["Cloudinary Media Storage"])

@router.post("/upload")
async def upload_media_file(
    file: UploadFile = File(...),
    folder: str = Form(default="carfixzi/onboarding"),
):
    """
    POST /v1/media/upload
    Receives an image (CNIC front/back, workshop storefront) or PDF document (FBR tax return)
    and uploads it securely to Cloudinary storage.
    """
    try:
        content = await file.read()
        if len(content) == 0:
            raise HTTPException(status_code=400, detail="Uploaded file is empty.")

        # Max 10 MB upload guard
        if len(content) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File size exceeds maximum 10MB limit.")

        result = await cloudinary_service.upload_file_bytes(
            file_bytes=content,
            filename=file.filename or "uploaded_media",
            folder=folder,
        )
        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Cloudinary upload failed: {str(e)}")

@router.post("/upload-authorize")
async def authorize_direct_upload(folder: str = "carfixzi/onboarding"):
    """
    POST /v1/media/upload-authorize
    Generates a secure timestamped SHA-1 signature so client can upload directly to Cloudinary.
    """
    return cloudinary_service.generate_upload_signature(folder=folder)

