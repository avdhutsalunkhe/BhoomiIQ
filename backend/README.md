# BhoomiIQ Satellite Crop Intelligence — Python Backend

A scientifically grounded FastAPI backend providing multispectral satellite image processing, agro-meteorological analytics, parcel resolution limits analysis, sugarcane harvesting authorization slips, and evidence-based AI agricultural advice.

---

## 1. Key Architectural Features

- **Multispectral Engine**: Calculates scientific vegetation & moisture indices (NDVI, NDMI, NDRE) using Copernicus Sentinel-2 Level-2A surface reflectance bands ($B4, B8, B11, B5$) with Scene Classification Layer (SCL) cloud/shadow masking.
- **Visual Basemap vs. Scientific Analysis**: Separates Google Satellite visual display from calibrated multispectral processing.
- **Small Parcel Resolution Analysis**: Accurately computes pure pixel counts, boundary erosion buffers, and usable pixel ratios for small plots (0.59 ac and 1.08 ac), triggering drone upgrade recommendations when sub-acre limits are reached.
- **Open-Meteo & IMD Agro-Weather**: Connects to the free Open-Meteo API to compute cumulative 7-day/14-day rainfall and $ET_0$ reference evapotranspiration water balance.
- **Evidence-Based Dynamic Advisories**: Synthesizes spectral indices, weather, and variety calendars (Co 86032, Phule 265) into sector-specific differential diagnoses.
- **Secure Harvesting Slips & QR**: Generates and verifies HMAC-SHA256 cryptographically signed harvesting slips, explicitly maintaining the legal distinction between harvest authorization and weighbridge payment receipts.
- **Strict Environment Configuration**: Loads all configuration directly from `.env` using `python-dotenv` and `pydantic-settings` without fallback logical operators or silent defaults.

---

## 2. Environment Configuration (`.env`)

All parameters are configured in [`.env`](file:///d:/Attend/field_staff_attendance_new/BhoomiIQ/backend/.env):

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `APP_ENV` | Application environment mode | `development` |
| `HOST` | Bind host address | `0.0.0.0` |
| `PORT` | Bind port number | `8000` |
| `DEBUG` | Enable debug / auto-reload | `true` |
| `CORS_ORIGINS` | Allowed frontend origins | `http://localhost:5173,http://localhost:3000` |
| `COPERNICUS_STAC_URL` | Copernicus Data Space STAC endpoint | `https://stac.dataspace.copernicus.eu/v1` |
| `PLANETARY_COMPUTER_STAC_URL` | Microsoft Planetary Computer STAC endpoint | `https://planetarycomputer.microsoft.com/api/stac/v1` |
| `OPEN_METEO_FORECAST_URL` | Open-Meteo Forecast & Agro-met API | `https://api.open-meteo.com/v1/forecast` |
| `FACTORY_NAME` | Associated Cooperative Sugar Factory | `Rajarambapu Patil Sahakari Sakhar Karkhana Ltd.` |
| `FACTORY_CODE` | Factory abbreviation code | `RBPSSK` |
| `SECRET_KEY` | Secret key for QR HMAC signing | Configured in `.env` |

---

## 3. How to Run the Backend

### Start Server
```powershell
cd d:\Attend\field_staff_attendance_new\BhoomiIQ\backend
python run_server.py
```
Or directly with uvicorn:
```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Interactive API Documentation
- **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc)
- **Health Check**: [http://localhost:8000/health](http://localhost:8000/health)

### Run Test Suite
```powershell
python test_api.py
```

---

## 4. API Endpoints Overview

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/health` | Server health and environmental configuration |
| `GET` | `/api/v1/fields` | List all registered sugarcane parcels |
| `GET` | `/api/v1/fields/{id}/analysis` | Full multispectral analysis (NDVI, NDMI, weather balance, resolution rating, advisory) |
| `GET` | `/api/v1/satellite/scenes/{id}` | Historical satellite revisit observations & cloud cover % |
| `GET` | `/api/v1/satellite/pixels/{id}` | Pixel-by-pixel band reflectances and classifications |
| `GET` | `/api/v1/weather/{id}` | Real-time agro-meteorology and ET0 water balance |
| `GET` | `/api/v1/slips` | Issued sugarcane harvesting slips |
| `POST` | `/api/v1/slips/verify-qr` | Cryptographic QR code verification |
| `GET` | `/api/v1/learn/guides` | Stage-categorized crop guides |
| `GET` | `/api/v1/learn/schemes` | Deduplicated factory subsidy schemes |
| `GET` | `/api/v1/learn/facilities` | Deduplicated factory facilities (Drone survey, Soil testing lab) |
| `POST` | `/api/v1/ai/photo-triage` | AI symptom triage tool for cane leaves & pests |
