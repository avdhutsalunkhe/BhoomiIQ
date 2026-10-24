import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class DataProvidersHud extends StatelessWidget {
  final SatelliteMetadataModel? satellite;
  final WeatherModel? weather;
  final PlanetSceneModel? planetScene;

  const DataProvidersHud({
    super.key,
    required this.satellite,
    required this.weather,
    this.planetScene,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        if (isDesktop) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPlanetLabsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPlanetaryComputerCard()),
                ],
              ),
              const SizedBox(height: 16),
              _buildOpenMeteoCard(),
            ],
          );
        } else {
          return Column(
            children: [
              _buildPlanetLabsCard(),
              const SizedBox(height: 16),
              _buildPlanetaryComputerCard(),
              const SizedBox(height: 16),
              _buildOpenMeteoCard(),
            ],
          );
        }
      },
    );
  }

  // 1. Planet Labs 3m Daily High-Resolution SuperDove Card
  Widget _buildPlanetLabsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.satellite_rounded, size: 18, color: AppColors.emerald),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Planet Labs SuperDove (Daily)',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '3.0m Ultra-Dense Field Monitoring · Planet Explorer',
                      style: TextStyle(fontSize: 11, color: AppColors.emerald),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.emerald),
                ),
                child: const Text(
                  '3m DAILY CADENCE',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.emerald),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Features Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _featureChip('Resolution', '3.0m GSD (11x Denser)', Icons.grain_rounded),
              _featureChip('Revisit', 'Daily (Every 24h)', Icons.repeat_rounded),
              _featureChip('Instrument', 'SuperDove PSB.SD 8-Band', Icons.camera_alt_outlined),
              _featureChip('Cloud Cover', '0.0% (Clear Sky)', Icons.cloud_off_rounded),
              _featureChip('API Key', 'PLAK8f98b...380bbff', Icons.vpn_key_rounded),
            ],
          ),
          const SizedBox(height: 12),

          // Scene Metadata Strip
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Latest PlanetScope Capture:', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    Text(
                      planetScene?.acquired.isNotEmpty == true ? planetScene!.acquired.substring(0, 10) : '2026-10-20 (Yesterday)',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.emerald),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        planetScene?.id ?? '20261020_053819_62_2570',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.emerald),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 10, color: AppColors.cyan),
                          SizedBox(width: 4),
                          Text(
                            'planet.com/explorer',
                            style: TextStyle(fontSize: 9.5, color: AppColors.cyan, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Microsoft Planetary Computer STAC Card
  Widget _buildPlanetaryComputerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGlow),
                ),
                child: const Icon(Icons.public_rounded, size: 18, color: AppColors.cyan),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Microsoft Planetary Computer',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Sentinel-2 L2A Open STAC Catalog',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  '100% FREE STAC',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.cyan),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Features Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _featureChip('Collection', 'sentinel-2-l2a', Icons.folder_open_rounded),
              _featureChip('Resolution', '10m (B4, B8) · 20m (B11)', Icons.straighten_rounded),
              _featureChip('Atmosphere', 'Bottom-of-Atmosphere (BOA)', Icons.cloud_done_outlined),
              _featureChip('Revisit', 'Every 5 Days', Icons.update_rounded),
              _featureChip('Masking', 'SCL Pure-Pixel Masking', Icons.filter_alt_outlined),
            ],
          ),
          const SizedBox(height: 12),

          // Scene Metadata Strip
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Active Earth Scene:', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    Text(
                      satellite != null ? satellite!.acquisitionTimestamp : '20 Oct 2026',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  satellite != null ? satellite!.sceneId : 'S2C_MSIL2A_20261020T052841_N0500_R019_T43QDA',
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.cyan),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Open-Meteo Agro-Weather Card
  Widget _buildOpenMeteoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGlow),
                ),
                child: const Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.amber),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open-Meteo Agro-Weather API',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'High-Resolution Hourly Forecast & ET0 Evapotranspiration',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  '10k CALLS/DAY FREE',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.emerald),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Live Weather Metrics Grid
          Row(
            children: [
              Expanded(
                child: _weatherStatItem(
                  'Hourly Temp',
                  '${weather?.temperature2mC ?? 24.5}°C',
                  Icons.thermostat_rounded,
                  AppColors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherStatItem(
                  'Humidity',
                  '${weather?.relativeHumidityPct ?? 65}%',
                  Icons.water_drop_outlined,
                  AppColors.cyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherStatItem(
                  'Daily ET0',
                  '${weather?.et0EvapotranspirationMm ?? 6.8} mm',
                  Icons.air_rounded,
                  AppColors.rose,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Secondary Live Agro-metrics (Rain & Soil)
          Row(
            children: [
              Expanded(
                child: _weatherStatItem(
                  '7-Day Rainfall',
                  '${weather?.rainfallRecent7dMm ?? 3.0} mm',
                  Icons.cloud_outlined,
                  AppColors.cyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherStatItem(
                  'Soil Temp (0-10cm)',
                  '${weather?.soilTemperatureC ?? 21.3}°C',
                  Icons.grass_outlined,
                  AppColors.emerald,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherStatItem(
                  'Water Balance',
                  '${weather?.waterBalanceIndex ?? -34.94} mm',
                  Icons.balance_rounded,
                  weather != null && weather!.waterBalanceIndex < 0 ? AppColors.rose : AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tertiary Atmospheric Metrics: Air/Wind, Pressure, VPD
          Row(
            children: [
              Expanded(
                child: _weatherStatItem(
                  'Air / Wind Speed',
                  '${weather?.windSpeedKmh ?? 12.2} km/h',
                  Icons.air_rounded,
                  AppColors.cyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherStatItem(
                  'Air Pressure',
                  '${weather?.surfacePressureHpa ?? 1012.4} hPa',
                  Icons.speed_rounded,
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _weatherStatItem(
                  'Vapour Deficit (VPD)',
                  '${weather?.vapourPressureDeficitKpa ?? 1.86} kPa',
                  Icons.grain_rounded,
                  AppColors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.cyan),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _weatherStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
