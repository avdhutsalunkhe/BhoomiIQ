# BhoomiIQ — Lightweight Flutter Frontend

A scientifically grounded, high-performance, lightweight Flutter client for the **BhoomiIQ Satellite Crop Intelligence & Farmer Advisory System**.

---

## 1. Design & Performance Philosophy

- **Lightweight Architecture**: Minimal dependencies (`http`, `qr_flutter`, `intl`).
- **Zero Heavy Native Map SDKs**: Uses Flutter's high-performance built-in `CustomPainter` to render the visual satellite aerial basemap, dashed polygon boundaries, and 10m/20m scientific pixel raster layers at silky smooth 60fps.
- **Offline-Ready Resilience**: Automatically connects to the local FastAPI backend at `http://127.0.0.1:8000/api/v1`. If offline or starting up, seamlessly falls back to pre-calibrated local data with zero crashes or blank screens.
- **Multi-Platform Support**: Built and compiled for **Web**, **Android**, **iOS**, and **Windows Desktop**.

---

## 2. Screen Specifications (Exact Screenshot Match)

| Screen | Core Features |
| :--- | :--- |
| **Home Dashboard** | Banner greeting ("Good morning, कारखाना"), "Your field today" selector, interactive satellite preview with growth overlay, health status chips (Growing well, Check, Inspect first), "A field to inspect" CTA, Quick action grid (My slips, Farm visits, Farm store, Drone services), "Ask annadata" box. |
| **Field Details** | Dual spectral tabs (**Crop growth** [NDVI] vs **Moisture signs** [NDMI]), interactive pixel tap/hover inspector, image date and refresh action, "What do the colours mean?" scientific legend, **Parcel Pixel Resolution alert badge** (pure usable pixels vs boundary exclusion), expandable "Image details & history" with revisit timeline slider, dynamic "YOUR NEXT STEP" differential diagnosis card, and soil test link prompt. |
| **Harvesting Slips** | Issued slips list with registration IDs, planned harvest dates, estimated tonnages; detailed printable slip view featuring official factory crest, legal authorization disclaimer, and **dynamic verified QR code**. |
| **Learn & Services** | Stage-categorized crop guides (Trash mulching, Co 86032, Seed treatment with Bavistin), deduplicated factory subsidy schemes (Drip irrigation 10% subsidy, Subsurface drainage loan), and factory facilities (Drone survey, Soil testing lab). |
| **Ask BhoomiIQ AI** | Interactive symptom triage dialog diagnosing leaf yellowing, borer dead-hearts, and fungal rot with severity ratings and actionable steps. |

---

## 3. How to Run

### Run on Chrome (Web)
```powershell
cd d:\Attend\field_staff_attendance_new\BhoomiIQ\frontend
flutter run -d chrome
```

### Run on Windows Desktop
```powershell
flutter run -d windows
```

### Run on Android
```powershell
flutter run -d <device_id>
```

### Run Tests
```powershell
flutter test
```

### Build Production Web Release
```powershell
flutter build web --release
```
The compiled, tree-shaken static bundle is output to `build/web/`.
