class PixelModel {
  final String id;
  final int col;
  final int row;
  final double ndvi;
  final double ndmi;
  final double ndre;
  final double msavi2;
  final double cari;
  final double cwsi;
  final bool isValidVegetation;
  final bool isBoundary;
  final String classification;

  const PixelModel({
    required this.id,
    required this.col,
    required this.row,
    required this.ndvi,
    required this.ndmi,
    required this.ndre,
    this.msavi2 = 0.55,
    this.cari = 0.42,
    this.cwsi = 0.25,
    required this.isValidVegetation,
    required this.isBoundary,
    required this.classification,
  });

  factory PixelModel.fromJson(Map<String, dynamic> json) {
    return PixelModel(
      id: json['id'] as String? ?? '',
      col: json['col'] as int? ?? 0,
      row: json['row'] as int? ?? 0,
      ndvi: (json['ndvi'] as num?)?.toDouble() ?? 0.0,
      ndmi: (json['ndmi'] as num?)?.toDouble() ?? 0.0,
      ndre: (json['ndre'] as num?)?.toDouble() ?? 0.0,
      msavi2: (json['msavi2'] as num?)?.toDouble() ?? 0.55,
      cari: (json['cari'] as num?)?.toDouble() ?? 0.42,
      cwsi: (json['cwsi'] as num?)?.toDouble() ?? 0.25,
      isValidVegetation: json['is_valid_vegetation'] as bool? ?? true,
      isBoundary: json['is_boundary'] as bool? ?? false,
      classification: json['classification'] as String? ?? 'Moderate',
    );
  }
}

class ResolutionAnalysisModel {
  final double areaAcres;
  final double areaSqMeters;
  final int theoretical10mPixels;
  final int theoretical20mPixels;
  final int usablePurePixels;
  final int boundaryExcludedPixels;
  final double usabilityRatio;
  final String resolutionRating; // "Optimal" | "Acceptable" | "Constrained"
  final bool droneSurveyRecommended;
  final String limitationNotice;

  const ResolutionAnalysisModel({
    required this.areaAcres,
    required this.areaSqMeters,
    required this.theoretical10mPixels,
    required this.theoretical20mPixels,
    required this.usablePurePixels,
    required this.boundaryExcludedPixels,
    required this.usabilityRatio,
    required this.resolutionRating,
    required this.droneSurveyRecommended,
    required this.limitationNotice,
  });

  factory ResolutionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ResolutionAnalysisModel(
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 0.0,
      areaSqMeters: (json['area_sq_meters'] as num?)?.toDouble() ?? 0.0,
      theoretical10mPixels: json['theoretical_10m_pixels'] as int? ?? 0,
      theoretical20mPixels: json['theoretical_20m_pixels'] as int? ?? 0,
      usablePurePixels: json['usable_pure_pixels'] as int? ?? 0,
      boundaryExcludedPixels: json['boundary_excluded_pixels'] as int? ?? 0,
      usabilityRatio: (json['usability_ratio'] as num?)?.toDouble() ?? 0.0,
      resolutionRating: json['resolution_rating'] as String? ?? 'Acceptable',
      droneSurveyRecommended: json['drone_survey_recommended'] as bool? ?? false,
      limitationNotice: json['limitation_notice'] as String? ?? '',
    );
  }
}

class SatelliteMetadataModel {
  final String sceneId;
  final String satellitePlatform;
  final String acquisitionTimestamp;
  final double cloudCoverPct;
  final double parcelCloudScore;
  final String dataSource;

  const SatelliteMetadataModel({
    required this.sceneId,
    required this.satellitePlatform,
    required this.acquisitionTimestamp,
    required this.cloudCoverPct,
    required this.parcelCloudScore,
    required this.dataSource,
  });

  factory SatelliteMetadataModel.fromJson(Map<String, dynamic> json) {
    return SatelliteMetadataModel(
      sceneId: json['scene_id'] as String? ?? '',
      satellitePlatform: json['satellite_platform'] as String? ?? 'Sentinel-2B L2A',
      acquisitionTimestamp: json['acquisition_timestamp'] as String? ?? '2026-10-20',
      cloudCoverPct: (json['cloud_cover_pct'] as num?)?.toDouble() ?? 0.0,
      parcelCloudScore: (json['parcel_cloud_score'] as num?)?.toDouble() ?? 0.0,
      dataSource: json['data_source'] as String? ?? 'Copernicus Sentinel-2',
    );
  }
}

