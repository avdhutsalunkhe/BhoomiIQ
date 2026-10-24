import math
from typing import List, Tuple
from app.models.schemas import ResolutionAnalysis, PixelSpectralResult


def compute_ndvi(b8_nir: float, b4_red: float) -> float:
    """
    Normalized Difference Vegetation Index (NDVI)
    NDVI = (NIR - Red) / (NIR + Red)
    """
    denominator = b8_nir + b4_red
    if denominator == 0:
        return 0.0
    return round((b8_nir - b4_red) / denominator, 4)


def compute_ndmi(b8_nir: float, b11_swir: float) -> float:
    """
    Normalized Difference Moisture Index (NDMI)
    NDMI = (NIR - SWIR) / (NIR + SWIR)
    Measures canopy water content and liquid leaf hydration.
    """
    denominator = b8_nir + b11_swir
    if denominator == 0:
        return 0.0
    return round((b8_nir - b11_swir) / denominator, 4)


def compute_ndre(b8_nir: float, b5_red_edge: float) -> float:
    """
    Normalized Difference Red Edge Index (NDRE)
    Useful for dense sugarcane canopies where NDVI saturates.
    """
    denominator = b8_nir + b5_red_edge
    if denominator == 0:
        return 0.0
    return round((b8_nir - b5_red_edge) / denominator, 4)


def compute_msavi2(b8_nir: float, b4_red: float) -> float:
    """
    Modified Soil Adjusted Vegetation Index 2 (MSAVI2)
    Minimizes soil background noise in early sugarcane growth.
    """
    term = (2.0 * b8_nir + 1.0) ** 2 - 8.0 * (b8_nir - b4_red)
    if term < 0:
        term = 0.0
    val = (2.0 * b8_nir + 1.0 - math.sqrt(term)) / 2.0
    return round(val, 4)


def compute_cari(b8_nir: float, b5_re: float, b4_red: float) -> float:
    """
    Chlorophyll Absorption Ratio Index (CARI)
    Direct proxy for leaf nitrogen status.
    """
    denom = b8_nir + b4_red
    if denom == 0:
        return 0.0
    return round((b5_re - b4_red) / denom, 4)


def compute_cwsi(ndmi: float) -> float:
    """
    Crop Water Stress Index (CWSI: 0.0 = Hydrated, 1.0 = Extreme Wilting)
    """
    if ndmi >= 0.15:
        return 0.05
    elif ndmi <= -0.15:
        return 0.85
    else:
        return round(0.45 - (ndmi * 2.0), 3)


def is_scl_valid_vegetation(scl_class: int) -> bool:
    """
    Sentinel-2 Scene Classification Layer (SCL) validation:
    SCL 4: Vegetation (High confidence)
    SCL 5: Bare soils / sparse vegetation
    SCL 6: Water
    SCL 7: Unclassified
    Invalid classes to mask out:
    SCL 3: Cloud shadow
    SCL 8: Cloud medium probability
    SCL 9: Cloud high probability
    SCL 10: Thin cirrus
    """
    return scl_class in [4, 5, 6, 7]


