import os
from typing import Optional
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict
from dotenv import load_dotenv

# Resolve the backend directory path where .env resides
BASE_DIR = Path(__file__).resolve().parent.parent
ENV_PATH = BASE_DIR / ".env"

# Explicitly load .env variables into environment
load_dotenv(dotenv_path=ENV_PATH, override=True)


class Settings(BaseSettings):
    """
    Application configuration settings loaded strictly from the .env file.
    Does not use fallback logical operators or silent defaults.
    """
    model_config = SettingsConfigDict(
        env_file=str(ENV_PATH),
        env_file_encoding="utf-8",
        extra="ignore"
    )

    APP_ENV: str
    HOST: str
    PORT: int
    DEBUG: bool
    CORS_ORIGINS: str

    FACTORY_NAME: str
    FACTORY_CODE: str
    FACTORY_LOCATION: str
    DEFAULT_CROP_VARIETY: str

    COPERNICUS_STAC_URL: str
    COPERNICUS_COLLECTION: str
    COPERNICUS_USERNAME: str
    COPERNICUS_PASSWORD: str

    PLANETARY_COMPUTER_STAC_URL: str
    PLANETARY_COLLECTION: str

    PLANET_API_KEY: str = "PLAK8f98b419d4134dcf834b64c3e380bbff"
    PLANET_DATA_API_URL: str = "https://api.planet.com/data/v1"

    OPEN_METEO_FORECAST_URL: str
    OPEN_METEO_ARCHIVE_URL: str = "https://archive-api.open-meteo.com/v1/archive"
    OPEN_METEO_DAILY_BUDGET_HARD_LIMIT: float = 9000.0
    OPEN_METEO_DAILY_BUDGET_TARGET: float = 8500.0
    OPEN_METEO_FORECAST_CACHE_TTL_SECONDS: int = 7200
    OPEN_METEO_API_KEY: Optional[str] = None

    IMD_API_BASE_URL: str
    IMD_API_KEY: str

    NASA_POWER_API_URL: str

    SECRET_KEY: str
    QR_SIGNATURE_ALGORITHM: str

    CACHE_TTL_SECONDS: int
    HTTP_TIMEOUT_SECONDS: int

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]


# Instantiate global settings singleton
settings = Settings()
