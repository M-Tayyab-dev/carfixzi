from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from typing import Optional
from app.services.email_service import EmailService

router = APIRouter(prefix="/email", tags=["Email"])
email_service = EmailService()

class SendEmailRequest(BaseModel):
    to_email: EmailStr
    subject: str
    headline: str
    greeting: str
    body_text: str
    cta_label: Optional[str] = None
    cta_url: Optional[str] = None
    info_box: Optional[str] = None

class BookingReceiptEmailRequest(BaseModel):
    to_email: EmailStr
    customer_name: str
    receipt_number: str
    service_title: str
    workshop_name: str
    amount_pkr: str
    date_str: str

@router.post("/send")
async def send_custom_email(req: SendEmailRequest):
    html = email_service.get_branded_template(
        headline=req.headline,
        greeting=req.greeting,
        body_text=req.body_text,
        cta_label=req.cta_label,
        cta_url=req.cta_url,
        info_box=req.info_box,
    )
    res = await email_service.send_email(
        to_email=req.to_email,
        subject=req.subject,
        html_content=html,
    )
    return res

@router.post("/send-booking-receipt")
async def send_booking_receipt(req: BookingReceiptEmailRequest):
    body = f"""
    Thank you for choosing <strong>{req.workshop_name}</strong> via CARFIXZI. Your service has been verified and settled.<br/><br/>
    <strong>Service:</strong> {req.service_title}<br/>
    <strong>Receipt #:</strong> {req.receipt_number}<br/>
    <strong>Total Paid:</strong> {req.amount_pkr}<br/>
    <strong>Date:</strong> {req.date_str}
    """
    html = email_service.get_branded_template(
        headline=f"Receipt #{req.receipt_number}",
        greeting=f"Dear {req.customer_name}",
        body_text=body,
        cta_label="View in CARFIXZI App",
        cta_url="https://carfixzi.pk/app",
        info_box="Your service is protected by the CARFIXZI 7-Day / 500 km Service Guarantee.",
    )
    res = await email_service.send_email(
        to_email=req.to_email,
        subject=f"CARFIXZI Receipt - {req.receipt_number}",
        html_content=html,
    )
    return res