def analyze_parcel_resolution(area_acres: float, pure_pixels: int) -> ResolutionAnalysis:
    """
    Calculates spatial resolution constraints for small agricultural parcels.
    1 acre = 4,046.86 sq.m.
    10m x 10m Sentinel-2 pixel = 100 sq.m.
    20m x 20m Sentinel-2 SWIR pixel = 400 sq.m.
    """
    area_sq_meters = round(area_acres * 4046.86, 2)
    theoretical_10m = int(area_sq_meters // 100)
    theoretical_20m = int(area_sq_meters // 400)
    
    boundary_excluded = max(0, theoretical_10m - pure_pixels)
    ratio = round(pure_pixels / max(1, theoretical_10m), 2)
    
    if ratio >= 0.70 and pure_pixels >= 30:
        rating = "Optimal"
        drone_rec = False
        notice = "Sufficient pure pixels available for reliable intra-field zone delineation."
    elif ratio >= 0.40 and pure_pixels >= 12:
        rating = "Acceptable"
        drone_rec = area_acres < 1.0
        notice = f"Moderate pixel count ({pure_pixels} pure pixels). Boundary buffer applied to avoid road/tree spectral bleeding."
    else:
        rating = "Constrained"
        drone_rec = True
        notice = f"Parcel area ({area_acres} acres) yields only {pure_pixels} pure pixels. Within-field variability is indicative; recommend multispectral drone survey for fine diagnosis."

    return ResolutionAnalysis(
        area_acres=area_acres,
        area_sq_meters=area_sq_meters,
        theoretical_10m_pixels=theoretical_10m,
        theoretical_20m_pixels=theoretical_20m,
        usable_pure_pixels=pure_pixels,
        boundary_excluded_pixels=boundary_excluded,
        usability_ratio=ratio,
        resolution_rating=rating,
        drone_survey_recommended=drone_rec,
        limitation_notice=notice
    )


def classify_ndvi(val: float) -> str:
    if val >= 0.70:
        return "Dense Canopy (Healthy)"
    elif val >= 0.50:
        return "Moderate Growth"
    elif val >= 0.35:
        return "Mild Growth / Transition"
    elif val >= 0.20:
        return "Stressed / Sparse Vegetation"
    else:
        return "Severe Deficit / Bare Ground"


def generate_field_pixel_grid(field_id: str, area_acres: float, date_offset_idx: int = 0) -> List[PixelSpectralResult]:
    """
    Generates scientific, field-specific pixel grids for registered field plots
    matching the parcel area, crop growth stage, and localized canopy health profiles.
    """
    results: List[PixelSpectralResult] = []
    
    # Extract plot number (e.g. "plot-15" -> 15)
    try:
        plot_num = int(field_id.replace("plot-", ""))
    except Exception:
        plot_num = 1
        
    # Determine realistic grid dimensions matching parcel acreage (10m Sentinel-2 resolution)
    if area_acres <= 0.20:
        rows, cols = 3, 3
    elif area_acres <= 0.35:
        rows, cols = 4, 3
    elif area_acres <= 0.50:
        rows, cols = 5, 3
    elif area_acres <= 0.70:
        rows, cols = 5, 4
    elif area_acres <= 0.90:
        rows, cols = 6, 4
    else:
        rows, cols = 6, 5
        
    # Archetype of plot condition derived from plot characteristics:
    # Mode 0: Dense, healthy sugarcane (high vigor, uniform green)
    # Mode 1: Moisture Deficit / Drought stress patch (in a specific quadrant)
    # Mode 2: Ripening / Senescence phase (lower water content, uniform golden/green)
    # Mode 3: Nitrogen chlorosis (central furrows deficient)
    # Mode 4: Early shoot borer / localized pest pressure
    archetype = plot_num % 5
    if field_id == "plot-30":
        archetype = 1  # Historical drought stress
        
    # Stress focus coordinates for intra-field variation
    stress_r = (plot_num * 2) % rows
    stress_c = (plot_num * 3) % cols
    
    # Base spectral properties based on archetype
    if archetype == 0:
        base_ndvi = 0.78 - (date_offset_idx * 0.01)
        base_ndmi = 0.29
        base_ndre = 0.46
    elif archetype == 1:
        base_ndvi = 0.58 - (date_offset_idx * 0.02)
        base_ndmi = 0.12 - (date_offset_idx * 0.03)
        base_ndre = 0.36
    elif archetype == 2:
        base_ndvi = 0.65 - (date_offset_idx * 0.015)
        base_ndmi = 0.14
        base_ndre = 0.38
    elif archetype == 3:
        base_ndvi = 0.54 - (date_offset_idx * 0.01)
        base_ndmi = 0.22
        base_ndre = 0.24  # Low Red Edge
    else:
        base_ndvi = 0.62 - (date_offset_idx * 0.02)
        base_ndmi = 0.19
        base_ndre = 0.35

    for r in range(rows):
        for c in range(cols):
            is_b = (r == 0 or r == rows - 1 or c == 0 or c == cols - 1)
            
            # Distance from stress epicenter (0.0 to 1.0)
            dist = math.sqrt((r - stress_r) ** 2 + (c - stress_c) ** 2) / max(1.0, math.sqrt(rows ** 2 + cols ** 2))
            
            # Sub-plot variation
            if archetype == 1:
                # Water stress: pixels near epicenter suffer drop in NDMI and NDVI
                stress_factor = max(0.0, 1.0 - (dist * 2.2))
                local_ndvi = max(0.26, base_ndvi - (stress_factor * 0.30))
                local_ndmi = max(-0.18, base_ndmi - (stress_factor * 0.32))
                local_ndre = max(0.18, base_ndre - (stress_factor * 0.20))
            elif archetype == 3:
                # Nitrogen chlorosis along furrows
                stress_factor = 1.0 if c == (cols // 2) else 0.2
                local_ndvi = max(0.30, base_ndvi - (stress_factor * 0.16))
                local_ndmi = base_ndmi + ((r % 2) * 0.03)
                local_ndre = max(0.14, base_ndre - (stress_factor * 0.18))
            elif archetype == 4:
                # Spotty pest patch
                is_patch = (r == stress_r and c == stress_c) or (abs(r - stress_r) <= 1 and c == stress_c)
                stress_factor = 0.85 if is_patch else 0.0
                local_ndvi = max(0.28, base_ndvi - (stress_factor * 0.28))
                local_ndmi = base_ndmi - (stress_factor * 0.12)
                local_ndre = max(0.18, base_ndre - (stress_factor * 0.17))
            else:
                # Gentle natural gradient across the cane canopy
                wave = math.sin((r * 0.8) + (c * 0.5) + plot_num) * 0.05
                local_ndvi = min(0.88, max(0.40, base_ndvi + wave))
                local_ndmi = min(0.40, max(0.05, base_ndmi + (wave * 0.6)))
                local_ndre = min(0.55, max(0.25, base_ndre + (wave * 0.8)))

            # Synthesize realistic surface reflectance (B4, B8, B11, B5)
            b8_nir = round(0.35 + (local_ndvi * 0.25), 4)
            b4_red = round(b8_nir * (1.0 - local_ndvi) / max(0.01, 1.0 + local_ndvi), 4)
            b11_swir = round(b8_nir * (1.0 - local_ndmi) / max(0.01, 1.0 + local_ndmi), 4)
            b5_re = round(b8_nir * (1.0 - local_ndre) / max(0.01, 1.0 + local_ndre), 4)
            
            ndvi_val = compute_ndvi(b8_nir, b4_red)
            ndmi_val = compute_ndmi(b8_nir, b11_swir)
            ndre_val = compute_ndre(b8_nir, b5_re)
            msavi2_val = compute_msavi2(b8_nir, b4_red)
            cari_val = compute_cari(b8_nir, b5_re, b4_red)
            cwsi_val = compute_cwsi(ndmi_val)

            results.append(PixelSpectralResult(
                id=f"{field_id}-r{r}-c{c}",
                col=c,
                row=r,
                ndvi=ndvi_val,
                ndmi=ndmi_val,
                ndre=ndre_val,
                msavi2=msavi2_val,
                cari=cari_val,
                cwsi=cwsi_val,
                is_valid_vegetation=True,
                is_boundary=is_b,
                classification=classify_ndvi(ndvi_val)
            ))
            
    return results
