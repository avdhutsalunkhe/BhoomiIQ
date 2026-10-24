"""
BhoomiIQ - Agricultural Weather Feature Engineering Layer
Transforms validated Open-Meteo time-series into model-ready agronomic features
for sugarcane yield prediction, sucrose maturity forecasting, and FAO-56 irrigation.
Strictly avoids target leakage by using only preceding and current operational windows.
"""

import math
from typing import Dict, Any, List, Optional
import pandas as pd
import numpy as np


class AgroWeatherFeatureService:
    """
    Transforms raw Open-Meteo meteorological time-series into scientifically validated
    sugarcane (Saccharum officinarum) agronomic features.
    """

    BASE_TEMPERATURE_SUGARCANE_C = 10.0  # Base temperature for sugarcane vegetative growth
    OPTIMAL_MAX_TEMPERATURE_C = 35.0     # Upper temperature threshold above which growth plateaus

    @classmethod
    def calculate_gdd(
        cls,
        t_max: float,
        t_min: float,
        t_base: float = BASE_TEMPERATURE_SUGARCANE_C,
        t_cap: float = OPTIMAL_MAX_TEMPERATURE_C
    ) -> float:
        """
        Calculates Growing Degree Days (GDD) for a single day using standard agronomic formula:
        GDD = max(0.0, ((min(t_max, t_cap) + t_min) / 2.0) - t_base)
        """
        capped_max = min(t_max, t_cap)
        t_mean = (capped_max + t_min) / 2.0
        return max(0.0, round(t_mean - t_base, 2))

    @classmethod
    def calculate_fao_effective_rainfall(cls, precipitation_mm: float) -> float:
        """
        Calculates effective rainfall (P_eff) using the USDA Soil Conservation Service / FAO method.
        Not all rainfall infiltrates the sugarcane root zone; run-off and deep percolation are subtracted.
        Formula:
          If P <= 8.3 mm/day: P_eff = P * 0.95 (light rain largely absorbed)
          If P <= 25.0 mm/day: P_eff = P * 0.80
          If P > 25.0 mm/day: P_eff = 20.0 + (P - 25.0) * 0.40 (heavy storm runoff)
        """
        if precipitation_mm <= 0.0:
            return 0.0
        elif precipitation_mm <= 8.3:
            return round(precipitation_mm * 0.95, 2)
        elif precipitation_mm <= 25.0:
            return round(precipitation_mm * 0.80, 2)
        else:
            return round(20.0 + (precipitation_mm - 25.0) * 0.40, 2)

    @classmethod
    def compute_vpd_from_rh(cls, temp_c: float, rh_pct: float) -> float:
        """
        Computes Vapour Pressure Deficit (VPD in kPa) from temperature and relative humidity
        using Tetens saturation vapour pressure formula:
          e_sat = 0.61078 * exp((17.27 * T) / (T + 237.3))
          e_actual = e_sat * (RH / 100.0)
          VPD = e_sat - e_actual
        """
        e_sat = 0.61078 * math.exp((17.27 * temp_c) / (temp_c + 237.3))
        e_act = e_sat * (max(0.0, min(100.0, rh_pct)) / 100.0)
        return round(max(0.0, e_sat - e_act), 3)

    @classmethod
    def engineer_features_from_dataframe(
        cls,
        daily_df: pd.DataFrame,
        hourly_df: Optional[pd.DataFrame] = None,
        crop_age_days: int = 180,
        variety: str = "Co 86032"
    ) -> Dict[str, Any]:
        """
        Computes the complete suite of agricultural features from validated daily and hourly frames.
        """
        # Ensure daily dataframe has expected columns with fallbacks
        df = daily_df.copy()
        if "date" in df.columns:
            df = df.sort_values("date")

        # Extract daily precipitation, ET0, and temperatures
        precips = df.get("precipitation_sum", pd.Series([0.0] * len(df))).fillna(0.0).tolist()
        et0s = df.get("et0_fao_evapotranspiration", pd.Series([4.5] * len(df))).fillna(4.5).tolist()
        t_maxs = df.get("temperature_2m_max", pd.Series([32.0] * len(df))).fillna(32.0).tolist()
        t_mins = df.get("temperature_2m_min", pd.Series([20.0] * len(df))).fillna(20.0).tolist()

        n_days = len(precips)

        # 1. Rolling rainfall windows
        rain_7d = round(float(sum(precips[-7:])), 2) if n_days >= 7 else round(float(sum(precips)), 2)
        rain_14d = round(float(sum(precips[-14:])), 2) if n_days >= 14 else round(float(sum(precips)), 2)
        rain_total = round(float(sum(precips)), 2)

        # 2. Effective rainfall
        effective_rains = [cls.calculate_fao_effective_rainfall(p) for p in precips]
        eff_rain_7d = round(float(sum(effective_rains[-7:])), 2) if n_days >= 7 else round(float(sum(effective_rains)), 2)

        # 3. Consecutive dry days (daily precipitation < 2.5 mm threshold)
        consecutive_dry_days = 0
        for p in reversed(precips):
            if p < 2.5:
                consecutive_dry_days += 1
            else:
                break

        # 4. Thermal accumulation & GDD
        daily_gdds = [cls.calculate_gdd(t_maxs[i], t_mins[i]) for i in range(len(t_maxs))]
        cum_gdd_7d = round(float(sum(daily_gdds[-7:])), 1) if len(daily_gdds) >= 7 else round(float(sum(daily_gdds)), 1)
        cum_gdd_total = round(float(sum(daily_gdds)), 1)
        mean_tmax_7d = round(float(np.mean(t_maxs[-7:])), 1) if t_maxs else 32.0
        mean_tmin_7d = round(float(np.mean(t_mins[-7:])), 1) if t_mins else 20.0
        diurnal_range_7d = round(mean_tmax_7d - mean_tmin_7d, 1)

        # 5. Evapotranspiration & Water balance
        et0_7d = round(float(sum(et0s[-7:])), 2) if n_days >= 7 else round(float(sum(et0s)), 2)
        et0_14d = round(float(sum(et0s[-14:])), 2) if n_days >= 14 else round(float(sum(et0s)), 2)
        water_balance_7d = round(rain_7d - et0_7d, 2)
        effective_water_balance_7d = round(eff_rain_7d - et0_7d, 2)

        # 6. Hourly aggregates: VPD & Soil moisture
        mean_vpd = 1.25  # default moderate kPa
        soil_m_0_7 = 0.28  # default m3/m3
        soil_m_7_28 = 0.32
        soil_t_0_7 = 26.5
        relative_humidity_current = 65.0
        temp_current = 31.0

        if hourly_df is not None and not hourly_df.empty:
            if "vapour_pressure_deficit" in hourly_df.columns:
                vpds = hourly_df["vapour_pressure_deficit"].dropna()
                if not vpds.empty:
                    mean_vpd = round(float(vpds.mean()), 3)
            elif "temperature_2m" in hourly_df.columns and "relative_humidity_2m" in hourly_df.columns:
                calc_vpds = [
                    cls.compute_vpd_from_rh(r["temperature_2m"], r["relative_humidity_2m"])
                    for _, r in hourly_df.iterrows()
                    if pd.notna(r.get("temperature_2m")) and pd.notna(r.get("relative_humidity_2m"))
                ]
                if calc_vpds:
                    mean_vpd = round(float(np.mean(calc_vpds)), 3)

            if "soil_moisture_0_to_7cm" in hourly_df.columns:
                sm = hourly_df["soil_moisture_0_to_7cm"].dropna()
                if not sm.empty:
                    soil_m_0_7 = round(float(sm.iloc[-1]), 3)

            if "soil_moisture_7_to_28cm" in hourly_df.columns:
                sm2 = hourly_df["soil_moisture_7_to_28cm"].dropna()
                if not sm2.empty:
                    soil_m_7_28 = round(float(sm2.iloc[-1]), 3)

            if "soil_temperature_0_to_7cm" in hourly_df.columns:
                st = hourly_df["soil_temperature_0_to_7cm"].dropna()
                if not st.empty:
                    soil_t_0_7 = round(float(st.iloc[-1]), 1)

            if "temperature_2m" in hourly_df.columns:
                temps = hourly_df["temperature_2m"].dropna()
                if not temps.empty:
                    temp_current = round(float(temps.iloc[-1]), 1)

            if "relative_humidity_2m" in hourly_df.columns:
                rhs = hourly_df["relative_humidity_2m"].dropna()
                if not rhs.empty:
                    relative_humidity_current = round(float(rhs.iloc[-1]), 1)

        # 7. Soil Water Stress Index (0.0 = Severe Wilting, 1.0 = Field Capacity / Optimum)
        # Vertisols (Black cotton soil in Sangli/Kolhapur):
        # Field capacity ~ 0.38 m3/m3, Permanent wilting point ~ 0.18 m3/m3
        raw_swsi = (soil_m_0_7 - 0.18) / (0.38 - 0.18)
        soil_water_stress_index = round(max(0.0, min(1.0, raw_swsi)), 2)

        # 8. Sugarcane Maturity Ripening Index
        # Ripening is promoted by:
        # - High diurnal temperature range (>12°C)
        # - Mild moisture deficit (consecutive dry days > 10)
        # - Crop age > 300 days
        ripening_favorability = "Low (Grand Growth)"
        if crop_age_days >= 300:
            if diurnal_range_7d >= 12.0 and consecutive_dry_days >= 7:
                ripening_favorability = "Optimal (High Brix Accumulation)"
            elif diurnal_range_7d >= 10.0:
                ripening_favorability = "Moderate Ripening"
            else:
                ripening_favorability = "Slow Ripening (Excess Humidity / Warm Nights)"

        return {
            "crop_variety": variety,
            "crop_age_days": crop_age_days,
            "current_temperature_c": temp_current,
            "current_relative_humidity_pct": relative_humidity_current,
            "mean_tmax_7d_c": mean_tmax_7d,
            "mean_tmin_7d_c": mean_tmin_7d,
            "diurnal_temperature_range_7d_c": diurnal_range_7d,
            "growing_degree_days_7d": cum_gdd_7d,
            "growing_degree_days_total": cum_gdd_total,
            "base_temperature_c": cls.BASE_TEMPERATURE_SUGARCANE_C,
            "precipitation_recent_7d_mm": rain_7d,
            "precipitation_recent_14d_mm": rain_14d,
            "effective_precipitation_7d_mm": eff_rain_7d,
            "consecutive_dry_days": consecutive_dry_days,
            "is_dry_spell_active": consecutive_dry_days >= 7,
            "et0_evapotranspiration_7d_mm": et0_7d,
            "et0_evapotranspiration_14d_mm": et0_14d,
            "water_balance_deficit_7d_mm": water_balance_7d,
            "effective_water_balance_7d_mm": effective_water_balance_7d,
            "vapour_pressure_deficit_kpa": mean_vpd,
            "soil_moisture_surface_0_7cm": soil_m_0_7,
            "soil_moisture_rootzone_7_28cm": soil_m_7_28,
            "soil_temperature_surface_c": soil_t_0_7,
            "soil_water_stress_index": soil_water_stress_index,
            "ripening_favorability": ripening_favorability,
            "target_leakage_safeguard": "Strictly preceding and current window evaluated"
        }
