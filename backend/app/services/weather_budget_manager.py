"""
BhoomiIQ - Weather API Budget & Daily Quota Controller
Enforces internal hard budget of 9,000 estimated billable Open-Meteo call units/day.
Provides atomic SQLite-backed usage tracking, multi-worker safety, and rate-limiting.
"""

import os
import sqlite3
import logging
from datetime import datetime, timezone, date
from typing import Dict, Any, Tuple, Optional
from pathlib import Path
import threading

logger = logging.getLogger(__name__)

# Daily Quota Thresholds
DAILY_HARD_LIMIT = 9000.0          # Absolute maximum allowed per UTC/IST day
NORMAL_OPERATING_TARGET = 8500.0   # Suspends discretionary requests; preserves reserve
THROTTLE_THRESHOLD_90 = 8100.0     # 90%: Halts nonessential refreshes & historical backfills
WARN_THRESHOLD_80 = 7200.0         # 80%: Emits operational warning alerts

# Rate limits
MAX_CALLS_PER_MINUTE = 60
MAX_CALLS_PER_HOUR = 600

DB_DIR = Path(__file__).resolve().parent.parent.parent / "data"
DB_PATH = DB_DIR / "weather_quota.db"


class WeatherBudgetException(Exception):
    """Raised when an Open-Meteo request violates the daily or hourly budget."""
    pass


class WeatherBudgetExhaustedError(WeatherBudgetException):
    """Raised when the 9,000 daily hard cap is reached."""
    pass


class WeatherBudgetThrottledError(WeatherBudgetException):
    """Raised when non-essential backfills or batch refreshes are throttled (>90% / 8,100 units)."""
    pass


