import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../theme/app_theme.dart';

class AdvisoryCard extends StatelessWidget {
  final DynamicAdvisoryModel advisory;
  final VoidCallback onAskQuestion;
  final VoidCallback onAddPhoto;

  const AdvisoryCard({
    super.key,
    required this.advisory,
    required this.onAskQuestion,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with leaf icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR NEXT STEP',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(
                Icons.eco_outlined,
                size: 20,
                color: advisory.statusLevel == 'inspect'
                    ? AppColors.statusRed
                    : AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Headline
          Text(
            advisory.headline,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Detailed text
          Text(
            advisory.detail,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Differential Possibilities
          if (advisory.differentialDiagnosis.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF3E5D8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.biotech, size: 16, color: Color(0xFFC05621)),
                      SizedBox(width: 6),
                      Text(
                        'Possible Explanations to Check in Field:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC05621),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...advisory.differentialDiagnosis.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF7B341E),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Checklist
          if (advisory.suggestedActions.isNotEmpty) ...[
            const Text(
              'Field Checklist:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            ...advisory.suggestedActions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Need a hand prompt
          const Text(
            'Need a hand? Ask BhoomiIQ.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Two Action Buttons: Ask a question & Add photo
          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: onAskQuestion,
                  icon: const Icon(Icons.chat_bubble_outline, size: 17),
                  label: const Text('Ask a question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  onPressed: onAddPhoto,
                  icon: const Icon(Icons.camera_alt_outlined, size: 17),
                  label: const Text('Add photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
