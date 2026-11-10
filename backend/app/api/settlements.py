from datetime import datetime
from typing import List
from pydantic import BaseModel, Field
from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/v1", tags=["Super Admin Settlements"])

class CommissionPolicyUpdate(BaseModel):
    service_rate_bps: int = Field(default=1000, ge=0, le=3000)
    parts_rate_bps: int = Field(default=500, ge=0, le=3000)
    wash_rate_bps: int = Field(default=1200, ge=0, le=3000)
    mobile_mechanic_rate_bps: int = Field(default=1500, ge=0, le=3000)

class RecordSettlementRequest(BaseModel):
    partner_id: str
    partner_name: str
    period: str
    amount_paisa: int
    payment_method: str  # Bank Transfer, Physical Cash, Cheque, JazzCash, EasyPaisa
    recorded_by_admin_id: str

_settlement_ledger = [
    {
        "id": "stl_001",
        "partner_id": "ws_01",
        "partner_name": "Apex GT Motorwerks",
        "period": "October 2026",
        "amount_paisa": 2890000,
        "method": "Bank Transfer",
        "status": "Outstanding",
        "created_at": "2026-11-01T08:00:00Z",
    },
    {
        "id": "stl_002",
        "partner_id": "ws_02",
        "partner_name": "Royal Auto Detailing Hub",
        "period": "October 2026",
        "amount_paisa": 1250000,
        "method": "Physical Cash",
        "status": "Outstanding",
        "created_at": "2026-11-01T08:00:00Z",
    },
    {
        "id": "stl_003",
        "partner_id": "ws_01",
        "partner_name": "Apex GT Motorwerks",
        "period": "September 2026",
        "amount_paisa": 3125000,
        "method": "Bank Transfer",
        "status": "Settled",
        "settled_date": "2026-10-05T14:30:00Z",
        "created_at": "2026-10-01T08:00:00Z",
    },
]

_current_policy = {
    "service_rate_bps": 1000,
    "parts_rate_bps": 500,
    "wash_rate_bps": 1200,
    "mobile_mechanic_rate_bps": 1500,
    "last_updated": "2026-11-10T00:00:00Z",
}

@router.get("/commission-policies")
async def get_commission_policies():
    """Returns current active basis point commission rates."""
    return _current_policy

@router.put("/commission-policies")
async def update_commission_policies(payload: CommissionPolicyUpdate):
    """Super Admin endpoint: Updates basis point platform commission rates."""
    global _current_policy
    _current_policy = {
        "service_rate_bps": payload.service_rate_bps,
        "parts_rate_bps": payload.parts_rate_bps,
        "wash_rate_bps": payload.wash_rate_bps,
        "mobile_mechanic_rate_bps": payload.mobile_mechanic_rate_bps,
        "last_updated": datetime.utcnow().isoformat() + "Z",
    }
    return _current_policy

@router.get("/settlements")
async def list_settlements():
    """Lists all partner commission settlement ledger records."""
    return {"settlements": _settlement_ledger}

@router.post("/settlements")
async def record_settlement(payload: RecordSettlementRequest):
    """Records an audited manual commission payment received from a workshop partner."""
    record = {
        "id": f"stl_{int(datetime.utcnow().timestamp())}",
        "partner_id": payload.partner_id,
        "partner_name": payload.partner_name,
        "period": payload.period,
        "amount_paisa": payload.amount_paisa,
        "method": payload.payment_method,
        "status": "Settled",
        "recorded_by_admin_id": payload.recorded_by_admin_id,
        "settled_date": datetime.utcnow().isoformat() + "Z",
        "created_at": datetime.utcnow().isoformat() + "Z",
    }
    _settlement_ledger.insert(0, record)
    return record

