import 'package:flutter/material.dart';

/// Scientific Color Stop for Agronomic Index Interpolation
class AgronomicColorStop {
  final double value;
  final Color color;
  final String label;

  const AgronomicColorStop({
    required this.value,
    required this.color,
    required this.label,
  });
}

/// Metadata and Continuous Color Interpolation Engine for Agricultural Parameters
class AgronomicParameterDefinition {
  final String id;
  final String displayName;
  final String displayNameMr;
  final String unit;
  final double minValid;
  final double maxValid;
  final List<AgronomicColorStop> stops;
  final String lowLabel;
  final String midLabel;
  final String highLabel;
  final String sensorSource;
  final String agronomicDescription;

  const AgronomicParameterDefinition({
    required this.id,
    required this.displayName,
    required this.displayNameMr,
    required this.unit,
    required this.minValid,
    required this.maxValid,
    required this.stops,
    required this.lowLabel,
    required this.midLabel,
    required this.highLabel,
    required this.sensorSource,
    required this.agronomicDescription,
  });

  /// Evaluates a smooth continuous color along the defined scientific ramp with custom opacity
  Color evaluateColor(double rawValue, {double opacity = 0.70}) {
    if (stops.isEmpty) return Colors.transparent;

    final clamped = rawValue.clamp(minValid, maxValid);

    if (clamped <= stops.first.value) {
      return stops.first.color.withValues(alpha: opacity);
    }
    if (clamped >= stops.last.value) {
      return stops.last.color.withValues(alpha: opacity);
    }

    // Locate segment for linear RGB interpolation
    for (int i = 0; i < stops.length - 1; i++) {
      final s0 = stops[i];
      final s1 = stops[i + 1];
      if (clamped >= s0.value && clamped <= s1.value) {
        final span = s1.value - s0.value;
        final t = span > 0 ? (clamped - s0.value) / span : 0.0;
        return Color.lerp(s0.color, s1.color, t)!.withValues(alpha: opacity);
      }
    }

    return stops.last.color.withValues(alpha: opacity);
  }
}

