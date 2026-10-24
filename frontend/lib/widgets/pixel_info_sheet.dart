import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../theme/app_theme.dart';

class PixelInfoSheet extends StatelessWidget {
  final PixelModel pixel;
  final VoidCallback onClose;

  const PixelInfoSheet({
    super.key,
    required this.pixel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pin_drop, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Pixel ${pixel.id} (Col: ${pixel.col}, Row: ${pixel.row})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _metricChip('NDVI (Canopy)', pixel.ndvi.toStringAsFixed(3), AppColors.statusGreen),
              const SizedBox(width: 8),
              _metricChip('NDMI (Moisture)', pixel.ndmi.toStringAsFixed(3), AppColors.moistureBlue),
              const SizedBox(width: 8),
              _metricChip('NDRE (Red Edge)', pixel.ndre.toStringAsFixed(3), AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pixel.isBoundary
                ? '⚠️ Perimeter Boundary Pixel: Mixed spectral reflection from adjoining farm path/trees.'
                : '✅ Interior Pure Pixel: High confidence sugarcane crop signal.',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: pixel.isBoundary ? Colors.brown : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              val,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
