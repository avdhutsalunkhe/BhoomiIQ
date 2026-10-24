from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.api.routes_fields import router as fields_router
from app.api.routes_satellite import router as satellite_router
from app.api.routes_weather import router as weather_router
from app.api.routes_slips import router as slips_router
from app.api.routes_learn import router as learn_router
from app.api.routes_ai import router as ai_router

app = FastAPI(
    title="BhoomiIQ - Satellite Crop Intelligence & Farmer Advisory Backend",
    description=(
        "Production-ready backend API connecting Copernicus Sentinel-2 multispectral Earth observation, "
        "Open-Meteo agro-meteorology, parcel-level resolution analysis, harvesting authorizations, "
        "and evidence-based sugarcane advisory for Rajarambapu Patil Sahakari Sakhar Karkhana."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS to allow local LAN devices, mobile phones, and web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_origin_regex=r"https?://.*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API routers under /api/v1 prefix
app.include_router(fields_router, prefix="/api/v1")
app.include_router(satellite_router, prefix="/api/v1")
app.include_router(weather_router, prefix="/api/v1")
app.include_router(slips_router, prefix="/api/v1")
app.include_router(learn_router, prefix="/api/v1")
app.include_router(ai_router, prefix="/api/v1")


@app.get("/health")
async def health_check():
    """
    Health check endpoint verifying system readiness and environment configuration.
    """
    return {
        "status": "healthy",
        "app_env": settings.APP_ENV,
        "factory": settings.FACTORY_NAME,
        "factory_code": settings.FACTORY_CODE,
        "copernicus_stac": settings.COPERNICUS_STAC_URL,
        "open_meteo": settings.OPEN_METEO_FORECAST_URL
    }


@app.get("/")
async def root():
    return {
        "portal": "BhoomiIQ Satellite Crop Intelligence System",
        "documentation": "/docs",
        "health": "/health",
        "version": "1.0.0",
        "endpoints": [
            "/api/v1/fields",
            "/api/v1/fields/{field_id}/analysis",
            "/api/v1/satellite/scenes/{field_id}",
            "/api/v1/weather/{field_id}",
            "/api/v1/slips",
            "/api/v1/slips/verify-qr",
            "/api/v1/learn/guides",
            "/api/v1/learn/schemes",
            "/api/v1/learn/facilities",
            "/api/v1/ai/photo-triage"
        ]
    }
