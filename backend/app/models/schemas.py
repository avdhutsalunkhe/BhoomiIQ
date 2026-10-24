from typing import List, Optional, Dict, Any, Tuple
from pydantic import BaseModel, Field


class Coordinates(BaseModel):
    lat: float
    lng: float


class PixelBandData(BaseModel):
    id: str
    col: int
    row: int
    b2_blue: float
    b3_green: float
    b4_red: float
    b8_nir: float
    b11_swir: float
    scl_class: int  # 4=vegetation, 5=bare soil, 3=shadow, 8/9/10=cloud
    is_boundary: bool


class PixelSpectralResult(BaseModel):
    id: str
    col: int
    row: int
    ndvi: float
    ndmi: float
    ndre: float
    msavi2: float = 0.55
    cari: float = 0.42
    cwsi: float = 0.25
    is_valid_vegetation: bool
    is_boundary: bool
    classification: str  # e.g., "Dense Growth", "Moist Canopy", "Stressed", "Cloud Masked"


class ResolutionAnalysis(BaseModel):
    area_acres: float
    area_sq_meters: float
    theoretical_10m_pixels: int
    theoretical_20m_pixels: int
    usable_pure_pixels: int
    boundary_excluded_pixels: int
    usability_ratio: float
    resolution_rating: str  # "Optimal" | "Acceptable" | "Constrained"
    drone_survey_recommended: bool
    limitation_notice: str


class SatelliteSceneMetadata(BaseModel):
    scene_id: str
    satellite_platform: str  # e.g., "Sentinel-2B (MSI Level-2A)"
    acquisition_timestamp: str
    cloud_cover_pct: float
    parcel_cloud_score: float
    sun_zenith_angle: float
    data_source: str  # e.g., "Copernicus Data Space / Planetary Computer STAC"
    bands_available: List[str]


class WeatherContext(BaseModel):
    source: str
    latitude: float
    longitude: float
    temperature_2m_c: float
    relative_humidity_pct: float
    rainfall_recent_7d_mm: float
    rainfall_recent_14d_mm: float
    et0_evapotranspiration_mm: float
    water_balance_index: float  # Rainfall - ET0
    soil_temperature_0_10cm_c: float
    forecast_7d_summary: str
    surface_pressure_hpa: float = 1012.8
    wind_speed_kmh: float = 12.0
    wind_direction_deg: float = 265.0
    dew_point_c: float = 12.4
    apparent_temperature_c: float = 25.2
    vapour_pressure_deficit_kpa: float = 1.86
    soil_moisture_surface_m3m3: float = 0.24
    soil_moisture_rootzone_m3m3: float = 0.25
    solar_radiation_mj_m2: float = 21.4
    sunshine_duration_hours: float = 9.2
    growing_degree_days_7d: float = 127.6
    temperature_max_c: float = 33.5
    temperature_min_c: float = 22.9


class DynamicAdvisory(BaseModel):
    status_level: str  # "good" | "check" | "inspect"
    headline: str
    detail: str
    affected_sector: Optional[str] = None
    confidence_pct: int
    differential_diagnosis: List[str]
    suggested_actions: List[str]
    scientific_disclaimer: str


class FarmField(BaseModel):
    id: str
    name: str
    name_mr: str
    plot_number: str
    area_acres: float
    variety: str
    cane_type: str
    planting_date: str
    expected_harvest_date: str
    crop_age_days: int
    crop_stage: str
    village: str
    coordinates: Coordinates
    boundary_polygon: List[Tuple[float, float]]


class SugarcaneYieldPrediction(BaseModel):
    predicted_yield_mt_per_acre: float
    total_field_tonnes: float
    historical_benchmark_mt: float = 45.0
    yield_delta_pct: float
    confidence_interval_mt: Tuple[float, float]
    ml_algorithm: str = "Ensemble Gradient Boosting (GDD + iPAR + Kc + Variety)"
    above_ground_biomass_tons_acre: float
    carbon_sequestered_mt_co2e: float
    yield_classification: str  # "Exceptional" | "Above Average" | "Average" | "Underperforming"


class SucroseMaturityForecast(BaseModel):
    brix_degrees: float
    ccs_percent: float  # Commercial Cane Sugar %
    pol_percent: float
    maturity_index: float  # Top/Bottom Brix ratio (0.85-1.0)
    optimal_harvest_window_start: str
    optimal_harvest_window_end: str
    days_to_peak_sucrose: int
    harvest_recommendation: str
    mill_recovery_bonus_potential_inr: float


class IrrigationPrescription(BaseModel):
    daily_etc_mm: float
    fao_kc_dual: float  # Kcb + Ke
    soil_depletion_mm: float
    soil_moisture_status: str  # "Adequate" | "Deficit Stress" | "Critical Wilting"
    recommended_irrigation_liters_per_acre: float
    recommended_drip_runtime_hours: float
    next_irrigation_urgency: str  # "Immediate (Today)" | "Within 48 Hours" | "Optimal Moisture"
    drainage_salinity_risk: str


