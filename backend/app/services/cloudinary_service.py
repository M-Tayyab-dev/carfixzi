import time
import base64
import hashlib
import json
import urllib.request
import urllib.parse
import urllib.error
import os
from typing import Dict, Any, Optional
from app.config import settings

class CloudinaryService:
    def __init__(self):
        self.cloud_name = settings.CLOUDINARY_CLOUD_NAME
        self.api_key = settings.CLOUDINARY_API_KEY
        self.api_secret = settings.CLOUDINARY_API_SECRET
        self.upload_endpoint = f"https://api.cloudinary.com/v1_1/{self.cloud_name}/auto/upload"

    @property
    def is_configured(self) -> bool:
        return bool(self.cloud_name and self.api_key and self.api_secret)

    async def upload_file_bytes(
        self,
        file_bytes: bytes,
        filename: str,
        folder: str = "carfixzi/onboarding",
        resource_type: str = "auto",
    ) -> Dict[str, Any]:
        """Uploads file bytes directly to Cloudinary and returns secure URL and metadata."""
        if not self.is_configured:
            timestamp = int(time.time())
            synthetic_id = f"{folder}/{timestamp}_{filename}"
            return {
                "public_id": synthetic_id,
                "secure_url": f"https://res.cloudinary.com/demo/image/upload/{synthetic_id}",
                "format": filename.split(".")[-1] if "." in filename else "bin",
                "resource_type": resource_type,
                "status": "simulated",
            }

        # Encode file bytes into data URI
        ext = filename.split(".")[-1].lower() if "." in filename else "png"
        mime = "application/pdf" if ext == "pdf" else f"image/{ext}"
        b64_content = base64.b64encode(file_bytes).decode("utf-8")
        data_uri = f"data:{mime};base64,{b64_content}"

        timestamp = str(int(time.time()))
        # Signature calculation: parameters sorted alphabetically
        to_sign = f"folder={folder}&timestamp={timestamp}{self.api_secret}"
        signature = hashlib.sha1(to_sign.encode("utf-8")).hexdigest()

        params = {
            "file": data_uri,
            "folder": folder,
            "timestamp": timestamp,
            "api_key": self.api_key,
            "signature": signature,
        }

        endpoint = f"https://api.cloudinary.com/v1_1/{self.cloud_name}/{'raw' if ext == 'pdf' else 'image'}/upload"
        data = urllib.parse.urlencode(params).encode("utf-8")
        req = urllib.request.Request(endpoint, data=data)

        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                result = json.loads(resp.read().decode("utf-8"))
                return {
                    "public_id": result.get("public_id"),
                    "secure_url": result.get("secure_url"),
                    "format": result.get("format", ext),
                    "resource_type": result.get("resource_type", "image"),
                    "bytes": result.get("bytes", len(file_bytes)),
                    "status": "uploaded",
                }
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8")
            raise Exception(f"Cloudinary HTTP {e.code}: {err_body}")

    def generate_upload_signature(self, folder: str = "carfixzi/onboarding") -> Dict[str, Any]:
        """Generates SHA signature and timestamp for direct client-side uploads."""
        timestamp = str(int(time.time()))
        to_sign = f"folder={folder}&timestamp={timestamp}{self.api_secret}"
        signature = hashlib.sha1(to_sign.encode("utf-8")).hexdigest()

        return {
            "cloud_name": self.cloud_name,
            "api_key": self.api_key,
            "timestamp": timestamp,
            "folder": folder,
            "signature": signature,
        }

cloudinary_service = CloudinaryService()
