import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/slip_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SlipsScreen extends StatefulWidget {
  const SlipsScreen({super.key});

  @override
  State<SlipsScreen> createState() => _SlipsScreenState();
}

class _SlipsScreenState extends State<SlipsScreen> {
  List<HarvestingSlipModel> _slips = [];
  HarvestingSlipModel? _selectedSlip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlips();
  }

  Future<void> _loadSlips() async {
    setState(() => _isLoading = true);
    final list = await ApiService.getSlips();
    if (mounted) {
      setState(() {
        _slips = list;
        _isLoading = false;
      });
    }
  }

  void _verifySlipQR(String payload) async {
    final result = await ApiService.verifyQR(payload);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              result.valid ? Icons.verified : Icons.cancel,
              color: result.valid ? AppColors.statusGreen : AppColors.statusRed,
            ),
            const SizedBox(width: 10),
            Text(
              result.valid ? 'Authorized Slip' : 'Verification Failed',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slip ID: ${result.slipId ?? "Unknown"}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Registration: ${result.regId ?? ""}'),
            Text('Estimated Cane: ${result.estimatedTonnes ?? 0} Tonnes'),
            Text('Issuer: ${result.issuer}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.legalNotice,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSlip != null) {
      return _buildSlipDetailView(_selectedSlip!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBEAD7)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My slips',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track registrations and harvest slips for Season 2026–27',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Slips Cards
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  : Column(
                      children: _slips.map((slip) => _buildSlipCard(slip)).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlipCard(HarvestingSlipModel slip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Season ${slip.season}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBEAD7)),
                  ),
                  child: Text(
                    slip.status,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Registration ${slip.regId}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 4),
            Text(
              slip.plotName,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _slipField('Area', '${slip.registeredAreaAcres} acres'),
                _slipField('Estimated cane', '${slip.estimatedTonnes.toInt()} estimated tonnes'),
                _slipField('Planned harvest', slip.harvestingDate),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _selectedSlip = slip),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('View / print slip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slipField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildSlipDetailView(HarvestingSlipModel slip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              TextButton.icon(
                onPressed: () => setState(() => _selectedSlip = null),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to registrations'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
              ),
              const SizedBox(height: 12),

              // Printable Document Panel (Screen 5 replication)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Factory Logo / Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'राजारामबापू पाटील सह. साखर कारखाना लि.',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sugarcane harvesting slip',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                            ),
                            Text(
                              slip.slipId,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                        // Interactive QR Code
                        GestureDetector(
                          onTap: () => _verifySlipQR(slip.qrPayload),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: slip.qrPayload,
                                  version: QrVersions.auto,
                                  size: 85,
                                  backgroundColor: Colors.white,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tap to verify',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Grid of Registration Details
                    Wrap(
                      spacing: 32,
                      runSpacing: 18,
                      children: [
                        _detailItem('Registration', slip.regId),
                        _detailItem('Village', slip.village),
                        _detailItem('Season', slip.season),
                        _detailItem('Cane type', slip.caneType),
                        _detailItem('Registered area', '${slip.registeredAreaAcres} acres'),
                        _detailItem('Harvesting date', slip.harvestingDate),
                        _detailItem('Farmer', slip.farmerNameMr),
                        _detailItem('Plot', slip.plotName),
                        _detailItem('Variety', slip.variety),
                        _detailItem('Planting date', slip.plantingDate),
                        _detailItem('Expected cane', '${slip.estimatedTonnes.toInt()} tonnes (estimate)'),
                        _detailItem('Method', slip.method),
                        _detailItem('Irrigation', 'Drip installed'),
                        _detailItem('Crop condition', 'Satisfactory'),
                        _detailItem('Slip status', 'Approved'),
                        _detailItem('Status', slip.status),
                        _detailItem('Registered at', slip.registeredAt),
                        _detailItem('Issued at', slip.issuedAt),
                        _detailItem('Assigned slip boy', slip.assignedOfficer),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Remarks
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Remarks: ${slip.remarks}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Legal Disclaimer Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.statusRed),
                              SizedBox(width: 8),
                              Text(
                                'Legal Disclaimer & Payment Notice:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusRed),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'This slip is for harvesting authorization only. Estimated tonnes do not represent delivered or accepted cane weight. '
                            'This document is NOT a bill or payment receipt. Final settlement will be calculated strictly based on electronic weighbridge gross and tare receipts at factory intake.',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF7F1D1D), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Print Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Slip sent to printer/PDF export.')),
                            );
                          },
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('Print Harvesting Slip'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