class DynamicAdvisoryModel {
  final String statusLevel; // "good" | "check" | "inspect"
  final String headline;
  final String detail;
  final String? affectedSector;
  final int confidencePct;
  final List<String> differentialDiagnosis;
  final List<String> suggestedActions;
  final String scientificDisclaimer;

  const DynamicAdvisoryModel({
    required this.statusLevel,
    required this.headline,
    required this.detail,
    this.affectedSector,
    required this.confidencePct,
    required this.differentialDiagnosis,
    required this.suggestedActions,
    required this.scientificDisclaimer,
  });

  factory DynamicAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return DynamicAdvisoryModel(
      statusLevel: json['status_level'] as String? ?? 'check',
      headline: json['headline'] as String? ?? 'Inspect field conditions',
      detail: json['detail'] as String? ?? '',
      affectedSector: json['affected_sector'] as String?,
      confidencePct: json['confidence_pct'] as int? ?? 75,
      differentialDiagnosis: (json['differential_diagnosis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      scientificDisclaimer: json['scientific_disclaimer'] as String? ?? '',
    );
  }
}

class FarmFieldModel {
  final String id;
  final String name;
  final String nameMr;
  final String plotNumber;
  final double areaAcres;
  final String variety;
  final String caneType;
  final String plantingDate;
  final String expectedHarvestDate;
  final int cropAgeDays;
  final String cropStage;
  final String village;
  final double lat;
  final double lng;
  final List<List<double>> boundaryPolygon; // normalized percentages [x, y]

  const FarmFieldModel({
    required this.id,
    required this.name,
    required this.nameMr,
    required this.plotNumber,
    required this.areaAcres,
    required this.variety,
    required this.caneType,
    required this.plantingDate,
    required this.expectedHarvestDate,
    required this.cropAgeDays,
    required this.cropStage,
    required this.village,
    required this.lat,
    required this.lng,
    required this.boundaryPolygon,
  });

  factory FarmFieldModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>? ?? {};
    final polyRaw = json['boundary_polygon'] as List<dynamic>? ?? [];
    final poly = polyRaw.map((pt) {
      if (pt is List) {
        return [(pt[0] as num).toDouble(), (pt[1] as num).toDouble()];
      }
      return [0.0, 0.0];
    }).toList();

    return FarmFieldModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameMr: json['name_mr'] as String? ?? '',
      plotNumber: json['plot_number'] as String? ?? '',
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 0.0,
      variety: json['variety'] as String? ?? 'Co 86032',
      caneType: json['cane_type'] as String? ?? 'Plant cane',
      plantingDate: json['planting_date'] as String? ?? '',
      expectedHarvestDate: json['expected_harvest_date'] as String? ?? '',
      cropAgeDays: json['crop_age_days'] as int? ?? 0,
      cropStage: json['crop_stage'] as String? ?? 'Grand Growth',
      village: json['village'] as String? ?? '',
      lat: (coords['lat'] as num?)?.toDouble() ?? 17.0512,
      lng: (coords['lng'] as num?)?.toDouble() ?? 74.3184,
      boundaryPolygon: poly,
    );
  }
}

class PlanetSceneModel {
  final String id;
  final String itemType;
  final String acquired;
  final double cloudCoverPct;
  final double pixelResolutionM;
  final double gsdM;
  final String instrument;
  final String satelliteId;
  final double sunAzimuth;
  final double sunElevation;
  final String thumbnailUrl;
  final String explorerUrl;

  const PlanetSceneModel({
    required this.id,
    required this.itemType,
    required this.acquired,
    required this.cloudCoverPct,
    required this.pixelResolutionM,
    required this.gsdM,
    required this.instrument,
    required this.satelliteId,
    required this.sunAzimuth,
    required this.sunElevation,
    required this.thumbnailUrl,
    required this.explorerUrl,
  });