class WeatherQuotaManager:
    """
    Centrally enforced, SQLite-backed atomic API-usage controller.
    Ensures BhoomiIQ never exceeds the 9,000 daily billable unit cap
    across multiple Uvicorn workers, scheduled background jobs, and retries.
    """
    _instance: Optional["WeatherQuotaManager"] = None
    _lock = threading.Lock()

    def __new__(cls, db_path: Optional[Path] = None):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super(WeatherQuotaManager, cls).__new__(cls)
                cls._instance._init_db(db_path or DB_PATH)
            return cls._instance

    def _init_db(self, path: Path):
        self.db_path = path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._mutex = threading.Lock()
        
        with sqlite3.connect(str(self.db_path), timeout=20.0) as conn:
            conn.execute("PRAGMA journal_mode = WAL;")
            conn.execute("PRAGMA busy_timeout = 20000;")
            conn.execute("""
                CREATE TABLE IF NOT EXISTS weather_api_calls (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    timestamp TEXT NOT NULL,
                    endpoint TEXT NOT NULL,
                    location_count INTEGER NOT NULL,
                    variables TEXT NOT NULL,
                    date_range TEXT,
                    estimated_units REAL NOT NULL,
                    http_status INTEGER,
                    retry_count INTEGER DEFAULT 0,
                    is_essential INTEGER DEFAULT 1,
                    daily_cumulative REAL NOT NULL,
                    monthly_cumulative REAL NOT NULL,
                    status_note TEXT
                );
            """)
            conn.execute("""
                CREATE TABLE IF NOT EXISTS daily_quota_summary (
                    day_key TEXT PRIMARY KEY,
                    cumulative_units REAL NOT NULL DEFAULT 0.0,
                    call_count INTEGER NOT NULL DEFAULT 0,
                    last_updated TEXT NOT NULL
                );
            """)
            conn.execute("""
                CREATE TABLE IF NOT EXISTS monthly_quota_summary (
                    month_key TEXT PRIMARY KEY,
                    cumulative_units REAL NOT NULL DEFAULT 0.0,
                    call_count INTEGER NOT NULL DEFAULT 0,
                    last_updated TEXT NOT NULL
                );
            """)
            conn.commit()

    @staticmethod
    def get_day_key(dt: Optional[datetime] = None) -> str:
        # Open-Meteo resets daily limits based on UTC day
        t = dt or datetime.now(timezone.utc)
        return t.strftime("%Y-%m-%d")

    @staticmethod
    def get_month_key(dt: Optional[datetime] = None) -> str:
        t = dt or datetime.now(timezone.utc)
        return t.strftime("%Y-%m")

    def estimate_cost(
        self,
        endpoint: str,
        location_count: int = 1,
        days: int = 7,
        variable_count: int = 8,
        models_count: int = 1
    ) -> float:
        """
        Estimates Open-Meteo billable API-call units according to provider rules:
          - Forecast endpoint (<= 16 days): 1 billable unit per location & model.
          - Multi-location queries: location_count * units.
          - Historical archive: if days <= 365, 1.0 unit per location;
            if days > 365, ceil(days / 365.0) units per location.
          - Multiple numerical models: multiplier = models_count.
        """
        locs = max(1, location_count)
        mods = max(1, models_count)
        
        is_archive = "archive" in endpoint.lower()
        if is_archive:
            time_factor = max(1.0, float(days) / 365.0)
        else:
            time_factor = 1.0  # Standard forecast up to 16 days is 1 call per loc
            
        units = locs * mods * time_factor
        return round(units, 2)

    def check_budget_availability(
        self,
        estimated_units: float,
        is_essential: bool = True
    ) -> Tuple[bool, str, Dict[str, Any]]:
        """
        Atomically inspects whether the proposed request can proceed
        under current daily and monthly limits.
        """
        day_key = self.get_day_key()
        month_key = self.get_month_key()

        with self._mutex:
            with sqlite3.connect(str(self.db_path), timeout=20.0) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "SELECT cumulative_units, call_count FROM daily_quota_summary WHERE day_key = ?",
                    (day_key,)
                )
                row = cursor.fetchone()
                current_daily = row[0] if row else 0.0
                daily_calls = row[1] if row else 0

                cursor.execute(
                    "SELECT cumulative_units FROM monthly_quota_summary WHERE month_key = ?",
                    (month_key,)
                )
                m_row = cursor.fetchone()
                current_monthly = m_row[0] if m_row else 0.0

        projected_daily = current_daily + estimated_units
        status_info = {
            "day_key": day_key,
            "current_daily_units": round(current_daily, 2),
            "projected_daily_units": round(projected_daily, 2),
            "daily_hard_limit": DAILY_HARD_LIMIT,
            "daily_operating_target": NORMAL_OPERATING_TARGET,
            "current_monthly_units": round(current_monthly, 2),
            "daily_calls": daily_calls,
            "budget_usage_pct": round((current_daily / DAILY_HARD_LIMIT) * 100.0, 1),
            "tier": "NORMAL"
        }

        # 1. Hard Limit Check (9,000 units)
        if projected_daily > DAILY_HARD_LIMIT:
            status_info["tier"] = "EXHAUSTED"
            msg = (
                f"Open-Meteo Daily Budget Hard Cap Reached: {current_daily:.1f} / {DAILY_HARD_LIMIT:.0f} units used. "
                f"Proposed request ({estimated_units:.1f} units) rejected to prevent quota breach."
            )
            return False, msg, status_info

        # 2. Operating Target Check (8,500 units)
        if projected_daily > NORMAL_OPERATING_TARGET and not is_essential:
            status_info["tier"] = "RESERVE_HOLD"
            msg = (
                f"Open-Meteo Normal Operating Target ({NORMAL_OPERATING_TARGET:.0f}) reached: {current_daily:.1f} units. "
                "Discretionary request paused to preserve emergency reserve for live operational plots."
            )
            return False, msg, status_info

        # 3. 90% Throttle Check (8,100 units)
        if current_daily >= THROTTLE_THRESHOLD_90 and not is_essential:
            status_info["tier"] = "THROTTLED"
            msg = (
                f"Open-Meteo 90% Throttle Active: {current_daily:.1f} units used. "
                "Non-essential backfills, historical crawls, and batch jobs suspended."
            )
            return False, msg, status_info

        # 4. 80% Warning Check (7,200 units)
        if current_daily >= WARN_THRESHOLD_80:
            status_info["tier"] = "WARNING"
            logger.warning(
                f"[QUOTA WARNING] Open-Meteo daily consumption at {status_info['budget_usage_pct']}% "
                f"({current_daily:.1f} / {DAILY_HARD_LIMIT:.0f} units)."
            )

        return True, "Approved", status_info

    def record_usage(
        self,
        endpoint: str,
        location_count: int,
        variables: str,
        date_range: str,
        estimated_units: float,
        http_status: int = 200,
        retry_count: int = 0,
        is_essential: bool = True,
        status_note: str = "SUCCESS"
    ) -> float:
        """
        Atomically records an executed API call and increments daily & monthly usage.
        """
        day_key = self.get_day_key()
        month_key = self.get_month_key()
        now_iso = datetime.now(timezone.utc).isoformat()

        with self._mutex:
            with sqlite3.connect(str(self.db_path), timeout=20.0) as conn:
                conn.isolation_level = "IMMEDIATE"
                cursor = conn.cursor()

                # Update daily summary
                cursor.execute(
                    """
                    INSERT INTO daily_quota_summary (day_key, cumulative_units, call_count, last_updated)
                    VALUES (?, ?, 1, ?)
                    ON CONFLICT(day_key) DO UPDATE SET
                        cumulative_units = cumulative_units + excluded.cumulative_units,
                        call_count = call_count + 1,
                        last_updated = excluded.last_updated
                    RETURNING cumulative_units;
                    """,
                    (day_key, estimated_units, now_iso)
                )
                daily_cum = cursor.fetchone()[0]

                # Update monthly summary
                cursor.execute(
                    """
                    INSERT INTO monthly_quota_summary (month_key, cumulative_units, call_count, last_updated)
                    VALUES (?, ?, 1, ?)
                    ON CONFLICT(month_key) DO UPDATE SET
                        cumulative_units = cumulative_units + excluded.cumulative_units,
                        call_count = call_count + 1,
                        last_updated = excluded.last_updated
                    RETURNING cumulative_units;
                    """,
                    (month_key, estimated_units, now_iso)
                )
                monthly_cum = cursor.fetchone()[0]

                # Insert detailed audit record
                cursor.execute(
                    """
                    INSERT INTO weather_api_calls (
                        timestamp, endpoint, location_count, variables, date_range,
                        estimated_units, http_status, retry_count, is_essential,
                        daily_cumulative, monthly_cumulative, status_note
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                    """,
                    (
                        now_iso, endpoint, location_count, variables, date_range,
                        estimated_units, http_status, retry_count, 1 if is_essential else 0,
                        daily_cum, monthly_cum, status_note
                    )
                )
                conn.commit()

        return daily_cum

    def get_quota_status(self) -> Dict[str, Any]:
        """
        Returns full monitoring diagnostics for dashboard HUD and system health.
        """
        day_key = self.get_day_key()
        month_key = self.get_month_key()

        with self._mutex:
            with sqlite3.connect(str(self.db_path), timeout=20.0) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "SELECT cumulative_units, call_count, last_updated FROM daily_quota_summary WHERE day_key = ?",
                    (day_key,)
                )
                row = cursor.fetchone()
                daily_units = row[0] if row else 0.0
                daily_calls = row[1] if row else 0
                last_updated = row[2] if row else None

                cursor.execute(
                    "SELECT cumulative_units, call_count FROM monthly_quota_summary WHERE month_key = ?",
                    (month_key,)
                )
                m_row = cursor.fetchone()
                monthly_units = m_row[0] if m_row else 0.0
                monthly_calls = m_row[1] if m_row else 0

        pct_used = round((daily_units / DAILY_HARD_LIMIT) * 100.0, 2)
        remaining = max(0.0, round(DAILY_HARD_LIMIT - daily_units, 2))

        tier = "NORMAL"
        if daily_units >= DAILY_HARD_LIMIT:
            tier = "EXHAUSTED"
        elif daily_units >= NORMAL_OPERATING_TARGET:
            tier = "RESERVE_HOLD"
        elif daily_units >= THROTTLE_THRESHOLD_90:
            tier = "THROTTLED"
        elif daily_units >= WARN_THRESHOLD_80:
            tier = "WARNING"

        return {
            "day_key": day_key,
            "daily_hard_limit_units": DAILY_HARD_LIMIT,
            "daily_operating_target_units": NORMAL_OPERATING_TARGET,
            "daily_units_consumed": round(daily_units, 2),
            "daily_units_remaining": remaining,
            "daily_usage_pct": pct_used,
            "daily_api_calls_count": daily_calls,
            "monthly_units_consumed": round(monthly_units, 2),
            "monthly_calls_count": monthly_calls,
            "status_tier": tier,
            "is_throttled": tier in ("THROTTLED", "RESERVE_HOLD", "EXHAUSTED"),
            "can_accept_operational": daily_units < DAILY_HARD_LIMIT,
            "last_updated": last_updated,
            "accounting_method": "Multi-Factor Location/Model/Timespan Quota Estimator"
        }

    def reset_for_testing(self):
        """Helper to reset quota tables during test runs."""
        with self._mutex:
            with sqlite3.connect(str(self.db_path), timeout=20.0) as conn:
                conn.execute("DELETE FROM weather_api_calls;")
                conn.execute("DELETE FROM daily_quota_summary;")
                conn.execute("DELETE FROM monthly_quota_summary;")
                conn.commit()


# Singleton accessor
quota_manager = WeatherQuotaManager()
