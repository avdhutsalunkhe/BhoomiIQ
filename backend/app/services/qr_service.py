import hmac
import hashlib
import time
from typing import Tuple, Dict, Any, Optional
from app.config import settings


def generate_slip_signature(slip_id: str, reg_id: str, tonnes: float, harvest_date: str) -> str:
    """
    Generates HMAC-SHA256 signature for harvesting authorization slip.
    """
    message = f"{slip_id}:{reg_id}:{tonnes}:{harvest_date}:{settings.FACTORY_CODE}".encode("utf-8")
    secret = settings.SECRET_KEY.encode("utf-8")
    return hmac.new(secret, message, hashlib.sha256).hexdigest()[:16]


def build_qr_payload(slip_id: str, reg_id: str, plot_name: str, tonnes: float, harvest_date: str) -> str:
    sig = generate_slip_signature(slip_id, reg_id, tonnes, harvest_date)
    return f"BHOOMIIQ:SLIP:{slip_id}|REG:{reg_id}|PLOT:{plot_name}|EXP:{tonnes}T|DATE:{harvest_date}|SIG:{sig}"


def verify_qr_token(payload: str) -> Tuple[bool, Optional[Dict[str, Any]]]:
    """
    Validates QR code payload authenticity against factory secret.
    """
    try:
        if not payload.startswith("BHOOMIIQ:SLIP:"):
            return False, None
            
        # Strip BHOOMIIQ: prefix for uniform key-value parsing
        clean_payload = payload.replace("BHOOMIIQ:", "", 1)
        parts = clean_payload.split("|")
        data = {}
        for p in parts:
            if ":" in p:
                k, v = p.split(":", 1)
                data[k.strip()] = v.strip()
                
        slip_id = data.get("SLIP")
        reg_id = data.get("REG")
        exp_tonnes_str = data.get("EXP", "").replace("T", "")
        tonnes = float(exp_tonnes_str) if exp_tonnes_str else 0.0
        harvest_date = data.get("DATE")
        sig = data.get("SIG")
        
        expected_sig = generate_slip_signature(slip_id, reg_id, tonnes, harvest_date)
        if sig and expected_sig and hmac.compare_digest(sig, expected_sig):
            return True, {
                "slip_id": slip_id,
                "reg_id": reg_id,
                "estimated_tonnes": tonnes,
                "harvesting_date": harvest_date,
                "plot_name": data.get("PLOT"),
                "status": "Verified Factory Authorization",
                "issuer": settings.FACTORY_NAME
            }
        return False, None
    except Exception:
        return False, None