  factory PlanetSceneModel.fromJson(Map<String, dynamic> json) {
    return PlanetSceneModel(
      id: json['id'] as String? ?? '',
      itemType: json['item_type'] as String? ?? 'PSScene',
      acquired: json['acquired'] as String? ?? '',
      cloudCoverPct: (json['cloud_cover_pct'] as num?)?.toDouble() ?? 0.0,
      pixelResolutionM: (json['pixel_resolution_m'] as num?)?.toDouble() ?? 3.0,
      gsdM: (json['gsd_m'] as num?)?.toDouble() ?? 3.9,
      instrument: json['instrument'] as String? ?? 'SuperDove PSB.SD',
      satelliteId: json['satellite_id'] as String? ?? '2570',
      sunAzimuth: (json['sun_azimuth'] as num?)?.toDouble() ?? 145.6,
      sunElevation: (json['sun_elevation'] as num?)?.toDouble() ?? 57.3,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      explorerUrl: json['explorer_url'] as String? ?? 'https://www.planet.com/explorer/',
    );
  }
}

class SugarcaneYieldModel {
  final double predictedYieldMtPerAcre;
  final double totalFieldTonnes;
  final double historicalBenchmarkMt;
  final double yieldDeltaPct;
  final List<double> confidenceIntervalMt;
  final String mlAlgorithm;
  final double aboveGroundBiomassTonsAcre;
  final double carbonSequesteredMtCo2e;
  final String yieldClassification;

  const SugarcaneYieldModel({
    required this.predictedYieldMtPerAcre,
    required this.totalFieldTonnes,
    required this.historicalBenchmarkMt,
    required this.yieldDeltaPct,
    required this.confidenceIntervalMt,
    required this.mlAlgorithm,
    required this.aboveGroundBiomassTonsAcre,
    required this.carbonSequesteredMtCo2e,
    required this.yieldClassification,
  });

  factory SugarcaneYieldModel.fromJson(Map<String, dynamic> json) {
    final ciRaw = json['confidence_interval_mt'] as List<dynamic>? ?? [20.0, 25.0];
    return SugarcaneYieldModel(
      predictedYieldMtPerAcre: (json['predicted_yield_mt_per_acre'] as num?)?.toDouble() ?? 58.4,
      totalFieldTonnes: (json['total_field_tonnes'] as num?)?.toDouble() ?? 17.5,
      historicalBenchmarkMt: (json['historical_benchmark_mt'] as num?)?.toDouble() ?? 45.0,
      yieldDeltaPct: (json['yield_delta_pct'] as num?)?.toDouble() ?? 29.8,
      confidenceIntervalMt: ciRaw.map((e) => (e as num).toDouble()).toList(),
      mlAlgorithm: json['ml_algorithm'] as String? ?? 'Ensemble Gradient Boosting (GDD + iPAR + NDRE)',
      aboveGroundBiomassTonsAcre: (json['above_ground_biomass_tons_acre'] as num?)?.toDouble() ?? 78.5,
      carbonSequesteredMtCo2e: (json['carbon_sequestered_mt_co2e'] as num?)?.toDouble() ?? 42.1,
      yieldClassification: json['yield_classification'] as String? ?? 'Exceptional',
    );
  }
}

class SucroseMaturityModel {
  final double brixDegrees;
  final double ccsPercent;
  final double polPercent;
  final double maturityIndex;
  final String optimalHarvestWindowStart;
  final String optimalHarvestWindowEnd;
  final int daysToPeakSucrose;
  final String harvestRecommendation;
  final double millRecoveryBonusPotentialInr;

  const SucroseMaturityModel({
    required this.brixDegrees,
    required this.ccsPercent,
    required this.polPercent,
    required this.maturityIndex,
    required this.optimalHarvestWindowStart,
    required this.optimalHarvestWindowEnd,
    required this.daysToPeakSucrose,
    required this.harvestRecommendation,
    required this.millRecoveryBonusPotentialInr,
  });

