import json
import urllib.request
import urllib.error
import os
from typing import List, Tuple
from app.config import settings
from app.models.chat import SourceCitationModel
from app.services.knowledge_base import PILOT_KNOWLEDGE_BASE, get_grounded_context

SYSTEM_PROMPT = f"""You are the official CARFIXZI AI Assistant, the intelligent support agent for Pakistan's premier verified automotive marketplace operating in the Sahiwal District, Punjab.

Your role:
1. Answer questions about workshops, services, doorstep wash, mobile mechanic, spare parts, and cash-on-service payments.
2. Ground all answers strictly in the verified pilot knowledge base provided below.
3. If an asked workshop or service is not in the knowledge base, honestly state that it is not currently verified on CARFIXZI in Sahiwal.
4. Keep answers friendly, professional, concise, and helpful. Always quote prices in Pakistani Rupees (PKR / Rs).

Verified Platform Knowledge Base:
{get_grounded_context()}
"""

class GroqService:
    def __init__(self):
        self.api_key = settings.GROQ_API_KEY
        self.model = settings.GROQ_MODEL
        self.endpoint = "https://api.groq.com/openai/v1/chat/completions"

    async def answer_query(self, user_message: str, locale: str = "en") -> Tuple[str, List[SourceCitationModel]]:
        # Match citations from knowledge base
        citations: List[SourceCitationModel] = []
        user_lower = user_message.lower()

        for key, entry in PILOT_KNOWLEDGE_BASE.items():
            words = entry["title"].lower().split()
            if any(w in user_lower for w in words if len(w) > 3):
                citations.append(SourceCitationModel(
                    title=entry["title"],
                    type="verified_policy",
                    route=entry.get("route")
                ))

        if not citations:
            citations.append(SourceCitationModel(
                title="CARFIXZI Pilot Handbook (Sahiwal)",
                type="general_faq",
                route="/customer/home"
            ))

        # Attempt Groq live inference
        if self.api_key and not self.api_key.startswith("gsk_your"):
            try:
                headers = {
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                    "User-Agent": "CARFIXZI-FastAPI/1.0",
                }
                payload = json.dumps({
                    "model": self.model,
                    "messages": [
                        {"role": "system", "content": SYSTEM_PROMPT},
                        {"role": "user", "content": user_message},
                    ],
                    "temperature": 0.3,
                    "max_tokens": 600,
                }).encode("utf-8")

                req = urllib.request.Request(self.endpoint, data=payload, headers=headers)
                with urllib.request.urlopen(req, timeout=12) as response:
                    data = json.loads(response.read().decode("utf-8"))
                    answer = data["choices"][0]["message"]["content"]
                    if answer and answer.strip():
                        return answer.strip(), citations
            except Exception as e:
                print(f"[GroqService] Error during live inference: {e}")

        # Intelligent Grounded Synthesizer (Zero-cost offline fallback)
        answer = self._offline_synthesize(user_message)
        return answer, citations

    def _offline_synthesize(self, query: str) -> str:
        q = query.lower()
        if "workshop" in q or "where" in q or "garage" in q or "apex" in q or "sahiwal" in q:
            return (
                "CARFIXZI currently has 3 verified partner workshops active in Sahiwal District:\n\n"
                "1. Apex GT Motorwerks (High Street) - Full engine diagnostics, ceramic brake replacement, and multi-bay repairs.\n"
                "2. Royal Auto Detailing Hub (Bypass Road) - Premium exterior wash, ceramic coating, and interior detailing.\n"
                "3. PakWheels Express Bay (GT Road) - Fast lube oil service and roadside mobile mechanic dispatch.\n\n"
                "You can view real-time bay availability and book appointments directly in the app."
            )
        elif "cash" in q or "pay" in q or "card" in q or "money" in q:
            return (
                "Payment on CARFIXZI is Cash on Service:\n\n"
                "• No online card details are required.\n"
                "• Pay the agreed amount in Pakistani Rupees directly to the workshop or technician once the job is inspected and completed.\n"
                "• The technician confirms receipt in the app, and you receive an official verified digital receipt #REC-2026."
            )
        elif "wash" in q or "clean" in q or "detail" in q:
            return (
                "We provide Doorstep Mobile Car Wash across Sahiwal:\n\n"
                "• Exterior Express Wash: Rs 800 (Sedans/Hatchbacks) | Rs 1,000 (SUVs)\n"
                "• Interior Vacuum & Sanitization: Rs 1,200\n"
                "• Full Showroom Detailing: Rs 2,500\n\n"
                "Our mobile wash team brings self-contained water tanks and pressure washers right to your home."
            )
        elif "mechanic" in q or "roadside" in q or "puncture" in q or "emergency" in q or "battery" in q:
            return (
                "Our Mobile Mechanic service is on standby across Sahiwal (up to 25 km radius):\n\n"
                "• Standard Callout Fee: Rs 1,200\n"
                "• Includes on-site battery jumpstart, electronic scan, and rapid roadside puncture repair.\n"
                "• Technicians arrive by motorcycle equipped with essential tools and fluids."
            )
        elif "commission" in q or "rate" in q or "percentage" in q:
            return (
                "Platform Commission Rates for the Sahiwal pilot:\n\n"
                "• Mechanical Repairs & Services: 10.00% (1000 bps)\n"
                "• Spare Parts Sales: 5.00% (500 bps)\n"
                "• Doorstep Wash: 12.00% (1200 bps)\n"
                "• Mobile Mechanic: 15.00% (1500 bps)\n\n"
                "Commission liabilities are settled monthly with Regional Super Admins."
            )
        else:
            return (
                "Welcome to CARFIXZI! As Pakistan's verified automotive marketplace, we offer certified workshop booking, "
                "doorstep car wash, mobile mechanic assistance, and genuine spare parts across Sahiwal District.\n\n"
                "All payments are handled securely via Cash-on-Service. How may I assist your vehicle today?"
            )

groq_service = GroqService()
