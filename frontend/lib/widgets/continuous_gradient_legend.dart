import 'package:flutter/material.dart';
import '../services/agronomic_color_ramp.dart';
import '../theme/app_theme.dart';

/// Interactive Continuous Gradient Legend Component (Matches Annadata / Sentinel-2 Reference Exactly)
class ContinuousGradientLegend extends StatelessWidget {
  final String activeTab;
  final bool isGradientMode;
  final bool isMarathi;
  final ValueChanged<bool>? onToggleGradientMode;
  final VoidCallback? onFullAnalysis;

  const ContinuousGradientLegend({
    super.key,
    required this.activeTab,
    this.isGradientMode = true,
    this.isMarathi = true,
    this.onToggleGradientMode,
    this.onFullAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final param = AgronomicColorRampRegistry.get(activeTab);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: What do the colours mean? + Display Mode Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.palette_outlined, size: 16, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Text(
                    isMarathi
                        ? 'रंगांचा अर्थ काय आहे? · ${param.displayNameMr}'
                        : 'What do the colours mean? · ${param.displayName}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (onToggleGradientMode != null)
                GestureDetector(
                  onTap: () => onToggleGradientMode!(!isGradientMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGradientMode ? AppColors.orangeLight : AppColors.bgSurfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isGradientMode ? AppColors.orange : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGradientMode ? Icons.blur_on_rounded : Icons.grid_on_rounded,
                          size: 13,
                          color: isGradientMode ? AppColors.orangeDark : AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isGradientMode
                              ? (isMarathi ? 'सलग रंग (स्मूथ)' : 'Smooth Gradient')
                              : (isMarathi ? 'तुकडे (ग्रिड)' : 'Discrete Grid'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isGradientMode ? AppColors.orangeDark : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Continuous Horizontal Color Ramp Bar
          Container(
            height: 9,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                colors: param.stops.map((s) => s.color).toList(),
                stops: _computeNormalizedStops(param),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),

          // Low / Mid / High Segment Labels (Natural Marathi or English)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isMarathi
                      ? (param.id == 'moisture'
                          ? '🔴 कमी ओलावा (ताण)'
                          : '🔴 कमी वाढ / लक्ष द्या')
                      : param.lowLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF5350),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  isMarathi
                      ? (param.id == 'moisture'
                          ? '🟡 मध्यम ओलावा'
                          : '🟡 मध्यम वाढ')
                      : param.midLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  isMarathi
                      ? (param.id == 'moisture'
                          ? '🟢 भरपूर ओलावा'
                          : '🟢 उत्तम जोमदार वाढ')
                      : param.highLabel,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: param.stops.last.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Contextual Agronomic Guidance & Satellite Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMarathi
                          ? (param.id == 'moisture'
                              ? 'पाणी देण्यापूर्वी शेतातील प्रत्यक्ष ओलावा तपासा. हे उपग्रहाने टिपलेले मोजमाप आहे.'
                              : 'लाल किंवा पिवळा रंग असलेल्या भागात प्रत्यक्ष फेरफटका मारून पिकाची पाहणी करा.')
                          : (param.id == 'moisture'
                              ? 'Check the soil before watering. This is a satellite multispectral signal, not a water-level measurement.'
                              : 'Ground truth field rows if low vigor is concentrated. Continuous surface clipped strictly to parcel cadastre.'),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isMarathi
                          ? 'उपग्रह नोंद: २० ऑक्टोबर २०२६ (सेंटिनेल-२ उपग्रह)'
                          : 'Image taken: 20 Oct · ${param.sensorSource}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onFullAnalysis != null) ...[
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: onFullAnalysis,
                  icon: const Icon(Icons.analytics_outlined, size: 15, color: AppColors.orange),
                  label: Text(
                    isMarathi ? 'संपूर्ण पाहणी ->' : 'Full Field Analysis ->',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.orange),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<double> _computeNormalizedStops(AgronomicParameterDefinition param) {
    final span = param.maxValid - param.minValid;
    if (span <= 0) return [0.0, 1.0];
    return param.stops.map((s) {
      final t = (s.value - param.minValid) / span;
      return t.clamp(0.0, 1.0);
    }).toList();
  }
}
