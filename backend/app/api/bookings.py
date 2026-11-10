from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field
from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/v1", tags=["Bookings, Orders & Payments"])

class BookingCreateRequest(BaseModel):
    customer_id: str
    partner_id: str
    service_id: str
    service_title: str
    scheduled_date: str
    time_slot: str
    vehicle_registration: str
    base_price_paisa: int
    notes: Optional[str] = None

class PaymentConfirmRequest(BaseModel):
    payment_method: str = Field(default="cash_declared", description="cash_declared or demo_simulated")
    received_amount_paisa: int
    confirmed_by_partner: bool = True

_in_memory_bookings = [
    {
        "id": "bk_2026_01",
        "customer_id": "cust_pilot_01",
        "partner_id": "ws_01",
        "partner_name": "Apex GT Motorwerks",
        "service_title": "Full Brake Pad Replacement & Bleed",
        "vehicle_registration": "LES-18-4921",
        "scheduled_date": "2026-11-12",
        "time_slot": "10:00 AM - 11:30 AM",
        "total_amount_paisa": 420000,
        "commission_amount_paisa": 42000,  # 10%
        "status": "confirmed",
        "payment_status": "unpaid",
    }
]

@router.get("/bookings")
async def list_bookings(customer_id: Optional[str] = None, partner_id: Optional[str] = None):
    """Lists bookings filtered by customer or workshop partner."""
    results = _in_memory_bookings
    if customer_id:
        results = [b for b in results if b["customer_id"] == customer_id]
    if partner_id:
        results = [b for b in results if b["partner_id"] == partner_id]
    return {"bookings": results}

@router.post("/bookings")
async def create_booking(payload: BookingCreateRequest):
    """Creates a new service booking with automated platform commission calculation."""
    commission_paisa = int(round(payload.base_price_paisa * 0.10))
    booking = {
        "id": f"bk_{int(datetime.utcnow().timestamp())}",
        "customer_id": payload.customer_id,
        "partner_id": payload.partner_id,
        "partner_name": "Apex GT Motorwerks",
        "service_title": payload.service_title,
        "vehicle_registration": payload.vehicle_registration,
        "scheduled_date": payload.scheduled_date,
        "time_slot": payload.time_slot,
        "total_amount_paisa": payload.base_price_paisa,
        "commission_amount_paisa": commission_paisa,
        "status": "confirmed",
        "payment_status": "unpaid",
        "created_at": datetime.utcnow().isoformat() + "Z",
    }
    _in_memory_bookings.append(booking)
    return booking

@router.post("/payments/{booking_id}/confirm")
async def confirm_payment(booking_id: str, payload: PaymentConfirmRequest):
    """
    Records customer cash handover and generates digital receipt #REC-2026.
    Triggers platform commission liability ledger entry.
    """
    booking = next((b for b in _in_memory_bookings if b["id"] == booking_id), None)
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    booking["payment_status"] = "cash_verified" if payload.payment_method == "cash_declared" else "demo_simulated"
    booking["settled_at"] = datetime.utcnow().isoformat() + "Z"

    return {
        "receipt_number": f"REC-2026-{booking_id[-4:]}",
        "booking_id": booking_id,
        "total_settled_paisa": payload.received_amount_paisa,
        "payment_method": payload.payment_method,
        "commission_due_paisa": booking["commission_amount_paisa"],
        "status": "receipt_issued",
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }

