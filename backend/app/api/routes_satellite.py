from fastapi import APIRouter, HTTPException, Query
from typing import List, Dict, Any
from app.models.schemas import SatelliteSceneMetadata, PixelSpectralResult
from app.services.copernicus_service import search_sentinel_scenes
from app.services.planet_service import search_planet_scenes, PlanetSceneMetadata
from app.services.spectral_engine import generate_field_pixel_grid
from app.api.routes_fields import FIELDS_DATABASE

router = APIRouter(prefix="/satellite", tags=["Satellite Earth Observation"])


@router.get("/scenes/{field_id}", response_model=List[SatelliteSceneMetadata])
async def get_field_satellite_scenes(field_id: str):
    """
    Returns available Sentinel-2 Level-2A observation dates and quality metadata
    for the specific field location.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail="Field not found")
        
    field = FIELDS_DATABASE[field_id]
    return await search_sentinel_scenes(field.coordinates.lat, field.coordinates.lng)


@router.get("/planet/scenes/{field_id}", response_model=List[PlanetSceneMetadata])
async def get_field_planet_scenes(field_id: str):
    """
    Returns live Planet Labs 3m daily SuperDove PSScene captures queried via
    Planet Data API using the user's Planet Explorer developer key.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail="Field not found")
        
    field = FIELDS_DATABASE[field_id]
    return await search_planet_scenes(field.coordinates.lat, field.coordinates.lng)


@router.get("/pixels/{field_id}", response_model=List[PixelSpectralResult])
async def get_field_pixels(
    field_id: str,
    date_offset: int = Query(0, ge=0, le=4)
):
    """
    Returns individual 10m/20m pixel values with band reflectances and spectral indices.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail="Field not found")
        
    field = FIELDS_DATABASE[field_id]
    return generate_field_pixel_grid(field.id, field.area_acres, date_offset)

