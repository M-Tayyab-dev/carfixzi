# CARFIXZI — Verified Automotive Services & Workshop Marketplace SaaS

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-1.0-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)](https://python.org)
[![Cloudinary](https://img.shields.io/badge/Storage-Cloudinary-3448C5?logo=cloudinary)](https://cloudinary.com)
[![GroqCloud](https://img.shields.io/badge/AI-GroqCloud_LLaMA-F05A28)](https://console.groq.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**CARFIXZI** is a production-grade, multi-tenant automotive SaaS marketplace engineered for verified workshop discovery, doorstep car wash, on-demand mobile mechanic dispatch, spare parts sales, and audited cash-on-service commission settlements.

Initial pilot rollout: **Sahiwal District, Punjab, Pakistan**.

---

## 🏛️ System Architecture

CARFIXZI follows **Clean MVVM Architecture** with **GetX** for reactive state management, typed routing, and Dependency Injection:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│   Controllers (GetxController)  ◄───►  Views & Custom Design System    │
│   - AuthController                     - Customer Views (D01 - D17)    │
│   - FormBuilderController              - Partner Operations (D18 - D22)│
│   - CartController                     - Admin Dashboards (D23 - D25)  │
│   - AiChatController                   - Super Admin Root (D24)        │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
┌────────────────────────────────────▼───────────────────────────────────┐
│                           DOMAIN LAYER                                 │
│   Entities, Enums & Repository Contracts (Pure Dart, Zero UI coupling) │
│   - ServiceItem, PartItem, FormFieldConfig, WorkshopFormVersion        │
│   - UserRole, BookingStatus, OrderStatus, PaymentStatus                │
│   - AuthRepository, BiometricService, CurrencyUtils (PKR Paisa)        │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
┌────────────────────────────────────▼───────────────────────────────────┐
│                            DATA LAYER                                  │
│   Data Sources & External Gateways                                     │
│   - Firebase Auth (Link-based email verification, zero SMS costs)      │
│   - OpenStreetMap (flutter_map + latlong2, zero Google billing)        │
│   - Cloudinary Media Storage (Signed uploads for CNIC & Tax PDFs)      │
│   - Python FastAPI Backend (Grounded Groq AI proxy & Form Governance)  │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 👥 Multi-Role Taxonomy

| Role | Target Platform | Primary Capabilities |
| :--- | :--- | :--- |
| **Customer** | Android Mobile | Discover verified workshops via OpenStreetMap, book repairs, doorstep car wash, request roadside mobile mechanic, buy spare parts, track milestones, and cash checkout. |
| **Workshop Partner** | Android Mobile | Dynamic onboarding with CNIC & Tax Return upload, live bay monitoring, technician assignment, spare parts inventory alerts, and monthly commission billing ledger. |
| **Regional Admin** | Responsive Web / Desktop | Review partner verification queue, verify CNIC/tax documents, dynamic workshop registration form builder (create/edit/reorder fields), moderate price proposals. |
| **Super Admin** | Responsive Web / Desktop | Root platform governance, basis point commission policy adjustments (1000 bps services, 500 bps parts), audited manual cash settlement recording, admin provisioning, and form field soft-retirement. |

---

## 🚀 Key Functional Capabilities

1. **Zero-Cost Security & Authentication**:
   - Link-based Firebase email verification (Zero SMS gateway / phone verification costs).
   - Strict 12+ character password policy enforced with real-time entropy scoring.
   - Local biometric session unlock (Fingerprint / Face ID via `local_auth`).
2. **OpenStreetMap Integration**:
   - Live interactive map using `flutter_map` and `latlong2` with custom map markers for verified workshops in Sahiwal.
3. **Cash-on-Service & Demo Simulated Checkout**:
   - Dual-mode checkout explicitly separating physical cash handover from demo simulated transactions.
   - All amounts calculated in integer PKR Paisa (`1 PKR = 100 Paisa`) with zero floating-point rounding errors.
4. **Dynamic Workshop Form Builder**:
   - Admin schema editor to add, edit, and reorder onboarding fields.
   - Policy-locked legal fields (Storefront photo, CNIC Front/Back, Tax Return) cannot be made optional or deleted by Admins.
   - Super Admin-only field soft-retirement with required justification audit reasons.
5. **Cloudinary Document & Photo Storage**:
   - Camera & Gallery image capture for workshop storefronts and CNIC verification.
   - PDF document file picker for FBR Tax Return / NTN certificates.
   - Direct signed Cloudinary uploads returning secure HTTPS URLs.
6. **Grounded GroqCloud AI Assistant**:
   - Powered by Qwen 3.8 / LLaMA on GroqCloud, proxied through a trusted local FastAPI backend.
   - Responses grounded strictly in verified pilot knowledge base (workshops, pricing, and policies).

---

## 📂 Project Structure

```
d:\fyp\carfixzi\
├── lib\
│   ├── app\
│   │   ├── bindings\            # Dependency Injection (InitialBinding)
│   │   ├── middleware\          # Role-based route guards (AuthMiddleware)
│   │   └── routes\              # Typed routing (AppRoutes, AppPages)
│   ├── core\
│   │   ├── constants\           # AppConstants, FirestorePaths, ApiEndpoints
│   │   ├── enums\               # UserRole, BookingStatus, PaymentStatus, etc.
│   │   ├── security\            # BiometricService (local_auth + secure_storage)
│   │   ├── services\            # MediaUploadService (Cloudinary integration)
│   │   └── utils\               # CurrencyUtils (integer PKR Paisa), Validators
│   ├── features\
│   │   ├── admin\               # Form Builder & Partner Document Verification
│   │   ├── ai_assistant\        # Grounded GroqCloud AI Chat
│   │   ├── auth\                # Splash, Onboarding, Login, Register, Verify Email
│   │   ├── customer\            # Home, Map Locator, Bookings, Wash, Mechanic, Cart
│   │   ├── partner\             # Dashboard, Dynamic Onboarding, Inventory, Billing
│   │   └── super_admin\         # Commission Policies, Settlements, Staff Provisioning
│   ├── shared\widgets\          # CarfixziButton, CarfixziCard, StatusBadge, etc.
│   └── theme\                   # AppColors, AppTypography, AppTheme
├── backend\                     # Python FastAPI Trusted Backend Service
│   ├── app\
│   │   ├── api\                 # AI chat, Dynamic Form, Bookings, Media, Settlements
│   │   ├── models\              # Pydantic data schemas
│   │   ├── services\            # Cloudinary & GroqCloud integration
│   │   ├── config.py            # Environment configuration
│   │   └── main.py              # FastAPI app with CORS & health checks
│   ├── requirements.txt         # Python dependencies
│   ├── .env.example             # Environment template
│   └── Dockerfile               # Production container definition
├── docs\                        # Full Architectural Analysis & Specifications
├── test\
│   ├── unit\                    # Validators, Currency, Form Builder, Cart, Commission tests
│   └── widget_test.dart         # Smoke test
└── pubspec.yaml
```

---

## 🛠️ Quick Start Guide

### 1. Prerequisites
- **Flutter SDK**: `>=3.13.4`
- **Dart SDK**: `>=3.13.4`
- **Python**: `>=3.10`

### 2. Run the Python FastAPI Backend
```bash
cd backend

# Create & activate virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1    # On Windows
source venv/bin/activate       # On Linux/macOS

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env

# Run FastAPI server
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
- Interactive API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)
- Health Check: [http://localhost:8000/health](http://localhost:8000/health)

### 3. Run the Flutter Client
```bash
# Get dependencies
flutter pub get

# Run Android Handset (Customer / Partner)
flutter run -d android

# Run Web Dashboard (Admin / Super Admin)
flutter run -d chrome
```

---

## 🧪 Test Suite Execution

Run the complete test suite:
```bash
flutter test
```
**Results: 38 / 38 unit & widget tests passed (100% success rate)**
- Password policy & entropy tests
- PKR Paisa currency and basis points commission calculations
- Dynamic form builder baseline locks & Super Admin retirement
- Cart stepper, stock ceilings & total calculation
- App smoke test

Static analysis:
```bash
flutter analyze
# Output: No issues found!
```
