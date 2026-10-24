class WeatherModel {
  final String source;
  final double latitude;
  final double longitude;
  final double temperature2mC;
  final double relativeHumidityPct;
  final double rainfallRecent7dMm;
  final double rainfallRecent14dMm;
  final double et0EvapotranspirationMm;
  final double waterBalanceIndex;
  final double soilTemperatureC;
  final String forecastSummary;
  final double surfacePressureHpa;
  final double windSpeedKmh;
  final double windDirectionDeg;
  final double dewPointC;
  final double apparentTemperatureC;
  final double vapourPressureDeficitKpa;
  final double soilMoistureSurface;
  final double soilMoistureRootzone;
  final double solarRadiationMjM2;
  final double sunshineDurationHours;
  final double growingDegreeDays7d;
  final double temperatureMaxC;
  final double temperatureMinC;

  const WeatherModel({
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.temperature2mC,
    required this.relativeHumidityPct,
    required this.rainfallRecent7dMm,
    required this.rainfallRecent14dMm,
    required this.et0EvapotranspirationMm,
    required this.waterBalanceIndex,
    required this.soilTemperatureC,
    required this.forecastSummary,
    this.surfacePressureHpa = 1012.4,
    this.windSpeedKmh = 12.2,
    this.windDirectionDeg = 265.0,
    this.dewPointC = 12.4,
    this.apparentTemperatureC = 25.2,
    this.vapourPressureDeficitKpa = 1.86,
    this.soilMoistureSurface = 0.24,
    this.soilMoistureRootzone = 0.25,
    this.solarRadiationMjM2 = 21.4,
    this.sunshineDurationHours = 9.2,
    this.growingDegreeDays7d = 127.6,
    this.temperatureMaxC = 33.5,
    this.temperatureMinC = 22.9,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      source: json['source'] as String? ?? 'Open-Meteo',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 17.0512,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 74.3184,
      temperature2mC: (json['temperature_2m_c'] as num?)?.toDouble() ?? 30.0,
      relativeHumidityPct: (json['relative_humidity_pct'] as num?)?.toDouble() ?? 65.0,
      rainfallRecent7dMm: (json['rainfall_recent_7d_mm'] as num?)?.toDouble() ?? 0.0,
      rainfallRecent14dMm: (json['rainfall_recent_14d_mm'] as num?)?.toDouble() ?? 0.0,
      et0EvapotranspirationMm: (json['et0_evapotranspiration_mm'] as num?)?.toDouble() ?? 4.5,
      waterBalanceIndex: (json['water_balance_index'] as num?)?.toDouble() ?? 0.0,
      soilTemperatureC: (json['soil_temperature_0_10cm_c'] as num?)?.toDouble() ?? 26.5,
      forecastSummary: json['forecast_7d_summary'] as String? ?? '',
      surfacePressureHpa: (json['surface_pressure_hpa'] as num?)?.toDouble() ?? 1012.4,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 12.2,
      windDirectionDeg: (json['wind_direction_deg'] as num?)?.toDouble() ?? 265.0,
      dewPointC: (json['dew_point_c'] as num?)?.toDouble() ?? 12.4,
      apparentTemperatureC: (json['apparent_temperature_c'] as num?)?.toDouble() ?? 25.2,
      vapourPressureDeficitKpa: (json['vapour_pressure_deficit_kpa'] as num?)?.toDouble() ?? 1.86,
      soilMoistureSurface: (json['soil_moisture_surface_m3m3'] as num?)?.toDouble() ?? 0.24,
      soilMoistureRootzone: (json['soil_moisture_rootzone_m3m3'] as num?)?.toDouble() ?? 0.25,
      solarRadiationMjM2: (json['solar_radiation_mj_m2'] as num?)?.toDouble() ?? 21.4,
      sunshineDurationHours: (json['sunshine_duration_hours'] as num?)?.toDouble() ?? 9.2,
      growingDegreeDays7d: (json['growing_degree_days_7d'] as num?)?.toDouble() ?? 127.6,
      temperatureMaxC: (json['temperature_max_c'] as num?)?.toDouble() ?? 33.5,
      temperatureMinC: (json['temperature_min_c'] as num?)?.toDouble() ?? 22.9,
    );
  }
}
