"""
BhoomiIQ - Weather & Agro-Meteorology API Endpoints
Provides real-time forecasts, historical reanalysis features, canonical grid metrics,
and atomic monitoring of the 9,000-unit daily Open-Meteo budget.
"""

from fastapi import APIRouter, HTTPException, Query
from typing import Optional, Dict, Any

from app.models.schemas import WeatherContext, WeatherQuotaStatus, AgroWeatherFeatures
from app.services.openmeteo_service import (
    get_weather_for_field,
    OpenMeteoWeatherService
)
from app.services.weather_budget_manager import (
    quota_manager,
    WeatherBudgetExhaustedError,
    WeatherBudgetThrottledError
)
from app.api.routes_fields import FIELDS_DATABASE

router = APIRouter(prefix="/weather", tags=["Agro-Meteorology & Water Balance"])


@router.get("/quota", response_model=WeatherQuotaStatus)
async def get_weather_quota():
    """
    Returns live monitoring telemetry for the 9,000 billable unit daily budget:
      - Units consumed today & remaining
      - Normal operating target (8,500 units)
      - Hard limit (9,000 units)
      - Warning & throttle tiers (80% / 90%)
      - Total call counts and monthly usage
    """
    return quota_manager.get_quota_status()


@router.get("/{field_id}", response_model=WeatherContext)
async def get_weather(field_id: str):
    """
    Returns real-time and 7-day forecast agro-weather metrics
    including precipitation sum, reference evapotranspiration (ET0), and water balance.
    Backward-compatible with standard dashboard cards.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail=f"Field '{field_id}' not found in registry")
        
    field = FIELDS_DATABASE[field_id]
    return await get_weather_for_field(field.coordinates.lat, field.coordinates.lng)


@router.get("/{field_id}/features", response_model=AgroWeatherFeatures)
async def get_field_agricultural_features(field_id: str):
    """
    Returns detailed agricultural feature layer:
      - Growing Degree Days (GDD with base 10°C)
      - Effective rainfall (FAO USDA SCS infiltration method)
      - Consecutive dry days & dry-spell indicator
      - Cumulative ET0 & root-zone water balance
      - Vapour Pressure Deficit (VPD in kPa)
      - Soil moisture (0-7cm & 7-28cm)
      - Sugarcane maturity ripening favorability index
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail=f"Field '{field_id}' not found in registry")

    field = FIELDS_DATABASE[field_id]
    res = OpenMeteoWeatherService.get_weather_for_coordinates(
        lat=field.coordinates.lat,
        lng=field.coordinates.lng,
        profile_name="water_balance",
        is_essential=True
    )
    features_dict = res.get("features", {})
    return AgroWeatherFeatures(**features_dict)


@router.get("/{field_id}/forecast")
async def get_detailed_forecast(
    field_id: str,
    profile: str = Query("water_balance", regex="^(daily_forecast|water_balance)$")
):
    """
    Returns full Open-Meteo multi-variable forecast, grid cell alignment metadata,
    and cache provenance for the given parcel.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail=f"Field '{field_id}' not found in registry")

    field = FIELDS_DATABASE[field_id]
    return OpenMeteoWeatherService.get_weather_for_coordinates(
        lat=field.coordinates.lat,
        lng=field.coordinates.lng,
        profile_name=profile,
        is_essential=True
    )


@router.get("/{field_id}/historical")
async def get_historical_weather(
    field_id: str,
    start_date: str = Query(..., regex=r"^\d{4}-\d{2}-\d{2}$"),
    end_date: str = Query(..., regex=r"^\d{4}-\d{2}-\d{2}$")
):
    """
    Retrieves historical weather reanalysis records (ERA5/ERA5-Land) from Open-Meteo archive.
    Enforces non-essential request budget limits to preserve the operational quota.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail=f"Field '{field_id}' not found in registry")

    field = FIELDS_DATABASE[field_id]
    try:
        return OpenMeteoWeatherService.get_historical_weather(
            lat=field.coordinates.lat,
            lng=field.coordinates.lng,
            start_date=start_date,
            end_date=end_date,
            is_essential=False
        )
    except WeatherBudgetThrottledError as exc:
        raise HTTPException(status_code=429, detail=f"Quota Governor Throttled: {str(exc)}")
    except WeatherBudgetExhaustedError as exc:
        raise HTTPException(status_code=429, detail=f"Daily Budget Cap Exceeded: {str(exc)}")
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Historical weather retrieval failed: {str(exc)}")


@router.get("/storage/manifest")
async def get_storage_manifest():
    """
    Returns full diagnostics of preserved JSON files stored on disk.
    Every small and small part is stored in structured, atomic JSON files.
    """
    from app.services.api_data_preserver import ApiDataPreserver
    return ApiDataPreserver.get_preservation_manifest()


@router.get("/{field_id}/json")
async def get_field_preserved_json(field_id: str):
    """
    Returns the complete preserved JSON package for the field's grid cell,
    including hourly granules, daily granules, features, and physical units.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail=f"Field '{field_id}' not found in registry")

    field = FIELDS_DATABASE[field_id]
    grid_lat = round(field.coordinates.lat, 2)
    grid_lng = round(field.coordinates.lng, 2)

    from app.services.api_data_preserver import ApiDataPreserver
    preserved = ApiDataPreserver.load_latest_preserved_weather(grid_lat, grid_lng)

    if preserved is None:
        # Trigger fresh ingestion to create preserved files
        OpenMeteoWeatherService.get_weather_for_coordinates(
            lat=field.coordinates.lat,
            lng=field.coordinates.lng,
            profile_name="water_balance",
            is_essential=True
        )
        preserved = ApiDataPreserver.load_latest_preserved_weather(grid_lat, grid_lng)

    if preserved is None:
        raise HTTPException(status_code=404, detail="Preserved JSON record not yet available for this grid cell")

    return preserved