  factory SucroseMaturityModel.fromJson(Map<String, dynamic> json) {
    return SucroseMaturityModel(
      brixDegrees: (json['brix_degrees'] as num?)?.toDouble() ?? 21.8,
      ccsPercent: (json['ccs_percent'] as num?)?.toDouble() ?? 12.4,
      polPercent: (json['pol_percent'] as num?)?.toDouble() ?? 14.2,
      maturityIndex: (json['maturity_index'] as num?)?.toDouble() ?? 0.94,
      optimalHarvestWindowStart: json['optimal_harvest_window_start'] as String? ?? 'In 35 Days',
      optimalHarvestWindowEnd: json['optimal_harvest_window_end'] as String? ?? 'In 55 Days',
      daysToPeakSucrose: json['days_to_peak_sucrose'] as int? ?? 38,
      harvestRecommendation: json['harvest_recommendation'] as String? ?? 'Schedule cutting in peak window',
      millRecoveryBonusPotentialInr: (json['mill_recovery_bonus_potential_inr'] as num?)?.toDouble() ?? 2850.0,
    );
  }
}

class IrrigationPrescriptionModel {
  final double dailyEtcMm;
  final double faoKcDual;
  final double soilDepletionMm;
  final String soilMoistureStatus;
  final double recommendedIrrigationLitersPerAcre;
  final double recommendedDripRuntimeHours;
  final String nextIrrigationUrgency;
  final String drainageSalinityRisk;

  const IrrigationPrescriptionModel({
    required this.dailyEtcMm,
    required this.faoKcDual,
    required this.soilDepletionMm,
    required this.soilMoistureStatus,
    required this.recommendedIrrigationLitersPerAcre,
    required this.recommendedDripRuntimeHours,
    required this.nextIrrigationUrgency,
    required this.drainageSalinityRisk,
  });

  factory IrrigationPrescriptionModel.fromJson(Map<String, dynamic> json) {
    return IrrigationPrescriptionModel(
      dailyEtcMm: (json['daily_etc_mm'] as num?)?.toDouble() ?? 8.64,
      faoKcDual: (json['fao_kc_dual'] as num?)?.toDouble() ?? 1.27,
      soilDepletionMm: (json['soil_depletion_mm'] as num?)?.toDouble() ?? 44.6,
      soilMoistureStatus: json['soil_moisture_status'] as String? ?? 'Deficit Stress',
      recommendedIrrigationLitersPerAcre: (json['recommended_irrigation_liters_per_acre'] as num?)?.toDouble() ?? 18500.0,
      recommendedDripRuntimeHours: (json['recommended_drip_runtime_hours'] as num?)?.toDouble() ?? 2.3,
      nextIrrigationUrgency: json['next_irrigation_urgency'] as String? ?? 'Immediate (Today)',
      drainageSalinityRisk: json['drainage_salinity_risk'] as String? ?? 'Low (ECe < 1.1 dS/m)',
    );
  }
}

class AnomalyDiagnosticMLModel {
  final String topCondition;
  final String topConditionMr;
  final int mlConfidencePct;
  final Map<String, double> probabilityDistribution;
  final List<String> spectralEvidence;
  final List<String> agronomicActionPlan;
  final String? chemicalPrescriptionRx;
  final String? biologicalRemedy;

  const AnomalyDiagnosticMLModel({
    required this.topCondition,
    required this.topConditionMr,
    required this.mlConfidencePct,
    required this.probabilityDistribution,
    required this.spectralEvidence,
    required this.agronomicActionPlan,
    this.chemicalPrescriptionRx,
    this.biologicalRemedy,
  });

  factory AnomalyDiagnosticMLModel.fromJson(Map<String, dynamic> json) {
    final probRaw = json['probability_distribution'] as Map<String, dynamic>? ?? {};
    final probs = probRaw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    final evidenceRaw = json['spectral_evidence'] as List<dynamic>? ?? [];
    final actionsRaw = json['agronomic_action_plan'] as List<dynamic>? ?? [];

    return AnomalyDiagnosticMLModel(
      topCondition: json['top_condition'] as String? ?? 'Moisture Deficit (Drought Stress)',
      topConditionMr: json['top_condition_mr'] as String? ?? 'पाण्याचा ताण आणि पानांचे पोषण',
      mlConfidencePct: json['ml_confidence_pct'] as int? ?? 75,
      probabilityDistribution: probs,
      spectralEvidence: evidenceRaw.map((e) => e.toString()).toList(),
      agronomicActionPlan: actionsRaw.map((e) => e.toString()).toList(),
      chemicalPrescriptionRx: json['chemical_prescription_rx'] as String?,
      biologicalRemedy: json['biological_remedy'] as String?,
    );
  }
}


