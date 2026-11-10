"""Authoritative Pilot Knowledge Base for CARFIXZI
Grounded specifically in the Sahiwal District, Punjab, Pakistan pilot launch.
"""

PILOT_KNOWLEDGE_BASE = {
    "platform_overview": {
        "title": "Platform Overview",
        "content": (
            "CARFIXZI is a verified automotive services marketplace in Pakistan operating an initial pilot "
            "in the Sahiwal District, Punjab. The platform features four roles: Customer, Workshop Partner, "
            "Admin, and Super Admin. It provides verified workshop discovery, doorstep car wash, on-demand "
            "mobile mechanic dispatch, spare parts marketplace, and transparent cash-on-service checkout."
        ),
        "route": "/customer/home",
    },
    "workshops": {
        "title": "Verified Workshops in Sahiwal",
        "content": (
            "Currently operating verified workshops in Sahiwal District:\n"
            "1. Apex GT Motorwerks - High Street, Sahiwal. Specializes in Honda, Toyota, and German vehicles. 4 service bays. Bay 01 & 02 equipped for full engine overhaul and ceramic brake replacements.\n"
            "2. Royal Auto Detailing Hub - Bypass Road, Sahiwal. Specializes in premium car wash, detailing, ceramic coating, and interior disinfection.\n"
            "3. PakWheels Express Bay - GT Road, Sahiwal. Specializes in quick oil changes, battery testing, filter replacements, and roadside mobile mechanic dispatch."
        ),
        "route": "/customer/workshops",
    },
    "cash_payment_policy": {
        "title": "Cash on Service Policy",
        "content": (
            "CARFIXZI operates exclusively on a Cash-on-Service model for physical fulfillment in Pakistan. "
            "Customers do NOT enter credit card or bank account details in the app. All amounts are calculated "
            "in integer Pakistani Rupees (PKR Paisa). The customer pays physical cash directly to the technician "
            "or workshop upon satisfactory completion. Both the partner and customer declare cash receipt in-app "
            "to issue a verified digital receipt #REC-2026."
        ),
        "route": "/customer/checkout",
    },
    "mobile_mechanic": {
        "title": "Doorstep & Roadside Mobile Mechanic",
        "content": (
            "Mobile mechanic service is available across Sahiwal District within a 25 km service radius. "
            "A verified technician arrives on a service motorcycle equipped with a basic diagnostic scanner, "
            "battery jump starter, tire puncture repair kit, and rapid fluid top-up kit. "
            "Standard callout fee is Rs 1,200 plus any parts or labor required."
        ),
        "route": "/customer/mobile-mechanic",
    },
    "doorstep_wash": {
        "title": "Doorstep Car Wash Packages",
        "content": (
            "Eco-friendly mobile car wash team brings pressurized mobile water tanks and pH-neutral foam shampoos directly to your driveway:\n"
            "• Exterior Express Wash: Rs 800 (sedan/hatchback), Rs 1,000 (SUV/crossover)\n"
            "• Interior Vacuum & Sanitization: Rs 1,200\n"
            "• Complete Showroom Detailing Package: Rs 2,500\n"
            "Customer water or power hookup is optional; teams carry self-contained battery pressure washers."
        ),
        "route": "/customer/wash-booking",
    },
    "commission_policy": {
        "title": "Platform Commission & Partner Settlements",
        "content": (
            "CARFIXZI charges workshop partners a platform commission on completed cash jobs:\n"
            "• Workshop Mechanical Services: 10.00% (1000 basis points)\n"
            "• Spare Parts Sales: 5.00% (500 basis points)\n"
            "• Doorstep Wash Services: 12.00% (1200 basis points)\n"
            "• Mobile Mechanic Callouts: 15.00% (1500 basis points)\n"
            "Partners accumulate commission liabilities during the month and settle with Regional Super Admins via verified bank transfer or cash deposit on the 5th of every month."
        ),
        "route": "/partner/billing",
    },
    "partner_verification": {
        "title": "Partner Registration & Dynamic Form Requirements",
        "content": (
            "To become a CARFIXZI verified workshop, applicants must provide:\n"
            "1. Workshop Front Facade Photo\n"
            "2. Owner CNIC Front & Back (13-digit Pakistani National Identity Card)\n"
            "3. Active FBR Tax Return / NTN Verification\n"
            "Regional Admins inspect the workshop physically before approving the partner application. Only Super Admins can retire schema fields."
        ),
        "route": "/partner/onboarding",
    },
    "dispute_resolution": {
        "title": "Dispute & Warranty Policy",
        "content": (
            "All mechanical repairs performed by CARFIXZI verified workshops carry a 7-day or 500 km workmanship guarantee. "
            "If an issue recurs, customers can report a dispute in the app under Service History. "
            "Regional Admins will mediate and dispatch an independent senior technician within 24 hours."
        ),
        "route": "/customer/history",
    },
}

def get_grounded_context() -> str:
    """Formats the entire grounded knowledge base as system prompt context."""
    blocks = []
    for key, data in PILOT_KNOWLEDGE_BASE.items():
        blocks.append(f"### {data['title']}\n{data['content']}")
    return "\n\n".join(blocks)

