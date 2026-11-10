# CARFIXZI Python FastAPI Trusted Backend

Official backend microservice for **CARFIXZI** — Pakistan's verified automotive services marketplace.

## Key Capabilities
1. **Grounded GroqCloud AI Assistant**: Zero-cost, high-speed LLM inference proxy grounded strictly in Sahiwal pilot verified workshops, pricing, and cash-on-service policies.
2. **Dynamic Workshop Registration Form Governance**: Admin dynamic schema management with Super Admin-only field soft-retirement.
3. **Commission & Settlement Tracking**: Basis points commission liability calculations for cash-declared jobs.

## Quick Start

### 1. Create and Activate Virtual Environment
```bash
cd backend
python -m venv venv

# Windows PowerShell:
.\venv\Scripts\Activate.ps1

# Linux / macOS:
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
*(Optional)* Add your free GroqCloud API key in `.env`:
```env
GROQ_API_KEY=gsk_your_key_here
```
> Note: If no GroqCloud key is set, the backend seamlessly falls back to its built-in verified knowledge base synthesizer.

### 4. Run the Server
```bash
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Interactive Swagger API documentation: [http://localhost:8000/docs](http://localhost:8000/docs)
Interactive ReDoc documentation: [http://localhost:8000/redoc](http://localhost:8000/redoc)

## API Endpoints
- `POST /v1/ai/chat` — Grounded AI Assistant query
- `GET /v1/workshop-form/active` — Active registration form schema
- `POST /v1/workshop-form/publish` — Publish new immutable schema version
- `POST /v1/workshop-form/fields/{id}/retire` — Super Admin field retirement
- `GET /v1/bookings` — List service bookings
- `POST /v1/payments/{id}/confirm` — Confirm cash payment & issue digital receipt
- `GET /v1/settlements` — Partner commission ledger

