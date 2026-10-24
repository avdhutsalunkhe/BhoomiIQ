import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../theme/app_theme.dart';

class ResolutionBadge extends StatelessWidget {
  final ResolutionAnalysisModel resolution;
  final VoidCallback? onDroneRequest;

  const ResolutionBadge({
    super.key,
    required this.resolution,
    this.onDroneRequest,
  });

  @override
  Widget build(BuildContext context) {
    final isConstrained = resolution.resolutionRating == 'Constrained';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isConstrained ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConstrained ? const Color(0xFFFCA5A5) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConstrained ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 18,
                color: isConstrained ? AppColors.statusRed : AppColors.statusGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Parcel Pixel Resolution: ${resolution.resolutionRating}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isConstrained ? AppColors.statusRed : AppColors.statusGreen,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${resolution.usablePurePixels} pure of ${resolution.theoretical10mPixels} pixels',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            resolution.limitationNotice,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (resolution.droneSurveyRecommended) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: onDroneRequest,
              child: const Row(
                children: [
                  Icon(Icons.flight_takeoff, size: 15, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Book Factory Drone Survey for sub-decimeter zoning ->',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
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
}
