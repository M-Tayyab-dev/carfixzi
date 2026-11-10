from typing import List, Optional
from pydantic import BaseModel, Field

class FormFieldConfigModel(BaseModel):
    id: str
    field_key: str
    label: str
    field_type: str  # text, number, dropdown, document, image
    required: bool = True
    is_policy_locked: bool = False
    is_retired: bool = False
    options: Optional[List[str]] = None
    validation_regex: Optional[str] = None
    help_text: Optional[str] = None

class WorkshopFormVersionModel(BaseModel):
    version_id: str
    version_number: int
    published_at: str
    published_by_admin_id: str
    is_active: bool = True
    fields: List[FormFieldConfigModel]

class RetireFieldRequest(BaseModel):
    retired_reason: str = Field(..., min_length=5, description="Super Admin justification for retirement")

class PublishFormRequest(BaseModel):
    admin_id: str
    fields: List[FormFieldConfigModel]

