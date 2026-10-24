import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../theme/app_theme.dart';

class SugarcaneMLCockpit extends StatelessWidget {
  final SugarcaneYieldModel? yieldModel;
  final SucroseMaturityModel? sucroseModel;
  final IrrigationPrescriptionModel? irrigationModel;
  final AnomalyDiagnosticMLModel? anomalyModel;
  final FarmFieldModel field;

  const SugarcaneMLCockpit({
    super.key,
    required this.yieldModel,
    required this.sucroseModel,
    required this.irrigationModel,
    required this.anomalyModel,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildYieldAndSucroseCard()),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: _buildIrrigationPrescriptionCard()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildYieldAndSucroseCard(),
              const SizedBox(height: 16),
              _buildIrrigationPrescriptionCard(),
            ],
          );
        }
      },
    );
  }

  // 1. Yield & Sucrose Ripening Intelligence Card
  Widget _buildYieldAndSucroseCard() {
    final yieldVal = yieldModel?.predictedYieldMtPerAcre ?? 58.4;
    final totalTonnes = yieldModel?.totalFieldTonnes ?? (yieldVal * field.areaAcres);
    final deltaPct = yieldModel?.yieldDeltaPct ?? 29.8;
    final isPositiveDelta = deltaPct >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGlow),
                ),
                child: const Icon(Icons.analytics_rounded, size: 20, color: AppColors.emerald),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI YIELD & SUCROSE RIPENING CORE',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Gradient Boosting Ensemble (GDD + iPAR + NDRE + Variety Potential)',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
                ),
                child: Text(
                  yieldModel?.yieldClassification ?? 'Exceptional',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.emerald),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Yield Telemetry Display
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PREDICTED YIELD',
                        style: TextStyle(fontSize: 10, letterSpacing: 1.0, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$yieldVal',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 5),
                          const Text('MT / Acre', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isPositiveDelta ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            size: 14,
                            color: isPositiveDelta ? AppColors.emerald : AppColors.rose,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${isPositiveDelta ? '+' : ''}$deltaPct% vs Mill Avg (45 MT)',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isPositiveDelta ? AppColors.emerald : AppColors.rose,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Field Output: ${totalTonnes.toStringAsFixed(1)} Tonnes',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.cyan, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SUCROSE & CCS %',
                        style: TextStyle(fontSize: 10, letterSpacing: 1.0, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${sucroseModel?.brixDegrees ?? 21.8}°',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.amber),
                          ),
                          const SizedBox(width: 4),
                          const Text('Brix', style: TextStyle(fontSize: 12, color: AppColors.amber)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'CCS: ${sucroseModel?.ccsPercent ?? 12.4}% · Pol: ${sucroseModel?.polPercent ?? 14.2}%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maturity Index: ${sucroseModel?.maturityIndex ?? 0.94} / 1.0',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Harvest Window Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded, size: 18, color: AppColors.emerald),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OPTIMAL HARVEST RECOVERY WINDOW',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sucroseModel?.harvestRecommendation ?? 'Ripening Peak: Schedule cutting squad for peak recovery bonus.',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Peak in ${sucroseModel?.daysToPeakSucrose ?? 38}d',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.amber),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. FAO-56 Dual Crop Coefficient Irrigation Prescription Card
  Widget _buildIrrigationPrescriptionCard() {
    final neededLiters = irrigationModel?.recommendedIrrigationLitersPerAcre ?? 18500.0;
    final runtimeHours = irrigationModel?.recommendedDripRuntimeHours ?? 2.3;
    final status = irrigationModel?.soilMoistureStatus ?? 'Deficit Stress';
    final urgency = irrigationModel?.nextIrrigationUrgency ?? 'Immediate (Today)';

    Color statusColor = AppColors.emerald;
    if (status.contains('Critical')) {
      statusColor = AppColors.rose;
    } else if (status.contains('Deficit')) {
      statusColor = AppColors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGlow),
                ),
                child: const Icon(Icons.water_drop_rounded, size: 20, color: AppColors.cyan),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FAO-56 DUAL KC DRIP PRESCRIPTION',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ETc = (Kcb + Ke) x ET0 · Root-Zone Water Balance Depletion',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  urgency,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Prescription Metrics Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DRIP WATER VOLUME', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${(neededLiters / 1000).toStringAsFixed(1)}k L',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.cyan),
                      ),
                      const SizedBox(height: 2),
                      const Text('per acre volume', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RECOMMENDED RUNTIME', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${runtimeHours.toStringAsFixed(1)} hrs',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.amber),
                      ),
                      const SizedBox(height: 2),
                      const Text('4 LPH inline drippers', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DAILY ETc DEMAND', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${irrigationModel?.dailyEtcMm ?? 8.64} mm',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.rose),
                      ),
                      const SizedBox(height: 2),
                      Text('Kc = ${irrigationModel?.faoKcDual ?? 1.27}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Recommendation Strip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined, size: 18, color: AppColors.cyan),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Run drip system in early morning (6:00 AM - 8:30 AM) to minimize canopy evaporation loss and prevent root hypoxia.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.95)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
