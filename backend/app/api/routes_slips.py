from fastapi import APIRouter, HTTPException
from typing import List
from datetime import datetime, timezone
from app.models.schemas import HarvestingSlip, QRVerificationRequest, QRVerificationResponse
from app.services.qr_service import build_qr_payload, verify_qr_token
from app.config import settings

router = APIRouter(prefix="/slips", tags=["Harvesting Slips & Quotas"])

# Registered factory sugarcane harvesting slips
SLIPS_DATABASE: dict[str, HarvestingSlip] = {
    "SC-00000002": HarvestingSlip(
        slip_id="SC-00000002",
        reg_id="CR-00000002",
        season="2026–27",
        farmer_name="Karkhana Bene Mala (Nursery)",
        farmer_name_mr="कारखाना बेणे मळा (Nursery)",
        plot_name="कारखाना बेणे मळा नं.1 - Plot 2",
        village="राजारामनगर",
        cane_type="Plant cane",
        variety="Co 86032",
        registered_area_acres=0.36,
        planting_date="2 Feb 2026",
        harvesting_date="2 Feb 2027",
        estimated_tonnes=14.0,
        method="Manual",
        status="Slip issued",
        registered_at="15/10/2026, 1:45:51 am",
        issued_at="15/10/2026, 1:47:21 am",
        assigned_officer="Factory admin (D. B. Patil)",
        remarks="Nursery plot with seasonal planning. Estimated tonnage requires field confirmation before cutting.",
        qr_payload=build_qr_payload("SC-00000002", "CR-00000002", "P2", 14.0, "2027-02-02")
    ),
    "SC-00000005": HarvestingSlip(
        slip_id="SC-00000005",
        reg_id="CR-00000005",
        season="2026–27",
        farmer_name="Shri. Babaso Patil",
        farmer_name_mr="श्री. बाबासो पाटील",
        plot_name="कारखाना बेणे मळा नं. 2 - Plot 5",
        village="राजारामनगर",
        cane_type="Ratoon cane (Khodwa)",
        variety="Phule 265",
        registered_area_acres=1.08,
        planting_date="15 Oct 2025",
        harvesting_date="10 Nov 2026",
        estimated_tonnes=52.0,
        method="Harvester",
        status="Approved",
        registered_at="10/10/2026, 11:20:00 am",
        issued_at="12/10/2026, 3:15:30 pm",
        assigned_officer="Field Inspector S. K. More",
        remarks="Pre-harvest brix reading scheduled on 1 Nov. Transport route via Main Factory Bypass.",
        qr_payload=build_qr_payload("SC-00000005", "CR-00000005", "P5", 52.0, "2026-11-10")
    )
}


@router.get("", response_model=List[HarvestingSlip])
async def list_slips():
    """
    Returns list of issued and approved sugarcane harvesting slips for current season.
    """
    return list(SLIPS_DATABASE.values())


@router.get("/{slip_id}", response_model=HarvestingSlip)
async def get_slip(slip_id: str):
    """
    Returns printable harvesting slip details with QR code payload.
    """
    if slip_id not in SLIPS_DATABASE:
        raise HTTPException(status_code=404, detail="Harvesting slip not found")
    return SLIPS_DATABASE[slip_id]


@router.post("/verify-qr", response_model=QRVerificationResponse)
async def verify_slip_qr(request: QRVerificationRequest):
    """
    Verifies cryptographic signature on printed or mobile harvesting slip QR code.
    Enforces security boundary separating harvest authorization from weighbridge receipt.
    """
    is_valid, data = verify_qr_token(request.qr_payload)
    now_str = datetime.now(timezone.utc).isoformat()
    
    if not is_valid or not data:
        return QRVerificationResponse(
            valid=False,
            issuer=settings.FACTORY_NAME,
            verified_at=now_str,
            legal_notice="Invalid or tampered QR code. Slip authorization cannot be confirmed."
        )

    return QRVerificationResponse(
        valid=True,
        slip_id=data.get("slip_id"),
        reg_id=data.get("reg_id"),
        farmer_name=SLIPS_DATABASE.get(data.get("slip_id"), HarvestingSlip.__new__(HarvestingSlip)).farmer_name if data.get("slip_id") in SLIPS_DATABASE else "Authorized Member",
        plot_name=data.get("plot_name"),
        estimated_tonnes=data.get("estimated_tonnes"),
        harvesting_date=data.get("harvesting_date"),
        status=data.get("status"),
        issuer=data.get("issuer"),
        verified_at=now_str,
        legal_notice=(
            "DISCLAIMER: This document serves solely as harvesting authorization. "
            "Estimated tonnage does not constitute delivered or accepted cane weight. "
            "Final payment will be calculated strictly based on electronic weighbridge gross and tare receipts at factory intake."
        )
    )
