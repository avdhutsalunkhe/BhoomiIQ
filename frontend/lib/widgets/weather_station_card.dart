import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

/// Full Atmospheric and Weather Intelligence Card
/// Displays Temp, Air/Wind, Pressure, Humidity, Dew Point, VPD, Rain, Soil Moisture, Solar Radiation, etc.
class WeatherStationCard extends StatefulWidget {
  final WeatherModel weather;
  final bool isMarathi;

  const WeatherStationCard({
    super.key,
    required this.weather,
    this.isMarathi = true,
  });

  @override
  State<WeatherStationCard> createState() => _WeatherStationCardState();
}

class _WeatherStationCardState extends State<WeatherStationCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final w = widget.weather;
    final isMr = widget.isMarathi;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, color: AppColors.orange, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isMr ? 'हवामान व वातावरणीय स्थिती' : 'Atmospheric & Weather Intelligence',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isMr ? 'थेट सेन्सर' : 'Live Met',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.emerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            isMr
                                ? 'तापमान, हवा, दाब, आर्द्रता आणि जमिनीचा ओलावा (Open-Meteo)'
                                : 'Temp, Wind, Pressure, Humidity, Dew Point, VPD & Soil Metrics',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            const Divider(color: AppColors.divider, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. Primary Highlight Banner: Temp + Feels Like + Air/Wind + Pressure
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.orangeLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _heroMetric(
                          icon: Icons.thermostat_rounded,
                          iconColor: const Color(0xFFE11D48),
                          label: isMr ? 'हवेचे तापमान' : 'Air Temp',
                          value: '${w.temperature2mC.toStringAsFixed(1)}°C',
                          subtext: isMr
                              ? 'भासमान: ${w.apparentTemperatureC.toStringAsFixed(1)}°C'
                              : 'Feels: ${w.apparentTemperatureC.toStringAsFixed(1)}°C',
                        ),
                        Container(width: 1, height: 45, color: AppColors.border),
                        _heroMetric(
                          icon: Icons.air_rounded,
                          iconColor: const Color(0xFF0284C7),
                          label: isMr ? 'वाऱ्याचा वेग (Air)' : 'Wind Speed',
                          value: '${w.windSpeedKmh.toStringAsFixed(1)} km/h',
                          subtext: isMr ? 'दिशा: ${w.windDirectionDeg.toStringAsFixed(0)}° W' : 'Dir: ${w.windDirectionDeg.toStringAsFixed(0)}° W',
                        ),
                        Container(width: 1, height: 45, color: AppColors.border),
                        _heroMetric(
                          icon: Icons.speed_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          label: isMr ? 'वातावरणीय दाब' : 'Air Pressure',
                          value: '${w.surfacePressureHpa.toStringAsFixed(0)} hPa',
                          subtext: isMr ? 'सर्वसामान्य पातळी' : 'Mean Sea Level',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Comprehensive 6-Grid Matrix for All Detailed Parameters
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 650 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.8,
                        children: [
                          // 1. Humidity & Dew Point
                          _metricCard(
                            icon: Icons.water_drop_outlined,
                            iconColor: AppColors.cyan,
                            title: isMr ? 'आर्द्रता (Humidity)' : 'Relative Humidity',
                            value: '${w.relativeHumidityPct.toStringAsFixed(0)}%',
                            detail: isMr ? 'दवबिंदू: ${w.dewPointC.toStringAsFixed(1)}°C' : 'Dew Point: ${w.dewPointC.toStringAsFixed(1)}°C',
                          ),

                          // 2. Vapour Pressure Deficit (VPD)
                          _metricCard(
                            icon: Icons.grain_rounded,
                            iconColor: const Color(0xFFD97706),
                            title: isMr ? 'बाष्प दाब तूट (VPD)' : 'Vapour Deficit (VPD)',
                            value: '${w.vapourPressureDeficitKpa.toStringAsFixed(2)} kPa',
                            detail: isMr ? 'बाष्पीभवन ताण: मध्यम' : 'Evaporative demand',
                          ),

                          // 3. Soil Moisture (0-7cm & 7-28cm)
                          _metricCard(
                            icon: Icons.layers_outlined,
                            iconColor: AppColors.emerald,
                            title: isMr ? 'जमिनीतील ओलावा' : 'Soil Moisture',
                            value: '${(w.soilMoistureSurface * 100).toStringAsFixed(0)}% vol',
                            detail: isMr
                                ? 'मुळांत: ${(w.soilMoistureRootzone * 100).toStringAsFixed(0)}% (७-२८cm)'
                                : 'Rootzone: ${(w.soilMoistureRootzone * 100).toStringAsFixed(0)}% (7-28cm)',
                          ),

                          // 4. Soil Temperature
                          _metricCard(
                            icon: Icons.landscape_outlined,
                            iconColor: const Color(0xFFB45309),
                            title: isMr ? 'जमिनीचे तापमान' : 'Soil Temperature',
                            value: '${w.soilTemperatureC.toStringAsFixed(1)}°C',
                            detail: isMr ? 'वरचा थर (०-१० सेमी)' : 'Surface (0-10cm)',
                          ),

                          // 5. Solar Radiation & Sunshine
                          _metricCard(
                            icon: Icons.wb_sunny_rounded,
                            iconColor: AppColors.orange,
                            title: isMr ? 'सूर्यप्रकाश व ऊर्जा' : 'Solar Radiation',
                            value: '${w.solarRadiationMjM2.toStringAsFixed(1)} MJ/m²',
                            detail: isMr ? 'सूर्यप्रकाश: ${w.sunshineDurationHours.toStringAsFixed(1)} तास' : 'Sunshine: ${w.sunshineDurationHours.toStringAsFixed(1)} hrs',
                          ),

                          // 6. Evapotranspiration (ET0) & Water Balance
                          _metricCard(
                            icon: Icons.opacity_rounded,
                            iconColor: const Color(0xFF0369A1),
                            title: isMr ? 'बाष्पीभवन (ET₀)' : 'Reference ET₀',
                            value: '${w.et0EvapotranspirationMm.toStringAsFixed(1)} mm/d',
                            detail: isMr ? '७ दिवसांचा पाऊस: ${w.rainfallRecent7dMm.toStringAsFixed(1)} mm' : '7d Rain: ${w.rainfallRecent7dMm.toStringAsFixed(1)} mm',
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // 3. Temperature Extremes and GDD Heat Units Summary Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.straighten_rounded, size: 16, color: AppColors.orange),
                            const SizedBox(width: 8),
                            Text(
                              isMr
                                  ? 'कमाल / किमान तापमान: ${w.temperatureMaxC.toStringAsFixed(1)}°C / ${w.temperatureMinC.toStringAsFixed(1)}°C'
                                  : 'High / Low Temp: ${w.temperatureMaxC.toStringAsFixed(1)}°C / ${w.temperatureMinC.toStringAsFixed(1)}°C',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Text(
                          isMr ? 'उष्णता निर्देशांक: ${w.growingDegreeDays7d.toStringAsFixed(0)} GDD (७ दिवस)' : 'Heat Units: ${w.growingDegreeDays7d.toStringAsFixed(0)} GDD',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.orangeDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroMetric({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        Text(
          subtext,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          Text(
            detail,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
