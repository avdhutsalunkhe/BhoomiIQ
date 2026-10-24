"""
BhoomiIQ Backend Integration Test Suite
Validates all API endpoints, scientific index calculations, resolution analysis,
environment variable loading, and secure harvesting QR verification.
"""

import sys
from fastapi.testclient import TestClient
from app.config import settings
from app.main import app

client = TestClient(app)


def test_env_configuration():
    print("\n--- 1. Testing Environment Configuration ---")
    assert settings.APP_ENV == "development", f"Expected development, got {settings.APP_ENV}"
    assert settings.PORT == 8000, f"Expected 8000, got {settings.PORT}"
    assert "copernicus.eu" in settings.COPERNICUS_STAC_URL
    assert "open-meteo.com" in settings.OPEN_METEO_FORECAST_URL
    assert settings.FACTORY_CODE == "RBPSSK"
    print(" [PASS] .env variables loaded strictly and accurately.")


def test_health_check():
    print("\n--- 2. Testing Health Check Endpoint ---")
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["factory_code"] == "RBPSSK"
    print(f" [PASS] Health check verified: {data}")


def test_fields_list():
    print("\n--- 3. Testing Fields List Endpoint ---")
    response = client.get("/api/v1/fields")
    assert response.status_code == 200
    fields = response.json()
    assert len(fields) >= 3
    plot_ids = [f["id"] for f in fields]
    assert "plot-30" in plot_ids
    assert "plot-5" in plot_ids
    print(f" [PASS] Found {len(fields)} registered sugarcane parcels: {plot_ids}")


def test_plot30_analysis():
    print("\n--- 4. Testing Plot 30 (0.59 ac) Full Multispectral Analysis ---")
    response = client.get("/api/v1/fields/plot-30/analysis")
    assert response.status_code == 200
    data = response.json()
    
    field = data["field"]
    res = data["resolution_analysis"]
    meta = data["satellite_metadata"]
    weather = data["weather"]
    advisory = data["advisory"]
    pixels = data["pixels"]

    print(f"  Parcel: {field['name']} ({field['area_acres']} acres)")
    print(f"  Satellite: {meta['satellite_platform']} (Scene: {meta['scene_id'][:25]}...)")
    print(f"  Resolution: {res['usable_pure_pixels']} pure pixels of {res['theoretical_10m_pixels']} theoretical ({res['resolution_rating']})")
    print(f"  Weather Context: Temp {weather['temperature_2m_c']}C, Rain 7d: {weather['rainfall_recent_7d_mm']}mm, ET0: {weather['et0_evapotranspiration_mm']}mm/day")
    print(f"  Advisory Headline: {advisory['headline']}")
    print(f"  Confidence: {advisory['confidence_pct']}% | Affected: {advisory['affected_sector']}")
    
    assert res["area_acres"] == 0.29
    assert res["resolution_rating"] in ["Optimal", "Acceptable", "Constrained"]
    assert len(pixels) >= 8
    assert advisory["status_level"] == "inspect"
    assert "North-West" in advisory["affected_sector"]
    print(" [PASS] Plot 30 analysis satisfies all remote sensing and agronomic requirements.")


def test_plot5_analysis():
    print("\n--- 5. Testing Plot 5 (0.22 ac) Analysis ---")
    response = client.get("/api/v1/fields/plot-5/analysis")
    assert response.status_code == 200
    data = response.json()
    advisory = data["advisory"]
    assert advisory["status_level"] in ["good", "check", "inspect"]
    print(f"  Plot 5 Status: {advisory['status_level'].upper()} - {advisory['headline']}")
    print(" [PASS] Plot 5 maturing cane analysis verified.")


def test_harvesting_slips_and_qr():
    print("\n--- 6. Testing Harvesting Slips & Cryptographic QR Verification ---")
    response = client.get("/api/v1/slips")
    assert response.status_code == 200
    slips = response.json()
    assert len(slips) >= 2
    
    slip = slips[0]
    print(f"  Testing Slip ID: {slip['slip_id']} | Farmer: {slip['farmer_name']} | Exp Tonnes: {slip['estimated_tonnes']}T")
    
    # Test valid QR payload verification
    qr_resp = client.post("/api/v1/slips/verify-qr", json={"qr_payload": slip["qr_payload"]})
    assert qr_resp.status_code == 200
    qr_data = qr_resp.json()
    assert qr_data["valid"] is True
    assert qr_data["slip_id"] == slip["slip_id"]
    assert "DISCLAIMER: This document serves solely as harvesting authorization" in qr_data["legal_notice"]
    print(f"  QR Verification Status: VALID (Authorized by {qr_data['issuer']})")
    
    # Test tampered QR payload
    tampered_resp = client.post("/api/v1/slips/verify-qr", json={"qr_payload": slip["qr_payload"] + "_tampered"})
    assert tampered_resp.status_code == 200
    assert tampered_resp.json()["valid"] is False
    print("  Tampered QR Detection: Rejected successfully as invalid.")
    print(" [PASS] Harvesting slip and QR security verified.")


def test_learn_schemes_facilities():
    print("\n--- 7. Testing Learn Guides, Schemes & Facilities Deduplication ---")
    guides_resp = client.get("/api/v1/learn/guides")
    assert guides_resp.status_code == 200
    guides = guides_resp.json()
    assert len(guides) >= 6

    schemes_resp = client.get("/api/v1/learn/schemes")
    assert schemes_resp.status_code == 200
    schemes = schemes_resp.json()
    scheme_ids = [s["id"] for s in schemes]
    assert len(scheme_ids) == len(set(scheme_ids)), "Duplicate schemes found!"
    print(f"  Schemes (Deduplicated): {[s['title'] for s in schemes]}")

    facilities_resp = client.get("/api/v1/learn/facilities")
    assert facilities_resp.status_code == 200
    facilities = facilities_resp.json()
    facility_ids = [f["id"] for f in facilities]
    assert len(facility_ids) == len(set(facility_ids)), "Duplicate facilities found!"
    print(f"  Facilities (Deduplicated): {[f['title'] for f in facilities]}")
    print(" [PASS] Guides, deduplicated schemes, and facilities verified.")


def test_ai_photo_triage():
    print("\n--- 8. Testing AI Farm Assistant Photo & Symptom Triage ---")
    
    # Yellow whorl symptoms (Iron chlorosis)
    resp1 = client.post("/api/v1/ai/photo-triage", json={
        "symptom_description": "Top whorl leaves are turning pale yellow between veins, Krishna black soil",
        "crop_stage": "Grand Growth",
        "variety": "Co 86032"
    })
    assert resp1.status_code == 200
    data1 = resp1.json()
    assert "Chlorosis" in data1["detected_condition"]
    print(f"  Symptom 1 detected: {data1['detected_condition']} (Confidence: {data1['confidence_score'] * 100}%)")

    # Borer dead heart symptoms
    resp2 = client.post("/api/v1/ai/photo-triage", json={
        "symptom_description": "Central shoot has dried dead heart with bore hole frass near ground",
        "crop_stage": "Tillering",
        "variety": "Co 86032"
    })
    assert resp2.status_code == 200
    data2 = resp2.json()
    assert "Borer" in data2["detected_condition"]
    print(f"  Symptom 2 detected: {data2['detected_condition']} (Confidence: {data2['confidence_score'] * 100}%)")
    print(" [PASS] AI symptom triage verified.")


if __name__ == "__main__":
    print("================================================================")
    print("  RUNNING BHOOMIIQ SATELLITE BACKEND INTEGRATION TESTS")
    print("================================================================")
    try:
        test_env_configuration()
        test_health_check()
        test_fields_list()
        test_plot30_analysis()
        test_plot5_analysis()
        test_harvesting_slips_and_qr()
        test_learn_schemes_facilities()
        test_ai_photo_triage()
        print("\n================================================================")
        print("  ALL 8 BHOOMIIQ BACKEND INTEGRATION TESTS PASSED SUCCESSFULLY! ")
        print("================================================================")
    except AssertionError as e:
        print(f"\n [FAIL] Assertion error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n [ERROR] Unexpected error: {e}")
        sys.exit(1)
