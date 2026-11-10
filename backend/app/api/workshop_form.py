from datetime import datetime
from typing import List
from fastapi import APIRouter, HTTPException, Depends
from app.models.form import (
    FormFieldConfigModel,
    WorkshopFormVersionModel,
    RetireFieldRequest,
    PublishFormRequest,
)

router = APIRouter(prefix="/v1/workshop-form", tags=["Workshop Form Governance"])

# Baseline legal fields mandated by Section 4.2A & FR-27
BASELINE_FIELDS: List[FormFieldConfigModel] = [
    FormFieldConfigModel(
        id="f_business_photo",
        field_key="business_photo",
        label="Workshop Front Facade Photo",
        field_type="image",
        required=True,
        is_policy_locked=True,
        help_text="Clear daylight photo showing workshop signage and street entrance",
    ),
    FormFieldConfigModel(
        id="f_cnic_front",
        field_key="cnic_front",
        label="Owner CNIC (Front Side)",
        field_type="image",
        required=True,
        is_policy_locked=True,
        validation_regex=r"^\d{5}-\d{7}-\d{1}$",
        help_text="13-digit Pakistani CNIC front side with clear photo",
    ),
    FormFieldConfigModel(
        id="f_cnic_back",
        field_key="cnic_back",
        label="Owner CNIC (Back Side)",
        field_type="image",
        required=True,
        is_policy_locked=True,
        help_text="CNIC back side showing permanent and present address",
    ),
    FormFieldConfigModel(
        id="f_tax_return",
        field_key="tax_return",
        label="FBR Active Tax Return / NTN Certificate",
        field_type="document",
        required=True,
        is_policy_locked=True,
        help_text="PDF document verifying commercial NTN registration",
    ),
    FormFieldConfigModel(
        id="f_lift_count",
        field_key="hydraulic_lifts_count",
        label="Number of Hydraulic Service Lifts",
        field_type="number",
        required=False,
        is_policy_locked=False,
        help_text="Operational vehicle hoist bays inside premises",
    ),
]

_active_version = WorkshopFormVersionModel(
    version_id="v_baseline_1_0",
    version_number=1,
    published_at=datetime.utcnow().isoformat() + "Z",
    published_by_admin_id="admin_system_seed",
    is_active=True,
    fields=BASELINE_FIELDS,
)

@router.get("/active", response_model=WorkshopFormVersionModel)
async def get_active_form_version():
    """Returns the currently active, immutable registration form schema for workshop applicants."""
    return _active_version

@router.post("/publish", response_model=WorkshopFormVersionModel)
async def publish_new_form_version(payload: PublishFormRequest):
    """
    Creates and activates a new numbered immutable form version.
    Validates that policy-locked baseline legal fields are NOT removed or made optional.
    """
    global _active_version

    # Validate that baseline legal fields are present and required
    locked_keys = {"business_photo", "cnic_front", "cnic_back", "tax_return"}
    present_locked_keys = {f.field_key for f in payload.fields if f.is_policy_locked and f.required}

    if not locked_keys.issubset(present_locked_keys):
        missing = locked_keys - present_locked_keys
        raise HTTPException(
            status_code=422,
            detail=f"Policy Violation: Baseline legal verification fields cannot be removed or optional: {missing}",
        )

    new_version = WorkshopFormVersionModel(
        version_id=f"v_schema_{_active_version.version_number + 1}_{int(datetime.utcnow().timestamp())}",
        version_number=_active_version.version_number + 1,
        published_at=datetime.utcnow().isoformat() + "Z",
        published_by_admin_id=payload.admin_id,
        is_active=True,
        fields=payload.fields,
    )
    _active_version = new_version
    return _active_version

@router.post("/fields/{field_id}/retire")
async def retire_field(field_id: str, payload: RetireFieldRequest):
    """
    Super Admin only endpoint: Retires a custom form field.
    Policy-locked fields (CNIC, tax return, business photo) cannot be retired.
    """
    field = next((f for f in _active_version.fields if f.id == field_id), None)
    if not field:
        raise HTTPException(status_code=404, detail="Field not found")

    if field.is_policy_locked:
        raise HTTPException(
            status_code=403,
            detail="Forbidden: Mandatory legal verification fields are policy-locked and cannot be retired.",
        )

    field.is_retired = True
    return {
        "status": "retired",
        "field_id": field_id,
        "reason": payload.retired_reason,
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }

