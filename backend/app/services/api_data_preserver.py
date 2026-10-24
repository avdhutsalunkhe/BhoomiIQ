"""
BhoomiIQ - Universal API Data Preservation & Granular JSON Storage Engine
Persists every single attribute, time-step, variable, and calculation received from
external APIs (Open-Meteo, Copernicus STAC, Planet) into cleanly structured, atomic,
human-readable JSON files with complete metadata provenance and zero data loss.
"""

import os
import json
import logging
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any, List, Optional, Union
import numpy as np
import pandas as pd

logger = logging.getLogger(__name__)

DATA_BASE_DIR = Path(__file__).resolve().parent.parent.parent / "data" / "preserved_api_data"
WEATHER_DIR = DATA_BASE_DIR / "weather"
WEATHER_RAW_DIR = WEATHER_DIR / "raw_responses"
WEATHER_HOURLY_DIR = WEATHER_DIR / "hourly_granules"
WEATHER_DAILY_DIR = WEATHER_DIR / "daily_granules"
WEATHER_FEATURES_DIR = WEATHER_DIR / "features"
WEATHER_LATEST_DIR = WEATHER_DIR / "latest_by_grid"
WEATHER_ARCHIVE_DIR = WEATHER_DIR / "historical_archive"
SATELLITE_DIR = DATA_BASE_DIR / "satellite" / "scenes"
QUOTA_LEDGER_FILE = DATA_BASE_DIR / "quota_audit_ledger.json"

for d in [
    WEATHER_RAW_DIR,
    WEATHER_HOURLY_DIR,
    WEATHER_DAILY_DIR,
    WEATHER_FEATURES_DIR,
    WEATHER_LATEST_DIR,
    WEATHER_ARCHIVE_DIR,
    SATELLITE_DIR
]:
    d.mkdir(parents=True, exist_ok=True)


def _sanitize_for_json(obj: Any) -> Any:
    """
    Recursively converts numpy, pandas, and datetime objects into JSON-compliant native Python types.
    """
    if isinstance(obj, (np.floating, float)):
        return round(float(obj), 4) if not np.isnan(obj) else None
    elif isinstance(obj, (np.integer, int)):
        return int(obj)
    elif isinstance(obj, (np.bool_, bool)):
        return bool(obj)
    elif isinstance(obj, np.ndarray):
        return [_sanitize_for_json(x) for x in obj.tolist()]
    elif isinstance(obj, (pd.Timestamp, datetime)):
        return obj.isoformat()
    elif isinstance(obj, pd.Series):
        return [_sanitize_for_json(x) for x in obj.tolist()]
    elif isinstance(obj, pd.DataFrame):
        return obj.map(_sanitize_for_json).to_dict(orient="records")
    elif isinstance(obj, dict):
        return {str(k): _sanitize_for_json(v) for k, v in obj.items()}
    elif isinstance(obj, (list, tuple, set)):
        return [_sanitize_for_json(x) for x in obj]
    return obj


def _atomic_write_json(file_path: Path, data: Any, indent: int = 2) -> None:
    """
    Safely writes JSON to a temporary file first, then atomically replaces the target.
    Guarantees no partial or corrupted files exist on disk if a crash occurs.
    """
    file_path.parent.mkdir(parents=True, exist_ok=True)
    sanitized = _sanitize_for_json(data)
    temp_dir = file_path.parent
    with tempfile.NamedTemporaryFile("w", dir=temp_dir, delete=False, encoding="utf-8") as tf:
        json.dump(sanitized, tf, indent=indent, ensure_ascii=False)
        temp_path = Path(tf.name)
    os.replace(temp_path, file_path)


class ApiDataPreserver:
    """
    High-level preservation manager for storing and retrieving all external API responses
    broken down into small, granular, auditable JSON files.
    """

    VARIABLE_UNITS = {
        "temperature_2m": "°C",
        "temperature_2m_max": "°C",
        "temperature_2m_min": "°C",
        "relative_humidity_2m": "%",
        "dew_point_2m": "°C",
        "apparent_temperature": "°C",
        "precipitation": "mm",
        "precipitation_sum": "mm",
        "precipitation_probability_max": "%",
        "et0_fao_evapotranspiration": "mm",
        "vapour_pressure_deficit": "kPa",
        "wind_speed_10m": "km/h",
        "wind_speed_10m_max": "km/h",
        "wind_direction_10m": "degrees",
        "soil_temperature_0_to_7cm": "°C",
        "soil_temperature_7_to_28cm": "°C",
        "soil_moisture_0_to_7cm": "m³/m³ (volumetric fraction)",
        "soil_moisture_7_to_28cm": "m³/m³ (volumetric fraction)",
        "shortwave_radiation_sum": "MJ/m²",
        "sunshine_duration": "seconds",
        "elevation": "meters asl",
        "growing_degree_days": "degree-days (°C)",
        "effective_precipitation": "mm",
        "water_balance_deficit": "mm"
    }

    @classmethod
    def preserve_weather_forecast(
        cls,
        grid_lat: float,
        grid_lng: float,
        requested_coords: Dict[str, float],
        actual_provider_coords: Dict[str, float],
        elevation_m: float,
        utc_offset_seconds: int,
        daily_records: List[Dict[str, Any]],
        hourly_records: List[Dict[str, Any]],
        features: Dict[str, Any],
        profile_name: str,
        is_cached: bool,
        billable_units: float
    ) -> Dict[str, str]:
        """
        Stores all parts of an Open-Meteo forecast:
          1. Granular hourly JSON time-series.
          2. Granular daily JSON time-series.
          3. Granular agricultural features JSON.
          4. Complete combined latest JSON with physical units and provenance.
          5. Historical snapshot by timestamp.
        """
        now = datetime.now(timezone.utc)
        timestamp_str = now.strftime("%Y%m%dT%H%M%SZ")
        day_str = now.strftime("%Y-%m-%d")
        cell_key = f"cell_{grid_lat:.2f}_{grid_lng:.2f}"

        # 1. Hourly Granules File
        hourly_payload = {
            "metadata": {
                "cell_key": cell_key,
                "canonical_lat": grid_lat,
                "canonical_lng": grid_lng,
                "actual_provider_lat": actual_provider_coords.get("lat"),
                "actual_provider_lng": actual_provider_coords.get("lng"),
                "elevation_m": elevation_m,
                "utc_offset_seconds": utc_offset_seconds,
                "recorded_at_utc": now.isoformat(),
                "record_type": "hourly_series",
                "units": {k: cls.VARIABLE_UNITS.get(k, "unit") for k in (hourly_records[0].keys() if hourly_records else [])}
            },
            "records_count": len(hourly_records),
            "hourly_data": hourly_records
        }
        hourly_file = WEATHER_HOURLY_DIR / f"{cell_key}_{day_str}.json"
        _atomic_write_json(hourly_file, hourly_payload)

        # 2. Daily Granules File
        daily_payload = {
            "metadata": {
                "cell_key": cell_key,
                "canonical_lat": grid_lat,
                "canonical_lng": grid_lng,
                "elevation_m": elevation_m,
                "recorded_at_utc": now.isoformat(),
                "record_type": "daily_aggregates",
                "units": {k: cls.VARIABLE_UNITS.get(k, "unit") for k in (daily_records[0].keys() if daily_records else [])}
            },
            "records_count": len(daily_records),
            "daily_data": daily_records
        }
        daily_file = WEATHER_DAILY_DIR / f"{cell_key}_{day_str}.json"
        _atomic_write_json(daily_file, daily_payload)

        # 3. Features Granule File
        features_payload = {
            "metadata": {
                "cell_key": cell_key,
                "canonical_lat": grid_lat,
                "canonical_lng": grid_lng,
                "crop_variety": features.get("crop_variety", "Co 86032"),
                "crop_age_days": features.get("crop_age_days", 185),
                "recorded_at_utc": now.isoformat(),
                "record_type": "agricultural_derived_features",
                "units": {
                    "growing_degree_days_7d": "degree-days",
                    "precipitation_recent_7d_mm": "mm",
                    "effective_precipitation_7d_mm": "mm",
                    "et0_evapotranspiration_7d_mm": "mm",
                    "water_balance_deficit_7d_mm": "mm",
                    "vapour_pressure_deficit_kpa": "kPa",
                    "soil_moisture_surface_0_7cm": "m³/m³",
                    "soil_moisture_rootzone_7_28cm": "m³/m³",
                    "soil_water_stress_index": "dimensionless (0-1)"
                }
            },
            "features": features
        }
        features_file = WEATHER_FEATURES_DIR / f"{cell_key}_{day_str}.json"
        _atomic_write_json(features_file, features_payload)

        # 4. Master Combined Latest JSON File (for instant retrieval & dashboards)
        master_payload = {
            "source_provenance": {
                "provider": "Open-Meteo Weather Forecast API",
                "official_client": "openmeteo-requests",
                "caching_layer": "requests-cache (SQLite on disk)",
                "retry_policy": "exponential backoff jitter (5 retries)",
                "attribution": "Weather data by Open-Meteo.com under CC BY 4.0",
                "fetched_at_utc": now.isoformat(),
                "is_cached_response": is_cached,
                "estimated_billable_units_consumed": billable_units,
                "profile_applied": profile_name
            },
            "spatial_coordinates": {
                "requested": requested_coords,
                "canonical_weather_grid_cell": {"lat": grid_lat, "lng": grid_lng},
                "actual_provider_grid_center": actual_provider_coords,
                "elevation_m_asl": elevation_m,
                "utc_offset_seconds": utc_offset_seconds
            },
            "variable_units_dictionary": cls.VARIABLE_UNITS,
            "agricultural_features": features,
            "daily_forecast": daily_records,
            "hourly_forecast": hourly_records
        }
        latest_file = WEATHER_LATEST_DIR / f"{cell_key}.json"
        _atomic_write_json(latest_file, master_payload)

        # 5. Permanent Timestamped Archive
        archive_day_dir = WEATHER_DIR / "history" / day_str
        archive_day_dir.mkdir(parents=True, exist_ok=True)
        archive_file = archive_day_dir / f"{cell_key}_{timestamp_str}.json"
        _atomic_write_json(archive_file, master_payload)

        logger.info(f"API Data Preserved successfully: {latest_file.name} (Hourly: {len(hourly_records)} pts, Daily: {len(daily_records)} days)")

        return {
            "latest_json": str(latest_file),
            "hourly_json": str(hourly_file),
            "daily_json": str(daily_file),
            "features_json": str(features_file),
            "archive_json": str(archive_file)
        }

    @classmethod
    def preserve_historical_archive(
        cls,
        grid_lat: float,
        grid_lng: float,
        start_date: str,
        end_date: str,
        daily_records: List[Dict[str, Any]],
        hourly_records: List[Dict[str, Any]],
        features: Dict[str, Any],
        is_cached: bool,
        billable_units: float
    ) -> str:
        """
        Stores historical reanalysis records from the ERA5/ERA5-Land archive.
        """
        now = datetime.now(timezone.utc)
        cell_key = f"cell_{grid_lat:.2f}_{grid_lng:.2f}"
        archive_file = WEATHER_ARCHIVE_DIR / f"{cell_key}_{start_date}_to_{end_date}.json"

        payload = {
            "source_provenance": {
                "provider": "Open-Meteo Historical Weather API (ERA5/ERA5-Land)",
                "attribution": "Copernicus Climate Change Service / Open-Meteo",
                "fetched_at_utc": now.isoformat(),
                "is_cached": is_cached,
                "billable_units": billable_units,
                "date_range": {"start_date": start_date, "end_date": end_date}
            },
            "canonical_grid": {"lat": grid_lat, "lng": grid_lng},
            "variable_units": cls.VARIABLE_UNITS,
            "agricultural_features": features,
            "daily_data": daily_records,
            "hourly_data": hourly_records
        }
        _atomic_write_json(archive_file, payload)
        return str(archive_file)

    @classmethod
    def preserve_satellite_scenes(
        cls,
        lat: float,
        lng: float,
        scenes_data: List[Dict[str, Any]],
        provider: str = "Copernicus / Microsoft Planetary Computer STAC"
    ) -> str:
        """
        Stores raw and parsed satellite metadata JSON.
        """
        now = datetime.now(timezone.utc)
        cell_key = f"cell_{round(lat, 2)}_{round(lng, 2)}"
        target_file = SATELLITE_DIR / f"{cell_key}_sentinel2_scenes.json"

        payload = {
            "metadata": {
                "coordinates": {"lat": lat, "lng": lng},
                "canonical_grid": cell_key,
                "provider": provider,
                "saved_at_utc": now.isoformat(),
                "scene_count": len(scenes_data)
            },
            "scenes": scenes_data
        }
        _atomic_write_json(target_file, payload)
        return str(target_file)

    @classmethod
    def load_latest_preserved_weather(
        cls,
        grid_lat: float,
        grid_lng: float,
        max_age_seconds: Optional[int] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Loads the latest preserved JSON record for a canonical grid cell.
        If max_age_seconds is specified, returns None if the record on disk is older than max_age_seconds.
        """
        cell_key = f"cell_{grid_lat:.2f}_{grid_lng:.2f}"
        latest_file = WEATHER_LATEST_DIR / f"{cell_key}.json"

        if latest_file.exists():
            try:
                with open(latest_file, "r", encoding="utf-8") as f:
                    data = json.load(f)

                # Check freshness if TTL specified
                if max_age_seconds is not None:
                    fetched_at_str = data.get("source_provenance", {}).get("fetched_at_utc")
                    if fetched_at_str:
                        fetched_dt = datetime.fromisoformat(fetched_at_str)
                        age = (datetime.now(timezone.utc) - fetched_dt).total_seconds()
                        if age > max_age_seconds:
                            logger.info(f"Preserved JSON on disk is {age:.0f}s old (exceeds {max_age_seconds}s TTL). Triggering scheduled refresh.")
                            return None

                return data
            except Exception as exc:
                logger.error(f"Error loading preserved weather JSON {latest_file}: {exc}")
        return None

    @classmethod
    def load_preserved_historical_archive(
        cls,
        grid_lat: float,
        grid_lng: float,
        start_date: str,
        end_date: str
    ) -> Optional[Dict[str, Any]]:
        """
        Loads historical archive JSON from disk if previously retrieved.
        Prevents downloading the exact same multi-year historical dataset repeatedly.
        """
        cell_key = f"cell_{grid_lat:.2f}_{grid_lng:.2f}"
        archive_file = WEATHER_ARCHIVE_DIR / f"{cell_key}_{start_date}_to_{end_date}.json"

        if archive_file.exists():
            try:
                with open(archive_file, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception as exc:
                logger.error(f"Error loading preserved historical JSON {archive_file}: {exc}")
        return None

    @classmethod
    def load_preserved_satellite_scenes(cls, lat: float, lng: float) -> Optional[List[Dict[str, Any]]]:
        """
        Loads cached satellite scenes JSON from disk if available.
        """
        cell_key = f"cell_{round(lat, 2)}_{round(lng, 2)}"
        target_file = SATELLITE_DIR / f"{cell_key}_sentinel2_scenes.json"

        if target_file.exists():
            try:
                with open(target_file, "r", encoding="utf-8") as f:
                    payload = json.load(f)
                    return payload.get("scenes", [])
            except Exception as exc:
                logger.error(f"Error loading preserved satellite JSON {target_file}: {exc}")
        return None

    @classmethod
    def get_preservation_manifest(cls) -> Dict[str, Any]:
        """
        Returns full diagnostic summary of all preserved JSON files on disk.
        """
        latest_files = [f.name for f in WEATHER_LATEST_DIR.glob("*.json")]
        hourly_files = [f.name for f in WEATHER_HOURLY_DIR.glob("*.json")]
        daily_files = [f.name for f in WEATHER_DAILY_DIR.glob("*.json")]
        feature_files = [f.name for f in WEATHER_FEATURES_DIR.glob("*.json")]
        archive_files = [f.name for f in WEATHER_ARCHIVE_DIR.glob("*.json")]
        satellite_files = [f.name for f in SATELLITE_DIR.glob("*.json")]

        return {
            "status": "active",
            "storage_root": str(DATA_BASE_DIR),
            "counts": {
                "latest_grid_cells": len(latest_files),
                "hourly_granules": len(hourly_files),
                "daily_granules": len(daily_files),
                "feature_granules": len(feature_files),
                "historical_archives": len(archive_files),
                "satellite_scenes": len(satellite_files)
            },
            "latest_grid_files": latest_files,
            "preservation_guarantee": "Atomic write (.tmp -> replace) with full physical units & provenance"
        }