class AnomalyDiagnosticML(BaseModel):
    top_condition: str
    top_condition_mr: str
    ml_confidence_pct: int
    probability_distribution: Dict[str, float]
    spectral_evidence: List[str]
    agronomic_action_plan: List[str]
    chemical_prescription_rx: Optional[str] = None
    biological_remedy: Optional[str] = None


class FieldAnalysisResponse(BaseModel):
    field: FarmField
    satellite_metadata: SatelliteSceneMetadata
    resolution_analysis: ResolutionAnalysis
    weather: WeatherContext
    spectral_summary: Dict[str, float]
    pixels: List[PixelSpectralResult]
    advisory: DynamicAdvisory
    yield_prediction: Optional[SugarcaneYieldPrediction] = None
    sucrose_maturity: Optional[SucroseMaturityForecast] = None
    irrigation_prescription: Optional[IrrigationPrescription] = None
    anomaly_ml: Optional[AnomalyDiagnosticML] = None


class HarvestingSlip(BaseModel):
    slip_id: str
    reg_id: str
    season: str
    farmer_name: str
    farmer_name_mr: str
    plot_name: str
    village: str
    cane_type: str
    variety: str
    registered_area_acres: float
    planting_date: str
    harvesting_date: str
    estimated_tonnes: float
    method: str
    status: str
    registered_at: str
    issued_at: str
    assigned_officer: str
    remarks: str
    qr_payload: str


class QRVerificationRequest(BaseModel):
    qr_payload: str


class QRVerificationResponse(BaseModel):
    valid: bool
    slip_id: Optional[str] = None
    reg_id: Optional[str] = None
    farmer_name: Optional[str] = None
    plot_name: Optional[str] = None
    estimated_tonnes: Optional[float] = None
    harvesting_date: Optional[str] = None
    status: Optional[str] = None
    issuer: str
    verified_at: str
    legal_notice: str


class FactoryScheme(BaseModel):
    id: str
    title: str
    title_mr: str
    benefit: str
    benefit_mr: str
    eligibility: str
    eligibility_mr: str
    contact_name: str
    contact_phone: str


class FactoryFacility(BaseModel):
    id: str
    title: str
    title_mr: str
    department: str
    department_mr: str
    description: str
    description_mr: str
    lead_time: str
    contact_phone: str


class AgronomicGuide(BaseModel):
    id: str
    stage: str
    stage_mr: str
    title: str
    title_mr: str
    summary: str
    summary_mr: str
    category: str
    dosages: Optional[List[str]] = None
    safety_notes: Optional[str] = None


class AIPhotoTriageRequest(BaseModel):
    symptom_description: str
    crop_stage: str
    variety: Optional[str] = "Co 86032"
    image_base64: Optional[str] = None
    field_id: Optional[str] = None


class AIPhotoTriageResponse(BaseModel):
    detected_condition: str
    condition_marathi: str
    severity: str  # "Low" | "Medium" | "High" | "Critical"
    confidence_score: float
    visual_evidence: List[str]
    differential_possibilities: List[str]
    immediate_next_steps: List[str]
    expert_consultation: str


class WeatherQuotaStatus(BaseModel):
    day_key: str
    daily_hard_limit_units: float
    daily_operating_target_units: float
    daily_units_consumed: float
    daily_units_remaining: float
    daily_usage_pct: float
    daily_api_calls_count: int
    monthly_units_consumed: float
    monthly_calls_count: int
    status_tier: str  # "NORMAL" | "WARNING" | "THROTTLED" | "RESERVE_HOLD" | "EXHAUSTED"
    is_throttled: bool
    can_accept_operational: bool
    last_updated: Optional[str] = None
    accounting_method: str


class AgroWeatherFeatures(BaseModel):
    crop_variety: str
    crop_age_days: int
    current_temperature_c: float
    current_relative_humidity_pct: float
    mean_tmax_7d_c: float
    mean_tmin_7d_c: float
    diurnal_temperature_range_7d_c: float
    growing_degree_days_7d: float
    growing_degree_days_total: float
    base_temperature_c: float
    precipitation_recent_7d_mm: float
    precipitation_recent_14d_mm: float
    effective_precipitation_7d_mm: float
    consecutive_dry_days: int
    is_dry_spell_active: bool
    et0_evapotranspiration_7d_mm: float
    et0_evapotranspiration_14d_mm: float
    water_balance_deficit_7d_mm: float
    effective_water_balance_7d_mm: float
    vapour_pressure_deficit_kpa: float
    soil_moisture_surface_0_7cm: float
    soil_moisture_rootzone_7_28cm: float
    soil_temperature_surface_c: float
    soil_water_stress_index: float
    ripening_favorability: str
    target_leakage_safeguard: str

