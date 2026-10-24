import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class TelemetryGaugesGrid extends StatelessWidget {
  final double meanNdvi;
  final double meanNdmi;
  final WeatherModel weather;
  final ResolutionAnalysisModel resolution;
  final String statusLevel;

  const TelemetryGaugesGrid({
    super.key,
    required this.meanNdvi,
    required this.meanNdmi,
    required this.weather,
    required this.resolution,
    required this.statusLevel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 950;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 950;

        if (isDesktop) {
          return Row(
            children: [
              Expanded(child: _buildNdviGauge()),
              const SizedBox(width: 14),
              Expanded(child: _buildNdmiGauge()),
              const SizedBox(width: 14),
              Expanded(child: _buildWaterBalanceGauge()),
              const SizedBox(width: 14),
              Expanded(child: _buildResolutionHud()),
            ],
          );
        } else if (isTablet) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildNdviGauge()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildNdmiGauge()),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildWaterBalanceGauge()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildResolutionHud()),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildNdviGauge(),
              const SizedBox(height: 12),
              _buildNdmiGauge(),
              const SizedBox(height: 12),
              _buildWaterBalanceGauge(),
              const SizedBox(height: 12),
              _buildResolutionHud(),
            ],
          );
        }
      },
    );
  }

  // 1. NDVI Radial Arc Speedometer
  Widget _buildNdviGauge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'NDVI VIGOR',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: meanNdvi >= 0.65
                      ? AppColors.emerald.withValues(alpha: 0.15)
                      : meanNdvi >= 0.45
                          ? AppColors.amber.withValues(alpha: 0.15)
                          : AppColors.rose.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meanNdvi >= 0.65 ? 'OPTIMAL' : meanNdvi >= 0.45 ? 'MODERATE' : 'STRESSED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: meanNdvi >= 0.65
                        ? AppColors.emerald
                        : meanNdvi >= 0.45
                            ? AppColors.amber
                            : AppColors.rose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 130,
              height: 75,
              child: CustomPaint(
                painter: _ArcGaugePainter(
                  value: meanNdvi.clamp(0.0, 1.0),
                  minValue: 0.0,
                  maxValue: 1.0,
                  activeColor: meanNdvi >= 0.65
                      ? AppColors.emerald
                      : meanNdvi >= 0.45
                          ? AppColors.amber
                          : AppColors.rose,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        meanNdvi.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'Scale: 0.0 - 1.0',
                        style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('15d Trend:', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
              ),
              Text(
                meanNdvi < 0.45 ? '-24% Deficit' : '+4% Growth',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: meanNdvi < 0.45 ? AppColors.rose : AppColors.emerald,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. NDMI Hydration Dial
  Widget _buildNdmiGauge() {
    final normVal = ((meanNdmi + 0.3) / 0.8).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'NDMI CANOPY WATER',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: meanNdmi >= 0.15
                      ? AppColors.cyan.withValues(alpha: 0.15)
                      : AppColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  meanNdmi >= 0.15 ? 'HYDRATED' : 'LOW WATER',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: meanNdmi >= 0.15 ? AppColors.cyan : AppColors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 130,
              height: 75,
              child: CustomPaint(
                painter: _ArcGaugePainter(
                  value: normVal,
                  minValue: 0.0,
                  maxValue: 1.0,
                  activeColor: AppColors.cyan,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (meanNdmi >= 0 ? '+' : '') + meanNdmi.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'SWIR Band B11 (20m)',
                        style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Hydration:', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
              ),
              Text(
                meanNdmi < 0 ? 'Water Stress Alert' : 'Healthy Turgor',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: meanNdmi < 0 ? AppColors.amber : AppColors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. 7-Day Rainfall & ET0 Water Balance
  Widget _buildWaterBalanceGauge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7D WATER BALANCE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(Icons.cloud_sync_outlined, size: 14, color: AppColors.cyan),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rainfall 7d', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    '${weather.rainfallRecent7dMm} mm',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.cyan),
                  ),
                ],
              ),
              Container(width: 1, height: 32, color: AppColors.divider),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily ET0', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    '${weather.et0EvapotranspirationMm} mm',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.amber),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (weather.rainfallRecent7dMm / (weather.et0EvapotranspirationMm * 7)).clamp(0.05, 1.0),
              backgroundColor: AppColors.bgSurface,
              color: AppColors.cyan,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Net Deficit: ${(weather.rainfallRecent7dMm - (weather.et0EvapotranspirationMm * 7)).toStringAsFixed(1)} mm',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // 4. Usable Pixel Resolution HUD
  Widget _buildResolutionHud() {
    final isConstrained = resolution.resolutionRating == 'Constrained';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isConstrained ? AppColors.rose.withValues(alpha: 0.35) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PIXEL RESOLUTION HUD',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                isConstrained ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 15,
                color: isConstrained ? AppColors.rose : AppColors.emerald,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${resolution.usablePurePixels}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isConstrained ? AppColors.rose : AppColors.emerald,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pure Pixels', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('of ${resolution.theoretical10mPixels} theoretical (10m)', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isConstrained ? AppColors.rose.withValues(alpha: 0.12) : AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isConstrained ? 'Sub-Acre Plot Alert: Drone Recommended' : 'Optimal Ground Sampling Ratio',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isConstrained ? AppColors.rose : AppColors.emerald,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coverage: ${(resolution.usabilityRatio * 100).toInt()}% pure interior',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;
  final Color activeColor;

  _ArcGaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;

    // Background track arc
    final bgPaint = Paint()
      ..color = AppColors.bgSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Active illuminated gauge arc
    final sweepAngle = (value - minValue) / (maxValue - minValue) * math.pi;
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.activeColor != activeColor;
  }
}