/// Central Registry of Continuous Agronomic Color Scales
class AgronomicColorRampRegistry {
  static final Map<String, AgronomicParameterDefinition> _parameters = {
    // 1. NDVI (Crop Growth & Biomass - Matches Reference Image 1)
    'ndvi': const AgronomicParameterDefinition(
      id: 'ndvi',
      displayName: 'Crop Growth (NDVI)',
      displayNameMr: 'पीक वाढ (NDVI)',
      unit: 'Index (-1..+1)',
      minValid: 0.15,
      maxValid: 0.85,
      lowLabel: 'Inspect first (<0.35)',
      midLabel: 'Check (0.35 - 0.60)',
      highLabel: 'Growing well (>0.60)',
      sensorSource: 'Sentinel-2 MSI (B8 NIR / B4 Red 10m) · PlanetScope (3m)',
      agronomicDescription:
          'Normalized Difference Vegetation Index measuring active photosynthetic canopy density.',
      stops: [
        AgronomicColorStop(value: 0.15, color: Color(0xFFC62828), label: 'Stressed / Thin'),
        AgronomicColorStop(value: 0.35, color: Color(0xFFEF6C00), label: 'Low Vigour'),
        AgronomicColorStop(value: 0.50, color: Color(0xFFFBC02D), label: 'Moderate Canopy'),
        AgronomicColorStop(value: 0.65, color: Color(0xFF689F38), label: 'Vigorous Growth'),
        AgronomicColorStop(value: 0.85, color: Color(0xFF1B5E20), label: 'Dense Canopy'),
      ],
    ),

    // 2. NDMI / Moisture Signs (Matches Reference Image 2: Red/Orange -> Yellow -> Teal/Blue)
    'moisture': const AgronomicParameterDefinition(
      id: 'moisture',
      displayName: 'Moisture Signs (NDMI)',
      displayNameMr: 'ओलावा निर्देशक (NDMI)',
      unit: 'Index (-0.2..+0.4)',
      minValid: -0.20,
      maxValid: 0.38,
      lowLabel: 'Red / orange · drier signal',
      midLabel: 'Yellow · middle range',
      highLabel: 'Teal / blue · wetter signal',
      sensorSource: 'Sentinel-2 MSI (B8 NIR 10m / B11 SWIR 20m)',
      agronomicDescription:
          'Normalized Difference Moisture Index tracking canopy leaf liquid water content.',
      stops: [
        AgronomicColorStop(value: -0.20, color: Color(0xFFBF360C), label: 'Severe Deficit'),
        AgronomicColorStop(value: -0.05, color: Color(0xFFE65100), label: 'Drier Signal'),
        AgronomicColorStop(value: 0.08, color: Color(0xFFFBC02D), label: 'Middle Range'),
        AgronomicColorStop(value: 0.20, color: Color(0xFF00ACC1), label: 'Adequate Moisture'),
        AgronomicColorStop(value: 0.38, color: Color(0xFF1565C0), label: 'Wetter Signal'),
      ],
    ),

    // 3. NDRE (RedEdge Nitrogen & Chlorophyll)
    'ndre': const AgronomicParameterDefinition(
      id: 'ndre',
      displayName: 'Nitrogen & RedEdge (NDRE)',
      displayNameMr: 'नत्र आणि क्लोरोफिल (NDRE)',
      unit: 'Index (0.1..0.5)',
      minValid: 0.12,
      maxValid: 0.46,
      lowLabel: 'Nitrogen Chlorosis (<0.22)',
      midLabel: 'Moderate Nitrogen (0.22 - 0.32)',
      highLabel: 'Dense Nitrogen (>0.32)',
      sensorSource: 'Sentinel-2 MSI (B8 NIR 10m / B5 RedEdge 20m)',
      agronomicDescription:
          'Non-saturating RedEdge index sensitive to stalk nitrogen and deep leaf chlorophyll.',
      stops: [
        AgronomicColorStop(value: 0.12, color: Color(0xFFE65100), label: 'Chlorosis'),
        AgronomicColorStop(value: 0.22, color: Color(0xFFFBC02D), label: 'Moderate N'),
        AgronomicColorStop(value: 0.32, color: Color(0xFF2E7D32), label: 'Optimal N'),
        AgronomicColorStop(value: 0.46, color: Color(0xFF6A1B9A), label: 'Luxuriant Canopy'),
      ],
    ),

    // 4. MSAVI2 (Soil-Free Vegetative Index)
    'msavi2': const AgronomicParameterDefinition(
      id: 'msavi2',
      displayName: 'Soil-Adjusted Canopy (MSAVI2)',
      displayNameMr: 'माती-सुधारित वाढ (MSAVI2)',
      unit: 'Index (0.0..0.85)',
      minValid: 0.10,
      maxValid: 0.80,
      lowLabel: 'Bare Soil / Gap (<0.30)',
      midLabel: 'Early Tillering (0.30 - 0.55)',
      highLabel: 'Closed Furrow (>0.55)',
      sensorSource: 'Sentinel-2 MSI Surface Reflectance (Self-calibrated soil noise filter)',
      agronomicDescription:
          'Minimizes soil spectral reflection during early tillering and ratoon emergence.',
      stops: [
        AgronomicColorStop(value: 0.10, color: Color(0xFF795548), label: 'Bare Soil'),
        AgronomicColorStop(value: 0.30, color: Color(0xFFFFA000), label: 'Early Emergence'),
        AgronomicColorStop(value: 0.55, color: Color(0xFF7CB342), label: 'Canopy Developing'),
        AgronomicColorStop(value: 0.80, color: Color(0xFF1B5E20), label: 'Full Ground Cover'),
      ],
    ),

    // 5. CARI (Chlorophyll Absorption Ratio)
    'cari': const AgronomicParameterDefinition(
      id: 'cari',
      displayName: 'Chlorophyll Absorption (CARI)',
      displayNameMr: 'हरितद्रव्य शोषण (CARI)',
      unit: 'Index (0.05..0.60)',
      minValid: 0.10,
      maxValid: 0.55,
      lowLabel: 'Low Chlorophyll (<0.24)',
      midLabel: 'Moderate Absorption (0.24 - 0.38)',
      highLabel: 'High Chlorophyll (>0.38)',
      sensorSource: 'Sentinel-2 MSI (B5 RedEdge / B4 Red / B8 NIR)',
      agronomicDescription:
          'Measures active photon absorption by chlorophyll a without ground interference.',
      stops: [
        AgronomicColorStop(value: 0.10, color: Color(0xFFAD1457), label: 'Deficient'),
        AgronomicColorStop(value: 0.24, color: Color(0xFFFB8C00), label: 'Moderate'),
        AgronomicColorStop(value: 0.38, color: Color(0xFFFDD835), label: 'Good'),
        AgronomicColorStop(value: 0.55, color: Color(0xFF00796B), label: 'High Absorption'),
      ],
    ),
  };

  /// Retrieves parameter definition by key ('growth', 'ndvi', 'moisture', 'ndmi', etc.)
  static AgronomicParameterDefinition get(String key) {
    final lower = key.toLowerCase();
    if (lower == 'growth' || lower == 'ndvi') {
      return _parameters['ndvi']!;
    }
    if (lower == 'moisture' || lower == 'ndmi') {
      return _parameters['moisture']!;
    }
    return _parameters[lower] ?? _parameters['ndvi']!;
  }
}
